const TG_BOT_TOKEN = '8748697920:AAGAdo2QT5zYAPW1n_8ZYUrc7ZIs7rOFjt4';
const TG_CHAT_IDS = ['572193621', '497905638', '774449935'];

interface FormData {
  name: string;
  telegram?: string;
  email?: string;
  message?: string;
}

export async function sendLeadToTelegram(data: FormData): Promise<boolean> {
  if (!TG_BOT_TOKEN) {
    console.warn('Telegram бот не настроен. Добавьте TG_BOT_TOKEN в src/services/telegram.ts');
    return false;
  }

  const name = (data.name || '').trim();
  const telegram = (data.telegram || '').trim();
  const email = (data.email || '').trim();
  const message = (data.message || '').trim();

  const text =
    '<b>Новая заявка с сайта</b>\n\n' +
    '<b>Имя:</b> ' + escapeHtml(name) + '\n' +
    '<b>Telegram:</b> ' + escapeHtml(telegram || '—') + '\n' +
    '<b>Email:</b> ' + escapeHtml(email || '—') + '\n\n' +
    '<b>Сообщение:</b>\n' +
    escapeHtml(message || '—');

  try {
    const api = `https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage`;
    const responses = await Promise.all(
      TG_CHAT_IDS.map(async (chatId) => {
        const response = await fetch(api, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            chat_id: chatId,
            text,
            parse_mode: 'HTML',
            disable_web_page_preview: true,
          }),
        });
        const result = await response.json().catch(() => ({}));
        return { ok: response.ok && !!result?.ok, result };
      }),
    );

    const allOk = responses.every((r) => r.ok);
    if (!allOk) {
      console.error('❌ Ошибка отправки в Telegram:', responses[0]?.result);
    }
    return allOk;
  } catch (error) {
    console.error('❌ Ошибка сети при отправке в Telegram:', error);
    return false;
  }
}

function escapeHtml(value: string): string {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}
