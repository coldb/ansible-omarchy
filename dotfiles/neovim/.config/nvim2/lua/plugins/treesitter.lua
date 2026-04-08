return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    require("nvim-treesitter").setup({})
    require("nvim-treesitter").install({ "bash", "c", "diff", "html", "javascript", "jsdoc", "lua", "luadoc", "markdown", "tsx", "typescript", "vim", "vimdoc" })
  end,
}
