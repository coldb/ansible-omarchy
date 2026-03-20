return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")

    -- REQUIRED
    harpoon:setup()
    -- REQUIRED

    vim.keymap.set("n", "<leader>a", function()
      harpoon:list():add()
    end, { desc = "Harpoon add item to list" })
    vim.keymap.set("n", "<C-e>", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "Harpoon show menu" })

    vim.keymap.set("n", "<leader>j", function()
      harpoon:list():select(1)
    end, { desc = "Harpoon select item 1" })
    vim.keymap.set("n", "<leader>k", function()
      harpoon:list():select(2)
    end, { desc = "Harpoon select item 2" })
    vim.keymap.set("n", "<leader>l", function()
      harpoon:list():select(3)
    end, { desc = "Harpoon select item 3" })
    vim.keymap.set("n", "<leader>;", function()
      harpoon:list():select(4)
    end, { desc = "Harpoon select item 4" })

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set("n", "<C-S-P>", function()
      harpoon:list():prev()
    end)
    vim.keymap.set("n", "<C-S-N>", function()
      harpoon:list():next()
    end)
  end,
}
