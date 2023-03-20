TESTS_INIT=tests/minimal_init.lua
TESTS_DIR=tests/

PLENARY_DIR = test/plenary
PLENARY_URL = https://github.com/nvim-lua/plenary.nvim/

.PHONY: test

test:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${TESTS_INIT}' }"
