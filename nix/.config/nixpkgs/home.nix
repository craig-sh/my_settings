{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "craig";
  home.homeDirectory = "/home/craig";

  # Packages to install
  home.packages = [
    # pkgs is the set of all packages in the default home.nix implementation
    pkgs.zsh
    pkgs.ripgrep
    # todo integrate with zsh
    pkgs.exa
    # neovim dependencies
    pkgs.tree-sitter
    pkgs.nodejs
    pkgs.nodePackages.npm
  ];
  # zsh
  home.file.".profile".source = ../../../zsh/.profile;
  home.file.".zprofile".source = ../../../zsh/.zprofile;
  home.file.".zsh_aliases".source = ../../../zsh/.zsh_aliases;
  home.file.".zshenv".source = ../../../zsh/.zshenv;
  home.file.".zshrc".source = ../../../zsh/.zshrc;


  programs.git = {
    enable = true;
    userName = "craig-sh";
    userEmail = "craig.s.henriques@gmail.com";
    aliases = {
	# https://git-scm.com/docs/git-reset#git-reset-emgitresetemltmodegtltcommitgt
	# Undo last commit
      undo = "reset --soft HEAD^";

      # We wanna grab those pesky un-added files!
      # https://git-scm.com/docs/git-stash
      stash-all = "stash save --include-untracked";

      # Fancier log, one line per commit
      glog = "log -n20 --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";

      ffmerge = "merge --ff-only";

      # Diff the whole directory with meld in one shot
      dirdiff = "difftool --dir-diff --tool=meld";
    };
    delta = {
      enable = true;
      options = {
        features = "line-numbers decorations";
        whitespace-error-style = "22 reverse";
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-style = "bold yellow ul";
          file-decoration-style = "none";
        };
      };
    };
    extraConfig = {
      core = { editor = "vim"; };
      format = { pretty = "oneline"; };
      pull = { ff = "only"; };
      push = { default = "simple"; };
      color = { ui = "true"; };
      credential = { helper = "cache --timeout=1440"; };
      merge = { tool = "meld"; };
      mergetool = {
        meld = {
          cmd = ''cmd = meld "$LOCAL" "$MERGED" "$REMOTE" --output "$MERGED'';
        };
      };
      difftool = { 
        prompt = "false";
        meld = { cmd = ''meld "$LOCAL" "$REMOTE" ''; };
      };
    };
  };

  programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      tmuxPlugins.resurrect
      tmuxPlugins.continuum
      tmuxPlugins.yank
      tmuxPlugins.copycat
      tmuxPlugins.sidebar
      tmuxPlugins.extrakto
      {
        plugin = tmuxPlugins.dracula;
        extraConfig = ''
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
    terminal = "screen-256color";
    baseIndex = 1;
    shell = "${pkgs.zsh}/bin/zsh";
    keyMode = "vi";
    historyLimit = 10000;
    extraConfig = ''

      # split panes using | and -
      bind - split-window -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"

      # reload config file (change file location to your the tmux.conf you want to use)
      bind r source-file ~/.tmux.conf

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

      set-option -ga terminal-overrides ",xterm-kitty:Tc"

      # Copy/Pasting
      # Unbing ] to paste because im always clickiung it by mistake
      unbind ]

      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'V' send -X select-line
      bind-key -T copy-mode-vi 'r' send -X rectangle-toggle
      bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel "xclip -in -selection clipboard"


      # extra commands for interacting with the ICCCM clipboard
      bind C-c run "tmux save-buffer - | xclip -i -sel clipboard"
      bind C-v run "tmux set-buffer \"$(xclip -o -sel clipboard)\"; tmux paste-buffer"


      # Selection with mouse should copy to clipboard right away, in addition to the default action.
      unbind -n -Tcopy-mode-vi MouseDragEnd1Pane
      bind -Tcopy-mode-vi MouseDragEnd1Pane send -X copy-selection-and-cancel\; run "tmux save-buffer - | xclip -i -sel clipboard > /dev/null"


      # Middle click to paste from the clipboard
      unbind-key MouseDown2Pane
      bind-key -n MouseDown2Pane run " \
        X=$(xclip -o -sel clipboard); \
        tmux set-buffer \"$X\"; \
        tmux paste-buffer -p; \
        tmux display-message 'pasted!' \
      "


      # Plugin Configs
      set -g @copycat_search_C-j '((maxtool|cxjobs).*)>?'
      set -g @copycat_search_G '\b[0-9a-f]{5,40}\b' # Search for Git commits

      set-option -g status-position top
      set-option -g allow-rename off

      set -g @sidebar-tree-command 'tree -C'
    '';
  };


  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;


  #nixpkgs.overlays = [
  #  (import (builtins.fetchTarball {
  #    url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
  #  }))
  #];
  #programs.neovim = {
  #  enable = true;
  #  package = pkgs.neovim-nightly;
  #  extraPackages = with pkgs; [
  #    tree-sitter
  #  ];
  #};
}
