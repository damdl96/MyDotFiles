" Ruby Solargraph 
let g:coc_global_extensions = ['coc-solargraph']

" Prettier
command! -nargs=0 Prettier :call CocAction('runCommand', 'prettier.formatFile')
