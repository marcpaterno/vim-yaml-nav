if exists('b:loaded_yaml_nav') | finish | endif
let b:loaded_yaml_nav = 1

function! s:YamlKeysHere() abort
  let l:cur_line   = line('.')
  let l:cur_indent = indent(l:cur_line)
  let l:last_line  = line('$')

  " Find block start
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

  " Find block end
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

  let l:items = []

  for l:num in range(l:start, l:end)
    let l:line = getline(l:num)

    if l:line =~ '^\s*$' || l:line =~ '^\s*#'
      continue
    endif

    if indent(l:num) == l:cur_indent
      if l:line =~ '^\s*\zs[^:]\+\ze:'
        call add(l:items, {
              \ 'lnum': l:num,
              \ 'col': 1,
              \ 'text': matchstr(l:line, '^\s*\zs[^:]\+\ze:')
              \ })
      endif
    endif
  endfor

  call setloclist(0, l:items, 'r')
  lopen
endfunction

command! -buffer YamlKeysHere call <SID>YamlKeysHere()

if !exists('g:yaml_nav_no_mapping')
  let s:map = get(g:, 'yaml_nav_mapping', '<leader>k')
  execute 'nnoremap <silent><buffer> ' . s:map . ' :YamlKeysHere<CR>'
endif
