
if has('vimscript-3')
    scriptversion 3
else
    finish
endif

let s:pluginname = 'ColorEdit'
let s:delimiter = '|'
let s:info = 0

function! s:hash_rbg() abort
    let cs = split(getline('.'), '\zs')
    let i = col('.') - 1
    let s = i
    let e = i
    let target = ''
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
        let target = join(cs[(s):(e)], '')
    endif
    let regex = '^#\([a-fA-F0-9][a-fA-F0-9]\)\([a-fA-F0-9][a-fA-F0-9]\)\([a-fA-F0-9][a-fA-F0-9]\)$'
    let m = matchlist(target, regex)
    if !empty(m)
        return {
                \ 'type' : 'hash_rgb',
                \ 'position' : [s, e],
                \ 'red' : str2nr(m[1], 16),
                \ 'green' : str2nr(m[2], 16),
                \ 'blue' : str2nr(m[3], 16),
                \ 'alpha' : '',
                \ }
    else
        return {}
    endif
endfunction

function! s:paren_rbg() abort
    let cs = split(getline('.'), '\zs')
    let i = col('.') - 1
    let s = i
    let e = i
    let target = ''
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
    let target = join(cs[(s):(e)], '')
    let regex = '^[rR][gG][bB](\s*\([0-9]\+\)\s*,\s*\([0-9]\+\)\s*,\s*\([0-9]\+\)\s*)$'
    let m = matchlist(target, regex)
    if !empty(m)
        return {
                \ 'type' : 'paren_rgb',
                \ 'position' : [s, e],
                \ 'red' : str2nr(m[1], 10),
                \ 'green' : str2nr(m[2], 10),
                \ 'blue' : str2nr(m[3], 10),
                \ 'alpha' : '',
                \ }
    else
        return {}
    endif
endfunction

function! s:paren_rbga() abort
    let cs = split(getline('.'), '\zs')
    let i = col('.') - 1
    let s = i
    let e = i
    let target = ''
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
    let target = join(cs[(s):(e)], '')
    let regex = '^[rR][gG][bB][aA](\s*\([0-9]\+\)\s*,\s*\([0-9]\+\)\s*,\s*\([0-9]\+\)\s*,\s*\([0-9.]\+\)\s*)$'
    let m = matchlist(target, regex)
    if !empty(m)
        return {
                \ 'type' : 'paren_rgba',
                \ 'position' : [s, e],
                \ 'red' : str2nr(m[1], 10),
                \ 'green' : str2nr(m[2], 10),
                \ 'blue' : str2nr(m[3], 10),
                \ 'alpha' : m[4],
                \ }
    else
        return {}
    endif
endfunction

function! coloredit#exec() abort
    let info = s:hash_rbg()
    if empty(info)
        let info = s:paren_rbg()
    endif
    if empty(info)
        let info = s:paren_rbga()
    endif
    if !empty(info)
        let s:info = info
        let winid = popup_menu(
                \ [
                \   repeat('X', len(s:makeline('_', 0))),
                \   s:makeline('R', info.red),
                \   s:makeline('G', info.green),
                \   s:makeline('B', info.blue),
                \ ] + (empty(info.alpha) ? [] : [(s:makeline('A', info.alpha))]), {
                \   'title' : s:pluginname,
                \   'pos' : 'center',
                \   'close' : 'button',
                \   'filter' : 'coloredit#filter',
                \   'callback' : 'coloredit#callback',
                \ })
        call coloredit#set_color_on_firstline(winid)
        call win_execute(winid, printf('call setpos(".", [0, %d, 1, 0])', 2))
        call win_execute(winid, 'setfiletype coloredit')
    else
        echohl Error
        echo printf('[%s] please position the cursor on "#rrggbb", "rbg(rr,gg,bb)" or "rbga(rr,gg,bb,aa)"', s:pluginname)
        echohl None
    endif
endfunction

function! coloredit#generate_hash_rbg(winid) abort
    let bnr = winbufnr(a:winid)
    let lines = getbufline(bnr, 1, '$')
    return printf('#%02x%02x%02x',
            \ str2nr(split(lines[1], s:delimiter)[1]),
            \ str2nr(split(lines[2], s:delimiter)[1]),
            \ str2nr(split(lines[3], s:delimiter)[1]))
endfunction

function! coloredit#generate_paren_rbg(winid) abort
    let bnr = winbufnr(a:winid)
    let lines = getbufline(bnr, 1, '$')
    return printf('rgb(%d, %d, %d)',
            \ str2nr(split(lines[1], s:delimiter)[1]),
            \ str2nr(split(lines[2], s:delimiter)[1]),
            \ str2nr(split(lines[3], s:delimiter)[1]))
endfunction

function! coloredit#generate_paren_rbga(winid) abort
    let bnr = winbufnr(a:winid)
    let lines = getbufline(bnr, 1, '$')
    return printf('rgba(%d, %d, %d, %s)',
            \ str2nr(split(lines[1], s:delimiter)[1]),
            \ str2nr(split(lines[2], s:delimiter)[1]),
            \ str2nr(split(lines[3], s:delimiter)[1]),
            \ split(lines[4], s:delimiter)[1])
endfunction

function! coloredit#set_color_on_firstline(winid) abort
    let rbg = coloredit#generate_hash_rbg(a:winid)
    call win_execute(a:winid, printf('highlight! %sFirstLine guifg=%s guibg=%s', s:pluginname, rbg, rbg))
endfunction

function! coloredit#callback(winid, key) abort
    if -1 != a:key
        let cs = split(getline('.'), '\zs')
        if s:info.type == 'hash_rgb'
            let rgb_cs = split(coloredit#generate_hash_rbg(a:winid), '\zs')
        elseif s:info.type == 'paren_rgb'
            let rgb_cs = split(coloredit#generate_paren_rbg(a:winid), '\zs')
        elseif s:info.type == 'paren_rgba'
            let rgb_cs = split(coloredit#generate_paren_rbga(a:winid), '\zs')
        else
            return
        endif
        let head = (0 < s:info.position[0]) ? cs[:(s:info.position[0] - 1)] : []
        let tail = cs[(s:info.position[1] + 1):]
        let cs = head + rgb_cs + tail
        call setline('.', join(cs, ''))
    else
        echohl Error
        echo printf('[%s] cancel', s:pluginname)
        echohl None
    endif
endfunction

function! coloredit#filter(winid, key) abort
    let bnr = winbufnr(a:winid)
    let lnum = getbufvar(bnr, 'lnum', 2)
    let lines = getbufline(bnr, 1, '$')
    if a:key == 'j'
        let lnum += 1
        if (1 < lnum) && (lnum <= 4)
            call setbufvar(bnr, 'lnum', lnum)
        else
            return 1
        endif
    endif
    if a:key == 'k'
        let lnum -= 1
        if (1 < lnum) && (lnum <= 4)
            call setbufvar(bnr, 'lnum', lnum)
        else
            return 1
        endif
    endif
    if (a:key == 'h') && (1 < lnum) && (lnum <= 4)
        let xs = split(lines[lnum - 1], s:delimiter)
        let n = str2nr(xs[1]) - 1
        if n < 0x00
            let n = 0x00
        endif
        call s:setline(bnr, lnum, xs, n)
        call coloredit#set_color_on_firstline(a:winid)
        return 1
    endif
    if (a:key == 'l') && (1 < lnum) && (lnum <= 4)
        let xs = split(lines[lnum - 1], s:delimiter)
        let n = str2nr(xs[1]) + 1
        if 0xff < n
            let n = 0xff
        endif
        call s:setline(bnr, lnum, xs, n)
        call coloredit#set_color_on_firstline(a:winid)
        return 1
    endif
    return popup_filter_menu(a:winid, a:key)
endfunction

function! s:makeline(x, n) abort
    let n = a:n
    if a:x == 'A'
        return printf('%s%s%s', a:x, s:delimiter, n)
    else
        if n < 0
            let n = 0
        endif
        if 255 < n
            let n = 255
        endif
        return printf('%s%s%3d%s%-25s', a:x, s:delimiter, n, s:delimiter, repeat('=', n / 10))
    endif
endfunction

function! s:setline(bnr, lnum, xs, n) abort
    call setbufline(a:bnr, a:lnum, s:makeline(a:xs[0], a:n))
endfunction

