import { withPluginApi } from "discourse/lib/plugin-api";
import PostAnalyzerButton from "../components/post-analyzer-button";

function registerPostAnalyzer(api) {
  const PostAnalyzerMetadata = <template>
    <PostAnalyzerButton @post={{@post}} />
  </template>;

  api.registerValueTransformer(
    "post-meta-data-infos",
    ({ value: metadata, context: { post, metaDataInfoKeys } }) => {
      const user = api.getCurrentUser();

      if (
        !user?.has_chat_enabled ||
        !user?.ai_enabled_chat_bots ||
        !settings.post_analyzer_bot_username ||
        !post?.url
      ) {
        return;
      }

      metadata.add("post-analyzer", PostAnalyzerMetadata, {
        after: metaDataInfoKeys.DATE,
      });
    }
  );
}

export default {
  name: "ai-bot-post-analyzer",

  initialize() {
    withPluginApi((api) => {
      registerPostAnalyzer(api);
    });
  },
};
