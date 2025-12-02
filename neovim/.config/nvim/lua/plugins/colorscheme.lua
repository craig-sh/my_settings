return {
  --"navarasu/onedark.nvim",
  --priority = 1000,
  --config = function()
  --  require('onedark').setup { style = 'dark' }
  --  require('onedark').load()
  --end
  {
   "catppuccin/nvim",
   name = "catppuccin",
   priority = 1000 ,
   config = function()
     require('catppuccin').setup { style = 'macchiato' }
     require('catppuccin').load()
   end
  }
}
