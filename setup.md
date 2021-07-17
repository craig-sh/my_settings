# Install

# Internet Do this under arch chroot

```
sudo pacman -S netctl dhcpd openssh
```

# SSD

Follow archwiki for setting SSD trim
```
systemctl enable fstrim.timer
```

# Video drivers

* Needed to diable modesetting with kernel parameter nomodeset after installing nvidia driver. Otherwise got a black screen on boot
* Also needed to blacklist the i915 module otherwise wasn't able to startx

# User
```
pacman -S zsh sudo vim
useradd -m craig -s /bin/zsh
passwd craig
gpasswd -a craig wheel # add craig to wheel group
export EDITOR=/usr/bin/vim
visudo # enable permissions for craig
```

# Generic

```
sudo pacman -S wget curl git stow
sudo pacman -S gcc make vim
cd my_settings && stow install vim
```

# Commandline

## Rust

```
# Used for starship prompt currently
# install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# this can take a while to compile, can also directly install the binary
# https://starship.rs/#quick-install
cargo install starship
cd my_settings && stow install starship
```

## ZSH Settings

```
# From https://github.com/zdharma/zinit
mkdir ~/.zinit
git clone https://github.com/zdharma/zinit.git ~/.zinit/bin
sudo pacman -S fzf
cd ~/my_settings &&  rm -f ~/.zshrc && stow zsh
```


# Tmux

```
sudo pacman -S tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cd ~/my_settings && stow tmux
```

# Scripts

```
cd ~
git clone https://github.com/craig-sh/my_settings.git
cd ~/my_settings && sudo stow usrlocalbins -t'/'
cd ~/my_settings && stow git
```

## Pyenv

```
# Update
sudo pacman -Syu --needed base-devel openssl zlib bzip2 readline sqlite curl llvm ncurses xz tk libffi python-pyopenssl git
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
pyenv install <version>
# set version in zshrc
# Activate corrent env and then outside of venv install tools we use
# see nvim init file for other python tools
pip install python-language-server
pip install pynvim

mkdir -p ~/pyvenvs

# Install envs with
python -m ~/pyvenvs/<envname> --system-site-packages
```

## Nvim

### compile it

```
sudo pacman -S base-devel cmake unzip ninja tree-sitter
mkdir ~/gits
cd ~/gits
git clone https://github.com/neovim/neovim.git
make distclean && make CMAKE_BUILD_TYPE=Release
sudo make install
```

### Plugin/Misc setup

```
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
mkdir -p ~/nvimtmp
mkdir -p ~/nvimundo
sudo pacman -Syu ripgrep
pip install pynvim

# install nvm zinit will probably have already done this
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash

nvm install --lts
nvm use --lts

# install whatever languages servers run on node

# Pyright
npm install -g pyright
mkdir -p /home/craig/.local/bin
cd /home/craig/.local/bin
ln -s $(which pyright)
ln -s $(which pyright-langserver)

#Bash
npm i -g bash-language-server
cd /home/craig/.local/bin
ln -s $(which bash-language-server)

# Diagnostic
npm install -g  diagnostic-languageserver
cd /home/craig/.local/bin
ln -s $(which diagnostic-languageserver)


npm install -g
cd ~/my_settings && stow neovim

# In nvim
:TSInstall bash python rust json html
```




# GUI


## Start

```
sudo pacman -S xorg xclip xsel xdotool xss-lock
```

## Fonts

```
mkdir -p ~/.local/share/fonts
cd  ~/.local/share/fonts
# Download from
https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/FantasqueSansMono/Regular/complete/Fantasque%20Sans%20Mono%20Regular%20Nerd%20Font%20Complete.ttf
fc-cache -v
pacman -S noto-fonts-emoji
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

Check bspwm github for dependencies
```
sudo pacman -Syu bspwm sxhkd

              OR

mkdir wm ; cd wm
git clone https://github.com/baskerville/bspwm.git
git clone https://github.com/baskerville/sxhkd.git
cd bspwm && make && sudo make install
cd ../sxhkd && make && sudo make install
#####################

sudo pacman -Syu xclip xsel gvim feh

```

## Polybar

```
sudo pacman -Syu --needed cmake gcc pkg-config libxcb xcb-proto xcb-util-image xcb-util-wm libxcb xcb-util-xrm xcb-util-cursor jsoncpp curl libnl
pyenv shell system
mkdir -p ~/gits
cd ~/gits
git clone --recursive https://github.com/polybar/polybar
cd polybar
mkdir build
cd build
git checkout <version>
cmake ..
make -j$(nproc)
# Optional. This will install the polybar executable in /usr/local/bin
sudo make install

sudo pacman -S --needed pacman-contrib python-pywal calc

mkdir -p ~/gits
cd ~/gits
git clone https://github.com/adi1090x/polybar-themes.git
cd polybar-themes
./setup.sh

edit ~/.config/polybar/<theme-name>/config.ini
Set below configs:

    tray-position
    monitor
    bottom
    width = 100%
    height = 35
    background = ${color.background}

In ~/.config/polybar/<theme-name>/modules.ini
pin-workspaces: false


```


## Final

```
sudo pacman -S termite

cd ~/my_settings
stow bspwm
stow sxhkd
stow X11
stow termite


# Edit bspwm and  .xinitrc for machine specific setup
```

## Browser

```
sudo pacman -Syu firefox gtk-engine-murrine gtk-engines lxappearance-gtk3 meld arc-gtk-theme arc-icon-theme --needed
# config with lxappearence
```

## Password manager

```
sudo pacman -Syu keepassxc
```

# Music
```
sudo pacman -Syu pipewire piprewire-alsa piprewire-pulse spotifyd pavucontrol

cd ~/my_settings && stow spotifyd
# save password in file called .config/spotifyd/.spotify_pw
systemctl enable --user --now spotifyd.service
cargo intsall spotify-tui
# then follow instructions for adding client id and secret
```

# Utils
```
sudo pacman -S progress bat exa fd jq procs --needed

Install rust

then

cargo install git-delta
cargo install du-dust
cargo install bottom
```

# Podman

For rootless setup
```
# Needed containerd/crun because I ran into issues with secomp
# https://github.com/containers/podman/issues/8472

sudo pacman -S podman crun containerd
[root@carbonarch ~]# echo craig:10000:65536 >> /etc/subuid
[root@carbonarch ~]# echo craig:10000:65536 >> /etc/subgid


# add any registries
❯ tail -2 /etc/containers/registries.conf
[registries.search]
registries = ['docker.io']


pip install podman-compose
``` 

# Power Settings

Created scripts in usrlocalbins and systemd. See set-battery-threshold
