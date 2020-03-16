---
title: Fish and Nix
---

I have used [fish](https://fishshell.com) as my main command line shell for many years now. I love the ease of use and sane defaults provided by fish. However, I recently started using [Nix](https://nixos.org/) as a package manager and discovered that fish and Nix require a bit of configuration to use together. This article describes how to configure fish so it will work with the Nix package manager.

Note that this configuration has only been tested on macOS. It may or may not work on other operating systems.

## Overview

The Nix installation does two things:

1) create the `/nix` directory
2) modify your `.bash_profile` to source `~/.nix-profile/etc/profile.d/nix.sh`.

Our goal is to configure the fish initialization procedure to modify the fish environment in an equivalent way. To do so, we will use a tool called [Foreign Environment](https://github.com/oh-my-fish/plugin-foreign-env), which allows us to modify fish environment variables via bash scripts.

## Instructions

This article assumes neither Nix nor fish are installed. You may need to skip or modify some steps based on what is already installed in your environment.

### 1. Install Nix

Nothing special needs to be done here. Simply follow the instructions in the [official docs](https://nixos.org/nix/download.html).

### 2. Install fish

Now that Nix is installed, we can use it to install fish:

```bash
nix-env -i fish
```

### 3. Install Foreign Environment (fenv)

See [installation instructions](https://github.com/oh-my-fish/plugin-foreign-env#install) in GitHub repo. I don't use Oh My Fish, so I simply cloned the repo into my home directory.

```bash
cd ~
git clone https://github.com/oh-my-fish/plugin-foreign-env.git
```

### 4. Modify fish config

Now we just need to use `fenv` to source the Nix setup script. My `~/.config/fish/config.fish` looks like:

```bash
# Add fenv to path
set fish_function_path $fish_function_path ~/plugin-foreign-env/functions

# Source Nix setup script
fenv source ~/.nix-profile/etc/profile.d/nix.sh
```

Note that if you used Oh My Fish to install `fenv`, the line adding `fenv` to your path is not necessary.

## Note on login shell

At this point, you can use fish and it will see packages installed with Nix. However, you may notice that we have not changed the login shell to fish. Therefore, any program that spawns a shell, e.g. `nix-shell`, drops you back into a bash/zsh shell.

I prefer to keep my default login shell because I have found many programs that spawn a shell expect it to be POSIX-compliant and may run into problems with other shells.

Instead of changing my login shell, I simply configure my terminal emulator to spawn a fish shell using the Nix symlink: `~/.nix-profile/bin/fish`. That way I can use fish as my main driver, but other tools still spawn bash/zsh shells.

## Acknowledgements

I'd like to thank all the commenters on [this GitHub issue](https://github.com/NixOS/nix/issues/1512) for leading me to this solution.
