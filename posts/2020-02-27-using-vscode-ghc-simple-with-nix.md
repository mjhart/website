---
title: Using vscode-ghc-simple with Nix
---

Haskell is a great language, but compared with other languages, the IDE ecosystem leaves much to be desired. [This page](https://github.com/rainbyte/haskell-ide-chart) gives a good breakdown of the various options and their capabilities. After trying many of the available tools, I have finally found this setup which works with relatively little configuration. There are other tools out there that have more features, but I have not been able to get them working.

The Visual Studio Code extension I am using, `vscode-ghc-simple`, is easy to get started with because it only depends on `ghci`. If you are not using Nix to provision your Haskell development environment, `vscode-ghc-simple` will most likely work for you without any configuration. However, if you use Nix, `vscode-ghc-simple` may not be running in a Nix environment, and therefore will not have `ghci` in its path. This tutorial will show you how to configure `vscode-ghc-simple` so that it can run in the Nix environment for your project.

## Install Nix

If you're reading this, you probably already have Nix installed. If not, the [official docs](https://nixos.org/nix/download.html) will do a better job explaining how to install than I can.

## Install vscode-ghc-simple

The extension can be [found](https://marketplace.visualstudio.com/items?itemName=dramforever.vscode-ghc-simple) in the Visual Studio Marketplace.

## Setup Nix Haskell Environment

I use the patterns described in Soares Chen's great [article](https://maybevoid.com/posts/2019-01-27-getting-started-haskell-nix.html). I'll describe my setup in brief, but I recommend reading the referenced article for a deeper understanding.

### Globally Install Cabal

```bash
nix-env -i cabal-install
```

Installing `cabal` globally introduces some impurity, but it makes writing the Nix package for your project much easier, so I use this method.

### Project Instantiation

First use `cabal` to create the skeleton of your project:

```bash
nix-shell --pure -p ghc cabal-install --run "cabal init"
```

With the skeleton in place, we can use `cabal2nix` to generate a default Nix package:

```bash
nix-shell --pure -p cabal2nix --run "cabal2nix --shell ./." > default.nix
```

**Note:** In the referenced article, Chen creates separate `default.nix` and `shell.nix` files. His approach is more flexible. I mostly use the `--shell` approach because I can get started on a new project more quickly.

## Configure vscode-ghc-simple

Finally, we need to configure `vscode-ghc-simple` to run `ghci` in a Nix environment. This is done by setting the `Repl Command` field to:

```bash
nix-shell --command "cabal new-repl all"
```

It should look something like

![screenshot](/images/vscode-ghc-simple-screen-shot.png)\

## That's It

After completing these steps, vscode-ghc-simple will automatically start in the background whenever you open a Haskell project.

## Alternatives

Instead of running the `cabal` process in a `nix-shell` directly, it is possible to run the `VSCode` process in a `nix-shell`. Then the `cabal` process spawned by `VSCode` will inherit its environment including `ghci` and all other dependencies. I did not go down this route because I want to be able to open a project in `VSCode` without having to remember to restart my editor with the correct environment for each project I'm working on.
