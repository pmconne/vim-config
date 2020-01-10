" -- Plugins (vundle) {{{

" Set up Vundle
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

" List plugins
Plugin 'pmconne/vim-repositories'
Plugin 'pmconne/vim-bufclean'
Plugin 'pmconne/vim-bsiheaders'
Plugin 'pmconne/vim-autodoc'
Plugin 'tpope/vim-jdaddy'
Plugin 'vim-airline/vim-airline'

" Finish setting up Vundle

call vundle#end()
filetype plugin indent on

" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ

" }}}

" -- General config {{{
set nocompatible
source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin

let typeScriptMode = !empty($VimTypeScript)

" if (typeScriptMode)
"   set ffs="unix,dos"
" else
"   set ffs="dos,unix"
" endif

filetype on

" Try to disable bold fonts in syntax highlighting
if !has('gui_running')
    set t_Co=8 t_md=
endif

syntax enable
syntax on
let mapleader = "\\"
set showcmd
set timeoutlen=1000

" wildmenu - allows e.g. ':b <TAB>' bringing up list of open buffers
set wildmenu
set wildignore=*.orig,*.swp

" path
" execute "cd ".$SrcRoot
execute "set path+=".$SrcRoot.'\**'

"Turn off the infernal beeping. It is not an error to press ESC while already
"in normal mode, so please. shut. up.
set noeb vb t_vb=

"Make the pwd always match the location of the file being edited
" set autochdir <- can break plugins?
autocmd! BufEnter * silent! lcd %:p:h

"Make it switch to location of first file opened
set browsedir=buffer

set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar

:set grepprg=grep\ -n\ --exclude-dir=*node_modules*\ --exclude-dir=lib\ --exclude-dir=api\ --exclude-dir=temp

" -- }}}

" -- Case-sensitivity {{{
" ignore case for tags and searching (unless \c supplied)
set ignorecase
" if search text contains any uppercase characters, it's case sensitive
set smartcase

" -- }}}

" -- Diff {{{
set diffexpr=MyDiff()
function! MyDiff()
    let opt = '-a --binary '
    if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
    if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
    let arg1 = v:fname_in
    if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
    let arg2 = v:fname_new
    if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
    let arg3 = v:fname_out
    if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
    let eq = ''
    if $VIMRUNTIME =~ ' '
        if &sh =~ '\<cmd'
            let cmd = '""' . $VIMRUNTIME . '\diff"'
            let eq = '"'
        else
            let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
        endif
    else
        let cmd = $VIMRUNTIME . '\diff'
    endif
    silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
endfunction
" -- }}}

" -- Hilite trailing whitespace {{{

" from https://vim.fandom.com/wiki/Highlight_unwanted_spaces
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" -- }}}

" -- Color and font {{{

" I use a batch script to build in the shell and then open gvim for quickfix
" when build completes. It is useful to use different colors/fonts in this
" mode to differentiate from normal editing window.
" If VimQuickFix is defined we are in quickfix mode.
let isQuickFix = exists("g:quickfix_mode")
let colors = $ColorScheme
if !empty(colors)
    if isQuickFix
        let colors .= "qf"
    endif

    execute "colorscheme " . colors
endif

if has("gui_running")
    " remove toolbar
    set guioptions-=T
    let fontSize = 14
    " if isQuickFix
    "     let font="Terminal"
    " else
        " let font="DejaVu_Sans_Mono_for_Powerline"
        " let font="Meslo_LG_L_DZ_for_Powerline"
        " let font="InputMonoNarrow_Light"
        let font="Fantasque_Sans_Mono"
    "endif

    execute "set guifont=" . font . ":h" . fontSize
    let g:airline_powerline_fonts = 1
    set encoding=utf-8

    " maximize window
    set lines=999 columns=999
endif
" -- }}}

" -- Indentation {{{

set autoindent
set expandtab
if (typeScriptMode)
    set shiftwidth=2
    set softtabstop=2
else
    set shiftwidth=4
    set softtabstop=4
  set cinoptions=f1s,{1s,>1s,g-1s,h1s,=1s
endif

" !!>> DgnDb - do not indent braces for structs
function! GetIndentOverride()
    let match = '^\s*\(struct \)\|\(class \)\|\(enum \) .*'
    let prevline = getline (v:lnum - 1)
    if prevline =~ match
        " echom 'overriding indent'
        return indent (v:lnum - 1)
    else
        " echom 'default indent'
        return cindent (v:lnum)
    endif
endfunction

function! SetCppIndent()
    setlocal cinoptions=f1s,{1s,>1s,g-1s,h1s,=1s
    if !empty($DgnDbIndent)
        setlocal indentexpr=GetIndentOverride()
    endif
endfunction

if (!typeScriptMode)
  autocmd FileType cpp call SetCppIndent()
endif

" -- }}}

" -- Search {{{
set hlsearch

" wrap from top<->bottom when searching (who turned this off? defaults to on)
set wrapscan

" magic
" $ eol
" . any single char
" * any number of previous atom
" \(\) grouping into an atom
" \| alternatives e.g. \(a\|b\)
" \a any alphabetic character
" \\ backslash
" \. .
set magic
" -- }}}

" -- NOPs {{{
nnoremap JJJJ <Nop>
" stupid mouse wheel doesn't paste
:map <MiddleMouse> <Nop>
:imap <MiddleMouse> <Nop>
:map <2-MiddleMouse> <Nop>
:imap <2-MiddleMouse> <Nop>
:map <3-MiddleMouse> <Nop>
:imap <3-MiddleMouse> <Nop>
:map <4-MiddleMouse> <Nop>
:imap <4-MiddleMouse> <Nop>
" -- }}}

" -- Avoid swp/~ file clutter in source trees {{{
set backupdir=$VIMRUNTIME\\temp\\
set directory=$VIMRUNTIME\\temp\\
silent execute '!del "'.$VIMRUNTIME.'\temp\*~'
set nobackup
" -- }}}

" -- Persistent Undo {{{
let undopath = $BsiRootDir . 'undo'
execute "set undodir=".undopath
set undofile
set undolevels=1000
set undoreload=10000
" -- }}}

" -- Tags {{{
" TODO: use btags
" let tagpath = $SrcRoot . '\tags'
" execute "set tags=".tagpath

" look for tags specific to current directory (usually repository)
set tags=tags;/

command! -nargs=1 Ta call FindTagInAllRepositories(<f-args>)
cnoreabbrev ta ta<c-\>esubstitute(getcmdline(), '^ta\>', 'Ta', '')<enter>

command! -nargs=+ Tg call FindTagInRepositoryByNumber(<f-args>)
cnoreabbrev tg tg<c-\>esubstitute(getcmdline(), '^tg\>', 'Tg', '')<enter>

" case-insensitive tag search
function! CaseInsensitiveTagJump (arg)
    set ignorecase
    execute 'tj ' . a:arg
    set noignorecase
endfunction

command! -nargs=1 Ti call CaseInsensitiveTagJump(<f-args>)
cnoreabbrev ti ti<c-\>esubstitute(getcmdline(), '^ti\>', 'Ti', '')<enter>

" C-] always jumps to first match. Make it show all matches if more than one
" exists
nnoremap <C-]> g<C-]>

" select entire word and jump to tag (useful for things like
" SomeClass::SomeMethod (args)
" but NEEDSWORK for Class::Method()
nnoremap <C-\> viWg<C-]>


" -- }}}

" -- Repositories {{{

command! -nargs=1 Repo call SetRepository(<f-args>)
cnoreabbrev repo repo<c-\>esubstitute(getcmdline(), '^repo\>', 'Repo', '')<enter>

command! -nargs=0 RepoList call ListRepositories()
cnoreabbrev repolist repolist<c-\>esubstitute(getcmdline(), '^repolist\>', 'RepoList', '')<enter>

" move to next/prev repository
nnoremap - :call IncDecRepository (1)<cr>
nnoremap _ :call IncDecRepository (0)<cr>

" Include all repositories in tags - on or off
command! -nargs=0 Ra call SetIncludeAllRepositories(1)
cnoreabbrev ra ra<c-\>esubstitute(getcmdline(), '^ra', 'Ra', '')<enter>

" Include only current repository in tags
command! -nargs=0 Rr call SetIncludeAllRepositories(0)
cnoreabbrev rr rr<c-\>esubstitute(getcmdline(), '^rr', 'Rr', '')<enter>

" -- }}}

" -- vimrc {{{
" refresh vimrc as soon as it's edited
autocmd! bufwritepost .vimrc source ~/.vim/.vimrc

" quickly edit vimrc
nnoremap <leader>ev :e ~/.vim/.vimrc<cr>
" -- }}}

" -- Navigation shortcuts {{{
" window/tab/buffer nav shortcuts
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-h> <C-W>h
noremap <C-l> <C-W>l
nnoremap gb :ls<CR>:b 

" C-B cannot be reversed by C-F and vice-versa. C-U and C-D can, but are
" farther way from each other.
noremap <C-B> <C-U><C-U>
noremap <C-F> <C-D><C-D>

" { } move by paragraph by default, this is useless for code. Remap to move to
" enclosing bracket
nnoremap { [{
nnoremap } ]}

"Use relative line numbering. Makes jumping between lines much easier
set number
autocmd BufEnter * set relativenumber

" highlight current line
set cursorline

" next/prev edit shortcuts
nnoremap <F12> g;
nnoremap <S-F12> g,

" -- }}}

" -- Editing shortcuts {{{
"Move visually selected lines of text using ALT+[jk]
nnoremap <M-j> mz:m+<cr>`z
nnoremap <M-k> mz:m-2<cr>`z
vnoremap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vnoremap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

" change text inside opposing angle brackets (e.g. xml tag)
" by default ci< and ci> change inside <brackets>
" remapped so ci> changes inside >brackets<
" <leader>ci> changes inside tag spanning multiple lines
nnoremap ci> T>ct<

" change next '.' to '->' and next '->' to '.'
" needs some work - won't work if on first character of line
nnoremap <leader>. bf.xi-><esc>b
nnoremap <leader>> bbf-f>bxxi.<esc>

" split line (inverse of J)
nnoremap S i<cr><esc>

" split line of form code { code }
nnoremap <leader>S ^f{a<cr><esc>la<cr><esc>f}a<cr><esc>

" -- }}}

" -- File system shortcuts {{{
" switch to directory of current buffer
nnoremap <leader>cd :cd %:p:h<cr>
" edit todo
let todofile=$TodoFile
if empty(todofile)
    let todofile="d:\\log\\todo"
endif

execute "nnoremap <leader>todo :e " . todofile . "<cr>"

" switch to src root directory
nnoremap <leader>src :cd $SrcRoot<cr>

" -- }}}

" -- Filetypes {{{

au BufNewFile,BufRead *.xaml        setf xml
au BufNewFile,BufRead *.fdf         setf cpp
au BufNewFile,BufRead *.html        setf xml
au BufNewFile,BufRead *.cshtml      setf html
au BufNewFile,BufRead *.ts,*.tsx    setlocal filetype=typescript

" -- }}}

" -- Make and QuickFix {{{
" Note I generally use a batch script from the shell to build, which will open
" quickfix in vim if errors occur, rather than building from VIM
set makeprg=bb\ $*

if (typeScriptMode)
  set errorformat=%f(%l\\\,%c):\ error\ TS%n:\ %m
else
  " C++ errors and warnings (MSVC)
  set errorformat=%f(%l)\ :\ error\ %t%n:\ %m
  set errorformat+=%f(%l)\ :\ warning\ %t%n:\ %m
  set errorformat+=%f(%l):\ error\ %t%n:\ %m

  " Uncomment the following for C++ errors and warnings (GCC)
  " set errorformat+=%f:%l:\ %m

  " C# errors
  set errorformat+=%f(%l\\\,%c):\ %m

  " grep (:cfile uses errorformat instead of grepformat for some reason)
  " set errorformat+=%f:%m
endif

autocmd QuickFixCmdPost [^l]* nested cwindow
autocmd QuickFixCmdPost    l* nested lwindow

" next/prev error
nnoremap <F1> :cn<cr><zz>
nnoremap <S-F1> :cp<cr><zz>

" open/close quickfix window
nnoremap <F2> :copen<cr>
nnoremap <S-F2> :cclose<cr>

" next/prev error file
nnoremap <F3> :cnfile<cr><zz>
nnoremap <S-F3> :cpfile<cr><zz>

" first/last error
nnoremap <F4> :crewind<cr>
nnoremap <S-F4> :clast<cr>

" list all errors
nnoremap <F5> :clist<cr>
" -- }}}

" -- Folds {{{
set foldmethod=marker

" Create a vim fold and position to insert fold label
" TODO: make the comment character based on filetype.
nnoremap <leader>f o<cr># -- }}}<esc>o<esc>xkkO# --  {{{<esc>hhhi
" -- }}}

" -- Todo lists {{{

" Toggle [X] <-> [ ]
" nnoremap <F12> V:s/\[ \]/__ON__<CR>V:s/\[X\]/__OFF__<CR>V:s/__ON__/\[X\]<CR>:s/__OFF__/\[ \]<CR>

" -- }}}

" -- Remove Trailing Whitespace {{{

nnoremap <leader>rtw :%s/\s\+$//<cr>

" -- }}}

" -- Fix stupid line endings produced by bb {{{

nnoremap <leader>rle :%s/\r//g<cr>

" -- }}}

" -- Quickly format XML {{{

nnoremap <leader>xml :%s/></>\r</g<cr>G=gg

" -- }}}

" -- [PLUGINS] {{{

"  -- AutoDoc {{{

" Paste documentation skeleton for function on current line above current
" line, center horizontally, and begin inserting function description
nnoremap <leader>dm :call InsertAutoDoc()<cr>zzA

" }}}

" -- airline {{{

function! SyntaxItem()
    return synIDattr(synID(line("."),col("."),1),"name")
endfunction

" Make vim show the status line when only 1 window open
set laststatus=2

" Make tabnext/previous easier
nnoremap <cr> :bnext<cr>
nnoremap <s-cr> :bprev<cr>

" show all buffers in tabline
let g:airline#extensions#tabline#enabled = 1

let g:airline_section_c = '%{getcwd()}'
let g:airline_section_b = '%{GetCurrentRepositoryLabel()}'
let g:airline_section_x = '%{SyntaxItem()}'

let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#buffer_nr_format = '%s '
" }}}

" -- BufClean {{{

" allow window to occupy minimal height
set noequalalways

nnoremap <leader>bd :call BufClean()<cr>
" -- }}}

" -- BsiHeaders {{{

" let g:bsi_username="Paul.Connelly"

" if inserting below, open a new line below for insertion
nnoremap <leader>mp :call InsertBsiHeader(0,0)<cr>ko
nnoremap <leader>mP :call InsertBsiHeader(0,1)<cr>
nnoremap <leader>sp :call InsertClassHeader(0,0)<cr>O<esc>cc
nnoremap <leader>sP :call InsertClassHeader(1,0)<cr>
nnoremap <leader>Sp :call InsertClassHeader(0,1)<cr>kA
nnoremap <leader>SP :call InsertClassHeader(1,1)<cr>kA

nnoremap <leader>ps :call InsertPublishTag(0,0)<cr>
nnoremap <leader>pS :call InsertPublishTag(0,1)<cr>
nnoremap <leader>pe :call InsertPublishTag(1,0)<cr>
nnoremap <leader>pE :call InsertPublishTag(1,1)<cr>
nnoremap <leader>pv :call InsertPublishVirtualTag(0)<cr>
nnoremap <leader>pV :call InsertPublishVirtualTag(1)<cr>

nnoremap <leader>cp :call InsertCopyrightNotice()<cr>
nnoremap <leader>cP :call InsertCopyrightNotice()<cr>
"  }}}

" -- vscommand.vim {{{
let g:VCSCommandDeleteOnHide=1
noremap <Leader>cll :VCSLog <C-R><C-W><CR>
noremap <Leader>cl :VCSLog -l5<CR>
noremap <Leader>crl :VCSReview <C-R><C-W><CR>
noremap <Leader>cn :VCSAnnotate!<CR>
" -- }}}

" -- Rainbow Parentheses {{{

let g:rainbow_active = empty($NoRainbowParens)

" -- }}}

" -- }}}

" -- Tips {{{
" g; and g, to go to previous/next change in changelist
" gu, gU - to lower/upper case
" ~g - swap case
" ge, gE - backwards versions of e, E
" g0, g$ - first/last screen column of wrapped line

" Text objects:
"   t - matched tags e.g. <tag someAttr="stuff">INNER</tag>
"   {, }, B - matched curly braces

" a motion preceded by 'v' is inclusive.
" Ex: delete from current pos to start of previous word, INCLUDING current
" character (e.g. when at end of line):
"   dvb
"
" Tags:
"   reg-ex tag search:
"     :tj /handle.*event
" -- }}}
