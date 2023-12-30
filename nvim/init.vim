let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

let g:coc_global_extensions = ['coc-solargraph']
let g:airline_theme='molokai'

" Plugins
source $HOME/MyDotFiles/nvim/vim-plug/plugins.vim

" Basic settings
source $HOME/MyDotFiles/nvim/general/settings.vim

" Key mappings
source $HOME/MyDotFiles/nvim/keys/mappings.vim

" Lua scripts
" source $HOME/MyDotFiles/nvim/lua-scripts/scripts.vim
