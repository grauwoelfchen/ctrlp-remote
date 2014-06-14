" =============================================================================
" File:          autoload/ctrlp/remote.vim
" Description:   CtrlP extension for remote
" =============================================================================

" To load this extension into ctrlp, add this to your vimrc:
"
"     let g:ctrlp_extensions = ['remote']

" Load guard
if (exists('g:loaded_ctrlp_remote') && g:loaded_ctrlp_remote)
  \ || v:version < 700 || &cp
  finish
endif
let g:loaded_ctrlp_remote = 1

let s:remote = 'origin'
let s:system = function(get(g:, 'ctrlp#remote#system_function', 'system'))


" Add this extension's settings to g:ctrlp_ext_vars
"
" Required:
"
" + init: the name of the input function including the brackets and any
"         arguments
"
" + accept: the name of the action function (only the name)
"
" + lname & sname: the long and short names to use for the statusline
"
" + type: the matching type
"   - line : match full line
"   - path : match full line like a file or a directory path
"   - tabs : match until first tab character
"   - tabe : match until last tab character

let s:ctrlp_remote_var = {
\  'init':   'ctrlp#remote#init()',
\  'exit':   'ctrlp#remote#exit()',
\  'accept': 'ctrlp#remote#accept',
\  'lname':  'remote',
\  'sname':  'br',
\  'type':   'path',
\  'sort':   0,
\}

"
" Optional:
"
" + enter: the name of the function to be called before starting ctrlp
"
" + exit: the name of the function to be called after closing ctrlp
"
" + opts: the name of the option handling function called when initialize
"
" + sort: disable sorting (enabled by default when omitted)
"
" + specinput: enable special inputs '..' and '@cd' (disabled by default)
"
" call add(g:ctrlp_ext_vars, {
"   \ 'init': 'ctrlp#remote#init()',
"   \ 'accept': 'ctrlp#remote#accept',
"   \ 'lname': 'remote',
"   \ 'sname': 'br',
"   \ 'type': 'line',
"   \ 'enter': 'ctrlp#remote#enter()',
"   \ 'exit': 'ctrlp#remote#exit()',
"   \ 'opts': 'ctrlp#remote#opts()',
"   \ 'sort': 0,
"   \ 'specinput': 0,
"   \ })

if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
  let g:ctrlp_ext_vars = add(g:ctrlp_ext_vars, s:ctrlp_remote_var)
else
  let g:ctrlp_ext_vars = [s:ctrlp_remote_var]
endif


" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#remote#init(...)
  let s:remote  = get(a:000, 0, s:remote)
  let s:remotes = split(s:system('git remote'), '\n')
  if (index(s:remotes, s:remote) >= 0)
    call ctrlp#init(ctrlp#remote#id())
    " TODO move to vimscript world!
    let s:command = join([
      \ 'git for-each-ref --format="%(refname:short)" refs/heads refs/remotes | ',
      \ 'while read remote;',
      \ 'do ',
      \ 'ahead=`git rev-list remotes/'.s:remote.'/master..${remote} --count 2>/dev/null`;',
      \ 'behind=`git rev-list ${remote}..remotes/'.s:remote.'/master --count 2>/dev/null`;',
      \ 'printf "%-30s %16s | %-15s %s\n" "$remote" "(behind $behind)" "(ahead $ahead)" "remotes/'.s:remote.'/master";',
      \ 'done'
    \ ], '')
    return split(s:system(s:command), '\n')
  else
    return ['git: cannot access '.s:remote.': No such remote', '']
  endif
endfunction


" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
"
function! ctrlp#remote#accept(mode, str)
  " For this example, just exit ctrlp and run help
  call ctrlp#exit()
  help ctrlp-extensions
endfunction


" (optional) Do something before enterting ctrlp
function! ctrlp#remote#enter()
endfunction


" (optional) Do something after exiting ctrlp
function! ctrlp#remote#exit()
endfunction


" (optional) Set or check for user options specific to this extension
function! ctrlp#remote#opts()
endfunction


" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

" Allow it to be called later
function! ctrlp#remote#id()
  return s:id
endfunction


" Create a command to directly call the new search type
"
" Put this in vimrc or plugin/remote.vim
" command! CtrlPremote call ctrlp#init(ctrlp#remote#id())


" vim:nofen:fdl=0:ts=2:sw=2:sts=2
