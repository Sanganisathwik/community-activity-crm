type RequestBody = { name?: string; space?: string; history?: string[] }

export default async function handler(request: { method?: string; body?: RequestBody }, response: { status: (code: number) => { json: (data: unknown) => void }; json: (data: unknown) => void }) {
  if (request.method !== 'POST') { response.status(405).json({ error: 'Method not allowed' }); return }
  const apiKey = process.env.GEMINI_API_KEY
  if (!apiKey) { response.status(503).json({ error: 'Gemini API key is not configured' }); return }
  const input = request.body || {}
  const prompt = `You are a community manager assistant. Use only these recorded facts. Do not infer buying intent or invent details. Return concise plain text with exactly three labelled lines: Activity Summary, Relevant Space, Suggested Next Step. Member: ${input.name || 'Unknown'}. Primary space: ${input.space || 'Unknown'}. Recorded activity: ${(input.history || []).join('; ')}`
  const models = ['gemini-2.5-flash', 'gemini-2.5-flash-lite', 'gemini-flash-latest']
  for (const model of models) {
    const upstream = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] }) })
    if (upstream.ok) {
      const data = await upstream.json() as { candidates?: Array<{ content?: { parts?: Array<{ text?: string }> } }> }
      response.json({ text: data.candidates?.[0]?.content?.parts?.[0]?.text || 'No insight was returned.' })
      return
    }
  }
  response.status(502).json({ error: 'Gemini request failed for all configured models' })
}
