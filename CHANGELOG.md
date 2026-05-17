# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-05-17

### Added

- `[k` / `]k` motions to jump to the previous/next sibling key at the same
  indentation level without opening the location list. Both motions stay put
  when there is no further sibling in that direction.
- `:YamlKeyPath` command to echo the full dotted ancestor path from the root
  key down to the key under the cursor (e.g. `services.api.env`).
- `YamlNavPath()` public function returning the same dotted path as a string,
  intended for use in statuslines (Vim `statusline` or Neovim lualine).
- `g:yaml_nav_prev_mapping` configuration variable to override the default
  `[k` mapping for the prev-sibling motion.
- `g:yaml_nav_next_mapping` configuration variable to override the default
  `]k` mapping for the next-sibling motion.
- Vader.vim test suite with one focused test file per feature:
  `keys_here.vader`, `prev_next.vader`, `key_path.vader`, `nav_path.vader`.
- GitHub Actions CI workflow running tests against Vim stable, Neovim stable,
  and Neovim nightly.
- Per-feature `make` targets (`test-keys-here`, `test-prev-next`,
  `test-key-path`, `test-nav-path`) to run a single test file in isolation.

## [1.0.0] - 2026-04-22

### Added

- Initial release.
- `:YamlKeysHere` command to populate the location list with all sibling keys
  at the current indentation level. Blank lines and comment lines are excluded.
  Location list entries report column 1 (start of line).
- `<leader>k` buffer-local mapping that calls `:YamlKeysHere`.
- `g:yaml_nav_no_mapping` option to suppress the default `<leader>k` mapping.
- `g:yaml_nav_mapping` option to use a custom key for the mapping.
