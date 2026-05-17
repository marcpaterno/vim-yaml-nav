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

function! s:YamlJumpPrev() abort
  let l:line = line('.')
  let l:indent = indent(l:line)

  let l:first = 1
  let l:last = line('$')

  " Scan upward for the first key at current indent level
  let l:start_key = 0
  for l:i in range(l:first, l:last)
    if l:i >= l:line
      break
    endif
    let l:ln = getline(l:i)
    if l:ln =~ '^\s*$' || l:ln =~ '^\s*#'
      continue
    endif
    if indent(l:i) == l:indent
      if l:ln =~ '^\s*\zs[^:]\+\ze:'
        let l:start_key = l:i
      endif
    endif
  endfor

  if l:start_key > 0
    call cursor(l:start_key, 1)
  endif
endfunction

function! s:YamlJumpNext() abort
  let l:line = line('.')
  let l:indent = indent(l:line)

  let l:first = 1
  let l:last = line('$')

  " Scan downward for the first key at current indent level after current line
  for l:i in range(l:line + 1, l:last)
    let l:ln = getline(l:i)
    if l:ln =~ '^\s*$' || l:ln =~ '^\s*#'
      continue
    endif
    if indent(l:i) == l:indent
      if l:ln =~ '^\s*\zs[^:]\+\ze:'
        call cursor(l:i, 1)
        return
      endif
    endif
  endfor
endfunction

function! s:BuildKeyPath(lnum) abort
  " Return the dotted ancestor path for the key at line a:lnum.
  " Returns an empty string if the line is not a key line.
  let l:path = []
  let l:line = a:lnum

  " Include the key on the given line if it is a key.
  let l:cur_text = getline(l:line)
  if l:cur_text =~ '^\s*$' || l:cur_text =~ '^\s*#'
    return ''
  endif
  if l:cur_text !~ '^\s*\zs[^:]\+\ze:'
    return ''
  endif
  let l:path = [matchstr(l:cur_text, '^\s*\zs[^:]\+\ze:')]

  " Scan upward for ancestor keys at strictly smaller indentation.
  let l:seek_indent = indent(l:line) - 1
  let l:i = l:line - 1
  while l:i >= 1 && l:seek_indent >= 0
    let l:ln = getline(l:i)
    if l:ln =~ '^\s*$' || l:ln =~ '^\s*#'
      let l:i -= 1
      continue
    endif
    if indent(l:i) <= l:seek_indent
      if l:ln =~ '^\s*\zs[^:]\+\ze:'
        call insert(l:path, matchstr(l:ln, '^\s*\zs[^:]\+\ze:'), 0)
        let l:seek_indent = indent(l:i) - 1
      endif
    endif
    let l:i -= 1
  endwhile

  return join(l:path, '.')
endfunction

function! s:YamlKeyPath() abort
  echo s:BuildKeyPath(line('.'))
endfunction

function! YamlNavPath() abort
  " Public function for use in statuslines. Returns the dotted key path at
  " the cursor position, or an empty string if the cursor is not on a key.
  if &filetype !=# 'yaml'
    return ''
  endif
  return s:BuildKeyPath(line('.'))
endfunction

command! -buffer YamlKeysHere call <SID>YamlKeysHere()
command! -buffer YamlKeyPath  call <SID>YamlKeyPath()

" Map prev/next functions
if !exists('g:yaml_nav_prev_mapping')
  let g:yaml_nav_prev_mapping = '[k'
endif

if !exists('g:yaml_nav_next_mapping')
  let g:yaml_nav_next_mapping = ']k'
endif

execute 'nnoremap <silent><buffer> ' . g:yaml_nav_prev_mapping . ' :call <SID>YamlJumpPrev()<CR>'
execute 'nnoremap <silent><buffer> ' . g:yaml_nav_next_mapping . ' :call <SID>YamlJumpNext()<CR>'

" Default key mapping (can be overridden or disabled)
if !exists('g:yaml_nav_no_mapping')
  let s:map = get(g:, 'yaml_nav_mapping', '<leader>k')
  execute 'nnoremap <silent><buffer> ' . s:map . ' :YamlKeysHere<CR>'
endif
