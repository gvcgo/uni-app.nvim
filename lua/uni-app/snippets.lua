local M = {}

-- Snippets are optional; the plugin remains usable without LuaSnip.
function M.setup()
	local ok, ls = pcall(require, "luasnip")
	if not ok then
		return
	end

	local s, t, i, c = ls.snippet, ls.text_node, ls.insert_node, ls.choice_node
	local function expand_or_jump()
		if ls.expand_or_locally_jumpable() then
			ls.expand_or_jump()
			return
		end

		if
			type(vim.snippet) == "table"
			and type(vim.snippet.active) == "function"
			and vim.snippet.active({ direction = 1 })
		then
			vim.snippet.jump(1)
			return
		end

		local blink_ok, blink = pcall(require, "blink.cmp")
		if
			blink_ok
			and type(blink.is_visible) == "function"
			and type(blink.select_next) == "function"
			and blink.is_visible()
		then
			blink.select_next()
			return
		end

		local cmp_ok, cmp = pcall(require, "cmp")
		if
			cmp_ok
			and type(cmp.visible) == "function"
			and type(cmp.select_next_item) == "function"
			and cmp.visible()
		then
			cmp.select_next_item()
			return
		end

		return "<Tab>"
	end

	local function setup_tab_mapping(bufnr)
		if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "vue" then
			return
		end
		vim.keymap.set({ "i", "s" }, "<Tab>", expand_or_jump, {
			buffer = bufnr,
			desc = "Expand uni-app LuaSnip snippets",
			expr = true,
			silent = true,
		})
	end

	local group = vim.api.nvim_create_augroup("UniAppSnippets", { clear = true })
	vim.api.nvim_create_autocmd({ "FileType", "InsertEnter" }, {
		pattern = "*",
		group = group,
		callback = function(args)
			vim.schedule(function()
				setup_tab_mapping(args.buf)
			end)
		end,
	})

	if vim.bo.filetype == "vue" then
		setup_tab_mapping(0)
	end

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
