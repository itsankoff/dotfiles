" Set runtime path
set rtp^=~/.vim-itsankoff

" ---------------------
" General configuration
" ---------------------

" General Vim settings
set nocompatible

" Backspace behaviour
set backspace=indent,eol,start

" Indentation configuration - Set default indent rules for all files
filetype plugin indent on
syntax on

autocmd FileType * setlocal tabstop=4 shiftwidth=4 expandtab
" Makefile don't expand tabs
autocmd FileType make setlocal noexpandtab

" Switch buffer without vim prompting to save or discard changes
set hidden

" Disable swap files
set noswapfile

" Mode indication configuration - Do not show mode in the bottom left
" Already have it in statusline
set noshowmode

" Key mappings
" Leader character configuration
let mapleader = '`'
" General key mappings
nnoremap <leader>r :so $MYVIMRC<CR> " Reload .vimrc
nnoremap <leader>qq :q<CR> " Close the file
" Easy window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Clipboard configuration
" Use y and p to work with system clipboard
nnoremap y "+y
vnoremap y "+y
nnoremap p "+p
vnoremap p "+p
nnoremap Y "+Y
" System clipboard interaction
set clipboard=unnamedplus

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

" Search options
set incsearch
set smartcase

" Show line numbers
set number

" Enable wildmenu for command-line completion
set wildmenu
set wildmode=longest:full,full
set completeopt=menuone,noselect

" Show whitespaces and trailing spaces
set list
set listchars=tab:▸\ ,trail:·,extends:>,precedes:<
" Remove trailing spaces on save for specific file types
autocmd FileType c,cpp,python,javascript,jsx autocmd BufWritePre <buffer> :%s/\s\+$//e

" Show matching parentheses
set showmatch

" Visual autocomplete for command menu
set wildmenu
set wildmode=longest:full,full

" Save buffer changes with sudo
cmap w!! w !sudo tee > /dev/null %

" Split direction
set splitright

" Markdown ` color highlighting
autocmd FileType markdown highlight link markdownCodeDelimiter Normal

" --------------------
" plugins installation
" --------------------
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
Plug 'tpope/vim-fugitive'
" vim-airline for status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" vim-commentary for commenting code
Plug 'tpope/vim-commentary'
call plug#end()
" end plugins installation

" -----------------------------
" nerdtree plugin configuration
" -----------------------------
" NERDTree toggle mapping
noremap <Tab> :NERDTreeToggle<CR>
" NERDTree Git Status Icon Customization
let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ 'Modified': '✹',
    \ 'Staged': '●',
    \ 'Untracked': '✭',
    \ 'Renamed': '➜',
    \ 'Unmerged': '═',
    \ 'Deleted': '✖',
    \ 'Dirty': '',
    \ 'Ignored': '☒',
    \ 'Clean': '✔',
    \ 'Unknown': '?'
    \ }
let g:NERDTreeGitStatusShowClean = 0
let g:NERDTreeGitStatusUseNerdFonts = 1
" end nerdtree plugin configuration

" --------------------------------
" colorscheme plugin configuration
" --------------------------------
" Set colorscheme
colorscheme jellygrass
" end colorscheme plugin configuration

" ------------------------
" coc plugin configuration
" ------------------------
" Golang formatting and import management on save using coc.nvim
autocmd BufWritePre *.go :call CocAction('organizeImport')
autocmd BufWritePre *.go :call CocAction('format')
" Go to definition and references key mappings
nnoremap gd <Plug>(coc-definition) " Go to definition
nnoremap gr <Plug>(coc-references) " Go to references
nnoremap K :call CocActionAsync('doHover')<CR> " Show hover information
" Show diagnostics in a floating window when the cursor is on a line with an issue
" autocmd CursorHold * silent call CocActionAsync('doHover')
autocmd CursorHold * silent call CocActionAsync('diagnosticInfo')
" Underline problematic terms based on severity
highlight CocErrorUnderline cterm=underline gui=underline ctermfg=red guifg=red
highlight CocWarningUnderline cterm=underline gui=underline ctermfg=yellow guifg=yellow
highlight CocInfoUnderline cterm=underline gui=underline ctermfg=yellow guifg=yellow
let g:coc_diagnostic_virtual_text = {'highlight': 'CocUnderline'}
" Trigger completion like VSCode
silent! iunmap <Tab>
inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
inoremap <expr> . coc#refresh() . '.'
" end coc plugin configuration

" ------------------------
" fzf plugin configuration
" ------------------------
" FZF key mappings
nnoremap <leader>s :Files<CR>
" end fzf plugin configuration

" -----------------------------
" fugitive plugin configuration
" -----------------------------
" default indent rules for fugitive buffers
autocmd User FugitiveIndex setlocal tabstop=4 shiftwidth=4 expandtab
" delete fugitive buffers when they are closed so they don't clutter
" memory
autocmd BufWinEnter fugitive://* set bufhidden=delete
" end fugitive plugin configuration

" ----------------------------
" airline plugin configuration
" ----------------------------
let g:airline_theme = 'minimalist'
let g:airline_powerline_fonts = 1
" end airline plugin configuration

" -------------------------------
" commentary plugin configuration
" -------------------------------
nnoremap <C-c> :Commentary<CR> " Comment current line or selection
vnoremap <C-c> :Commentary<CR> " Comment selection
nnoremap <C-x> :Commentary<CR> " Uncomment current line or selection
vnoremap <C-x> :Commentary<CR> " Uncomment selection
" Comment prefix definition for different files
" autocmd FileType apache set commentstring=#\ %s
" end commentary plugin configuration
