export default function migrate(settings) {
  if (settings.has("ai_chatbot_username")) {
    settings.set("post_analyzer_bot_username", settings.get("ai_chatbot_username"));
    settings.delete("ai_chatbot_username");
  }
  return settings;
}
