{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    sensibleOnTop = false;
    plugins = with pkgs; [
      #tmuxPlugins.resurrect
      tmuxPlugins.continuum
      tmuxPlugins.yank
      tmuxPlugins.copycat
      tmuxPlugins.sidebar
      tmuxPlugins.extrakto
      {
        plugin = tmuxPlugins.dracula;
        extraConfig = ''
          # set -g @dracula-plugins "battery attached-clients weather time"
          set -g @dracula-show-battery false
          set -g @dracula-show-weather false
          set -g @dracula-fixed-location "Toronto"
          set -g @dracula-show-fahrenheit false
          set -g @dracula-show-flags true
          set -g @dracula-military-time true
          set -g @dracula-show-timezone false
          set -g @dracula-left-icon-padding 2
          set -g @dracula-show-left-icon session
        '';
      }
    ];
    prefix = "C-a";
    escapeTime = 10;
    terminal = "tmux-256color";
    baseIndex = 1;
    shell = "${pkgs.zsh}/bin/zsh";
    keyMode = "vi";
    historyLimit = 10000;
    extraConfig = ''

      bind-key -n C-b send-prefix

      # split panes using | and -
      bind - split-window -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"

      # reload config file (change file location to your the tmux.conf you want to use)
      bind r source-file ~/.config/tmux/tmux.conf

      # Use Alt-vim keys without prefix key to switch panes
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D 
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R


      # ctrl pg-up/pg-down for switching windows
      bind-key -n C-Pageup previous-window
      bind-key -n C-Pagedown next-window

      # Enable mouse mode (tmux 2.1 and above)
      set -g mouse on

      # For passing through OSC52 copy/paste sequences
      set -g allow-passthrough on
      set -g set-clipboard on

      set-option -ga terminal-overrides ",xterm-kitty:Tc"

      # Copy/Pasting
      # Unbing ] to paste because im always clickiung it by mistake
      unbind ]

      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'V' send -X select-line
      bind-key -T copy-mode-vi 'r' send -X rectangle-toggle
      # 'y' and mouse selection handled by tmux-yank plugin (auto-detects wl-copy vs OSC52 for SSH)
      set -g @yank_selection 'clipboard'
      set -g @yank_selection_mouse 'clipboard'

      # extra commands for interacting with the ICCCM clipboard
      bind C-c run "tmux save-buffer - | wl-copy"
      bind C-v run "tmux set-buffer \"$(wl-paste)\"; tmux paste-buffer"


      # Middle click to paste from the clipboard
      unbind-key MouseDown2Pane
      bind-key -n MouseDown2Pane run " \
        X=$(wl-paste); \
        tmux set-buffer \"$X\"; \
        tmux paste-buffer -p; \
        tmux display-message 'pasted!' \
      "

      # Browse tmux pane in nvim
      #bind [ run-shell 'kitty @ kitten /home/craig/.local/share/nvim/lazy/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py --env "TMUX=$TMUX" --env "TMUX_PANE=#{pane_id}" --nvim-args --clean --noplugin -n'
      #bind ] run-shell 'kitty @ kitten /home/craig/.local/share/nvim/lazy/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py --env "TMUX=$TMUX" --env "TMUX_PANE=#{pane_id}"'
      #bind ] {
      #  capture-pane -S -
      #  save-buffer /tmp/tmux_buffer_tmp
      #  delete-buffer
      #  split-window
      #  send-keys 'nvim + /tmp/tmux_buffer_tmp' Enter
      #}

      bind-key ] {
        capture-pane -eJS -
        save-buffer /tmp/tmux_buffer_tmp
        delete-buffer
        display-popup -h 100% -w 100% -E "nvim +'lua Snacks.terminal.colorize(); vim.opt.relativenumber=true' /tmp/tmux_buffer_tmp"
      }

      # Plugin Configs
      set -g @copycat_search_C-j '((maxtool|cxjobs).*)>?'
      set -g @copycat_search_G '\b[0-9a-f]{5,40}\b' # Search for Git commits

      set-option -g status-position top
      set-option -g allow-rename off

      set -g @sidebar-tree-command 'tree -C'
    '';
  };
}
