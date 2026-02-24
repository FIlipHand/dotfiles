vim.o.relativenumber = true
vim.o.number = true
-- vim.o.wrap = false
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.g.mapleader = " "
vim.o.swapfile = false
vim.o.winborder = "rounded"
vim.opt.list = true
vim.opt.termguicolors = true
vim.opt.listchars = {
  space = "·",
  tab = "󰌒 ",
  trail = "·",
}
vim.opt.clipboard = "unnamedplus"

vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)

vim.pack.add({
    { src = "https://github.com/ellisonleao/gruvbox.nvim" },
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/lukas-reineke/indent-blankline.nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/nvim-mini/mini.completion" },
    { src = "https://github.com/nvim-mini/mini.comment" },
    { src = "https://github.com/nvim-mini/mini.pairs" },
    { src = "https://github.com/nvim-mini/mini.surround" },
    { src = "https://github.com/folke/trouble.nvim" },
    { src = "https://github.com/akinsho/bufferline.nvim" },
    { src = "https://github.com/nvim-tree/nvim-tree.lua" },
    { src = "https://github.com/nvim-mini/mini.icons" },
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
})

local gitapi = require("gitsigns")
vim.keymap.set('n', '<leader>gs', gitapi.preview_hunk, { desc = 'Gitsigns preview hunk' })
vim.keymap.set('n', '<leader>gr', gitapi.reset_hunk, { desc = 'Gitsigns reset buffer' })

require('mini.icons').setup()
MiniIcons.mock_nvim_web_devicons()

require("bufferline").setup()
require("nvim-tree").setup()

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

local function get_visual_selection()
  local _, srow, scol = unpack(vim.fn.getpos('v'))
  local _, erow, ecol = unpack(vim.fn.getpos('.'))
  if srow > erow or (srow == erow and scol > ecol) then
    srow, scol, erow, ecol = erow, ecol, srow, scol
  end
  local lines = vim.api.nvim_buf_get_text(0, srow - 1, scol - 1, erow - 1, ecol, {})
  return table.concat(lines, ' ')
end

vim.keymap.set('v', '<leader>ff', function()
  local sel = get_visual_selection()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)
  builtin.find_files({ default_text = sel })
end, { desc = 'Telescope find files (selection)' })

vim.keymap.set('v', '<leader>fg', function()
  local sel = get_visual_selection()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)
  builtin.live_grep({ default_text = sel })
end, { desc = 'Telescope live grep (selection)' })

local api = require('nvim-tree.api')
vim.keymap.set('n', '<leader>ft', api.tree.toggle, { desc = 'Toggle file tree' })
vim.keymap.set('n', '<leader>fd', api.tree.focus, { desc = 'Focus file tree' })


require("ibl").setup()
-- mini setup
vim.o.completeopt = 'menuone,noinsert'
require('mini.completion').setup()

-- Tab to accept completion, Shift-Tab to go back
vim.keymap.set('i', '<Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-y>'
  else
    return '<Tab>'
  end
end, { expr = true })

vim.keymap.set('i', '<S-Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-p>'
  else
    return '<S-Tab>'
  end
end, { expr = true })
require('mini.comment').setup()
-- Ctrl+/ to toggle comment in normal mode
vim.keymap.set('n', '<C-_>', function()
    require('mini.comment').toggle_lines(vim.fn.line('.'), vim.fn.line('.'))
end, { desc = 'Toggle comment' })

-- Ctrl+/ to toggle comment in visual mode
vim.keymap.set('v', '<C-_>', function()
    local start_line = vim.fn.line('v')
    local end_line = vim.fn.line('.')
    -- Ensure start_line is always less than or equal to end_line
    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end
    require('mini.comment').toggle_lines(start_line, end_line)
end, { desc = 'Toggle comment' })
-- Ctrl+/ to toggle comment in insert mode
vim.keymap.set('i', '<C-_>', '<Esc>:lua require("mini.comment").toggle_lines(vim.fn.line("."), vim.fn.line("."))<CR>a', { desc = 'Toggle comment' })

require('mini.pairs').setup()

-- Auto-insert () after completing a function/method and place cursor inside
vim.api.nvim_create_autocmd('CompleteDone', {
  callback = function()
    local item = vim.v.completed_item
    if not item or not item.kind then return end
    -- LSP kinds that are callable: Function, Method, Constructor
    local callable_kinds = { 'Function', 'Method', 'Constructor', 'f', 'm' }
    for _, k in ipairs(callable_kinds) do
      if item.kind:find(k) then
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local line = vim.api.nvim_get_current_line()
        local after = line:sub(col + 1)
        -- Only insert if next char isn't already a paren
        if after:sub(1, 1) ~= '(' then
          vim.api.nvim_feedkeys('()', 'n', false)
          -- Move cursor back inside the parens
          local left = vim.api.nvim_replace_termcodes('<Left>', true, false, true)
          vim.api.nvim_feedkeys(left, 'n', false)
        end
        break
      end
    end
  end,
})
-- there is a small bug here, where when importing a function in pytohn, it inserts automatically ()

require('mini.surround').setup()
require('trouble').setup()
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
})

-- Toggle diagnostics with <leader>dd
vim.keymap.set('n', '<leader>dd', function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = 'Toggle diagnostics' })

-- Subtle warning colors (must be after colorscheme)
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#7c6f4e" })
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#5c5238" })
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { sp = "#5c5238", undercurl = true })
  end,
})

require("mason").setup()

vim.lsp.enable({'clangd', 'basedpyright', 'bash-language-server'})

require("gruvbox").setup({
    italic = {
        strings = false
    },
    contrast = "hard",
    bold = true,
    terminal_colors = true,
    overrides = {
        pythonInclude = { fg = "#fb4934" }, -- gruvbox bright_red
    },
})
vim.cmd("colorscheme gruvbox")
