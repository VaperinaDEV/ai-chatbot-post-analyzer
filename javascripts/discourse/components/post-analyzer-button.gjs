import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import DButton from "discourse/components/d-button";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class PostAnalyzerButton extends Component {
  @service chat;
  @service chatApi;
  @service router;

  @tracked isAnalyzing = false;

  get label() {
    return i18n(themePrefix("analyze_post_text"));
  }

  @action
  async analyzePost() {
    if (this.isAnalyzing) {
      return;
    }

    this.isAnalyzing = true;

    try {
      const channel = await this.chat.upsertDmChannel({
        usernames: [settings.post_analyzer_bot_username],
      });

      if (!channel) {
        console.error("Failed to find or create AI Bot DM channel.");
        return;
      }

      const postUrl = `${window.location.origin}${this.args.post.url}`;

      // Send the message before navigating. In drawer mode, the Chat route
      // intentionally aborts the router transition and opens the drawer via
      // the chat:open-url event instead.
      await this.chatApi.sendMessage(channel.id, {
        message: `${this.label}: ${postUrl}`,
      });

      this.router.transitionTo("chat.channel", ...channel.routeModels);
    } catch (error) {
      console.error("Error during analyzing post:", error);
      popupAjaxError(error);
    } finally {
      this.isAnalyzing = false;
    }
  }

  <template>
    <DButton
      class="analyze-post-btn btn-flat"
      @translatedTitle={{this.label}}
      @icon={{settings.analyze_post_icon}}
      @action={{this.analyzePost}}
      @disabled={{this.isAnalyzing}}
    />
  </template>
}
