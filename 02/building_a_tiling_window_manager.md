# Building a Tiling Window Manager with Rust and Penrose
During the pursuit of increased productivity, many developers discover the wonders of mouse-free development
and tiling-window mangers.

## What is a tiling-window manager?
Traditional window managers follow a "floating" or "stacking" philosophy. These window managers were
originally intended to mimic the familiarity of moving papers around a desk. A newly opened window in a 
floating-window manager has no regard for the state or visibility of the other opened windows. A 
tiling-window manager, however, makes the assumption that every window needs to be visible. A newly opened
window in a tiling-window manager will be placed in a tile along with the other windows, depending on the
chosen layout. The opened windows can then be cycled though, moved, resized, and closed with the use of
keyboard bindings. This takes much of the work usually done with the mouse and offloads it to the keyboard
thus significantly increasing productivity.   

## Why Penrose?
There are many existing tiling-window managers with [i3](https://i3wm.org/) probably being the most popular
choice for linux systems. These window managers can depend on extensive configuration files or in the case
of [dwm](https://dwm.suckless.org/), git patching or C programming.
[Penrose](https://github.com/sminez/penrose) takes a different approach in that Penrose is not a window
manager. Penrose is a high-level rust [library](https://docs.rs/penrose/latest/penrose/) that you use to
build your own window manager. This has the advantage of having a large amount of customization while also
giving us all the advantages that come with writing rust code.

## Prerequisites
### X11
Penrose works for the X11 window management system. This means that your choice of operating system is 
basically only linux or bsd.
### Rust
Some familiarity with rust is required. The [Rust Book](https://doc.rust-lang.org/book/) is the best place
to start.

## Getting Started
To start, we're going to generate a new rust binary project using cargo with the command:
```bash
cargo new mywm
```
