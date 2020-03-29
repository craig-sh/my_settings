# Install

# Generic

```
sudo pacman -S wget curl git stow
sudo pacman -S gcc make
```

# Internet

```
sudo pacman -S netctl dhcpd openssh
```

# Scripts

```
cd ~/my_settings && sudo stow usrlocalbins -t'/'
cd ~/my_settings && stow git
```

## ZSH Settings

```
# From https://github.com/zdharma/zinit
mkdir ~/.zinit
git clone https://github.com/zdharma/zinit.git ~/.zinit/bin

cd ~/my_settings &&  rm -f ~/.zshrc && stow zsh
```

## Fonts

```
pacman -S noto-fonts-emoji ttf-fantasque-sans-mono
```

# Tmux

```
sudo pacman -S tmux powerline
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cd ~/my_settings && stow tmux
```

## Nvim

```
# App image dependency
sudo pacman -S fuse2 xclip xsel wget curl
neovim_install
mkdir -p ~/nvimtmp
mkdir -p ~/nvimundo
sudo pacman -S ctags ripgrep python
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cd ~/my_settings && stow neovim
```

# Commandline

## Rust

```
# Used for starship prompt currently
sudo pacman -S rust

# this can take a while to compile, can also directly install the binary
# https://starship.rs/#quick-install
cargo install starship
cd my_settings && stow install starship
```


## Pyenv

```
# Update
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
# Activate corrent env and then outside of venv install tools we use
pip install python-language-server
pip install pynvim

mkdir -p ~/pyvenvs

# Install envs with 
python -m ~/pyvenvs/<envname> --system-site-packages
```

# GUI

```
sudo pacman -S xorg
sudo pacman -S termite
sudo pacman -S ttf-fantasque-sans-mono
```

## BSPWM

Check bspwm github for dependencies

```
mkdir wm ; cd wm
git clone https://github.com/baskerville/bspwm.git
git clone https://github.com/baskerville/sxhkd.git
cd bspwm && make && sudo make install
cd ../sxhkd && make && sudo make install

cd ~/my_settings
stow bspwm
stow sxhkd
stow X11
stow termite

# Edit bspwm and  .xinitrc for machine specific setup
```

## Rofi

```
sudo pacman -S rofi
cd ~/my_settings && stow rofi
```

## Dunst

```
sudo pacman -S dunst libnotify
cd ~/my_settings && stow dunst
```

## Polybar

```
sudo pacman -S cmake gcc pkg-config libxcb xcb-proto xcb-util-image xcb-util-wm libxcb xcb-util-xrm xcb-util-cursor jsoncpp curl libnl

mkdir -p ~/wm
cd ~/wm
git clone --recursive https://github.com/polybar/polybar
cd polybar
mkdir build
cd build
cmake ..
make -j$(nproc)
# Optional. This will install the polybar executable in /usr/local/bin
sudo make install

mkdir -p ~/gits
cd ~/gits
git clone https://github.com/adi1090x/polybar-themes.git
cd polybar-themes/polybar-6
sudo cp -r fonts/*  /usr/share/fonts/
fc-cache

sudo pacman -S pacman-contrib

cd ~/my_settings && stow polybar
```

## Browser

```
pacman -S firefox gtk-engine-murrine gtk-engines lxappearence meld
cd ~/gits
git clone https://github.com/vinceliuice/vimix-gtk-themes
cd vimix-gtk-themes
./Install
# config with lxappearence
```


# Power Settings

TODO
