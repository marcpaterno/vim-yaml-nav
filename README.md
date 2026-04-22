# vim-yaml-nav

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

YAML navigation plugin for Vim 9 and Neovim.

Populates the location list with all keys at the current indentation level,
making it easy to jump between sibling keys in a YAML block.

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

## Configuration

```vim
" Disable the default mapping
let g:yaml_nav_no_mapping = 1

" Use a custom mapping key (default: <leader>k)
let g:yaml_nav_mapping = '<leader>y'
```

## License

Apache License 2.0. See [LICENSE](LICENSE).
