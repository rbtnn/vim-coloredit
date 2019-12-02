
if !(has('popupwin') || has('textprop'))
    finish
endif

let g:loaded_coloredit = 1

command! -nargs=0   ColorEdit     :call coloredit#exec()

