_: {
  services.zoneminder = {
    enable = true;

    # Database settings
    database = {
      createLocally = true;
      username = "zoneminder";
      password = "zmpass";
    };
    openFirewall = true;

    # Web server configuration
    #webserver = "nginx";

    # Storage configuration
    #storageDir = "/var/lib/zoneminder";

    # Additional camera configurations can be added here
    #cameras = {
    #  # Camera configurations will be added through the web interface
    #};
  };

  # Enable nginx if using it as the web server
  #services.nginx.enable = true;

  # Open firewall ports for web access
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
