# Introduction

This repository serves as a to help me setup and maintain my Linux systems. Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Contents

| Package     | Description                            |
| ----------- | -------------------------------------- |
| `zsh`       | Shell with plugins                     |
| `scripts`   | Personal shell scripts                 |
| `ghostty`   | Terminal emulator                      |
| `starship`  | Starship prompt theme                  |
| `fastfetch` | Tool for fetching system information   |
| `btop`      | Terminal resource monitor              |
| `neovim`      | Terminal text editor                   |
| `mpv`       | Media player                           |
| `spicetify` | Spotify customization                  |

## Requirements

- `git`
- `curl`
- `stow`
- `zsh`
- `fzf`

## Quick Install

Clone and run the install script it handles everything automatically:

```bash
git clone https://github.com/ribeiro-ian/dotfiles ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The script will:

- Detect your package manager (`apt`, `pacman`)
- Install requirements
- Install `zsh` and plugins
- Install packages: `ghostty`, `mpv`, `nvim` and other utils
- Install Nerd Fonts to `~/.fonts`
- Rename `~/dotfiles` `~/.dotfiles` and stow all configs

## Manual Install

If you prefer to set things up yourself:

### 1. Requirements

```bash
# apt
sudo apt install git stow curl fzf mpv neovim

# pacman
sudo pacman -S git stow curl fzf mpv neovim
```

### 2. Clone

```bash
git clone https://github.com/ribeiro-ian/dotfiles ~/.dotfiles
cd ~/.dotfiles
```

### 3. Zsh

```bash
# Oh My Zsh
RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Plugins
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab

# Zoxide
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# Starship
curl -sS https://starship.rs/install.sh | sh
```

### 4. Apps

- [Ghostty](github.com/ghostty-org/ghostty)
- [Spicetify](github.com/spicetify)

### 5. Stow

```bash
cd ~/.dotfiles
stow --restow --adopt */
git restore .
```
