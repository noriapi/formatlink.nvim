# formatlink.nvim

Neovim plugin to get title from URL and format.

## Usage

After copying the URL, run this command and type `p`. A Markdown formatted link will be inserted.

```vim
:Formatlink [<title>](<url>)
```

If you want to insert a link in HTML format, do the following.

```vim
:Formatlink <a href="<url>"><title></a>
```
## Installation

Install the plugin with your preferred package manager:

### [packer](https://github.com/wbthomason/packer.nvim)

```lua
{ "noriapi/formatlink.nvim" }
```

## Setup

Call the `setup` function, otherwise commands will not be created.

```lua
require("formatlink").setup()
```

### Example setup with lazy.nvim

```lua
{
  "noriapi/formatlink.nvim",
  config = true,
  cmd = { "Formatlink" },
  keys = {
    { "<leader>lm", "<cmd>Formatlink [<title>](<url>)<cr>", desc = "Markdown Link" },
    { "<leader>lh", '<cmd>Formatlink <a href="<url>"><title></a><cr>', desc = "HTML Link" },
  },
}
```

Example of defining a Markdown buffer-specific keymap

```lua
{
  "noriapi/formatlink.nvim",
  cmd = { "Formatlink" },
  ft = { "markdown", "md" },
  config = function(_, opts)
    require("formatlink").setup()

    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "markdown",
        "md",
      },
      callback = function(event)
        vim.keymap.set(
          "n",
          "<localleader>l",
          "<cmd>Formatlink [<title>](<url>)<cr>",
          { buffer = event.buf, desc = "Formatlink" }
        )
      end,
    })
  end,
}
```

## Commands

:Formatlink [x] {formatter}

: Format a link in [register x] with {formatter}.
1. Reads URL from [register x] (or the default register if not specified).
2. Access URL using curl and extract the title.
3. Format URL and title using {formatter} (string or function).
4. Writes a formatted string to [register x].
5. You can paste a formatted link into a buffer using <kbd>p</kbd>, <kbd>P</kbd>, etc.

## Formatter Template

If {formatter} is a string, it is considered a template. In this case, `<title>` and `<url>` in the string will be replaced with the title and URL, respectively.

### Example Templates

- Markdown: `[<title>](<url>)`
- HTML: `<a href="<url>"><title></a>`
