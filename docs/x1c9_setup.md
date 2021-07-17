X1 Carbon Gen 9 specifics

# Audio
sudo pacman -S sof-firmware

# Video
sudo pacman -S xf86-video-intel # Needed this to adjust brightness settings although this is an od driver and not reccommended

# Firmware

sudo pacman -S fwupd udisks2

## Hibernate

Worked with no issues. Opening lid even brings system out of hibernate

For suspend then hibernate
sudo vim /etc/systemd/logind.conf
```
HandleLidSwitch=suspend-then-hibernate
HandlePowerKey=hibernate # this one is optional..unrelated to suspend-then-hibernate
```

sudo vim /etc/systemd/sleep.conf
```
HibernateDelaySec=60min
```
Then restart and it should work


Mouse Set tap to click with
```
sudo vim /etc/X11/xorg.conf.d/30-touchpad.conf

Section "InputClass"
        Identifier "libinput touchpad catchall"
        MatchIsTouchpad "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
        Option "Tapping" "on"
EndSection
```


Fingerprint
```
sudo pacman -Syu fprintd
```
follow steps in arch linux wiki for fprint
used polkit-gnome for authentication. ...fingerprint is registered but still not completely setup
