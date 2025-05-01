import { apiInitializer } from "discourse/lib/api";
import { schedule } from "@ember/runloop";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { iconHTML } from "discourse/lib/icon-library";
import { i18n } from "discourse-i18n";

export default apiInitializer("1.8.0", (api) => {
  const user = api.getCurrentUser();
  const canUseChat = user?.has_chat_enabled;
  const userEnabledChatBots = user?.ai_enabled_chat_bots

  if (!user || !canUseChat || !userEnabledChatBots) {
    return;
  }
  
  api.decorateWidget("post-date:after", (helper) => {
    const post = helper.getModel();
    const postAnalyzerText = i18n(themePrefix("analyze_post_text"));

    if (!post) return;

    const postUrl = `${window.location.origin}${post.url}`;
    return helper.h(
      "button.analyze-post-btn.btn-flat",
      {
        title: postAnalyzerText,
        onclick: async function () {
          try {
            const chatService = api.container.lookup("service:chat");
            const routerService = api.container.lookup("service:router");

            if (!chatService || !routerService) {
              console.error("Chat or Router service not found.");
              return;
            }

            // Open or create DM channel with AI ChatBot
            const channel = await chatService.upsertDmChannel({
              usernames: [settings.ai_chatbot_username],
            });

            if (!channel) {
              console.error("Failed to find or create AI ChatBot DM channel.");
              return;
            }

            // Navigate to chat
            routerService.transitionTo("chat.channel", ...channel.routeModels);

            schedule("afterRender", () => {
              try {
                // Send the message after channel is ready
                api.sendChatMessage(channel.id, {
                  message: `${postAnalyzerText}: ${postUrl}`,
                  threadId: null
                });
              } catch (error) {
                console.error("Error sending message:", error);
                popupAjaxError(error);
              }
            });
            
          } catch (error) {
            console.error("Error during analyzing post:", error);
            popupAjaxError(error);
          }
        },
      },
      helper.rawHtml(iconHTML(settings.analyze_post_icon))
    );
  });
});
