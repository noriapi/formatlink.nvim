local M = {}

--- Module setup
---
---@usage `require('formatlink').setup()`
function M.setup()
  M.create_formatlink_command()
end

---@alias values { url: string, title: string }
---@alias formatter string|fun(values: values): string

--- Fetch content by given url
---@param url string
---@return string
---@nodiscard
local function fetch(url)
  return vim.fn.system({ "curl", "-sS", url })
end

---@type any
local title_regex = vim.regex([[\m\c<\_s*title\_s*>\_s*\zs.\{-}\ze\_s*<\_s*/title\_s*>]])

--- Exctract title from `html`
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

--- Get title of `url` content
---@param url string
---@return string|nil title Nil if not found title
---@nodiscard
function M.get_title(url)
  local res = fetch(url)

  local title = extract_title(res)

  return title
end

--- Format `values` using `template`
---@param values values Table containing url and title
---@param template string `<url>` and `<title>` will be replaced
---@return string formatted_string
---@nodiscard
function M.format_with_template(values, template)
  local result = string.gsub(template, "<(%w+)>", values)
  return result
end

--- Format `values` using `formatter`
---@param values values Table containing url and title
---@param formatter formatter Template string or function
---@return string formatted_string
---@nodiscard
function M.format(values, formatter)
  if type(formatter) == "string" then
    return M.format_with_template(values, formatter)
  else
    return formatter(values)
  end
end

--- Returns default register name respecting 'clipboard' option
---@return string register_name
---@nodiscard
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

--- Format URL in the register into link format using a formatter
---@param args { reg: string|nil, args: formatter|nil }
function M.formatlink(args)
  local register = args.reg
  if register == nil or register == "" then
    register = M.default_register()
  end

  local url = vim.trim(vim.fn.getreg(register))

  local formatter = args.args
  if formatter == nil or formatter == "" then
    formatter = "<title>"
  end

  local title = M.get_title(url)

  if title == nil then
    vim.notify("Can't get title of '" .. url .. "'", vim.log.levels.ERROR)
  else
    local result = M.format({ url = url, title = title }, formatter)
    vim.fn.setreg(register, result)
    vim.notify("Copied(" .. register .. "): " .. result, vim.log.levels.INFO)
  end
end

--- Creates |:Formatlink| command
function M.create_formatlink_command()
  vim.api.nvim_create_user_command("Formatlink", function(args)
    M.formatlink(args)
  end, {
    nargs = "?",
    register = true,
    desc = "Formatlink",
  })
end

return M
