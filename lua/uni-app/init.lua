local M = {}
-- Each integration can be disabled independently through setup options.
M.config = {
	auto_lsp = true,
	auto_snippets = true,
	auto_commands = true,
	conditional_highlight = true,
	terminal = "split",
	pages_schema_url = "https://json.schemastore.org/uni-app-pages.json",
}

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})

	if M.config.auto_commands then
		require("uni-app.commands").setup(M.config)
	end

	if M.config.conditional_highlight then
		require("uni-app.highlight").setup()
	end

	if M.config.auto_lsp then
		require("uni-app.lsp").setup(M.config)
	end

	if M.config.auto_snippets and pcall(require, "luasnip") then
		require("uni-app.snippets").setup()
	end

	local utils = require("uni-app.utils")

	-- Mark buffers opened in detected uni-app projects for downstream checks.
	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
		group = vim.api.nvim_create_augroup("UniApp", { clear = true }),
		callback = function()
			if utils.is_uni_app_project() then
				vim.b.is_uni_app = true
			end
		end,
	})
end

return M
