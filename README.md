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

The details of this command are as follows

1. Reads the URL from the register specified by `"` (or the default register if not specified).
2. Access the URL using curl and extract the title.
3. Format the URL and title using the template (string or function) specified in the argument.
4. Writes a formatted string to the default register.
5. Use commands such as `p` or `P` to paste the result into a buffer.

## Installation

Install the plugin with your preferred package manager:

### [packer](https://github.com/wbthomason/packer.nvim)

```lua
{ "noriapi/formatlink.nvim" }
```

## Setup

Call the `setup` function, otherwise the command will not be created.

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
