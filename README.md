# vim-yaml-nav

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

YAML navigation plugin for Vim 8+ and Neovim.

Populates the location list with all keys at the current indentation level,
making it easy to jump between sibling keys in a YAML block.

**Note:** This plugin is written in legacy Vimscript and is compatible with both
Vim 8+ and Neovim.

## Installation

Use any plugin manager, e.g. with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ 'marcpaterno/vim-yaml-nav' }
```

Or with [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'marcpaterno/vim-yaml-nav'
```

## Running tests

The test suite uses [vader.vim](https://github.com/junegunn/vader.vim) and is
organised into focused files, one per feature:

| File | Coverage |
|---|---|
| `test/keys_here.vader` | `:YamlKeysHere` and location list behaviour |
| `test/prev_next.vader` | `[k` / `]k` prev/next sibling motions |
| `test/key_path.vader` | `:YamlKeyPath` ancestor path command |
| `test/nav_path.vader` | `YamlNavPath()` statusline function |

Run tests with `make`:

```bash
make all             # run all tests with both Vim and Neovim
make test-vim        # run all tests with Vim
make test-nvim       # run all tests with Neovim
make test-keys-here  # run :YamlKeysHere tests only
make test-prev-next  # run [k/]k motion tests only
make test-key-path   # run :YamlKeyPath tests only
make test-nav-path   # run YamlNavPath() tests only
make clean           # remove temporary files
```

## Usage

All commands and mappings are buffer-local and only active in YAML buffers.

**Location list of sibling keys**

Run `:YamlKeysHere` or press `<leader>k` to open the location list of all keys
at the current indentation level. Blank lines and comment lines (`#`) are
excluded. Location list entries jump to the start of the line (column 1).

**Prev/next sibling motions**

Press `[k` to jump to the previous sibling key and `]k` to jump to the next
sibling key at the same indentation level, without opening the location list.
Both motions stay put when there is no further sibling in that direction.

**Ancestor key path**

Run `:YamlKeyPath` to echo the full dotted path from the root key down to the
key under the cursor (e.g. `services.api.env`).

**Statusline integration**

`YamlNavPath()` is a public function that returns the same dotted path as a
string, suitable for use in a statusline:

```vim
" Example: vanilla statusline
set statusline+=%{YamlNavPath()}

" Example: lualine (Neovim)
require('lualine').setup {
  sections = {
    lualine_c = { { function() return vim.fn.YamlNavPath() end } }
  }
}
```

## Configuration

```vim
" Disable the default <leader>k mapping (g:yaml_nav_mapping is ignored if set)
let g:yaml_nav_no_mapping = 1

" Use a custom key for :YamlKeysHere (default: <leader>k)
let g:yaml_nav_mapping = '<leader>y'

" Use custom keys for prev/next sibling motions (defaults: [k and ]k)
let g:yaml_nav_prev_mapping = '[y'
let g:yaml_nav_next_mapping = ']y'
```

**Notes:**

- Setting `g:yaml_nav_no_mapping = 1` suppresses the default `<leader>k`
  mapping entirely. The `[k`/`]k` motions are unaffected.
- `g:yaml_nav_mapping` is ignored if `g:yaml_nav_no_mapping` is set to 1.
- Location list entries jump to the start of the line (column 1), not to the
  key text itself.

## License

Apache License 2.0. See [LICENSE](LICENSE).
