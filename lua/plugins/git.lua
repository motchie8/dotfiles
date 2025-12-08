return {
  -- Git commands and Gdiffsplit
  {
    "tpope/vim-fugitive",
    event = "VeryLazy",
  },
  -- Git decoration
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },
  -- Git diffview
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    config = function()
      require("diffview").setup {
        view = {
          default = {
            layout = "diff2_horizontal",
            -- layout = "diff3_mixed",
          },
        },
      }
      vim.api.nvim_set_keymap(
        "n",
        "<Leader>GD",
        "<Cmd>DiffviewOpen<CR>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<Leader>GF",
        "<Cmd>DiffviewFileHistory %<CR>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<Leader>GB",
        "<Cmd>DiffviewFileHistory<CR>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<Leader>GP",
        "<Cmd>DiffviewOpen origin/HEAD...HEAD --imply-local<CR>",
        { noremap = true, silent = true }
      )
    end,
  },
}
