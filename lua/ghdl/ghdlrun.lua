local M = {}

local utils = require("ghdl.utils")
function M.ghdlanalyze(exit)
  local cmd="ghdl -a"
  local f=io.open("./hdl-prj.json","r")
  json=f:read("a")
  f:close()
  local config=utils.jsondecode(json)
  for k, file in ipairs(config.files) do
    cmd=cmd.." "..file.file
  end
  if exit==nil then exit =false end
  cmd=cmd .. utils.extra
  utils.ToggleTerminal(cmd, "float",exit)
end

function M.ghdlrun(args)
  local f=io.open("./hdl-prj.json","r")
  json=f:read("a")
  f:close()
  local config=utils.jsondecode(json)
  if args == nil then
    args=config.test.testbench
  end
  local command = "ghdl -r " .. args .. " --vcd=wave.vcd --stop-time=" .. config.test.stop..utils.extra
  utils.ToggleTerminal(command, "float",false)
  local job =vim.fn.jobstart("gtkwave wave.vcd")
end

function M.ghdlelaborate(args,exit)
  local f=io.open("./hdl-prj.json","r")
  json=f:read("a")
  f:close()
  local config=utils.jsondecode(json)
  if args == nil then
    args=config.test.testbench
  end
  local command = "ghdl -e " .. args .. utils.extra
  if exit==nil then exit =false end
  utils.ToggleTerminal(command, "float",exit)
end

function M.ghdlrunall(args)
  M.ghdlanalyze(true)
  M.ghdlelaborate(args,true)
  M.ghdlrun(args)
end
return M
