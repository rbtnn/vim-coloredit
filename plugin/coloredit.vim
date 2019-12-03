
let s:flag = v:false

if has('gui_running')
    let s:flag = v:true
elseif has('termguicolors')
    if &termguicolors
        let s:flag = v:true
    endif
endif

if !((has('popupwin') || has('textprop')) && s:flag)
    finish
endif

let g:loaded_coloredit = 1

command! -nargs=0   ColorEdit     :call coloredit#exec()

