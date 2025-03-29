# My Dotfiles

This repo contains the dotfiles for my system

## Requirements

### Git

```
sudo apt install git
```

### Stow

```
sudo apt install stow
```

## Installation

First

```
cd ~
git clone https://github.com/ribeiro-ian/.dotfiles
cd .dotfiles
```

use GNU stow to create symlinks

```
$ stow -v .
```

### ZSH

```
# Install ZSH
sudo apt install zsh

# Install fzf
sudo apt install fzf
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

```

### Apps
```
apt update && apt upgrade -y
apt install btop micro fusuma flameshot
```
