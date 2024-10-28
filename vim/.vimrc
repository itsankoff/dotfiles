" Set runtime path
set rtp^=~/.vim-itsankoff

" General Vim settings
set nocompatible
filetype plugin indent on
syntax on
set hidden

" Plugin manager - vim-plug setup
call plug#begin('~/.vim-itsankoff')

" NERDTree for file navigation
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle' }

" Custom color scheme
Plug 'flazz/vim-colorschemes'

" coc.nvim for autocompletion
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" fzf for fuzzy finding
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all', 'on': ['Files', 'Ag'] }
Plug 'junegunn/fzf.vim', { 'on': ['Files', 'Ag'] }

" git integration
Plug 'tpope/vim-fugitive', { 'on': 'G' }

" vim-airline for status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" vim-commentary for commenting code
Plug 'tpope/vim-commentary'

call plug#end()

" Set colorscheme
colorscheme jellygrass

" Set default indent rules
autocmd FileType * setlocal tabstop=4 shiftwidth=4 expandtab

" Golang specific autocommands
augroup go_settings
  autocmd!
  autocmd FileType go setlocal tabstop=4 shiftwidth=4 expandtab
  autocmd FileType go let g:go_fmt_command = "goimports"
  autocmd FileType go let g:go_auto_type_info = 1
  autocmd FileType go set updatetime=100
  autocmd FileType go let g:go_decls_includes = "func,type"
  autocmd FileType go let g:go_def_mode = 'godef'
  autocmd FileType go let g:go_highlight_types = 1
  autocmd FileType go let g:go_highlight_fields = 1
  autocmd FileType go let g:go_highlight_functions = 1
  autocmd FileType go let g:go_highlight_operators = 1
augroup END

" Trigger completion like VSCode
silent! iunmap <Tab>
inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : coc#refresh()
inoremap <expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
inoremap <expr> . coc#refresh() . '.'

" Clipboard interaction
set clipboard=unnamedplus

" Use y and p to work with system clipboard
nnoremap y "+y
vnoremap y "+y
nnoremap p "+p
vnoremap p "+p
nnoremap Y "+Y

" NERDTree toggle mapping
noremap <Tab> :NERDTreeToggle<CR>

" Airline configuration
let g:airline_theme = 'minimalist'
let g:airline_powerline_fonts = 1
set noshowmode

" Commentary mapping (using vim-commentary)
" No additional configuration required as vim-commentary is simple and effective

" Spell checking settings
set spell
hi clear SpellBad
hi SpellBad guisp=blue gui=underline guifg=NONE guibg=NONE cterm=underline ctermbg=NONE ctermfg=NONE term=underline

" History and undo settings
set history=1000
set undolevels=1000

" Folding settings
set foldmethod=syntax
set foldlevelstart=99 " Open most folds by default
set nofoldenable " Do not fold files by default

" FZF key mappings
nnoremap <leader>s :Files<CR>

" General key mappings
nnoremap <leader>r :so $MYVIMRC<CR> " Reload .vimrc
vnoremap <leader>c :Commentary<CR> " Comment selection

" Easy window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Search options
set incsearch
set smartcase

" Show line numbers
set number

" Remove trailing spaces on save for specific file types
autocmd FileType c,cpp,python,javascript,jsx autocmd BufWritePre <buffer> :%s/\s\+$//e

" Enable wildmenu for command-line completion
set wildmenu
set wildmode=longest:full,full
set completeopt=menuone,noselect

" Show matching parentheses
set showmatch

" Visual autocomplete for command menu
set wildmenu
set wildmode=longest:full,full

" Save buffer changes with sudo
cmap w!! w !sudo tee > /dev/null %

" Split direction
set splitright
