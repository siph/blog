---
layout: post
title:  "Writing Polybar Modules in Nushell"
date:   2023-04-25 16:43:23 -0700
categories: functional programming shell linux
---

[Polybar](https://www.github.com/polybar/polybar) modules are almost always
written in either `bash` or `python`. `Bash` offers an ubiquitous, stable
platform and `python`, a large ecosystem and much nicer syntax. I want to show
how [`nushell`](https://www.github.com/nushell/nushell) can serve as another
alternative.


## Building the Module

The sample module is simple. It queries a GitHub repository for an RSS document
and prints how much time has elapsed since the last update.

```nu
# elapsed.nu


#!/usr/bin/env nu

# Returns how long it has been since a repository received its last update.
def main [
    --user: string,         # GitHub username
    --repository: string    # User repository
] {
    let elapsed = (http get $"https://github.com/($user)/($repository)/releases.atom"
        | from xml
        | get content
        | where { |it| $it.tag == `updated` }
        | $in.content.0.content.0
        | into datetime
        | date humanize)
    print $"($user)/($repository) was updated ($elapsed)."
}
```

I'm not going to get into the syntax of `nushell` but here is a summary of what
this script does:

1. Make a web request.
2. Load the RSS response as structured data.
3. Filter and traverse the data structure to access values.
4. Convert a string into a workable datetime object.
5. Determine the amount of elapsed time.
5. Print an interpolated message.

This isn't anything that couldn't be done with `python` or `bash`, but
`nushell` has some advantages that makes it a compelling option in this
instance.

First, `nushell` is able to do all of this without any external dependencies.
An http call would need a dependency or significantly more lines in `python`
and `bash` would offload the task to `curl`. Deserialization is also
non-trivial in `python` and `bash` even with dependencies.

`Nushell` also has a nice syntax, certainly better than `bash`. With a
functional approach and lots of high-level functionality, powerful operations
can be done with relatively small amounts of code.

There are also constant improvements and changes to the language/shell because
`nushell` is fairly young and still in very active development. The downside is
that this does result in `nushell` being far less stable than the others.

## Using the Module

`Polybar` uses the module the same way it would any other module.

```ini
[module/elapsed]
type = custom/script
interval = 600
exec = ~/scripts/elapsed.nu --user nushell --repository nushell
```

Now its ready to be added to your bar. Here it is in my
[config](https://www.github.com/siph/nix-dotfiles).

![module added](/blog/assets/images/07/module.png)

This isn't a very useful module and only meant as a demonstration, but the
weather and clock modules are also written in `nushell`.

```nu
#clock.nu


#!/usr/bin/env nu

# Get date and time as string with format.
def main [
    --format: string = "%a ● %D ● %r";  # Output string display format. Default: `%a ● %D ● %r`.
] {
    date now | date format $"($format)"
}
```

```nu
#weather.nu


#!/usr/bin/env nu

# Query `wttr.in` for weather report with location and format.
def main [
    --location: string,                         # Can be city name or ICAO code.
    --format: string = "%c%t ● %h ● %w ● %m";   # Optional output string display format. Default: `%c%t ● %h ● %w ● %m`.
] {
    http get $"https://wttr.in/($location)?format=($format)"
}
```

## Conclusion

You could really use whatever you wanted to build these simple modules. You
could build a `java` app and run the jar in the configuration file as long as
it prints to stdout. The reason people choose `python` or `bash` is the same
reason they choose them for any other script. `Nushell` is nice to work with on
both the command line and when building scripts and it makes a great tool to
build `polybar` modules.

