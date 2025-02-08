return {
  "numToStr/FTerm.nvim",
  event = 'VeryLazy',
  opts = { blend = 10, border = "double" },
  keys = {
    {
      "<F12>",
      function()
        require("FTerm").toggle()
      end,
      desc = "Open Terminal",
      mode = { "n", "t", "i" }
    },
  },
}
