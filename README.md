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

## Usage

With the cursor anywhere inside a YAML block, run `:YamlKeysHere` or press
`<leader>k` to open the location list of sibling keys at the same indentation
level.

The location list contains all YAML keys (lines of the form `key:`) at the
cursor's indentation level. Blank lines and comment lines (`#`) are excluded.

The mapping and command are buffer-local and only active in YAML buffers.

## Configuration

```vim
" Disable the default mapping (g:yaml_nav_mapping is ignored if this is set)
let g:yaml_nav_no_mapping = 1

" Use a custom mapping key (default: <leader>k)
let g:yaml_nav_mapping = '<leader>y'
```

**Notes:**

- The `<leader>k` mapping is buffer-local and only works in YAML buffers.
- Setting `g:yaml_nav_no_mapping = 1` suppresses the default mapping entirely.
  If you wish to define your own mapping, do so after the plugin loads.
- Location list entries jump to the start of the line (column 1), not to the
  key text itself.

## License

Apache License 2.0. See [LICENSE](LICENSE).
