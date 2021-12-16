set rtp^=~/.vim-itsankoff

filetype plugin indent on
syntax on

set nocompatible
filetype off

call plug#begin('~/.vim-itsankoff')

" NERDTree
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
" Custom color scheme
Plug 'flazz/vim-colorschemes'
" vim language server
Plug 'prabirshrestha/vim-lsp'
" auto complete
Plug 'maralla/completor.vim'
" terraform for vim
Plug 'hashivim/vim-terraform'
" typescript for vim
Plug 'leafgarland/typescript-vim'
" golang for vim
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
" language packs for vim
Plug 'sheerun/vim-polyglot'
" fzf integration
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" git integration
Plug 'tpope/vim-fugitive'
" silver search integration
Plug 'epmatsw/ag.vim'
" status line integration
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

if has('autocmd')
    " Default indent rules
    autocmd FileType * set tabstop=4 shiftwidth=4 expandtab softtabstop=0

    " vim-go
    " auto imports
    autocmd FileType go let g:go_fmt_command = "goimports"
    " show only quickfix
    autocmd FileType go let g:go_list_type = "quickfix"
    " show types and functions signature
    autocmd FileType go let g:go_auto_type_info = 1
    autocmd FileType go set updatetime=100
    " show highlights for same function and types
    autocmd FileType go let g:go_auto_sameids = 1
    autocmd FileType go let g:go_decls_includes = "func,type"
    autocmd FileType go let g:go_def_mode = 'godef'
    autocmd FileType go let g:go_highlight_types = 1
    autocmd FileType go let g:go_highlight_fields = 1
    autocmd FileType go let g:go_highlight_functions = 1
    autocmd FileType go let g:go_highlight_operators = 1
    " autocmd FileType go let g:go_metalinter_autosave = 1

    " ycm go LSP
    autocmd FileType go let g:ycm_gopls_binary_path = '$GOPATH/bin/gopls'

    " Go mappings
    " Trigger :GoCoverage
    autocmd FileType go nmap <leader>1 <Plug>(go-coverage-toggle)
    autocmd FileType go nmap <leader>h <Plug>(go-info)
    autocmd FileType go nnoremap <leader>b :GoBuild<CR>
    autocmd FileType go nnoremap <leader>t :GoTest!<CR>
    autocmd FileType go nnoremap <leader>f :GoTestFunc!<CR>
    autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
    autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
    autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
    autocmd Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')

    " Custom javascript indent rules
    autocmd FileType javascript,javascript.jsx,typescript,typescriptreact,html,htmldjango set tabstop=2 shiftwidth=2 expandtab

    autocmd BufRead,BufNewFile *.hcl set filetype=terraform
    autocmd FileType hcl set filetype=terraform syntax=terraform

    " Custom python indent rules
    autocmd FileType python set tabstop=4 shiftwidth=4 expandtab

    autocmd FileType yaml,yaml.ansible set tabstop=2 shiftwidth=2 expandtab

    " Custom Makefile indent rules
    autocmd Filetype make set noexpandtab tabstop=4 shiftwidth=4 softtabstop=4

    " Commenting blocks of code.
    autocmd FileType c,cpp,java,scala,javascript,css,go,typescript let b:comment_leader = '// '
    autocmd FileType sh,python,yaml,conf,fstab,nginx,make,terraform let b:comment_leader = '# '
    autocmd FileType vim                             let b:comment_leader = '" '

    " Remember last position in file
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

    " Remove trailing spaces on save for specific file types
    autocmd FileType c,vim,cpp,python,javascript,jsx autocmd BufWritePre <buffer> :%s/\s\+$//e

    " Keep clipboard content after vim exit
    autocmd VimLeave * call system("xclip -o | xclip -selection c")
endif

" airline configuration
let g:airline_theme = 'minimalist'
" Do mess with spell settings
let g:airline_detect_spell=0
" Use for GUI environments
let g:airline_powerline_fonts = 1
" Use for non-GUI environments
"let g:airline_symbols_ascii = 1

" ycm autocompletion settings
let g:ycm_key_invoke_completion = '<C-f>'

" Terraform vim config
let g:terraform_align=1
let g:terraform_fmt_on_save=1

" Golang documentation pop-up
let g:go_doc_popup_window = 1

" Golang autocompletion
let g:completor_filetype_map = {}
let g:completor_filetype_map.go = {'ft': 'lsp', 'cmd': 'gopls -remote=auto'}"

" Complete on TAB
let g:completor_auto_trigger = 1
" inoremap <expr> <Tab> pumvisible() ? "<C-N>" : "<C-R>=completor#do('complete')<CR>"

" for hex editing
augroup Binary
  au!
  au BufReadPre  *.bin let &bin=1
  au BufReadPost *.bin if &bin | %!xxd
  au BufReadPost *.bin set ft=xxd | endif
  au BufWritePre *.bin if &bin | %!xxd -r
  au BufWritePre *.bin endif
  au BufWritePost *.bin if &bin | %!xxd
  au BufWritePost *.bin set nomod | endif
augroup END

" Color scheme
colorscheme jellygrass

" NERDThree Git plugin
let g:NERDTreeGitStatusIndicatorMapCustom = {
                \ 'Modified'  :'✐',
                \ 'Staged'    :'▲',
                \ 'Untracked' :'⟎',
                \ 'Renamed'   :'☈',
                \ 'Unmerged'  :'▽',
                \ 'Deleted'   :'✖',
                \ 'Dirty'     :'✹',
                \ 'Ignored'   :'.',
                \ 'Clean'     :'✔︎',
                \ 'Unknown'   :'?',
                \ }

let g:NERDTreeGitStatusUseNerdFonts = 1 "

" Vim, not vi
set nocompatible

" Use Unix as a default file type
set ffs=unix,mac,dos

" Set default encoding
set encoding=UTF-8

" Automatically save before commands like :next and :make
set autowrite

" Show matching parenthesis.
set showmatch

" Set modifiable
set ma

" Vim gutter
set scl=no

" Check for file changes
set autoread

" Show line numbers
set number

" Disable backups
set nobackup
set nowritebackup
set noswapfile

" Copy to clipboard
set clipboard=unnamed

" Search options
set incsearch

" Ignore case sensitive when search with lower case and enable it otherwise
set smartcase

" History and undo
set history=1000
set undolevels=1000

" Show 79 line
highlight ColorColumn ctermbg=gray
set colorcolumn=79

" Do not fold files
set nofoldenable

" Optimize redrawing
set lazyredraw
set ttyfast

" Show title
set title

" Turn the spell check on by default. Use underline as indicator.
set spell
hi clear SpellBad
hi SpellBad guisp=blue gui=underline guifg=NONE guibg=NONE cterm=underline ctermbg=NONE ctermfg=NONE term=underline

set notimeout
set nottimeout

" Start scrolling new content before cursor hit top or bottom
set scrolloff=5

" Show trailing spaces and tabs
set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.

" Visual autocomplete for command menu
set wildmenu
set wildmode=longest:full,full
set completeopt=longest,menuone

" <F12> to toggle between :paste and :nopaste
set pastetoggle=<F12>

" Make Cyrillic usable
set langmap+=чявертъуиопшщасдфгхйклзьцжбнмЧЯВЕРТЪУИОПШЩАСДФГХЙКЛЗѝЦЖБНМ;`qwertyuiop[]asdfghjklzxcvbnm~QWERTYUIOP{}ASDFGHJKLZXCVBNM,ю\\,Ю\|,

set backspace=indent,eol,start

" Set split direction
set splitright

" Leader definition
let mapleader = "`"

" Save buffer changes with sudo even if it was opened without sudo
cmap w!! w !sudo tee > /dev/null %
cmap W!! w !sudo tee > /dev/null %

" Comment mapping
noremap <silent> <C-c> :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
noremap <silent> <C-x> :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>

" Open close nerdtree
noremap <Tab> :NERDTreeToggle<CR>

" Save files
nnoremap <leader>ww :w<CR>

" Save and exit
nnoremap <leader>wq :wq<CR>

" Exit without save
nnoremap <silent> <leader>qq :q!<CR>

" Easy error nagivation
nnoremap <leader>oo :copen<CR>
nnoremap <leader>jj :cclose<CR>
nnoremap <leader>nn :cn<CR>
nnoremap <leader>pp :cp<CR>
nnoremap <leader>cc :cc<CR>

" Easy .vimrc reload
nnoremap <leader>r :so $MYVIMRC<CR>

" FZF mappings
nnoremap <leader>s :Files<CR>

" Ag search word under the cursor
noremap <leader>u :Ag! "<cword>"<cr>

" Easy window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Ignore arrows
" nnoremap <Up> <NOP>
" inoremap <Up> <NOP>
" vnoremap <Up> <NOP>
"
" nnoremap <Down> <NOP>
" inoremap <Down> <NOP>
" vnoremap <Down> <NOP>
"
" nnoremap <Left> <NOP>
" inoremap <Left> <NOP>
" vnoremap <Left> <NOP>
"
" nnoremap <Right> <NOP>
" inoremap <Right> <NOP>
" vnoremap <Right> <NOP>

" Do not show mode status in default status line and use airline one
set noshowmode
