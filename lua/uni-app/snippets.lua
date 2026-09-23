local M = {}

-- Snippets are optional; the plugin remains usable without LuaSnip.
function M.setup()
	local ok, ls = pcall(require, "luasnip")
	if not ok then
		return
	end
	local s, t, i, c = ls.snippet, ls.text_node, ls.insert_node, ls.choice_node
	-- These templates target Vue single-file components used by uni-app.
	ls.add_snippets("vue", {
		s("upage", {
			t({ "<template>", '\t<view class="container">', "\t\t" }),
			i(1, "<text>Hello</text>"),
			t({
				"",
				"\t</view>",
				"</template>",
				"",
				'<script setup lang="ts">',
				"import { onLoad } from '@dcloudio/uni-app'",
				"",
			}),
			i(0),
			t({ "", "</script>", "", "<style scoped>", "</style>" }),
		}),
		s("ureq", {
			t("uni.request({\n\turl: '"),
			i(1, "https://api.example.com"),
			t("',\n\tmethod: '"),
			c(2, { t("GET"), t("POST") }),
			t("',\n\tsuccess: (res) => { console.log(res.data) },\n\tfail: (err) => { console.error(err) }\n});"),
		}),
		s("unavi", { t("uni.navigateTo({\n\turl: '/pages/"), i(1, "index/index"), t("?"), i(2, "id=1"), t("'\n});") }),
		s("utoast", {
			t("uni.showToast({\n\ttitle: '"),
			i(1, "Message"),
			t("',\n\ticon: '"),
			c(2, { t("none"), t("success"), t("error") }),
			t("'\n});"),
		}),
		s("uifdef", {
			t("<!-- #ifdef "),
			c(1, { t("MP-WEIXIN"), t("H5"), t("APP-PLUS") }),
			t(" -->\n"),
			i(0),
			t("\n<!-- #endif -->"),
		}),
		s(
			"uifdefjs",
			{ t("// #ifdef "), c(1, { t("MP-WEIXIN"), t("H5"), t("APP-PLUS") }), t("\n"), i(0), t("\n// #endif") }
		),
		s("uonload", { t("onLoad((options) => {\n\t"), i(0), t("\n});") }),
	})
end

return M
