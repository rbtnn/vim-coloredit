
if has('vimscript-3')
    scriptversion 3
else
    finish
endif

let s:pluginname = 'ColorEdit'
let s:delimiter = '|'
let s:start_position = 0

function! coloredit#exec() abort
    let cs = split(getline('.'), '\zs')
    let i = col('.') - 1
    let s = i
    let e = i
    let hash_rgb = ''
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
        let hash_rgb = join(cs[(s):(e)], '')
    endif
    if hash_rgb =~# '^#[a-fA-F0-9]\{6,6\}$'
        let s:start_position = s
        let r = str2nr(hash_rgb[1:2], 16)
        let g = str2nr(hash_rgb[3:4], 16)
        let b = str2nr(hash_rgb[5:6], 16)
        let winid = popup_menu(
                \ [
                \   repeat('X', len(s:makeline('_', 0))),
                \   s:makeline('R', r),
                \   s:makeline('G', g),
                \   s:makeline('B', b),
                \ ], {
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
        echo printf('[%s] please position the cursor on "#rrggbb"', s:pluginname)
        echohl None
    endif
endfunction

function! coloredit#generate_rbg(winid) abort
    let bnr = winbufnr(a:winid)
    let lines = getbufline(bnr, 1, '$')
    return printf('#%02x%02x%02x',
            \ str2nr(split(lines[1], s:delimiter)[1]),
            \ str2nr(split(lines[2], s:delimiter)[1]),
            \ str2nr(split(lines[3], s:delimiter)[1]))
endfunction

function! coloredit#set_color_on_firstline(winid) abort
    let rbg = coloredit#generate_rbg(a:winid)
    call win_execute(a:winid, printf('highlight! %sFirstLine guifg=%s guibg=%s', s:pluginname, rbg, rbg))
endfunction

function! coloredit#callback(winid, key) abort
    if -1 != a:key
        let cs = split(getline('.'), '\zs')
        let rgb_cs = split(coloredit#generate_rbg(a:winid), '\zs')
        for i in range(0, len(rgb_cs) - 1)
            let cs[(s:start_position + i)] = rgb_cs[i]
        endfor
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
    return printf('%s%s%3d%s%-25s', a:x, s:delimiter, a:n, s:delimiter, repeat('=', a:n / 10))
endfunction

function! s:setline(bnr, lnum, xs, n) abort
    call setbufline(a:bnr, a:lnum, s:makeline(a:xs[0], a:n))
endfunction

