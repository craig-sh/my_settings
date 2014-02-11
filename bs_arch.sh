#!/bin/bash

dir=~/my_settings                    # dotfiles directory
olddir=~/my_settings_old             # old dotfiles backup directory

configfiles="bspwm sxhkd tint2"    # list of files/folders to symlink in homedir
xfiles=".xinit .Xresources"

#####PUT IN CHECK TO MAKE SURE WE AREN"T MOVING SYMLINKS
for file in $configfiles; do
    if [-d ~/.config/$file];then
        mv ~/.config/$file/${file}rc $olddir/
        ln -s $dir/${file}r ~/.config/$file/${file}rc 
    fi
done


for file in $xfiles; do
    mv ~/$file $olddir/
    ln -s $dir/$file ~/$file 
done

#infinality
#####CHECK ROOT ACCESS
infa=/etc/profile.d/infinality-settings.sh

if [-f $infa];then
    mv $infa $olddir
    ln -s $dir/infinality-settings.sh $infa
fi
