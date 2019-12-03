
# vim-coloredit

This plugin provides to edit RGB and HSL such as the following:

* `hsl({hue},{saturation}%,{lightness}%)`
* `hsla({hue},{saturation}%,{lightness}%,{alpha})`
* `rgb({red},{green},{blue})` 
* `rgba({red},{green},{blue},{alpha})`
* `#rrggbb`

When you edit `rgba()` or `hsla()`, this plugin does not support to edit the alpha value.  

Also this plugin provides to switch to another display-mode such as RGB and HSL.

## Requirements

* Vim only. Does not support Neovim
* Vim must be compiled with `+popupwin` or `+textprop` feature
* 256 bit color

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

![](https://raw.githubusercontent.com/rbtnn/vim-coloredit/master/coloredit.gif)

## License

Distributed under MIT License. See LICENSE.
