local function find_venv_python(root)
  for _, name in ipairs({ ".venv", "venv" }) do
    local python = root .. "/" .. name .. "/bin/python"
    if vim.uv.fs_stat(python) then
      return python
    end
  end
  return nil
end

return {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    ".venv",
    "venv",
    ".git",
  },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".venv", "venv", ".git" }
    local root = vim.fs.root(fname, markers)
    on_dir(root or vim.fn.getcwd())
  end,
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "standard",
      },
    },
  },
  on_init = function(client)
    local root = client.config.root_dir
    if not root then return end

    local python = find_venv_python(root)
    if python then
      client.config.settings.python = { pythonPath = python }
      client:notify("workspace/didChangeConfiguration", {
        settings = client.config.settings,
      })
    end
  end,
}
