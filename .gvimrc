silent function! OSX()
    return has('macunix')
endfunction
silent function! LINUX()
    return has('unix') && !has('macunix') && !has('win32unix')
endfunction
silent function! WINDOWS()
    return  (has('win16') || has('win32') || has('win64'))
endfunction

" use big font
if LINUX()
    set guifont=Andale\ Mono\ Regular\ 12,Menlo\ Regular\ 11,Consolas\ Regular\ 12,Courier\ New\ Regular\ 14
elseif OSX()
    set linespace=2
    set guifont=JetBrainsMonoNLNFM-Regular:h14,Andale\ Mono\ Regular:h12,Menlo\ Regular:h11,Consolas\ Regular:h12,Courier\ New\ Regular:h14
elseif WINDOWS()
    set guifont=Andale_Mono:h10,Menlo:h10,Consolas:h10,Courier_New:h10
endif
" echom ".gvimrc loaded"
