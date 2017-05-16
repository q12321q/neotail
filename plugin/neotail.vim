"=============================================================================
" FILE: neotail.vim
"=============================================================================

if exists('g:loaded_neotail')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

" Start neotail on the current buffer
command! Neotail call g:neotail#start()
" stop neotail on the current buffer
command! NeotailStop call g:neotail#stop()

let g:loaded_neotail = 1

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
