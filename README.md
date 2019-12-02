
# vim-coloredit

This plugin provides to edit RGB and HSL such as the following:

* `#rrggbb`
* `rgb({red},{green},{blue})` 
* `rgba({red},{green},{blue},{alpha})`
* `hsl({hue},{saturation}%,{lightness}%)`

When you edit `rgba({red},{green},{blue},{alpha})`, this plugin does not support to edit the alpha value.  

## Requirements

* Vim only. Does not support Neovim
* Vim 8.1 or above
* Vim must be compiled with `+popupwin` or `+textprop` feature

## Concepts

* This plugin does not provide to customize user-settings.
* This plugin provides only one command.

## Installation

This is an example of installation using [vim-plug](https://github.com/junegunn/vim-plug).

```
Plug 'rbtnn/vim-coloredit'
```

## Usage

### :ColorEdit

__#rrggbb__
![](https://raw.githubusercontent.com/rbtnn/vim-coloredit/master/hash_rgb.gif)

__rgb({red},{green},{blue})__
![](https://raw.githubusercontent.com/rbtnn/vim-coloredit/master/paren_rgb.gif)

__rgba({red},{green},{blue},{alpha})__
![](https://raw.githubusercontent.com/rbtnn/vim-coloredit/master/paren_rgba.gif)

__hsl({hue},{saturation}%,{lightness}%)__
![](https://raw.githubusercontent.com/rbtnn/vim-coloredit/master/paren_hsl.gif)


## License

Distributed under MIT License. See LICENSE.
