{
  workspaces = {
    format = "{icon}";
    on-click = "activate";
    format-icons = {
      "1" = ""; # terminals
      "2" = ""; # coding
      "3" = "󰆩"; # scratchpad
      "4" = "󰭻"; # comms
      "5" = "5";
      "6" = "󰖟"; # browser
      "7" = "󰢹"; # remote sessions
      "8" = "󰊴"; # gaming
      "9" = "9";
      "10" = "󰘨"; # Long running
      urgent = "󱈸";
    };
  };

  workspacesWindows = {
    active-only = true;
    format = "{windows}";
    workspace-taskbar = {
      enable = true;
      update-active-window = true;
      format = "{icon} {title:.15}";
      icon-size = 16;
      orientation = "horizontal";
    };
  };
}
