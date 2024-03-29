---
title:  "Declare and version control your tmux sessions"
date:   2023-04-15
---

Anyone who spends a significant amount of time in the command line understands
how tedious and cumbersome managing multiple tmux sessions can be. Many
programmers find themselves switching between a variety of projects of
different languages and sizes on a daily basis. With
[`tmuxp`](https://www.github.com/tmux-python/tmuxp) you can declare what a tmux
session for a project should look like using json/yaml.

A simple declaration that fetches from a remote repo and opens `neovim` in one
window with `bottom` running in a second.
```yaml
# ~/example/.tmuxp.yaml
session_name: Swoll Sesh
start_directory: ~/example
windows:
    - window_name: nvim
      panes:
        - shell_command:
          - git fetch
          - nvim .
    - window_name: monitor
      panes:
        - shell_command:
          - btm
```

To start this session just run:
```shell
tmuxp load ~/example
```

This file can then be version controlled, keeping your developer environment
organized, consistent and reusable. You can find more examples in the
[documentation](https://tmuxp.git-pull.com/configuration/examples.html)

Combining this with one of the session management plugins for neovim/vim means
that your editor will automatically open where you want it.

This can be even further expanded with [`nix`](https://nixos.org/),
[`flakes`](https://nixos.wiki/wiki/Flakes), [`direnv`](https://direnv.net/),
and [`nix-direnv`](https://github.com/nix-community/nix-direnv) to give you a
fully automated and reproducible developer environment complete with the
environment variables and dependencies needed to start hacking on a project.
