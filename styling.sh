
###################solarized stuffs
cd
wget --no-check-certificate https://raw.github.com/seebi/dircolors-solarized/master/dircolors.ansi-dark
mv dircolors.ansi-dark .dircolors
eval `dircolors ~/.dircolors`

sudo apt-get install git
git clone https://github.com/sigurdga/gnome-terminal-colors-solarized.git
cd gnome-terminal-colors-solarized

./set_dark.sh

###########GTK3 + Theme
sudo add-apt-repository ppa:upubuntu-com/gtk3

sudo apt-get update

sudo apt-get install gtk+3
sudo apt-get install gnome-tweak-tool

sudo add-apt-repository ppa:numix/ppa
sudo apt-get update
##sudo apt-get install numix-gtk-theme
sudo apt-get install numix-icon-theme numix-icon-theme-circle

#####################
sudo add-apt-repository ppa:noobslab/themes
sudo apt-get update
sudo apt-get install elementary-theme
#enable from advanced seetings