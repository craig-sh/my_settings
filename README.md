Install configs with commands like:

	`stow vim`

For usrlocalbins/systemd do

	`sudo stow usrlocalbins -t'/'`
	`sudo stow systemd -t'/'`

For installing via nix.

```
sh <(curl -L https://nixos.org/nix/install) --no-daemon
. ${HOME}/.nix-profile/etc/profile.d/nix.sh

export NIX_PATH=${NIX_PATH:+$NIX_PATH:}$HOME/.nix-defexpr/channels
nix-channel --add https://github.com/nix-community/home-manager/archive/release-22.11.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

cd ~/my_settings
stow nix
#symlink home.nix to point to desired config
home-manager switch

# To set default shell its kinda manual still
sudo -i
echo /home/craig/.nix-profile/bin/zsh >> /etc/shells
chsh --shell /home/craig/.nix-profile/bin/zsh craig
```
