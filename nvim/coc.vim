" Ruby Solargraph 
let g:coc_global_extensions = ['coc-solargraph', 'coc-tsserver']

" Prettier
command! -nargs=0 Prettier :call CocAction('runCommand', 'prettier.formatFile')

" TS highlighting
autocmd BufEnter *.{js,jsx,ts,tsx} :syntax sync fromstart
autocmd BufLeave *.{js,jsx,ts,tsx} :syntax sync clear
