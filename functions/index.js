/**
 * Заявки с формы на лендинге → сообщение в Telegram.
 * Секреты: firebase functions:config:set telegram.bot_token="..." telegram.chat_id="..."
 *
 * Токен НЕ хранить в HTML/JS на сайте.
 */
const functions = require("firebase-functions");

exports.leadForm = functions.https.onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }

  if (req.method !== "POST") {
    res.status(405).json({ ok: false, error: "Method not allowed" });
    return;
  }

  let data = req.body;
  if (typeof data === "string") {
    try {
      data = JSON.parse(data);
    } catch {
      res.status(400).json({ ok: false, error: "Invalid JSON" });
      return;
    }
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
    res.status(400).json({
      ok: false,
      error: "Укажите имя и Telegram или Email",
    });
    return;
  }

  const cfg = functions.config().telegram || {};
  const token = cfg.bot_token;
  const chatId = cfg.chat_id;

  if (!token || !chatId) {
    functions.logger.error("Missing telegram.bot_token or telegram.chat_id in functions config");
    res.status(500).json({ ok: false, error: "Server configuration error" });
    return;
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
  let tgJson;
  try {
    const tgRes = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        chat_id: String(chatId),
        text,
        parse_mode: "HTML",
        disable_web_page_preview: true,
      }),
    });
    tgJson = await tgRes.json();
    if (!tgRes.ok || !tgJson.ok) {
      functions.logger.error("Telegram API error", tgJson);
      res.status(502).json({ ok: false, error: "Не удалось отправить в Telegram" });
      return;
    }
  } catch (err) {
    functions.logger.error("Telegram fetch failed", err);
    res.status(502).json({ ok: false, error: "Ошибка сети" });
    return;
  }

  res.status(200).json({ ok: true });
});

function escapeHtml(s) {
  return s
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}
