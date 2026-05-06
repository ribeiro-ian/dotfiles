# ian's dotfiles

![Last Commit](https://img.shields.io/github/last-commit/ribeiro-ian/dotfiles)
![Repo Size](https://img.shields.io/github/repo-size/ribeiro-ian/dotfiles)
![MIT License](https://img.shields.io/badge/License-MIT-blue)
![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)
![Git](https://img.shields.io/badge/Git-F05032?logo=git&logoColor=white)
![GNU Stow](https://img.shields.io/badge/Stow-FFFFFF?logo=gnu&logoColor=black)
![Zsh](https://img.shields.io/badge/Zsh-000000?logo=zsh&logoColor=white)
![Ghostty](https://img.shields.io/badge/Ghostty-423F3E?logo=ghostty&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-57A143?logo=neovim&logoColor=white)

My personal dotfiles for setting up and maintaining Linux systems. Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Contents

| Package     | Description                            |
| ----------- | -------------------------------------- |
| `zsh`       | Shell with plugins                     |
| `scripts`   | Personal shell scripts                 |
| `ghostty`   | Terminal emulator                      |
| `starship`  | Starship prompt theme                  |
| `fastfetch` | Tool for fetching system information   |
| `btop`      | Terminal resource monitor              |
| `neovim`    | Terminal text editor                   |
| `mpv`       | Media player                           |
| `spicetify` | Spotify customization                  |

## Requirements

- `git`
- `curl`
- `stow`
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
- Install packages: `ghostty`, `mpv`, `nvim` and more
- Install Nerd Fonts to `~/.fonts`
- Rename `~/dotfiles` → `~/.dotfiles` and stow all configs

## Manual Install

If you prefer to set things up yourself:

### 1. Requirements & Packages

```bash
# apt
sudo apt install -y git stow curl fzf

# pacman
sudo pacman -S --noconfirm git stow curl fzf
```

### 2. Clone

```bash
git clone https://github.com/ribeiro-ian/dotfiles ~/.dotfiles
cd ~/.dotfiles
```

### 3. Zsh

```bash
# apt
sudo apt install -y zsh

# pacman
sudo pacman -S --noconfirm zsh
```

```bash
# Oh My Zsh
RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Zsh plugins
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab

# Zoxide
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# Starship
curl -sS https://starship.rs/install.sh | sh
```

### 4. Packages

```bash
# apt
sudo apt install -y mpv neovim fastfetch btop

# pacman
sudo pacman -S --noconfirm mpv neovim fastfetch btop ghostty spotify
```

#### Manual installation packages:

- Spotify
- [Spicetify](https://spicetify.app/docsgetting-started)
- [Ghostty](https://ghostty.org/download)

### 5. Stow

```bash
cd ~/.dotfiles
stow --restow --adopt -v */
git restore .
```
