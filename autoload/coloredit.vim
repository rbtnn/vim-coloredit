
if !(has('popupwin') || has('textprop'))
    finish
endif

let s:pluginname = 'ColorEdit'
let s:delimiter = '|'
let s:info = 0

function! s:col2idx(cs, col) abort
    let i = 0
    let total = a:col
    for c in a:cs
        let total -= len(c)
        if 0 < total
            let i += 1
        else
            break
        endif
    endfor
    return i
endfunction

function! s:split3(cs, s, e) abort
    let cs = a:cs
    let s = a:s
    let e = a:e
    let s1 = (0 < a:s) ? join(cs[:(s - 1)], '') : ''
    let s2 = join(cs[(s):(e)], '')
    let s3 = join(cs[(e + 1):], '')
    return [s1, s2, s3]
endfunction

function! s:hash_rgb() abort
    let cs = split(getline('.'), '\zs')
    let i = s:col2idx(cs, col('.'))
    let s = i
    let e = i
    if 0 < len(cs)
        if cs[i] =~# '^[#a-fA-F0-9]$'
            while 0 <= s - 1
                if cs[s - 1] =~# '^[#a-fA-F0-9]$'
                    let s -= 1
                else
                    break
                endif
            endwhile
            while e + 1 < len(cs)
                if cs[e + 1] =~# '^[#a-fA-F0-9]$'
                    let e += 1
                else
                    break
                endif
            endwhile
            let ss = s:split3(cs, s, e)
            let regex = '^#\([a-fA-F0-9][a-fA-F0-9]\)\([a-fA-F0-9][a-fA-F0-9]\)\([a-fA-F0-9][a-fA-F0-9]\)$'
            let m = matchlist(ss[1], regex)
            if !empty(m)
                return {
                    \ 'type' : 'hash_rgb',
                    \ 'ss' : ss,
                    \ 'red' : str2nr(m[1], 16),
                    \ 'green' : str2nr(m[2], 16),
                    \ 'blue' : str2nr(m[3], 16),
                    \ 'alpha' : '',
                    \ }
            endif
        endif
    endif
    return {}
endfunction

function! s:paren_rgb() abort
    let cs = split(getline('.'), '\zs')
    let i = s:col2idx(cs, col('.'))
    let s = i
    let e = i
    if 0 < len(cs)
        while 0 <= s
            if (cs[s] == 'r') || (cs[s] == 'R')
                break
            else
                let s -= 1
            endif
        endwhile
        while e < len(cs)
            if cs[e] == ')'
                break
            else
                let e += 1
            endif
        endwhile
        let ss = s:split3(cs, s, e)
        let regex = '^[rR][gG][bB](\s*\([0-9]\+\)\s*,\s*\([0-9]\+\)\s*,\s*\([0-9]\+\)\s*)$'
        let m = matchlist(ss[1], regex)
        if !empty(m)
            return {
                \ 'type' : 'paren_rgb',
                \ 'ss' : ss,
                \ 'red' : str2nr(m[1], 10),
                \ 'green' : str2nr(m[2], 10),
                \ 'blue' : str2nr(m[3], 10),
                \ 'alpha' : '',
                \ }
        endif
    endif
    return {}
endfunction

function! s:paren_rgba() abort
    let cs = split(getline('.'), '\zs')
    let i = s:col2idx(cs, col('.'))
    let s = i
    let e = i
    if 0 < len(cs)
        while 0 <= s
            if (cs[s] == 'r') || (cs[s] == 'R')
                break
            else
                let s -= 1
            endif
        endwhile
        while e < len(cs)
            if cs[e] == ')'
                break
            else
                let e += 1
            endif
        endwhile
        let ss = s:split3(cs, s, e)
        let regex = '^[rR][gG][bB][aA](\s*\([0-9]\+\)\s*,\s*\([0-9]\+\)\s*,\s*\([0-9]\+\)\s*,\s*\([0-9.]\+\)\s*)$'
        let m = matchlist(ss[1], regex)
        if !empty(m)
            return {
                \ 'type' : 'paren_rgba',
                \ 'ss' : ss,
                \ 'red' : str2nr(m[1], 10),
                \ 'green' : str2nr(m[2], 10),
                \ 'blue' : str2nr(m[3], 10),
                \ 'alpha' : m[4],
                \ }
        endif
    endif
    return {}
endfunction

function! s:paren_hsl() abort
    let cs = split(getline('.'), '\zs')
    let i = s:col2idx(cs, col('.'))
    let s = i
    let e = i
    if 0 < len(cs)
        while 0 <= s
            if (cs[s] == 'h') || (cs[s] == 'H')
                break
            else
                let s -= 1
            endif
        endwhile
        while e < len(cs)
            if cs[e] == ')'
                break
            else
                let e += 1
            endif
        endwhile
        let ss = s:split3(cs, s, e)
        let regex = '^[hH][sS][lL](\s*\([0-9]\+\)\s*,\s*\([0-9]\+\)\s*%,\s*\([0-9]\+\)\s*%)$'
        let m = matchlist(ss[1], regex)
        if !empty(m)
            return {
                \ 'type' : 'paren_hsl',
                \ 'ss' : ss,
                \ 'hue' : str2nr(m[1], 10),
                \ 'saturation' : str2nr(m[2], 10),
                \ 'lightness' : str2nr(m[3], 10),
                \ 'alpha' : '',
                \ }
        endif
    endif
    return {}
endfunction

function! coloredit#exec() abort
    let info = s:hash_rgb()
    if empty(info)
        let info = s:paren_rgb()
    endif
    if empty(info)
        let info = s:paren_rgba()
    endif
    if empty(info)
        let info = s:paren_hsl()
    endif
    if !empty(info)
        let s:info = info
        let options = {
            \   'pos' : 'center',
            \   'filter' : 'coloredit#filter',
            \   'callback' : 'coloredit#callback',
            \ }
        let lines = [repeat('X', len(s:makeline('_', 0)))]
        if s:info.type == 'paren_hsl'
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
            let lines += (empty(info.alpha) ? [''] : [(s:makeline_alpha('A', info.alpha))])
        endif

        let winid = popup_menu(lines, options)
        if s:info.type == 'paren_hsl'
            call coloredit#set_color_on_firstline_hsl(winid)
        else
            call coloredit#set_color_on_firstline_rgb(winid)
        endif
        call win_execute(winid, printf('call setpos(".", [0, %d, 1, 0])', 2))
        call win_execute(winid, 'setfiletype coloredit')
    else
        echohl Error
        echo printf('[%s] please position the cursor on RGB or HSL', s:pluginname)
        echohl None
    endif
endfunction

function! coloredit#generate_hash_rgb(winid) abort
    let bnr = winbufnr(a:winid)
    let lines = getbufline(bnr, 1, '$')
    return printf('#%02x%02x%02x',
        \ str2nr(split(lines[1], s:delimiter)[1]),
        \ str2nr(split(lines[2], s:delimiter)[1]),
        \ str2nr(split(lines[3], s:delimiter)[1]))
endfunction

function! coloredit#generate_paren_rgb(winid) abort
    let bnr = winbufnr(a:winid)
    let lines = getbufline(bnr, 1, '$')
    return printf('rgb(%d, %d, %d)',
        \ str2nr(split(lines[1], s:delimiter)[1]),
        \ str2nr(split(lines[2], s:delimiter)[1]),
        \ str2nr(split(lines[3], s:delimiter)[1]))
endfunction

function! coloredit#generate_paren_rgba(winid) abort
    let bnr = winbufnr(a:winid)
    let lines = getbufline(bnr, 1, '$')
    return printf('rgba(%d, %d, %d, %s)',
        \ str2nr(split(lines[1], s:delimiter)[1]),
        \ str2nr(split(lines[2], s:delimiter)[1]),
        \ str2nr(split(lines[3], s:delimiter)[1]),
        \ split(lines[4], s:delimiter)[1])
endfunction

function! coloredit#generate_paren_hsl(winid) abort
    let bnr = winbufnr(a:winid)
    let lines = getbufline(bnr, 1, '$')
    return printf('hsl(%d, %d%%, %d%%)',
        \ str2nr(split(lines[1], s:delimiter)[1]),
        \ str2nr(split(lines[2], s:delimiter)[1]),
        \ str2nr(split(lines[3], s:delimiter)[1]))
endfunction

function! coloredit#generate_hash_rgb_from_hsl(winid) abort
    let bnr = winbufnr(a:winid)
    let lines = getbufline(bnr, 1, '$')
    let H = str2nr(split(lines[1], s:delimiter)[1])
    let S = str2nr(split(lines[2], s:delimiter)[1])
    let L = str2nr(split(lines[3], s:delimiter)[1])
    let rgb = s:hsl2rgb(H, S, L)
    return printf('#%02x%02x%02x', rgb[0], rgb[1], rgb[2])
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
            call setline('.', s:info.ss[0] .. coloredit#generate_hash_rgb(a:winid) .. s:info.ss[2])
        elseif s:info.type == 'paren_rgb'
            call setline('.', s:info.ss[0] .. coloredit#generate_paren_rgb(a:winid) .. s:info.ss[2])
        elseif s:info.type == 'paren_rgba'
            call setline('.', s:info.ss[0] .. coloredit#generate_paren_rgba(a:winid) .. s:info.ss[2])
        elseif s:info.type == 'paren_hsl'
            call setline('.', s:info.ss[0] .. coloredit#generate_paren_hsl(a:winid) .. s:info.ss[2])
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

function! s:hsl2rgb(H, S, L) abort
    if a:L <= 49
        let max = 2.55 * (a:L + a:L * (1.0 * a:S / 100))
        let min = 2.55 * (a:L - a:L * (1.0 * a:S / 100))
    else
        let max = 2.55 * (a:L + (100 - a:L) * (1.0 * a:S / 100))
        let min = 2.55 * (a:L - (100 - a:L) * (1.0 * a:S / 100))
    endif
    if (0 <= a:H) && (a:H < 60)
        let R = max
        let G = (1.0 * a:H / 60) * (max - min) + min
        let B = min
    elseif (60 <= a:H) && (a:H < 120)
        let R = (1.0 * (120 - a:H) / 60) * (max - min) + min
        let G = max
        let B = min
    elseif (120 <= a:H) && (a:H < 180)
        let R = min
        let G = max
        let B = (1.0 * (a:H - 120) / 60) * (max - min) + min
    elseif (180 <= a:H) && (a:H < 240)
        let R = min
        let G = (1.0 * (240 - a:H) / 60) * (max - min) + min
        let B = max
    elseif (240 <= a:H) && (a:H < 300)
        let R = (1.0 * (a:H - 240) / 60) * (max - min) + min
        let G = min
        let B = max
    elseif (300 <= a:H) && (a:H <= 360)
        let R = max
        let G = min
        let B = (1.0 * (360 - a:H) / 60) * (max - min) + min
    endif
    return map([R, G, B], { i,x -> float2nr(ceil(x)) })
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

"echo s:hsl2rgb(1, 80, 30) == [138, 18, 16]
"echo s:hsl2rgb(61, 80, 30) == [136, 138, 16]
"echo s:hsl2rgb(121, 80, 30) == [16, 138, 18]
"echo s:hsl2rgb(181, 80, 30) == [16, 136, 138]
"echo s:hsl2rgb(241, 80, 30) == [18, 16, 138]
"echo s:hsl2rgb(301, 80, 30) == [138, 16, 136]

