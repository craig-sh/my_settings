{
    username,
    config,
    ...
}:
{
    services = {
        syncthing = {
            enable = true;
            user = "${username}";
            dataDir = "/home/${username}";
            configDir = "/home/${username}/.config/syncthing";
            overrideDevices = false;     # overrides any devices added or deleted through the WebUI
            overrideFolders = false;     # overrides any folders added or deleted through the WebUI
            openDefaultPorts = true;
            guiAddress = "0.0.0.0:8384";
            settings = {
                options = {
                    relaysEnabled = false;
                    urAccepted = -1;
                    globalAnnounceEnabled = false;
                };
#                devices = {
#                    "carbonarch" = {
#                        id = config.sops.templates."st-carbon-tpl".content;
#                        addresses = "tcp://carbonarch.localdomain:22000";
#                    };
#                    "homelab" = {
#                        id = config.sops.templates."st-homelab-tpl".content;
#                        addresses = "tcp://homelab.localdomain:31112";
#                    };
#                    "craigpixel6" = {
#                        id = config.sops.templates."st-pixel6-tpl".content;
#                        addresses = "tcp://craigpixel6.localdomain:22000";
#                    };
#                    "hypernix" = {
#                        id = config.sops.templates."st-hypernix-tpl".content;
#                        addresses = "tcp://hypernix.localdomain:22000";
#                    };
#                };
                folders = {
                    "Documents" = {         # Name of folder in Syncthing, also the folder ID
                        id = "ahef7-3ngex";
                        path = "/home/${username}/Documents";    # Which folder to add to Syncthing
#                        devices = [ "homelab" "craigpixel6" "carbonarch" "hypernix"];      # Which devices to share the folder with
                        ignorePerms = false;
                    };
                };
            };
        };
    };
}
