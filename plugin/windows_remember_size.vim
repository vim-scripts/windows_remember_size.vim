" == New version: tries to automatically keep up without whatever layout changes
" you make, by storing an unfocused and focused size for each window. ==
"
" Explanation: Whenever you leave a window, it remembers what size it was, and
" whenever you enter a window, it remembers what size it was before entering.
" Thus it records "focused" and "unfocused" sizes for each window, and it will
" try to grow/shrink windows on entering/leaving, to match the recorded value.
"
" Warning: This system is not perfect, specifically when opening a new window
" (changing the layout) it has no strategy and will often shrink the new
" window when it is unfocused.
"
" Solution: The best approach appears to be, as soon as your layout breaks in
" some way, fix it immediately with 20<C-W>+ or whatever, to minimize the
" damage (before the new broken values get recorded).  This is a small work
" overhead for the user, which he must exchange for the beneficial features of
" this script!

augroup WindowsRememberSizes
  autocmd!
  autocmd WinLeave * call <SID>Leaving()
  autocmd WinEnter * call <SID>Entering()
augroup END

function! s:Debug(msg)
  if exists('g:wrsDebug') && g:wrsDebug > 0
    echo a:msg
  endif
endfunction

function! s:Leaving()
  let w:heightWhenFocused = winheight(0)
  let w:widthWhenFocused = winwidth(0)
  call s:Debug( "[exit] ".bufname('%')." saved foc ".w:widthWhenFocused.",".w:heightWhenFocused )
  if exists('w:heightWhenUnfocused') && w:heightWhenUnfocused < winheight(0)
    call s:Debug( "[exit] ".bufname('%')." setting ".w:widthWhenUnfocused."x".w:heightWhenUnfocused )
    exec "resize ".w:heightWhenUnfocused
  endif
  if exists('w:widthWhenUnfocused') && w:widthWhenUnfocused < winwidth(0)
    exec "vert resize ".w:widthWhenUnfocused
  endif
endfunction

function! s:Entering()
  let w:heightWhenUnfocused = winheight(0)
  let w:widthWhenUnfocused = winwidth(0)
  call s:Debug( "[enter] ".bufname('%')." saved unf ".w:widthWhenUnfocused.",".w:heightWhenUnfocused )
  if exists('w:heightWhenFocused') && w:heightWhenFocused > winheight(0)
    call s:Debug( "[enter] ".bufname('%')." restoring ".w:widthWhenFocused."x".w:heightWhenFocused )
    exec "resize ".w:heightWhenFocused
  endif
  if exists('w:widthWhenFocused') && w:widthWhenFocused > winwidth(0)
    exec "vert resize ".w:widthWhenFocused
  endif
endfunction

" BUGS:
" When we add a new window to the list, e.g. TagList, when switching to it, the old unfocused size of the previous window from the *old* layout is applied.
" I think we need to forget some things when layout changes?  Forget all unfocused sizes?
" Or perhaps when a new window enters the layout, we should quickly grab its dimensions and set those as its focused and unfocused size?

" OK I like this version a lot now.  With the exception of the major bugs, which is when new windows are made, sometimes a window will end up 0 height or 0 width.
" When we are thinking of restoring or saving values, we could check the number of windows (or even their names) to see if any change has occured.
" New windows should be encouraged to take 50% of the space I guess, as per Vim's default.

" Perhaps what we should do is have window remember their relative size rather than their actual size.  Would this be a percentage, or a ratio?
" Then what do we do when a new window is created?  Shrink them all by 10%?  Shrink them intelligently?

" Exposed to user
function! ForgetWindowSizes()
  let l:winnr = winnr()
  windo exec "unlet! w:widthWhenFocused"
  windo exec "unlet! w:widthWhenUnfocused"
  windo exec "unlet! w:heightWhenFocused"
  windo exec "unlet! w:heightWhenUnfocused"
  exec l:winnr." wincmd w"
endfunction

" Some keybinds, entirely optional
" nmap <silent> Om <C-W>-
" nmap <silent> Ok <C-W>+
" nmap <silent> Oo <C-W><
" nmap <silent> Oj <C-W>>
" nnoremap <silent> <C-kMinus> <C-W>-
" nnoremap <silent> <C-kPlus> <C-W>+
" nnoremap <silent> <C-kDivide> <C-W><
" nnoremap <silent> <C-kMultiply> <C-W>>

