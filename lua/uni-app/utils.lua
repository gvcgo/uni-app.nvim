local M = {}

-- Project roots are based on files shared by common uni-app layouts.
function M.get_project_root()
	return vim.fs.root(0, { "package.json", "pages.json" }) or vim.fn.getcwd()
end

function M.is_uni_app_project()
	-- A dependency marker provides a lightweight uni-app project check.
	local root = M.get_project_root()
	local f = io.open(root .. "/package.json", "r")
	if not f then
		return false
	end
	local content = f:read("*a")
	f:close()
	return content:match("@dcloudio") ~= nil
end

function M.has_dcloudio_types()
	return vim.fn.isdirectory(M.get_project_root() .. "/node_modules/@dcloudio/types") == 1
end

function M.get_pages_json_path()
	-- Support both root-level and src-based pages.json locations.
	local root = M.get_project_root()
	for _, sub in ipairs({ "src/pages.json", "pages.json" }) do
		local p = root .. "/" .. sub
		if vim.fn.filereadable(p) == 1 then
			return p
		end
	end
	return nil
end

return M
