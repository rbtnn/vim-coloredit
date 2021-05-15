
let s:TEST_LOG = expand('<sfile>:h:h:gs?\?/?') . '/test.log'

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

" NOTE: https://www.rapidtables.com/convert/color/rgb-to-hsl.html
" This returns HSL float value that up to the first place in the minority.
function! coloredit#converter#rgb2hsl_float(R, G, B) abort
	let max = max([(a:R), (a:G), (a:B)])
	let min = min([(a:R), (a:G), (a:B)])

	" Hue calculation
	if max == min
		let H = 0
	elseif max == a:R
		let H = 60 * (1.0 * (a:G - a:B) / (max - min))
	elseif max == a:G
		let H = 60 * (1.0 * (a:B - a:R) / (max - min)) + 120
	elseif max == a:B
		let H = 60 * (1.0 * (a:R - a:G) / (max - min)) + 240
	else
		let H = 0
	endif
	if H < 0
		let H = H + 360
	endif

	" Saturation calculation
	if max == min
		let S = 0
	else
		if 128 <= (max + min) / 2
			let S = 1.0 * (max - min) / (510 - max - min)
		else
			let S = 1.0 * (max - min) / (max + min)
		endif
		let S *= 100
	endif

	" Lightness calculation
	let L = 1.0 * (max + min) / 2 / 255
	let L *= 100

	return map([H, S, L], { i,x -> floor(x * 10) / 10 })
endfunction

" This returns HSL real number value
function! coloredit#converter#rgb2hsl_nr(R, G, B) abort
	let [H, S, L] = coloredit#converter#rgb2hsl_float(a:R, a:G, a:B)
	return map([H, S, L], { i,x -> float2nr(ceil(x)) })
endfunction

function! coloredit#converter#run_tests() abort
	if filereadable(s:TEST_LOG)
		call delete(s:TEST_LOG)
	endif

	let v:errors = []

	call assert_equal(
		\ [[60, 34, 30], [60.0, 33.3, 30.0]],
		\ [coloredit#converter#rgb2hsl_nr(0x66, 0x66, 0x33),
		\  coloredit#converter#rgb2hsl_float(0x66, 0x66, 0x33)
		\ ])
	call assert_equal(
		\ [[207, 82, 66], [207.0, 81.6, 65.8]],
		\ [coloredit#converter#rgb2hsl_nr(0x61, 0xaf, 0xef),
		\  coloredit#converter#rgb2hsl_float(0x61, 0xaf, 0xef)
		\ ])
	" Black
	call assert_equal(
		\ [[0, 0, 0], [0.0, 0.0, 0.0]],
		\ [coloredit#converter#rgb2hsl_nr(0x00, 0x00, 0x00),
		\ coloredit#converter#rgb2hsl_float(0x00, 0x00, 0x00)
		\ ])
	" White
	call assert_equal(
		\ [[0, 0, 100], [0.0, 0.0, 100.0]],
		\ [coloredit#converter#rgb2hsl_nr(0xff, 0xff, 0xff),
		\  coloredit#converter#rgb2hsl_float(0xff, 0xff, 0xff)
		\ ])
	" Red
	call assert_equal(
		\ [[0, 100, 50], [0.0, 100.0, 50.0]],
		\ [coloredit#converter#rgb2hsl_nr(0xff, 0x00, 0x00),
		\  coloredit#converter#rgb2hsl_float(0xff, 0x00, 0x00)
		\ ])
	" Lime
	call assert_equal(
		\ [[120, 100, 50], [120.0, 100.0, 50.0]],
		\ [coloredit#converter#rgb2hsl_nr(0x00, 0xff, 0x00),
		\  coloredit#converter#rgb2hsl_float(0x00, 0xff, 0x00)
		\ ])
	" Blue
	call assert_equal(
		\ [[240, 100, 50], [240.0, 100.0, 50.0]],
		\ [coloredit#converter#rgb2hsl_nr(0x00, 0x00, 0xff),
		\  coloredit#converter#rgb2hsl_float(0x00, 0x00, 0xff)
		\ ])
	" Yellow
	call assert_equal(
		\ [[60, 100, 50], [60.0, 100.0, 50.0]],
		\ [coloredit#converter#rgb2hsl_nr(0xff, 0xff, 0x00),
		\  coloredit#converter#rgb2hsl_float(0xff, 0xff, 0x00)
		\ ])
	" Cyan
	call assert_equal(
		\ [[180, 100, 50], [180.0, 100.0, 50.0]],
		\ [coloredit#converter#rgb2hsl_nr(0x00, 0xff, 0xff),
		\  coloredit#converter#rgb2hsl_float(0x00, 0xff, 0xff)
		\ ])
	" Magenta
	call assert_equal(
		\ [[300, 100, 50], [300.0, 100.0, 50.0]],
		\ [coloredit#converter#rgb2hsl_nr(0xff, 0x00, 0xff),
		\  coloredit#converter#rgb2hsl_float(0xff, 0x00, 0xff)
		\ ])
	" Silver
	call assert_equal(
		\ [[0, 0, 75], [0.0, 0.0, 74.9]],
		\ [coloredit#converter#rgb2hsl_nr(0xbf, 0xbf, 0xbf),
		\  coloredit#converter#rgb2hsl_float(0xbf, 0xbf, 0xbf)
		\ ])
	" Gray
	call assert_equal(
		\ [[0, 0, 51], [0.0, 0.0, 50.1]],
		\ [coloredit#converter#rgb2hsl_nr(0x80, 0x80, 0x80),
		\  coloredit#converter#rgb2hsl_float(0x80, 0x80, 0x80)
		\ ])
	" Maroon
	call assert_equal(
		\ [[0, 100, 25], [0.0, 100.0, 25.0]],
		\ [coloredit#converter#rgb2hsl_nr(0x80, 0x00, 0x00),
		\  coloredit#converter#rgb2hsl_float(0x80, 0x00, 0x00)
		\ ])
	" Olive
	call assert_equal(
		\ [[60, 100, 25], [60.0, 100.0, 25.0]],
		\ [coloredit#converter#rgb2hsl_nr(0x80, 0x80, 0x00),
		\  coloredit#converter#rgb2hsl_float(0x80, 0x80, 0x00)
		\ ])
	" Green
	call assert_equal(
		\ [[120, 100, 25], [120.0, 100.0, 25.0]],
		\ [coloredit#converter#rgb2hsl_nr(0x00, 0x80, 0x00),
		\  coloredit#converter#rgb2hsl_float(0x00, 0x80, 0x00)
		\ ])
	" Purple
	call assert_equal(
		\ [[300, 100, 25], [300.0, 100.0, 25.0]],
		\ [coloredit#converter#rgb2hsl_nr(0x80, 0x00, 0x80),
		\  coloredit#converter#rgb2hsl_float(0x80, 0x00, 0x80)
		\ ])
	" Teal
	call assert_equal(
		\ [[180, 100, 25], [180.0, 100.0, 25.0]],
		\ [coloredit#converter#rgb2hsl_nr(0x00, 0x80, 0x80),
		\  coloredit#converter#rgb2hsl_float(0x00, 0x80, 0x80)
		\ ])
	" Navy
	call assert_equal(
		\ [[240, 100, 25], [240.0, 100.0, 25.0]],
		\ [coloredit#converter#rgb2hsl_nr(0x00, 0x00, 0x80),
		\  coloredit#converter#rgb2hsl_float(0x00, 0x00, 0x80)
		\ ])

	if !empty(v:errors)
		call writefile(v:errors, s:TEST_LOG)
		for err in v:errors
			echohl Error
			echo substitute(substitute(err, 'Expected ', "\n  \&", ''), 'but got ', "\n  \& ", '')
			echohl None
		endfor
	endif
endfunction

call coloredit#converter#run_tests()
