local fl = require("formatlink")

describe("get title", function()
	it("returns valid title", function()
		assert.equals("Home - Neovim", fl.get_title("https://neovim.io/"))
	end)
end)
