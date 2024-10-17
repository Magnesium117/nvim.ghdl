local M = {}

local utils = require("platformio.utils")

function M.piobuild()
  utils.cd_pioini()
  local command = "ghdl -a" .. utils.extra
  utils.ToggleTerminal(command, "float")
end

function M.pioupload()
  utils.cd_pioini()
  local command = "pio run --target upload" .. utils.extra
  utils.ToggleTerminal(command, "float")
end

function M.pioclean()
  utils.cd_pioini()
  local command = "pio run --target clean" .. utils.extra
  utils.ToggleTerminal(command, "float")
end

function M.piorun(arg)
  if not utils.pio_install_check() then
    return
  end

  if arg == nil then
    arg = "upload"
  end

  arg = utils.strsplit(arg, "%s")[1]
  if arg == "upload" then
    M.pioupload()
  elseif arg == "build" then
    M.piobuild()
  elseif arg == "clean" then
    M.pioclean()
  else
    vim.notify("Invalid argument: build, upload or clean", vim.log.levels.WARN)
  end
end

return M
