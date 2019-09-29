
if has('vimscript-3')
    scriptversion 3
else
    finish
endif

let g:loaded_coloredit = 1

command! -nargs=0   ColorEdit     :call coloredit#exec()

