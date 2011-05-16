" Pathogen setup (python)
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

"Folding
set foldmethod=indent
set foldlevel=99

" Window movements
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h

"Tasklists \td
map <leader>td <Plug>TaskList

"Revision history \g
map <leader>g :GundoToggle<CR>

"Syntax highlighting and validation
syntax on
filetype on
filetype plugin indent on

let g:pyflakes_use_quickfix = 0

"PEP8 code consistency \8
let g:pep8_map='<leader>8'

"Python tab completion
au FileType python set omnifunc=pythoncomplete#Complete
let g:SuperTabDefaultCompletionType = "context"
set completeopt=menuone,longest,preview
			
"Python refactoring
map <leader>j :RopeGotoDefinition<CR>
map <leader>r :RopeRename<CR>

" ex command for toggling hex mode - define mapping if desired
command -bar Hexmode call ToggleHex()

" helper function to toggle hex mode
function ToggleHex()
  " hex mode should be considered a read-only operation
  " save values for modified and read-only for restoration later,
  " and clear the read-only flag for now
  let l:modified=&mod
  let l:oldreadonly=&readonly
  let &readonly=0
  let l:oldmodifiable=&modifiable
  let &modifiable=1
  if !exists("b:editHex") || !b:editHex
    " save old options
    let b:oldft=&ft
    let b:oldbin=&bin
    " set new options
    setlocal binary " make sure it overrides any textwidth, etc.
    let &ft="xxd"
    " set status
    let b:editHex=1
    " switch to hex editor
    %!xxd
  else
    " restore old options
    let &ft=b:oldft
    if !b:oldbin
      setlocal nobinary
    endif
    " set status
    let b:editHex=0
    " return to normal editing
    %!xxd -r
  endif
  " restore values for modified and read only state
  let &mod=l:modified
  let &readonly=l:oldreadonly
  let &modifiable=l:oldmodifiable
endfunction

filetype plugin indent on
set nu
"set spell
"set cursorline
"set mouse=a
set ruler
set incsearch
set laststatus=2
set scrolloff=10

if has("gui_running")
  set guifont=Mensch\ 10
  colorscheme darkblue
endif

function! CurDir()
    let curdir = substitute(getcwd(), '/Users/mozes', "~/", "g")
    let curdir = substitute(curdir, '/homes/mozes', "~/", "g")
    return curdir
endfunction

function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    else
        return ''
    endif
endfunction
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{CurDir()}%h\ \ \ Line:\ %l/%L:%c

if !exists("autocommands_loaded")
    let autocommands_loaded = 1
    autocmd BufRead,BufNewFile,FileReadPost *.py source ~/.vim/python
endif

" This beauty remembers where you were the last time you edited the file, and returns to the same position.
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif
autocmd BufRead *.py inoremap # X<c-h>#
let python_highlight_all = 1
