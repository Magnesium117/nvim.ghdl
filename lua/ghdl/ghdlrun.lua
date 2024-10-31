local M = {}

local utils = require("ghdl.utils")
local jobs={}
function M.ghdlanalyze(exit)
  local cmd="ghdl -a"
  local f=io.open("./hdl-prj.json","r")
  if f==nil then
    print("could not find ./hdl-prj.json")
    return
  end
  local json=f:read("a")
  f:close()
  local config=utils.jsondecode(json)
  if config == nil then
    print("could not decode json from ./hdl-prg.json")
    return
  end
  for _, file in ipairs(config.files) do
    cmd=cmd.." "..file.file
  end
  if exit==nil then exit =false end
  cmd=cmd .. utils.extra
  utils.ToggleTerminal(cmd, "float",exit)
end

function M.ghdlrun(args,opts)
  if args~=nil then
    if string.sub(args,1,1)=="-" then
      local sw=args
      args=opts
      opts=sw
    end
  end
  local keep_gtkwave=false
  if opts=="-k" then
    keep_gtkwave=true
  end
 local f=io.open("./hdl-prj.json","r")
  if f==nil then
    print("could not find ./hdl-prj.json")
    return
  end
  local json=f:read("a")
  f:close()
  local config=utils.jsondecode(json)
  if config == nil then
    print("could not decode json from ./hdl-prg.json")
    return
  end
  if args == nil then
    args=config.test.testbench
  end
  print(utils.getParentPath(debug.getinfo(1).source:sub(2)))
  local command = "ghdl -r " .. args .. " --vcd=wave.vcd --stop-time=" .. config.test.stop .. " && python "..utils.getParentPath(debug.getinfo(1).source:sub(2)) .. "/../../python/add_sigs.py wave.vcd 1 > wave.gtkw && echo 'do_initial_zoom_fit 1' > .gtkwaverc " .. utils.extra
  utils.ToggleTerminal(command, "float",false)
  -- vim.fn.jobstart("python python/add_sigs.py wave.vcd 1 > wave.gtkw")
  -- local job =vim.fn.jobstart("gtkwave wave.vcd")
  os.execute("sleep 0.001")
  if not keep_gtkwave then
    for _, job in ipairs(jobs) do
      vim.fn.jobstop(job)
    end
    jobs={}
  end
  jobs[#jobs+1]=vim.fn.jobstart("gtkwave wave.vcd wave.gtkw")
end

function M.ghdlelaborate(args,exit)
  local f=io.open("./hdl-prj.json","r")
  if f==nil then
    print("could not find ./hdl-prj.json")
    return
  end
  local json=f:read("a")
  f:close()
  local config=utils.jsondecode(json)
  if config == nil then
    print("could not decode json from ./hdl-prg.json")
    return
  end
  if args == nil then
    args=config.test.testbench
  end
  local command = "ghdl -e " .. args .. utils.extra
  if exit==nil then exit =false end
  utils.ToggleTerminal(command, "float",exit)
end

function M.ghdlrunall(args,opts)
  if args~=nil then
    if string.sub(args,1,1)=="-" then
      local swp=args
      args=opts
      opts=swp
    end
  end

  M.ghdlanalyze(true)
  M.ghdlelaborate(args,true)
  M.ghdlrun(args,opts)
end
return M


