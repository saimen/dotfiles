set nocompatible
set encoding=utf-8
set t_Co=16
call pathogen#infect()


" Theme
set background=dark " dark | light "
colorscheme solarized
call togglebg#map("F5")

filetype on
filetype plugin on
filetype indent on


" change buffer from modified buffer without write
set hidden

" looks :-)
set cursorline
set textwidth=80
set colorcolumn=+1
syntax on
set number

set foldmethod=marker
highlight ShowTrailingWhitespace ctermbg=Red guibg=Red

set showmode
set wildmenu


" lightline
let g:lightline = {
	\ 'colorscheme': 'wombat',
	\ 'component': {
		\ 'readonly': '%{&readonly?"\ue0a2":""}',
		\ },
	\ 'separator': {
		\ 'left': "\ue0b0",
		\ 'right': "\ue0b2",
		\ },
	\ 'subseparator': {
		\ 'left': "\ue0b1",
		\ 'right': "\ue0b3",
		\ },
	\ }
" fix spacing in lightline
set laststatus=2

" change directory to directory containing current file
nmap ,cd :lcd %:h

" window movement
noremap <silent> ,j :wincmd j<cr>
noremap <silent> ,k :wincmd k<cr>
noremap <silent> ,h :wincmd h<cr>
noremap <silent> ,l :wincmd l<cr>

" close windows
noremap <silent> ,cj :wincmd j<cr>:close<cr>
noremap <silent> ,ck :wincmd k<cr>:close<cr>
noremap <silent> ,ch :wincmd h<cr>:close<cr>
noremap <silent> ,cl :wincmd l<cr>:close<cr>

" move windows
noremap <silent> ,mj <C-W>J
noremap <silent> ,mk <C-W>K
noremap <silent> ,mh <C-W>H
noremap <silent> ,ml <C-W>L

" search the whole file
set wrapscan

" set slash in windows for shell commands as well
set shellslash

" higher command line
set ch=2

" deactivate beeping
set vb

" map fuzzyfinder
nmap ,f :FufFile<cr>
nmap ,b :FufBuf<cr>
nmap ,t :FufTag<cr>

" Autocommands
if !exists("g:autocommands_loaded")
	let g:autocommands_loaded = 1
	autocmd FileType mail DeleteTrailingWhitespace
	" Change standard indentatoin for neovmi project
	autocmd BufNewFile,BufRead /home/saimen/Development/neovim/* set nowrap tabstop=2 shiftwidth=2 expandtab
	autocmd BufNewFile,BufRead /home/saimen/Development/bosch/* set nowrap tabstop=3 shiftwidth=3 expandtab
	" Activate language detection for LaTeX files
	autocmd FileType tex,latex call DetermineLanguageLatex()
	" VHDL files
	autocmd FileType vhdl set nowrap tabstop=2 shiftwidth=2 expandtab
endif
" make _ word separator in C
"autocmd FileType c set iskeyword-=_

" LaTeX compiling
if !exists("g:latex_command")
	let g:latex_command = "lualatex"
endif

if !exists("g:bibliography_command")
	let g:bibliography_command = "biber"
endif

if !exists("g:latex_output_dir")
	let g:latex_output_dir = "pdf"
endif

if !exists("g:pdf_viewer")
	let g:pdf_viewer = "mupdf"
endif

function! HasBibliography()
	let l:bibfile = system("ls " . shellescape(expand("%:p:h")) . "/" . g:latex_output_dir . "/" . shellescape(expand("%:t:r")) . ".bcf")
	if l:bibfile =~ "No such"
		return 0
	else
		return 1
	endif
endfunction

"function! LatexCompileSilent()
"	l:working_dir = shellescape(expand('%:p:h'))
"	l:absolute_output_dir = l:working_dir . '/' . g:latex_output_dir
"	l:jobname = shellescape(expand('%:t:r'))
"	l:complete_latex_command = '!' . ' ' . g:latex_command . ' ' . '-output-directory=' . l:absolute_output_dir . ' ' . '-jobname=' . l:jobname . ' ' . shellescape(bufname('%'))
"	l:complete_biber_command = '!' . ' ' . g:bibliography_command . ' ' . '--output_directory' . ' ' . l:absolute_output_dir
"	silent !clear
"	silent execute l:complete_latex_command
"	if HasBibliography()
"		silent execute l:complete_biber_command
"		silent execute l:complete_latex_command
"	endif
"endfunction

function! LatexCompileSilent()
	silent !clear
	silent execute '!' g:latex_command '-output-directory=' .shellescape(expand('%:p:h')) . '/' . g:latex_output_dir '-jobname=' . shellescape(expand('%:t:r')) shellescape(bufname('%'))
	if HasBibliography()
		silent execute '!' g:bibliography_command '--output_directory' shellescape(expand('%:p:h')) . '/' . g:latex_output_dir shellescape(expand('%:t:r'))
		silent execute '!' g:latex_command '-output-directory=' .shellescape(expand('%:p:h')) . '/' . g:latex_output_dir '-jobname=' . shellescape(expand('%:t:r')) shellescape(bufname('%'))
	endif
endfunction

"function! LatexCompile()
"	l:working_dir = shellescape(expand("%:p:h"))
"	l:absolute_output_dir = l:working_dir . "/" . g:latex_output_dir
"	l:jobname = shellescape(expand("%:t:r"))
"	l:complete_latex_command = "!" . " " . g:latex_command . " " . "-output-directory=" . l:absolute_output_dir . " " . "-jobname=" . l:jobname . " " . shellescape(bufname("%"))
"	l:complete_biber_command = "!" . " " . g:bibliography_command . " " . "--output_directory" . " " . l:absolute_output_dir
"	silent !clear
"	execute l:complete_latex_command
"	if HasBibliography()
"		execute l:complete_biber_command
"		execute l:complete_latex_command
"	endif
"endfunction

function! LatexCompile()
	silent !clear
	execute '!' g:latex_command '-output-directory=' .shellescape(expand('%:p:h')) . '/' . g:latex_output_dir '-jobname=' . shellescape(expand('%:t:r')) shellescape(bufname('%'))
	if HasBibliography()
		execute '!' g:bibliography_command '--output_directory' shellescape(expand('%:p:h')) . '/' . g:latex_output_dir shellescape(expand('%:t:r'))
		execute '!' g:latex_command '-output-directory=' .shellescape(expand('%:p:h')) . '/' . g:latex_output_dir '-jobname=' . shellescape(expand('%:t:r')) shellescape(bufname('%'))
	endif
endfunction

function! RefreshPDF(pid)
	silent execute "!" "kill -s SIGHUP " . b:pid_of_pdf_viewer
endfunction


function! ShowPDF()
	let l:pdf_viewer_instances = system("pidof" . " " . g:pdf_viewer)
	if !exists('b:pid_of_pdf_viewer') || !(l:pdf_viewer_instances =~ b:pid_of_pdf_viewer)
		silent let b:pid_of_pdf_viewer = system(g:pdf_viewer . " \"" . expand("%:p:h") . "/pdf/" . expand("%:r") . ".pdf\" & LE_PID=$! ; echo $LE_PID" )
	else
		call RefreshPDF(b:pid_of_pdf_viewer)
	endif
endfunction

function! LatexCompileAndShow()
	call LatexCompileSilent()
	call ShowPDF()
endfunction

function! DetermineLanguageLatex()
	let language_line = "language_unknown"
	for line in readfile(expand("%"))
		if line =~ '\\usepackage\[[a-z]*\]{babel}'"|documentclass\[[a-z]*\]{*})'
			let language_line = line
		endif
	endfor
	let tmp_lang_string = strpart(language_line, strlen("\usepackage[")+1)
	let language_string = strpart(tmp_lang_string, 0, stridx(tmp_lang_string, ']'))

	let languages = {
			\ 'spanish': 'es',
			\ 'english': 'en',
			\ 'american': 'en_us',
			\ 'ngerman': 'de',
			\ 'german': 'de',
			\ }

	echo language_string

	let &l:spelllang=get(languages, language_string)
"	setlocal spelllang=language
	setlocal spell
endfunction

nnoremap ,Lc :call LatexCompile()<cr>
nnoremap ,S :call ShowPDF()<cr>
nnoremap <silent> ,L :call LatexCompileAndShow()<cr>
let g:ycm_allow_changing_updatetime = 0
