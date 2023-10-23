call plug#begin()
  " Theme
  Plug 'morhetz/gruvbox' "https://github.com/morhetz/gruvbox
  " To visualize files
  Plug 'preservim/nerdtree'
  " nerdtree icons
  Plug 'ryanoasis/vim-devicons'
  Plug 'nvim-lua/popup.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-treesitter/nvim-treesitter'
  " Autocompletion vim
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  " To search for a file and within the files
  Plug 'nvim-telescope/telescope.nvim'
  " To visualize identation lines
  Plug 'vim-scripts/indentLine.vim'
  " Quick view of the git blame per line of code
  Plug 'zivyangll/git-blame.vim'
  " Shows the changes compared to the base file recorded by git
  Plug 'airblade/vim-gitgutter'
  " React stuff
  Plug 'pangloss/vim-javascript'
  Plug 'leafgarland/typescript-vim'
  Plug 'maxmellon/vim-jsx-pretty'
  " This adds the vim status bar
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
call plug#end()
