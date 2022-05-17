# Building a Tiling Window Manager with Rust and Penrose
During the pursuit of increased productivity, many developers strive to eliminate their usage of the
mouse as much as possible. The most effective way to eliminate a large percentage of your mouse usage
is by switching from a traditional style of window manager to a tiling style window manager.

## What is a tiling-window manager?
Traditional window managers follow a "floating" or "stacking" philosophy. These window managers were
originally intended to mimic the familiarity of moving papers around a desk. A newly opened window in a 
floating-window manager has no regard for the state or visibility of the other opened windows. A 
tiling-window manager, however, makes the assumption that if a window is open, it should be visible.
A newly opened window in a tiling-window manager will be placed in a tile along with the other windows, 
depending on the chosen layout. The opened windows can then be cycled though, moved, resized, and closed 
with the use of keyboard bindings. This takes much of the work usually done with the mouse and offloads 
it to the keyboard thus significantly increasing productivity.   

## Why Penrose?
There are many existing tiling-window managers with [i3](https://i3wm.org/) probably being the most popular
choice for linux systems. These window managers can depend on extensive configuration files or in the case
of [dwm](https://dwm.suckless.org/), git patching or C programming.
[Penrose](https://github.com/sminez/penrose) takes a different approach in that Penrose is not a window
manager. Penrose is a high-level rust [library](https://docs.rs/penrose/latest/penrose/) that you use to
build your own window manager. This gives us many options for customization while also
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
### Dependencies
To build our window manager, we only need two dependencies. A logging library and penrose itself.
Our needs are simple so we can just log to stdout. We will add these to our Cargo.toml.
### Cargo.toml
```toml
penrose = "0.2"
simplelog = "0.8"
```
## Styles
Before we start building the main application, lets make some modules which contain the styles that we are
going to use. Let's create a styles module, which will make our file tree look like this:
```
mywm
│   Cargo.toml
└───src
│   │   main.rs
│   │   styles.rs
```
### styles.rs
```rust
pub const PROFONT: &str = "JetBrainsMono Nerd Font";

pub mod colors {
    pub const BLACK: &str = "#000000";
    pub const GREY: &str = "#808080";
    pub const WHITE: &str = "#ffffff";
    pub const PURPLE: &str = "#a020f0";
    pub const BLUE: &str = "#0000ff";
    pub const RED: &str = "#ff0000";
}

pub mod dimensions {
    pub const HEIGHT: usize = 18;
}
```
In our styles module we can add our preferred font and submodules for some basic colors and dimensions.
We can declare this module directly in our main file along with our intent to use them.
### main.rs
```rust
mod styles;
use styles::{ PROFONT, colors, dimensions };
```
## Hooks
Penrose supports the use of hooks to further modify the behavior of our window manager. For our purposes, we
are only interested in creating a hook which will execute an external script upon startup. This script will
allow us to do things like run feh to set our background, start window-compositors to enable window
transparency, and more. We can create the hooks module the same way we created the styles modules, leaving
our file tree looking like this:
```
mywm
│   Cargo.toml
└───src
│   │   main.rs
│   │   styles.rs
│   │   hooks.rs
```
### hooks.rs
```rust
use penrose::{
    core::{
        hooks::Hook,
        manager::WindowManager,
        xconnection::XConn,
    },
    Result,
    spawn,
};

pub struct StartupScript {
    path: String,
}

impl StartupScript {
    pub fn new(s: impl Into<String>) -> Self {
        Self { path: s.into() }
    }
}

impl<X: XConn> Hook<X> for StartupScript {
    fn startup(&mut self, _: &mut WindowManager<X>) -> Result<()> {
        spawn!(&self.path)
    }
}
```
This is the entirety of our hooks module. First we declare a struct which holds the path to the script on
our system. Then we implement the hook trait for penrose to spawn the process. We can declare this
module in the main file the same way we did our styles module.
### main.rs
```rust
mod hooks;
```
## Main Application
Now we can move on to implementing the actual application logic. Everything from this point will be added
to the main.rs file. To start, we are going to declare a few constant variables which will hold our 
choice of terminal, application launcher, and the path to our start script.
```rust
pub const TERMINAL: &str = "kitty";
pub const LAUNCHER: &str = "dmenu_run";
pub const PATH_TO_START_SCRIPT: &str = "$HOME/.mywm";
```
Replace these values with your preferred application choices and the path to your start script. These 
values could be declared programmatically through the use of something like the 
[clap](https://docs.rs/clap/latest/clap/) crate. This would have the benefit of externalizing our
configuration, which would allow us to make changes without re-compiling the entire application. That 
would be beyond the scope of this tutorial. You can, however, find an example of this in my personal
build: [HERE](https://www.gitlab.com/xsiph/mywm).

### Main Function Return Type
Our main function is going to return a penrose Result to make error handling much simpler.
```rust
fn main() -> penrose::Result<()> {
}
```

### Logging initialization
```rust
use simplelog::{ LevelFilter, SimpleLogger };
...
if let Err(e) = SimpleLogger::init(LevelFilter::Info, simplelog::Config::default()) {
    panic!("unable to set log level: {}", e);
};
```
We are going to use the [simplelog](https://docs.rs/simplelog/latest/simplelog/) crate to initialize our 
logger. The SimpleLogger logs to stdout, if we wanted to log to a file we could replace it with WriteLogger.

### Layouts
```rust
use penrose::{
    core::{
    layout::{
        LayoutConf,
        side_stack,
    },
    Layout,
    },
};
...
let side_stack_layout = Layout::new("[[]=]", LayoutConf::default(), side_stack, 1, 0.6);
```
For our purposes, we are only going to declare a single layout. This layout allows one main window
and allocates 60% screen of the real-estate to the main window, and shares the remaining 40% between
the other windows. The string is the symbol that will be displayed when the layout is active.

### Config
```rust
use penrose::Config;
...
let config = Config::default()
    .builder()
    .show_bar(true)
    .top_bar(true)
    .layouts(vec![side_stack_layout])
    .focused_border(colors::PURPLE)?
    .build()
    .expect("Unable to build configuration");
```
This config is very simple. We allocate space for a top bar, add our layouts, and choose a border color 
which will appear around the active window.

### Top-Bar
```rust
use penrose::{
    draw::{
        TextStyle,
        Color,
        dwm_bar,
    },
    xcb::XcbDraw,
};
...

let style = TextStyle {
    font: PROFONT.to_string(),
    point_size: 11,
    fg: Color::try_from(colors::WHITE)?,
    bg: Some(Color::try_from(colors::BLACK)?),
    padding: (2.0, 2.0),
};

let empty_ws = Color::try_from(colors::GREY)?;
let draw = XcbDraw::new()?;

let bar = dwm_bar(
    draw,
    dimensions::HEIGHT,
    &style,
    Color::try_from(colors::PURPLE)?,
    empty_ws,
    config.workspaces().clone(),
)?;
```
We could use something like [polybar](https://github.com/polybar/polybar) to build a powerful and 
sophisticated top-bar for our system. However, for this example we are going to use the built-in dwm_bar
which mimics the bar that can be found in dwm. What's happening here is pretty straight-forward. First we
populate the styling struct, and then we plug these values into the dwm_bar.

### Keybindings
```rust
use penrose::{
    core::{
        ring::Direction::{
            Forward,
            Backward,
        },
        data_types::Change::{
            More,
            Less,
        },
        helpers::index_selectors,
    },
    Selector,
};
...
let key_bindings = gen_keybindings! {
        // Program launchers
        "M-p" => run_external!(LAUNCHER);
        "M-Return" => run_external!(TERMINAL);

        // Exit Penrose (important to remember this one!)
        "M-A-C-Escape" => run_internal!(exit);

        // client management
        "M-j" => run_internal!(cycle_client, Forward);
        "M-k" => run_internal!(cycle_client, Backward);
        "M-S-j" => run_internal!(drag_client, Forward);
        "M-S-k" => run_internal!(drag_client, Backward);
        "M-f" => run_internal!(toggle_client_fullscreen, &Selector::Focused);
        "M-c" => run_internal!(kill_client);

        // workspace management
        "M-Tab" => run_internal!(toggle_workspace);
        "M-A-period" => run_internal!(cycle_workspace, Forward);
        "M-A-comma" => run_internal!(cycle_workspace, Backward);

        // Layout management
        "M-grave" => run_internal!(cycle_layout, Forward);
        "M-S-grave" => run_internal!(cycle_layout, Backward);
        "M-A-Up" => run_internal!(update_max_main, More);
        "M-A-Down" => run_internal!(update_max_main, Less);
        "M-l" => run_internal!(update_main_ratio, More);
        "M-h" => run_internal!(update_main_ratio, Less);

        map: { "1", "2", "3", "4", "5" } to index_selectors(5) => {
             "M-{}" => focus_workspace (REF);
             "M-S-{}" => client_to_workspace (REF);
         };
    };
```
Penrose includes a helpful macro that allows us to quickly set our keybindings. The 'M' key is the meta 
key aka Windows key. We also label our workspaces here. We are only declaring 5, but you could use any 
arbitrary number of workspaces. We also label our workspaces with numbers, but they could be labeled 
using icons or emojis.

### Hooks
```rust
use penrose::{
    core::{
        hooks::Hooks,
    },
    XcbConnection,
};
...
let hooks: Hooks<XcbConnection> = vec![
    Box::new(bar),
    Box::new(hooks::StartupScript::new(PATH_TO_START_SCRIPT)),
];
```
Here we create a vector to hold our hooks. We only have two hooks, the top-bar, and the start script we
declared earlier.

### Run
```rust
use penrose::{
    new_xcb_backed_window_manager,
    logging_error_handler,
};
...
let mut wm = new_xcb_backed_window_manager(config, hooks, logging_error_handler())?;
wm.grab_keys_and_run(key_bindings, map!{})
```
All that is left now is to build it and run it.

## Additional Steps
### Compiling and Running
Compilation is as simple as running the cargo build command:
```bash
cargo build --release
```
Now that we have a binary, how do we run it? We could use 
[xinit](https://wiki.archlinux.org/title/Xinit) to launch a session directly from a tty. Instead, if you
already have a login manager installed, you can move the binary to the /usr/bin/ directory and make a 
mywm.desktop file that looks something like this:
```
[Desktop Entry]
Encoding=UTF-8
Name=Mywm
Comment=Tiling Window Manager
Exec=mywm
Type=Xsession
```
Place the .desktop file in /usr/share/xsessions/ directory, and you will be able to select mywm upon login.

### .mywm Hook Script
We built a hook that would run our script on startup. The script can be used to do many things, but the
most common would probably be to set your background.
```bash
 #!/bin/sh
 feh --no-fehbg --bg-scale '$HOME/Pictures/background.png'
```
Just make sure that .mywm has executable privileges.

## Jetbrains IDE
Intellij along with other Jetbrains IDEs can have trouble when running under a tiling-window manager. To
solve this problem, you need to export a variable for the JVM that runs the IDE to use:
```bash
export _JAVA_AWT_WM_NONREPARENTING=1
```
The best place to put this is in an .env file like .zshenv, if zsh is your default shell.

## Conclusion
Building your own window manager can be a very daunting undertaking. With tools like Penrose, much of
the complexities involved are hidden behind helpful libraries. This particular build only scratches the
surface of what can be accomplished. The complete code for this project can be found on my 
[gitlab](https://gitlab.com/xsiph/MYWM/-/tree/article-version) alongside my actual 
[build](https://gitlab.com/xsiph/MYWM/).
