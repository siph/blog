---
layout: post
title:  "Hi There! Have You Heard The Good News About Our Lord And Saviour Nix?"
date:   2023-02-28 18:47:33 -0700
categories: linux nixos programming systems
---

It seems like there is a lot of buzz lately around Nix and NixOS. It keeps
popping up more and more as a topic of discussion, especially with software
developers. However, looking at it's surface and trying to understand what Nix
even is can be a struggle. Nix is expansive and knowing what problems it solves
and how to even begin to approach the ecosystem can be challenging. This guide
is intended to be an introduction and brief exploration into what Nix/NixOS is
and how it can benefit you as a developer.


# Table of Contents
* [What is Nix?](#what-is-nix)
    * [Difference Between Nix and NixOS](#difference-between-nix-and-nixos)
* [System Management](#system-management)
    * [User](#user)
        - [Home Manager](#home-manager)
        - [Nixos-Generators](#nixos-generators)
    * [Server](#server)
* [Nixpkgs](#nixpkgs)
    * [Packaging Software](#packaging-software)
        - [Flakes](#flakes)
* [Development Environment](#development-environment)
    * [Devshell](#devshell)
* [Learning Nix](#learning-nix)


# What is Nix?

Nix is a purely functional package manager and operating system deployment
tool. It was designed to manage the configuration and installation of software
on a variety of operating systems, including Linux, and macOS.

Nix's distinguishing feature is its functional approach to package management.
Instead of the traditional approach of installing packages into a global system
directory, Nix packages are built in isolation and stored in a per-user store.
This means that multiple versions of a package can coexist on the same system,
and dependencies are managed in a consistent and predictable way.

Here are some reasons why someone might want to use Nix:

- Reproducible builds: Nix ensures that every package build is isolated and
uses exactly the same dependencies, making it easy to reproduce builds
across different machines.

- Multiple versions: Nix allows you to have multiple versions of the same
package installed at the same time, which is useful for development and
testing.

- Declarative package management: Nix uses a declarative language to
describe package dependencies and configurations, making it easy to
specify exactly what you want installed on a system.

- Rollbacks: Nix allows you to roll back to a previous system configuration
if something goes wrong, which can be a lifesaver in production
environments.

- Cross-platform support: Nix works on a variety of operating systems, so
you can use the same package management tool across different machines.

- Massive package repository: Nix has a huge repository of pre-built packages,
which can save time and effort in setting up a new system or developing
software. [See how nixpkgs compares to your package manager.](https://repology.org/repositories/graphs)


## Difference Between Nix and NixOS

Nix is a package manager for Linux and other Unix-like systems that allows for
declarative, reproducible, and isolated software installation and
configuration.

NixOS, on the other hand, is a Linux distribution that uses Nix as its package
manager and is built around the principles of declarative system configuration
and functional package management. NixOS uses a declarative language (also
confusingly called Nix) to describe system configuration, including the
installation and configuration of packages, users, network interfaces, and
other system components. This makes it easy to reproduce a system's
configuration and to roll back to a previous configuration if necessary.

In other words, while Nix is a package manager that can be used on any Linux or
Unix-like system, NixOS is a complete Linux distribution that uses Nix as its
package manager and has a unique approach to system configuration.


# System Management

One of the most appealing features of Nix/NixOS that tends to draw new users in
is the ability to have your entire system configuration written out and version
controlled. This means that your entire fully configured system is ready to
deploy anytime, anywhere right from a git repository. This even includes things
like SSH or PGP keys by using [`agenix`](https://github.com/ryantm/agenix).


## User

Using Nix as a package manager and configuring your home applications with
[`home-manager`](https://github.com/nix-community/home-manager) means that your
configuration can be deployed outside of NixOS. Nix can reproduce a
configuration on Ubuntu, Fedora, etc. as well as macOS. This can allow users
to leverage some strengths of Nix without diving all the way into the
ecosystem.


### Home Manager

[`Home-manager`](https://github.com/nix-community/home-manager) is a tool for
managing user-specific configuration files on top of the Nix package manager.
It allows users to declaratively manage their user environment, including their
shell configuration, editor configuration, and other user-specific settings.

Home-manager extends the power of NixOS system management to user management
letting you declaratively configure your home applications.

Some examples of what you can do with Home Manager include:
- Configuring your shell (e.g. zsh or bash or nushell) with custom settings and
plugins
- Installing and configuring your favorite text editor (e.g. Neovim or VSCode)
with custom settings and plugins
- Configuring your development tools (e.g. Git or Docker) with custom settings
and aliases


### Nixos-Generators

[`Nixos-generators`](https://github.com/nix-community/nixos-generators) can be
used to generate a plethora of formats including ISO. Meaning you can keep a
configuration that's specific to your needs and have it handy on a thumb drive.

You can also build a server configuration and have a cloud image (digitalocean,
aws, etc) uploaded and ready to deploy on-demand.


## Server

NixOS really shines when used to build application infrastructure. Things like
firewalls, databases, reverse-proxies, and environment variables can all be
configured using NixOS declarative module system.

Using NixOS for server configuration provides several other benefits, including:

- Declarative configuration: NixOS modules provide a declarative way to describe
server configuration, allowing you to specify exactly what software should be
installed, how it should be configured, and what services should be running on
the server. This makes it easy to reproduce server configurations across
different machines, and ensures that server configuration is always consistent
and predictable.

- Modularity: NixOS modules are designed to be modular, with each module
responsible for configuring a specific aspect of the server. This makes it easy
to manage complex server configurations, and allows you to reuse configuration
across different servers.

- Reusability: NixOS modules can be reused across different server
configurations, making it easy to share configuration between different
projects and teams.

- Versioning: NixOS modules are versioned, making it easy to track changes to
server configuration over time and to roll back to previous configurations if
necessary.

- Safety: NixOS modules are designed to be safe, with built-in checks to prevent
invalid configurations and to ensure that server configuration is consistent
and predictable.


# Nixpkgs

[`Nixpkgs`](https://www.github.com/nixos/nixpkgs) currently has more software
packages than any other package repository (excluding the `npm` madhouse). The
packages also tend to be very fresh and up-to-date thanks to the community and
projects like [`nixpkgs-update`](https://github.com/ryantm/nixpkgs-update).


## Packaging Software

Packaging software for Nix involves creating a Nix derivation, which is an
expression that describes how to build and install the software. In this
expression you provide a list of dependencies as well as instructions on how
the software should be built. There are many helpful tools to make building
common project types like cargo, poetry, or go projects much simpler.


### Flakes

Nix Flakes is a new feature that was introduced in Nix version 2.4. It's a way
to make Nix more composable and modular, and to simplify the process of
managing and distributing Nix configurations as well as achieving strict
reproducibility through a lock file.

At a high level, Nix Flakes allow you to specify a set of inputs (e.g. Nix
packages or other Flakes) and a set of outputs (e.g. a configuration for a
specific system or environment). You can then use these inputs to build your
outputs, and share your configuration as a single, self-contained unit that can
be easily distributed and reused.

Flakes have created somewhat of a schism in the Nix community although adoption
continues to increase as Flakes reduce or eliminate many of the pain-points
experienced while working with Nix.


# Development Environment

Nix is a developers dream. There is a staggering amount of tooling, utility,
and clever mechanisms that can provide enormous amounts of value and
productivity to a project. Using Nix, Flakes, and Devshells can eliminate the
worry of dependencies and versions inside a developers' environment.


## Devshell

Devshells are a feature of Nix that allow you to create a shell environment
with all the dependencies and environment variables needed for a particular
project or task. Devshells are useful for developers who work on multiple
projects or who need to switch between different programming languages or
development environments frequently.

They're also useful as a means of unifying dependencies and development
environments in a consistent and reproducible way. By defining the dependencies
and environment in a Nix expression, you can ensure that all developers on your
team are using the same versions of libraries and tools, and that the
environment can be easily recreated on different machines or platforms.

This can be further extended into automation environments like CI/CD pipelines
and even into production.

Combined with Flakes, Devshell dependencies can all be pinned to specific
versions for extremely consistent reproducibility which virtually eliminates
the 'works on my machine' dilemma.


# Learning Nix

Overall, Nix and NixOS offer many benefits for developers, including
reproducible builds, isolation, easy package management, and rollback
capabilities. These features can help developers be more productive and
efficient, and make it easier to collaborate on software projects with others.

However, Nix has a pretty notorious reputation for being difficult to grasp.
The learning curve for Nix and NixOS can be steep, especially for developers
who are new to functional programming and declarative configuration management.

Documentation for NixOS is mostly adequate in 2023 although oftentimes
scattered around the internet.

Despite these challenges, many developers find that the benefits of using Nix
and NixOS outweigh the learning curve. Once developers become proficient with
Nix and NixOS, they can enjoy the benefits of reproducible builds, isolation,
easy package management, and rollback capabilities, among others.

**Links**:
 - [awesome-nix](https://github.com/nix-community/awesome-nix): Officially curated list of Nix resources.
 - [nixpkgs](https://github.com/nixos/nixpkgs): Software repository for Nix.
 - [wiki](https://nixos.wiki/wiki/Main_Page): Official NixOS wiki.
 - [discourse](https://discourse.nixos.org/): NixOS community discussion.
 - [nixos-search](https://search.nixos.org/packages): Search nixpkgs from the web.
