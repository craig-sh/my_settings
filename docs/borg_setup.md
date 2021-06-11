*First setup a borg repo

```
borg init --encryption=repokey '/windrive/Backups/ArchBorg/'
borg key export
borg key export '/windrive/Backups/ArchBorg/' ~/private/borgkey.key
```

Script for backing up at ~/my_settings/usrlocalbins/usr/local/bin/borg_backup.sh

To run everyday make a systemd timer
Create -> /etc/systemd/system/borg.timer

```
[Unit]
Description=Run borg daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

Create /etc/systemd/system/borg.service

```
[Unit]
Description=Runs borg to backup data
Wants=borg.timer

[Service]
Type=oneshot
ExecStart=/usr/local/bin/borg_backup.sh

[Install]
WantedBy=multi-user.target
```

Then run below
```
systemctl enable borg.timer
```
