
function! coloredit#parser#hash_rgb() abort
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
                    \ 'head' : ss[0],
                    \ 'tail' : ss[2],
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

function! coloredit#parser#paren_rgb() abort
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
                \ 'head' : ss[0],
                \ 'tail' : ss[2],
                \ 'red' : str2nr(m[1], 10),
                \ 'green' : str2nr(m[2], 10),
                \ 'blue' : str2nr(m[3], 10),
                \ 'alpha' : '',
                \ }
        endif
    endif
    return {}
endfunction

function! coloredit#parser#paren_rgba() abort
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
                \ 'head' : ss[0],
                \ 'tail' : ss[2],
                \ 'red' : str2nr(m[1], 10),
                \ 'green' : str2nr(m[2], 10),
                \ 'blue' : str2nr(m[3], 10),
                \ 'alpha' : m[4],
                \ }
        endif
    endif
    return {}
endfunction

function! coloredit#parser#paren_hsl() abort
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
                \ 'head' : ss[0],
                \ 'tail' : ss[2],
                \ 'hue' : str2nr(m[1], 10),
                \ 'saturation' : str2nr(m[2], 10),
                \ 'lightness' : str2nr(m[3], 10),
                \ 'alpha' : '',
                \ }
        endif
    endif
    return {}
endfunction

function! coloredit#parser#paren_hsla() abort
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
        let regex = '^[hH][sS][lL][aA](\s*\([0-9]\+\)\s*,\s*\([0-9]\+\)\s*%,\s*\([0-9]\+\)\s*%,\s*\([0-9.]\+\)\s*)$'
        let m = matchlist(ss[1], regex)
        if !empty(m)
            return {
                \ 'type' : 'paren_hsla',
                \ 'head' : ss[0],
                \ 'tail' : ss[2],
                \ 'hue' : str2nr(m[1], 10),
                \ 'saturation' : str2nr(m[2], 10),
                \ 'lightness' : str2nr(m[3], 10),
                \ 'alpha' : m[4],
                \ }
        endif
    endif
    return {}
endfunction

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

