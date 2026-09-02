import { mkdir, writeFile } from 'node:fs/promises'
import { dirname, resolve } from 'node:path'
import { defineConfig, loadEnv, type Plugin } from 'vite'

function localMemberFile(): Plugin {
  return {
    name: 'local-member-file',
    configureServer(server) {
      server.middlewares.use('/api/members-sync', async (request, response, next) => {
        if (request.method !== 'POST') { next(); return }
        let body = ''
        request.on('data', chunk => { body += chunk })
        request.on('end', async () => {
          try {
            const filePath = resolve(process.cwd(), 'data', 'members.csv')
            await mkdir(dirname(filePath), { recursive: true })
            await writeFile(filePath, body, 'utf8')
            response.statusCode = 204
            response.end()
          } catch {
            response.statusCode = 500
            response.end('Unable to update data/members.csv')
          }
        })
      })
    },
  }
}

function geminiProxy(apiKey: string): Plugin {
  return {
    name: 'gemini-proxy',
    configureServer(server) {
      server.middlewares.use('/api/ai-insight', async (request, response, next) => {
        if (request.method !== 'POST') { next(); return }
        let body = ''
        request.on('data', chunk => { body += chunk })
        request.on('end', async () => {
          if (!apiKey) { response.statusCode = 503; response.end('Gemini API key is not configured'); return }
          try {
            const input = JSON.parse(body) as { name: string; space: string; history: string[] }
            const prompt = `You are a community manager assistant. Use only these recorded facts. Do not infer buying intent or invent details. Return concise plain text with exactly three labelled lines: Activity Summary, Relevant Space, Suggested Next Step. Member: ${input.name}. Primary space: ${input.space}. Recorded activity: ${input.history.join('; ')}`
            const request = { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] }) }
            const models = ['gemini-2.5-flash', 'gemini-2.5-flash-lite', 'gemini-flash-latest']
            let result: Response | undefined
            let data: { candidates?: Array<{ content?: { parts?: Array<{ text?: string }> } }> } = {}
            for (const model of models) { const candidate = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`, request); if (candidate.ok) { result = candidate; data = await candidate.json() as typeof data; break } console.error(`Gemini model ${model} returned HTTP ${candidate.status}`) }
            if (!result) throw new Error('Gemini request failed for all configured models')
            response.setHeader('Content-Type', 'application/json')
            response.end(JSON.stringify({ text: data.candidates?.[0]?.content?.parts?.[0]?.text || 'No insight was returned.' }))
          } catch (error) { console.error('Gemini insight request failed:', error instanceof Error ? error.message : 'Unknown error'); response.statusCode = 502; response.end('Unable to generate AI insight') }
        })
      })
    },
  }
}

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  return { plugins: [localMemberFile(), geminiProxy(env.GEMINI_API_KEY || '')] }
})
