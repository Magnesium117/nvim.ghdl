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
  print(utils.getParentPath(debug.getinfo(1).source:sub(2)))
  local command = "ghdl -r " .. args .. " --vcd=wave.vcd --stop-time=" .. config.test.stop .. " && python "..utils.getParentPath(debug.getinfo(1).source:sub(2)) .. "/../../python/add_sigs.py wave.vcd 1 > wave.gtkw && echo 'do_initial_zoom_fit 1' > .gtkwaverc " .. utils.extra
  utils.ToggleTerminal(command, "float",false)
  -- vim.fn.jobstart("python python/add_sigs.py wave.vcd 1 > wave.gtkw")
  -- local job =vim.fn.jobstart("gtkwave wave.vcd")
  os.execute("sleep 0.001")
  local job =vim.fn.jobstart("gtkwave wave.vcd wave.gtkw")
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


