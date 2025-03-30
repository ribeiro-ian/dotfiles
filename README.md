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
git clone https://github.com/ribeiro-ian/dotfiles
cd dotfiles
```

use GNU stow to create symlinks

```
stow -v .
```

### ZSH

```
# Install ZSH
sudo apt install zsh

# Install fzf
sudo apt install fzf

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Oh My Zsh Plugins
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```

### Apps
```
sudo apt update && sudo apt upgrade -y
sudo apt install btop micro
```
