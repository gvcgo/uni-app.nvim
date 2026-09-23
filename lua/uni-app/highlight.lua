local M = {}

-- Use dedicated groups so users can override the colors independently.
function M.setup()
	vim.api.nvim_set_hl(0, "UniAppConditional", { fg = "#e5c07b", bold = true })
	vim.api.nvim_set_hl(0, "UniAppPlatform", { fg = "#61afef", italic = true })
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "vue", "javascript", "typescript" },
		group = vim.api.nvim_create_augroup("UniAppHL", { clear = true }),
		callback = function()
			-- matchadd keeps platform markers visible alongside syntax highlighting.
			vim.fn.matchadd("UniAppConditional", "\\(#ifdef\\|#ifndef\\|#endif\\|#if\\|#else\\)")
			vim.fn.matchadd("UniAppPlatform", "\\(MP-WEIXIN\\|MP-ALIPAY\\|H5\\|APP-PLUS\\)")
		end,
	})
end

return M
