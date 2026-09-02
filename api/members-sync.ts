export default function handler(
  _request: { method?: string },
  response: { status: (code: number) => { json: (data: unknown) => void } }
) {
  response.status(200).json({
    status: 'ok',
    message: 'Members synced. Local storage is active in production.',
  })
}
