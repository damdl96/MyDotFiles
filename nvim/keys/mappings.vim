nmap <leader>z :u<CR>
nmap <leader>Q :qa!<CR>
nmap <leader>q :bw<CR>

" NERDTree
nnoremap <leader>/ :NERDTreeToggle<CR>
nnoremap <leader>. :NERDTreeFind<CR>

" Telescope
nnoremap <leader>f <cmd>Telescope find_files<CR>
nnoremap <leader>fh <cmd>Telescope find_files hidden=true<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<CR>
nnoremap <leader>fgh <cmd>Telescope live_grep hidden=true<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fhi <cmd>Telescope help_tags<cr>

" Git blame
nnoremap <Leader>s :<C-u>call gitblame#echo()<CR>

noremap Zz <c-w>_ \| <c-w>\|
noremap Zo <c-w>=

" noremap <Tab> :tabnext<CR>
" noremap <leader>0 :tablast<cr>
" noremap <Leader>1<Tab> 1gt<CR>
" noremap <Leader>2<Tab> 2gt<CR>
" noremap <Leader>3<Tab> 3gt<CR>
" noremap <Leader>4<Tab> 4gt<CR>
" noremap <Leader>5<Tab> 5gt<CR>
" noremap <Leader>6<Tab> 6gt<CR>
" noremap <Leader>7<Tab> 7gt<CR>
" noremap <Leader>8<Tab> 8gt<CR>
" noremap <Leader>9<Tab> 9gt<CR>

" Use alt + hjkl to resize windows
nnoremap <M-j>    :resize -2<CR>
nnoremap <M-k>    :resize +2<CR>
nnoremap <M-h>    :vertical resize -2<CR>
nnoremap <M-l>    :vertical resize +2<CR>

" Easy CAPS
inoremap <c-u> <ESC>viwUi
nnoremap <c-u> viwU<Esc>

" TAB in general mode will move to next tab
nnoremap <TAB> :tabnext<CR>

" SHIFT-TAB will go to previous tab
nnoremap <S-TAB> :tabprevious<CR>

" Alternate way to save
nnoremap <C-s> :w<CR>

" Alternate way to quit
nnoremap <C-Q> :wq!<CR>

" Use control-c instead of escape
" nnoremap <C-c> <Esc>

" <TAB>: completion.
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

" Better tabbing
vnoremap < <gv
vnoremap > >gv

" Better window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" COC tooltip documentation
nnoremap <silent> K :call CocAction('doHover')<CR>

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

