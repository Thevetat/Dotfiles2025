vim.g.lazyvim_eslint_auto_format = true

-- Set Node.js memory limit for LSP servers (8GB)
vim.env.NODE_OPTIONS = "--max-old-space-size=8192"

return {
  -- Configure LSP servers
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Override LSP keymaps to use <leader>C instead of <leader>c
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      
      -- Disable default <leader>c mappings
      keys[#keys + 1] = { "<leader>ca", false }
      keys[#keys + 1] = { "<leader>cr", false }
      keys[#keys + 1] = { "<leader>cR", false }
      keys[#keys + 1] = { "<leader>cl", false }
      keys[#keys + 1] = { "<leader>cA", false }
      keys[#keys + 1] = { "<leader>cc", false }
      keys[#keys + 1] = { "<leader>cC", false }
      
      -- Add new <leader>C mappings
      keys[#keys + 1] = { "<leader>Ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" }
      keys[#keys + 1] = { "<leader>Cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" }
      keys[#keys + 1] = { "<leader>CR", LazyVim.lsp.rename_file, desc = "Rename File", mode = "n", has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } }
      keys[#keys + 1] = { "<leader>Cl", "<cmd>LspInfo<cr>", desc = "Lsp Info" }
      keys[#keys + 1] = { "<leader>CA", function() vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } }) end, desc = "Source Action", has = "codeAction" }
      keys[#keys + 1] = { "<leader>Cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" }, has = "codeLens" }
      keys[#keys + 1] = { "<leader>CC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = "n", has = "codeLens" }
      
      -- Configure servers
      opts.servers = {
        jsonls = {
          settings = {
            json = {
              -- Use schemastore if available, otherwise use empty schemas
              schemas = (function()
                local ok, schemastore = pcall(require, "schemastore")
                if ok then
                  return schemastore.json.schemas()
                else
                  return {}
                end
              end)(),
              validate = { enable = true },
              -- Increase max file size for JSON language server (100MB)
              maxFileSize = 104857600,
            },
          },
          -- Increase memory limit for JSON language server
          init_options = {
            provideFormatter = true,
            maxItemsComputed = 50000,
          },
          -- Increase capabilities for large files
          capabilities = {
            workspace = {
              didChangeWatchedFiles = {
                dynamicRegistration = false,
              },
            },
          },
        },
        bashls = {
          settings = {
            bashIde = {
              shellcheckArguments = { "--exclude=SC2034" },
            },
          },
        },
        tsserver = {
          init_options = {
            preferences = {
              -- Enable all completions
              includeCompletionsWithSnippetText = true,
              includeCompletionsForImportStatements = true,
              includeCompletionsWithClassMemberSnippets = true,
            },
            -- Increase memory limit for large projects (16GB)
            maxTsServerMemory = 16384,
          },
        },
        yamlls = {
          settings = {
            yaml = {
              -- Increase limits for YAML files
              maxItemsComputed = 50000,
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              -- Increase workspace max preload and file size
              workspace = {
                maxPreload = 10000,
                preloadFileSize = 5000,
              },
            },
          },
        },
        eslint = {
          settings = {
            workingDirectories = { mode = "auto" },
            format = true,
          },
        },
      }
      
      opts.setup = {
        eslint = function()
          local function get_client(buf)
            return LazyVim.lsp.get_clients({ name = "eslint", bufnr = buf })[1]
          end

          local formatter = LazyVim.lsp.formatter({
            name = "eslint: lsp",
            primary = false,
            priority = 200,
            filter = "eslint",
          })

          if not pcall(require, "vim.lsp._dynamic") then
            formatter.name = "eslint: EslintFixAll"
            formatter.sources = function(buf)
              local client = get_client(buf)
              return client and { "eslint" } or {}
            end
            formatter.format = function(buf)
              local client = get_client(buf)
              if client then
                local diag = vim.diagnostic.get(buf, { namespace = vim.lsp.diagnostic.get_namespace(client.id) })
                if #diag > 0 then
                  vim.cmd("EslintFixAll")
                end
              end
            end
          end

          LazyVim.format.register(formatter)
        end,
      }
      
      return opts
    end,
  },
}