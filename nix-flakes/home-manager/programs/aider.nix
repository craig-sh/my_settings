_: {
  programs.aider-chat = {
    enable = true;
    settings = {
      dark-mode = true;
    };
  };

  home.sessionVariables = {
    OLLAMA_API_BASE = "http://hypernix.localdomain:11434";
  };
}
