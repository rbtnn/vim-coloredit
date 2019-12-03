
function! coloredit#converter#hsl2rgb(H, S, L) abort
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

function! coloredit#converter#rgb2hsl(R, G, B) abort
    let max = max([(a:R), (a:G), (a:B)])
    let min = min([(a:R), (a:G), (a:B)])
    if (a:G < a:R) && (a:B < a:R)
        let H = 60 * (1.0 * (a:G - a:B) / (max - min))
    elseif (a:R < a:G) && (a:B < a:G)
        let H = 60 * (1.0 * (a:B - a:R) / (max - min)) + 120
    elseif (a:R < a:B) && (a:G < a:B)
        let H = 60 * (1.0 * (a:R - a:G) / (max - min)) + 240
    else
        let H = 0
    endif
    if H < 0
        let H = H + 360
    endif
    let cnt = (max + min) / 2
    if 128 <= cnt
        let S = 1.0 * (max - min) / (510 - max - min)
    else
        let S = 1.0 * (max - min) / (max + min)
    endif
    let S *= 100
    let L = 1.0 * (max + min) / 2 / 255
    let L *= 100
    return map([H, S, L], { i,x -> float2nr(ceil(x)) })
endfunction

