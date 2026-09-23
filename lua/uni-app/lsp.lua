local M = {}
local find_tsserver

function M.setup(config)
	if vim.lsp.config == nil or type(vim.lsp.enable) ~= "function" then
		vim.notify("[uni-app.nvim] Neovim 0.11 or newer is required for LSP setup", vim.log.levels.WARN)
		return
	end

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	local blink_ok, blink = pcall(require, "blink.cmp")
	if blink_ok then
		capabilities = blink.get_lsp_capabilities(capabilities)
	else
		local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
		if cmp_ok then
			capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
		end
	end

	local utils = require("uni-app.utils")
	local root = utils.get_project_root()
	local vue_typescript_plugin = root .. "/node_modules/@vue/typescript-plugin"

	if vim.fn.isdirectory(vue_typescript_plugin) ~= 1 then
		vue_typescript_plugin = vim.fn.stdpath("data")
			.. "/mason/packages/vue-language-server/node_modules/@vue/typescript-plugin"
	end

	local tsserver_path = find_tsserver(root)

	if tsserver_path then
		vim.lsp.config("ts_ls", {
			capabilities = capabilities,
			filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
			init_options = {
				plugins = {
					{
						name = "@vue/typescript-plugin",
						location = vue_typescript_plugin,
						languages = { "javascript", "typescript", "vue" },
					},
				},
				tsserver = { path = tsserver_path },
			},
			root_markers = { "package.json", "tsconfig.json" },
		})
		vim.lsp.enable("ts_ls")
	else
		vim.notify(
			"[uni-app.nvim] TypeScript LSP disabled: install the typescript package in the project",
			vim.log.levels.WARN
		)
	end

	vim.lsp.config("vue_ls", {
		capabilities = capabilities,
		settings = { vue = { server = { maxOldSpaceSize = 4096 } } },
		root_markers = { "package.json", "pages.json" },
		on_attach = function()
			if utils.is_uni_app_project() and not utils.has_dcloudio_types() then
				vim.notify("[uni-app.nvim] Run: npm install -D @dcloudio/types", vim.log.levels.WARN)
			end
		end,
	})
	vim.lsp.enable("vue_ls")

	vim.lsp.config("jsonls", {
		capabilities = capabilities,
		settings = {
			json = {
				schemas = { { fileMatch = { "pages.json" }, url = config.pages_schema_url } },
				format = { enable = true },
			},
		},
		root_markers = { "pages.json", "package.json", ".git" },
	})
	vim.lsp.enable("jsonls")
end

find_tsserver = function(root)
	local paths = {
		root .. "/node_modules/typescript/lib/tsserver.js",
		vim.fn.stdpath("data") .. "/mason/packages/typescript-language-server/node_modules/typescript/lib/tsserver.js",
		vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/typescript/lib/tsserver.js",
	}

	for _, path in ipairs(paths) do
		if vim.fn.filereadable(path) == 1 then
			return path
		end
	end
end

return M
