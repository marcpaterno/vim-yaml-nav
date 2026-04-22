if exists('b:loaded_yaml_nav') | finish | endif
let b:loaded_yaml_nav = 1

function! s:YamlKeysHere() abort
  " Record the cursor's line and its indentation level. All sibling keys
  " must share this exact indentation.
  let l:cur_line   = line('.')
  let l:cur_indent = indent(l:cur_line)
  let l:last_line  = line('$')

  " Scan upward from the cursor to find the first line of the enclosing block.
  " Blank lines are absorbed (they don't end the block). Any non-blank line
  " with less indentation than the cursor marks the boundary; stop just below it.
  let l:start = l:cur_line
  while l:start > 1
    let l:prev = l:start - 1
    let l:pline = getline(l:prev)

    if l:pline =~ '^\s*$'
      let l:start = l:prev
      continue
    endif

    if indent(l:prev) < l:cur_indent
      break
    endif

    let l:start = l:prev
  endwhile

  " Scan downward from the cursor to find the last line of the enclosing block,
  " using the same logic: absorb blank lines, stop when indentation decreases.
  let l:end = l:cur_line
  while l:end < l:last_line
    let l:next = l:end + 1
    let l:nline = getline(l:next)

    if l:nline =~ '^\s*$'
      let l:end = l:next
      continue
    endif

    if indent(l:next) < l:cur_indent
      break
    endif

    let l:end = l:next
  endwhile

  " Walk every line in the block and collect YAML keys at the cursor's
  " indentation level. A key is any line of the form '<whitespace>word(s):'.
  " Blank lines and comment lines (starting with #) are skipped.
  " Lines at a deeper indentation level are values or nested blocks; skip them.
  let l:items = []

  for l:num in range(l:start, l:end)
    let l:line = getline(l:num)

    if l:line =~ '^\s*$' || l:line =~ '^\s*#'
      continue
    endif

    if indent(l:num) == l:cur_indent
      " Match the key name: non-colon characters before the first colon,
      " ignoring leading whitespace.
      if l:line =~ '^\s*\zs[^:]\+\ze:'
        call add(l:items, {
              \ 'lnum': l:num,
              \ 'col': 1,
              \ 'text': matchstr(l:line, '^\s*\zs[^:]\+\ze:')
              \ })
      endif
    endif
  endfor

  " Replace the current window's location list with the collected keys
  " and open it so the user can jump to any sibling key.
  call setloclist(0, l:items, 'r')
  lopen
endfunction

command! -buffer YamlKeysHere call <SID>YamlKeysHere()

if !exists('g:yaml_nav_no_mapping')
  let s:map = get(g:, 'yaml_nav_mapping', '<leader>k')
  execute 'nnoremap <silent><buffer> ' . s:map . ' :YamlKeysHere<CR>'
endif
