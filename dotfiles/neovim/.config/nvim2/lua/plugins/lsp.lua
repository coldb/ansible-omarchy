return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim", opts = {} },
      { "folke/lazydev.nvim", ft = "lua", opts = {} },
    },
    config = function()
      -- Mason: install servers and tools
      require("mason").setup()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "ansible-language-server",
          "ansible-lint",
          "deno",
          "dockerfile-language-server",
          "eslint_d",
          "graphql-language-service-cli",
          "lua-language-server",
          "prettier",
          "prettierd",
          "stylua",
          "typescript-language-server",
          "yaml-language-server",
        },
      })

      -- Add Mason bin dir to PATH so vim.lsp.enable() finds installed servers
      vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

      -- Override server configs where needed (nvim-lspconfig provides defaults via lsp/ dir)
      vim.lsp.config("yamlls", {
        filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.ansible" },
        settings = {
          yaml = {
            format = {
              enable = true,
            },
          },
        },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
          },
        },
      })

      -- Detect Ansible YAML files
      vim.filetype.add({
        pattern = {
          [".*/playbooks/.*%.ya?ml"] = "yaml.ansible",
          [".*/roles/.*%.ya?ml"] = "yaml.ansible",
          [".*/tasks/.*%.ya?ml"] = "yaml.ansible",
          [".*/handlers/.*%.ya?ml"] = "yaml.ansible",
          [".*/host_vars/.*%.ya?ml"] = "yaml.ansible",
          [".*/group_vars/.*%.ya?ml"] = "yaml.ansible",
          [".*/ansible/.*%.ya?ml"] = "yaml.ansible",
        },
      })

      -- Enable servers (definitions come from nvim-lspconfig's lsp/ runtime files)
      vim.lsp.enable({
        "ansiblels",
        "ts_ls",
        "denols",
        "graphql",
        "yamlls",
        "dockerls",
        "lua_ls",
      })

      -- LspAttach autocmd for keymaps and completion
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Custom keymaps (not provided by Neovim 0.11+ defaults)
          map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
          map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
          map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

          -- Enable native LSP completion
          vim.opt.completeopt = { "menu", "menuone", "noinsert", "popup" }
          vim.lsp.completion.enable(true, event.data.client_id, event.buf, { autotrigger = true })

          -- Snippet navigation keymaps
          vim.keymap.set({ "i", "s" }, "<C-l>", function()
            if vim.snippet.active({ direction = 1 }) then
              vim.snippet.jump(1)
            end
          end, { buffer = event.buf, desc = "Snippet: Jump forward" })

          vim.keymap.set({ "i", "s" }, "<C-h>", function()
            if vim.snippet.active({ direction = -1 }) then
              vim.snippet.jump(-1)
            end
          end, { buffer = event.buf, desc = "Snippet: Jump backward" })

          -- Document highlight on CursorHold
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
              end,
            })
          end

          -- Toggle inlay hints
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, "[T]oggle Inlay [H]ints")
          end
        end,
      })
    end,
  },
}
