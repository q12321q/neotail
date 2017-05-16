"=============================================================================
" FILE: neotail.vim
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

"=============================================================================
" Global variables
"=============================================================================

" Period of the loop to check if the file changed (in milliseconds)
let g:neotail_loop_period = get(g:, 'neotail_loop_period', 100)

" Activate debug mode
let g:neotail_debug = get(g:, 'neotail_debug', v:false)

"=============================================================================
" Public functions
"=============================================================================

" Start neotail on the current buffer
function! g:neotail#start() abort
  if !exists('b:neotail')
    let b:neotail = s:Neotail.New()
    autocmd BufEnter <buffer> call g:neotail#start()
    autocmd BufLeave <buffer> call g:neotail#stop()
  endif
  call b:neotail.start()
endfunction

" Stop neotail on the current buffer
function! g:neotail#stop() abort
  if exists('b:neotail')
    call b:neotail.stop()
  endif
endfunction

" Log function. Only enable on debug mode (g:neotail_debug)
function! g:neotail#log(msg) abort
  if g:neotail_debug
    call system('echo "' . localtime() . ' ' . a:msg . '" >> /tmp/neotail.log')
  endif
endfunction

"=============================================================================
" Neotail class
" Follow the tail of a buffer like a tail -f
"=============================================================================

let s:Neotail = {}

" Neotail constructor
function! s:Neotail.New() abort dict
    let l:_self = copy(self)
    let l:_self.bufnr = bufnr('%')
    let l:_self.filesize = getfsize(expand('%'))
    let l:_self.active = v:false
    let l:_self.timer = v:null
    call g:neotail#log('Neotail.New')
    return l:_self
endfunction

" Each tick of the timer this function is called
function! s:Neotail.loop(...) abort dict
  try
    if !self.active || self.bufnr != bufnr('%') || &modified
      return
    endif

    let l:filesize = getfsize(expand('%'))
    if l:filesize != self.filesize
      call g:neotail#log('Neotail.Loop')
      let l:follow = line('$') == line('.')

      if !l:follow
        let l:save_view = winsaveview()
      endif

      edit

      if l:follow
        normal! GG
      else
        call winrestview(l:save_view)
      endif

      let self.filesize = l:filesize
    endif
  catch
    call self.stop()
    throw 'fail in neotail_loop'
  endtry
endfunction

" Start the timer
function! s:Neotail.start() abort dict
  call g:neotail#log('Neotail.start')
  if !self.active || !self.timer
    let self.timer = timer_start(g:neotail_loop_period, self.loop, {'repeat': -1})
  endif
  let self.active = v:true
endfunction

" Stop the timer
function! s:Neotail.stop() abort dict
  call g:neotail#log('Neotail.stop')
  if self.timer
    call timer_stop(self.timer)
  endif
  let self.timer = v:null
  let self.active = v:false
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
