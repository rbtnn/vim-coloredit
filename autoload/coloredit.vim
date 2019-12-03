
let s:pluginname = 'ColorEdit'
let s:delimiter = '|'
let s:info = 0

function! coloredit#enabled() abort
    let flag = v:false
    if has('gui_running')
        let flag = v:true
    elseif has('termguicolors')
        if &termguicolors
            let flag = v:true
        endif
    endif
    return (has('popupwin') || has('textprop')) && flag
endfunction

function! coloredit#exec() abort
    if coloredit#enabled()
        let info = coloredit#parser#hash_rgb()
        if empty(info)
            let info = coloredit#parser#paren_rgb()
        endif
        if empty(info)
            let info = coloredit#parser#paren_rgba()
        endif
        if empty(info)
            let info = coloredit#parser#paren_hsl()
        endif
        if empty(info)
            let info = coloredit#parser#paren_hsla()
        endif
        if !empty(info)
            let options = {
                \   'pos' : 'center',
                \   'filter' : 'coloredit#filter',
                \   'callback' : 'coloredit#callback',
                \ }
            let lines = [repeat('X', len(s:makeline_rgb('_', 0)))]
            if (info.type == 'paren_hsl') || (info.type == 'paren_hsla')
                let lines += [
                    \   s:makeline_hsl('H', info.hue),
                    \   s:makeline_hsl('S', info.saturation),
                    \   s:makeline_hsl('L', info.lightness),
                    \ ]
            else
                let lines += [
                    \   s:makeline_rgb('R', info.red),
                    \   s:makeline_rgb('G', info.green),
                    \   s:makeline_rgb('B', info.blue),
                    \ ]
            endif
            let lines += (empty(info.alpha) ? [''] : [(s:makeline_alpha('A', info.alpha))])
            let winid = popup_menu(lines, options)
            if (info.type == 'paren_hsl') || (info.type == 'paren_hsla')
                call coloredit#set_color_on_firstline_hsl(winid)
            else
                call coloredit#set_color_on_firstline_rgb(winid)
            endif
            call win_execute(winid, printf('call setpos(".", [0, %d, 1, 0])', 2))
            call win_execute(winid, 'setfiletype coloredit')
            let s:info = info
        else
            echohl Error
            echo printf('[%s] please position the cursor on RGB or HSL', s:pluginname)
            echohl None
        endif
    else
        echohl Error
        echo printf('[%s] does not support your vim', s:pluginname)
        echohl None
    endif
endfunction

function! s:get_3or4values(winid) abort
    let lines = getbufline(winbufnr(a:winid), 1, '$')
    let xs = [
        \ str2nr(get(split(lines[1], s:delimiter), 1, '0')),
        \ str2nr(get(split(lines[2], s:delimiter), 1, '0')),
        \ str2nr(get(split(lines[3], s:delimiter), 1, '0'))
        \ ]
    if 4 < len(lines)
        let alpha = split(lines[4], s:delimiter)
        if get(alpha, 0, '') == 'A'
            let xs += [get(alpha, 1, '0')]
        endif
    endif
    return xs
endfunction

function! coloredit#generate_hash_rgb(winid) abort
    return call('printf', ['#%02x%02x%02x'] + s:get_3or4values(a:winid)[:2])
endfunction

function! coloredit#generate_paren_rgb(winid) abort
    return call('printf', ['rgb(%d, %d, %d)'] + s:get_3or4values(a:winid)[:2])
endfunction

function! coloredit#generate_paren_rgba(winid) abort
    return call('printf', ['rgba(%d, %d, %d, %s)'] + s:get_3or4values(a:winid))
endfunction

function! coloredit#generate_paren_hsl(winid) abort
    return call('printf', ['hsl(%d, %d%%, %d%%)'] + s:get_3or4values(a:winid)[:2])
endfunction

function! coloredit#generate_paren_hsla(winid) abort
    return call('printf', ['hsla(%d, %d%%, %d%%, %s)'] + s:get_3or4values(a:winid))
endfunction

function! coloredit#generate_hash_rgb_from_hsl(winid) abort
    return call ('printf', ['#%02x%02x%02x'] + call('coloredit#converter#hsl2rgb', s:get_3or4values(a:winid)[:2]))
endfunction

function! coloredit#set_color_on_firstline_rgb(winid) abort
    let rgb = coloredit#generate_hash_rgb(a:winid)
    call win_execute(a:winid, printf('highlight! %sFirstLine guifg=%s guibg=%s', s:pluginname, rgb, rgb))
endfunction

function! coloredit#set_color_on_firstline_hsl(winid) abort
    let rgb = coloredit#generate_hash_rgb_from_hsl(a:winid)
    call win_execute(a:winid, printf('highlight! %sFirstLine guifg=%s guibg=%s', s:pluginname, rgb, rgb))
endfunction

function! coloredit#callback(winid, key) abort
    if -1 != a:key
        if s:info.type == 'hash_rgb'
            call setline('.', s:info.head .. coloredit#generate_hash_rgb(a:winid) .. s:info.tail)
        elseif s:info.type == 'paren_rgb'
            call setline('.', s:info.head .. coloredit#generate_paren_rgb(a:winid) .. s:info.tail)
        elseif s:info.type == 'paren_rgba'
            call setline('.', s:info.head .. coloredit#generate_paren_rgba(a:winid) .. s:info.tail)
        elseif s:info.type == 'paren_hsl'
            call setline('.', s:info.head .. coloredit#generate_paren_hsl(a:winid) .. s:info.tail)
        elseif s:info.type == 'paren_hsla'
            call setline('.', s:info.head .. coloredit#generate_paren_hsla(a:winid) .. s:info.tail)
        endif
    else
        echohl Error
        echo printf('[%s] cancel', s:pluginname)
        echohl None
    endif
endfunction

function! coloredit#filter(winid, key) abort
    call win_execute(a:winid, 'let w:lnum = line(".")')
    let lnum = getwinvar(a:winid, 'lnum', 2)
    let bnr = winbufnr(a:winid)
    let lines = getbufline(bnr, 1, '$')
    let is_rbg = lines[1][0] == 'R'
    if a:key == 'j'
        let lnum += 1
        if (1 < lnum) && (lnum <= 4)
            call setwinvar(a:winid, 'lnum', lnum)
        elseif lnum == 5
            let lnum += 1
            call win_execute(a:winid, printf('call setpos(".", [0, %d, 1, 0])', lnum))
            call setwinvar(a:winid, 'lnum', lnum)
            return 1
        else
            return 1
        endif
    endif
    if a:key == 'k'
        let lnum -= 1
        if (1 < lnum) && (lnum <= 4)
            call setwinvar(a:winid, 'lnum', lnum)
        elseif lnum == 5
            let lnum -= 1
            call win_execute(a:winid, printf('call setpos(".", [0, %d, 1, 0])', lnum))
            call setwinvar(a:winid, 'lnum', lnum)
            return 1
        else
            return 1
        endif
    endif
    if (a:key == 'h') && (1 < lnum) && (lnum <= 4)
        let xs = split(lines[lnum - 1], s:delimiter)
        let n = str2nr(xs[1]) - 1
        if is_rbg
            call s:setline_rgb(bnr, lnum, xs, n)
            call coloredit#set_color_on_firstline_rgb(a:winid)
        else
            call s:setline_hsl(bnr, lnum, xs, n)
            call coloredit#set_color_on_firstline_hsl(a:winid)
        endif
        return 1
    endif
    if (a:key == 'l') && (1 < lnum) && (lnum <= 4)
        let xs = split(lines[lnum - 1], s:delimiter)
        let n = str2nr(xs[1]) + 1
        if is_rbg
            call s:setline_rgb(bnr, lnum, xs, n)
            call coloredit#set_color_on_firstline_rgb(a:winid)
        else
            call s:setline_hsl(bnr, lnum, xs, n)
            call coloredit#set_color_on_firstline_hsl(a:winid)
        endif
        return 1
    endif
    return popup_filter_menu(a:winid, a:key)
endfunction

function! s:makeline_rgb(x, n) abort
    let n = a:n
    if n < 0
        let n = 0
    endif
    if 255 < n
        let n = 255
    endif
    return printf('%s%s%3d%s%-25s', a:x, s:delimiter, n, s:delimiter, repeat('=', n / 10))
endfunction

function! s:makeline_hsl(x, n) abort
    let n = a:n
    if n < 0
        let n = 0
    endif
    if a:x == 'H'
        if 360 < n
            let n = 360
        endif
        return printf('%s%s%3d%s%-25s', a:x, s:delimiter, n, s:delimiter, repeat('=', (n * 255 / 360 / 10)))
    else
        if 100 < n
            let n = 100
        endif
        return printf('%s%s%3d%s%-25s', a:x, s:delimiter, n, s:delimiter, repeat('=', (n * 255 / 100 / 10)))
    endif
endfunction

function! s:makeline_alpha(x, n) abort
    let n = a:n
    return printf('%s%s%s', a:x, s:delimiter, n)
endfunction

function! s:setline_rgb(bnr, lnum, xs, n) abort
    call setbufline(a:bnr, a:lnum, s:makeline_rgb(a:xs[0], a:n))
endfunction

function! s:setline_hsl(bnr, lnum, xs, n) abort
    call setbufline(a:bnr, a:lnum, s:makeline_hsl(a:xs[0], a:n))
endfunction


