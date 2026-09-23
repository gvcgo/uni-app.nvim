local M = {}
-- Keep platform names centralized for validation and command completion.
local PLATFORMS = {
	"h5",
	"mp-weixin",
	"mp-alipay",
	"mp-baidu",
	"mp-toutiao",
	"app",
}
function M.setup(config)
	local utils = require("uni-app.utils")

	vim.api.nvim_create_user_command("UniPage", function(opts)
		local name = opts.args
		if name == "" then
			return vim.notify("Usage: :UniPage <name>", vim.log.levels.ERROR)
		end

		local root = utils.get_project_root()
		-- Follow the conventional src/pages layout when it exists.
		local pages_dir = vim.fn.isdirectory(root .. "/src/pages") == 1 and root .. "/src/pages" or root .. "/pages"
		local file = pages_dir .. "/" .. name .. "/" .. name .. ".vue"

		if vim.fn.filereadable(file) == 1 then
			return vim.notify("Page exists: " .. file, vim.log.levels.WARN)
		end

		vim.fn.mkdir(vim.fn.fnamemodify(file, ":h"), "p")
		vim.cmd("edit " .. file)

		-- Generate a minimal Vue page with uni-app defaults.
		vim.api.nvim_buf_set_lines(0, 0, -1, false, {
			"<template>",
			'\t<view class="' .. name .. '">',
			"\t\t<text>" .. name .. "</text>",
			"\t</view>",
			"</template>",
			"",
			'<script setup lang="ts">',
			"import { onLoad } from '@dcloudio/uni-app'",
			"onLoad((options) => { console.log('onLoad', options) })",
			"</script>",
			"",
			"<style scoped>",
			"." .. name .. " { padding: 20rpx; }",
			"</style>",
		})

		vim.notify("Page created: " .. file .. "\nRegister it in pages.json", vim.log.levels.INFO, { timeout = 5000 })
	end, { nargs = 1 })

	vim.api.nvim_create_user_command("UniRun", function(opts)
		local p = opts.args ~= "" and opts.args or "h5"
		if not vim.tbl_contains(PLATFORMS, p) then
			return vim.notify("Available: " .. table.concat(PLATFORMS, ", "), vim.log.levels.ERROR)
		end
		local cmd = "npm run dev:" .. p
		-- Use toggleterm only when explicitly configured and available.
		if config.terminal == "toggleterm" and pcall(require, "toggleterm") then
			require("toggleterm").exec(cmd)
		else
			vim.cmd("botright split | terminal " .. cmd)
		end
	end, {
		nargs = "?",
		complete = function()
			return PLATFORMS
		end,
	})

	vim.api.nvim_create_user_command("UniCheck", function()
		local r =
			{ utils.is_uni_app_project() and "✅ uni-app project detected" or "❌ uni-app project not detected" }

		table.insert(
			r,
			utils.has_dcloudio_types() and "✅ @dcloudio/types installed" or "⚠️ @dcloudio/types missing"
		)

		-- Support both current and legacy Neovim LSP client APIs.
		local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
		local vue_ls = false
		for _, c in ipairs(get_clients({ bufnr = 0 })) do
			if c.name == "vue_ls" then
				vue_ls = true
				break
			end
		end

		table.insert(r, vue_ls and "✅ Vue language server active" or "⚠️ Vue language server inactive")

		vim.notify("UniApp Check:\n" .. table.concat(r, "\n"), vim.log.levels.INFO, { timeout = 8000 })
	end, {})
end

return M
