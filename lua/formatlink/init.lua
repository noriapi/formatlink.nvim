local M = {}

---@alias values { url: string, title: string }
---@alias transformer string|fun(values: values): string

---Fetch content by given url
---@param url string
---@return string
---@nodiscard
local function fetch(url)
	return vim.fn.system({ "curl", "-sS", url })
end

---@type any
local title_regex = vim.regex([[\m\c<\_s*title\_s*>\_s*\zs.\{-}\ze\_s*<\_s*/title\_s*>]])

---Exctract title from given HTML string
---@param html string
---@return string|nil title Nil if not found title
---@nodiscard
local function extract_title(html)
	local start_idx, end_idx = title_regex:match_str(html)

	if start_idx == nil or end_idx == nil then
		return nil
	end

	return string.sub(html, start_idx + 1, end_idx)
end

---Get title of given url content
---@param url string
---@return string|nil title Nil if not found title
---@nodiscard
function M.get_title(url)
	local res = fetch(url)

	local title = extract_title(res)

	return title
end

---comment
---@param template string
---@param values values
---@return string
---@nodiscard
function M.transform_with_template(template, values)
	local result = string.gsub(template, "<(%w+)>", values)
	return result
end

---comment
---@param transformer transformer
---@param values values
---@return string
---@nodiscard
function M.transform(transformer, values)
	if type(transformer) == "string" then
		return M.transform_with_template(transformer, values)
	else
		return transformer(values)
	end
end

function M.default_register()
	local cb = vim.opt.clipboard:get()
	if vim.tbl_contains(cb, "unnamed") then
		return "*"
	elseif vim.tbl_contains(cb, "unnamedplus") then
		return "+"
	else
		return "@"
	end
end

function M.formatlink(args)
	local register = args.reg
	if register == nil or register == "" then
		register = M.default_register()
	end

	local url = vim.trim(vim.fn.getreg(register))

	local transformer = args.args
	if transformer == nil or transformer == "" then
		transformer = "<title>"
	end

	local title = M.get_title(url)

	if title == nil then
		vim.notify("Can't get title of '" .. url .. "'", vim.log.levels.ERROR)
	else
		local result = M.transform(transformer, { url = url, title = title })
		vim.fn.setreg(register, result)
		vim.notify("Copied(" .. register .. "): " .. result, vim.log.levels.INFO)
	end
end

function M.create_formatlink_command()
	vim.api.nvim_create_user_command("Formatlink", function(args)
		M.formatlink(args)
	end, {
		nargs = "?",
		register = true,
		desc = "Formatlink",
	})
end

function M.setup()
	M.create_formatlink_command()
end

return M
