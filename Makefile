# Makefile for vim-yaml-nav tests
# Usage: make all        # run tests with both vim and neovim
#        make test-vim   # run tests with vim only
#        make test-nvim  # run tests with Neovim only

VADER_DIR ?= /tmp/vader
REPO_ROOT := $(shell pwd)

# Override VADER_DIR for CI to avoid cross-run state
ifdef CI
  VADER_DIR := /tmp/vader-$(shell date +%s)
endif

# Detect editor
ifeq ($(VIM),)
  VIM := $(shell which vim)
endif

# Check if Neovim
IS_NVIM := $(shell $(VIM) --version 2>/dev/null | grep -q NVIM && echo yes || echo no)

# Test runner command
TEST_CMD := $(VIM) --version 2>/dev/null | head -1

# Vim flags
ifeq ($(IS_NVIM),yes)
  # Neovim: --headless mode (avoids E484 syntax.vim issues)
  VIM_FLAGS := --headless -Nu
else
  # Vim: -Es mode (silent batch)
  VIM_FLAGS := -Es -Nu
endif

.PHONY: all test-vim test-nvim clean

all: test-vim test-nvim

test-vim: vader $(REPO_ROOT)/.vimrc
	@echo "Running tests with: $$( $(VIM) --version 2>/dev/null | head -1 )"
	@$(VIM) $(VIM_FLAGS) $(REPO_ROOT)/.vimrc \
		-c 'Vader! $(REPO_ROOT)/test/*.vader' \
		-c 'qa!' 2>&1

test-nvim: VIM := $(shell which nvim)
test-nvim: vader $(REPO_ROOT)/.vimrc
	@echo "Running tests with: nvim"
	@$(VIM) --headless -Nu $(REPO_ROOT)/.vimrc \
		-c 'Vader! $(REPO_ROOT)/test/*.vader' \
		-c 'qa!' 2>&1

# Create a minimal vimrc for tests
$(REPO_ROOT)/.vimrc: | vader
	@echo "Creating test vimrc..."
	@echo 'filetype off' > $@
	@echo 'set rtp+='$(VADER_DIR) >> $@
	@echo 'set rtp+='$(REPO_ROOT) >> $@
	@echo 'set rtp+='$(REPO_ROOT)/after >> $@
	@echo 'filetype plugin indent on' >> $@

vader:
	@if [ ! -d '$(VADER_DIR)' ]; then \
		echo "Cloning vader.vim into $(VADER_DIR) ..."; \
		git clone --depth=1 https://github.com/junegunn/vader.vim '$(VADER_DIR)'; \
	fi

clean:
	@rm -f $(REPO_ROOT)/.vimrc
