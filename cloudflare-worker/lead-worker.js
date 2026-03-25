/**
 * Cloudflare Worker: заявка с лендинга → Telegram (без Firebase).
 *
 * Настройка в Cloudflare Dashboard → Workers → Create → HTTP handler,
 * или wrangler: см. ../LEADS_WITHOUT_FIREBASE.md
 *
 * Secrets / Variables (Settings → Variables):
 *   BOT_TOKEN  — токен от @BotFather
 *   CHAT_ID    — ваш user id (например 572193621), напишите боту /start
 */
export default {
  async fetch(request, env) {
    const headers = corsHeaders(request);

    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers });
    }

    if (request.method !== "POST") {
      return json({ ok: false, error: "Method not allowed" }, 405, headers);
    }

    const token = env.BOT_TOKEN;
    const chatId = env.CHAT_ID;
    if (!token || !chatId) {
      return json({ ok: false, error: "Server configuration error" }, 500, headers);
    }

    let data;
    try {
      data = await request.json();
    } catch {
      return json({ ok: false, error: "Invalid JSON" }, 400, headers);
    }

    const name = String(data.name || "")
      .trim()
      .slice(0, 200);
    const telegram = String(data.telegram || "")
      .trim()
      .slice(0, 200);
    const email = String(data.email || "")
      .trim()
      .slice(0, 200);
    const message = String(data.message || "")
      .trim()
      .slice(0, 4000);

    if (!name || (!telegram && !email)) {
      return json(
        { ok: false, error: "Укажите имя и Telegram или Email" },
        400,
        headers
      );
    }

    const text = [
      "<b>Новая заявка с сайта</b>",
      "",
      `<b>Имя:</b> ${escapeHtml(name)}`,
      `<b>Telegram:</b> ${escapeHtml(telegram || "—")}`,
      `<b>Email:</b> ${escapeHtml(email || "—")}`,
      "",
      "<b>Сообщение:</b>",
      escapeHtml(message || "—"),
    ].join("\n");

    const url = `https://api.telegram.org/bot${token}/sendMessage`;
    let tgRes;
    try {
      tgRes = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          chat_id: String(chatId),
          text,
          parse_mode: "HTML",
          disable_web_page_preview: true,
        }),
      });
    } catch {
      return json({ ok: false, error: "Ошибка сети" }, 502, headers);
    }

    const tgJson = await tgRes.json().catch(() => ({}));
    if (!tgRes.ok || !tgJson.ok) {
      return json({ ok: false, error: "Не удалось отправить в Telegram" }, 502, headers);
    }

    return json({ ok: true }, 200, headers);
  },
};

function corsHeaders(request) {
  const origin = request.headers.get("Origin");
  return {
    "Access-Control-Allow-Origin": origin || "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Max-Age": "86400",
  };
}

function json(body, status, extraHeaders) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json",
      ...extraHeaders,
    },
  });
}

function escapeHtml(s) {
  return s
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}
