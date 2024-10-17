local M = {}

local utils = require("ghdl.utils")
function M.ghdlanalyze()
  local cmd="ghdl -a"
  local f=io.open("./hdl-prj.json","r")
  json=f:read("a")
  f:close()
  local config=utils.jsondecode(json)
  for k, file in ipairs(config.files) do
    cmd=cmd.." "..file.file
  end
  utils.ToggleTerminal(cmd, "float")
end
function M.ghdlrun(args)
  local command = "ghdl -r " .. args .. "--vcd=wave.vcd"
  utils.ToggleTerminal(command, "float")
end

function M.ghdlelaborate(args)
  local command = "ghdl -e " .. args
  utils.ToggleTerminal(command, "float")
end
return M
