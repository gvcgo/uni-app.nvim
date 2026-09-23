-- Prevent the plugin entrypoint from being sourced more than once.
if vim.g.loaded_uni_app then
	return
end

vim.g.loaded_uni_app = true
