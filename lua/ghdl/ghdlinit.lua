local M = {}
local file1=[[{
  "options": {
    "ghdl_analysis": [
      "--workdir=work",
      "--ieee=synopsys",
      "-fexplicit"
    ]
  },
  "test":{
    "testbench":"testbench",
    "stop":"10us"
  },
  "files": [
]]
local file2=[[

  ]
}]]
local line1='    { "file": "'
local line2='", "language": "vhdl" }'
local rust_vhdl=[[standard="2008"
[libraries]
src.files=[
  "./*.vhdl",
]
]]
local utils=require("ghdl.utils")

M.ghdlinit=function()
  local path=vim.fn.getcwd()
  local files=io.popen('ls -a "'..path..'"')
  if files==nil then
    print("Could not list files in current directory")
    return
  end
  local rust_f=io.open("vhdl_ls.toml","w")
  if rust_f==nil then
    print("Could not create file vhdl_ls.toml for rust_hdl lsp")
    return
  end
  local file=file1
  local start=0
  local filelist={}
  print("Decide order of compilation (from top to bottom) by entering the numbers of the files seperated by spaces:")
  local count=0;
  for filename in files:lines() do
    if(string.find(filename,'.vhdl')) then
      print(count..": "..filename)
      filelist[count]=filename
      -- table.insert(filelist,{[count]=filename})
      count=count+1
    end
  end
  local order=vim.fn.input("Enter order: ")
  if order=="" then
    for ch=0,(count-1),1 do
      if(start==0) then
        file=file..line1..filelist[tonumber(ch)]..line2
        start=1
      else
        file=file..",\n"..line1..filelist[tonumber(ch)]..line2
      end
    end
  else
    order=order:match('^(.*%S)%s*$')
    for ch in order:gmatch("%S+") do
      if(start==0) then
        file=file..line1..filelist[tonumber(ch)]..line2
        start=1
      else
        file=file..",\n"..line1..filelist[tonumber(ch)]..line2
      end
    end
  end
  file=file..file2
  local f=io.open("./hdl-prj.json","w")
  if f==nil then
    print("could not write to ./hdl-prj.json")
    return
  end
  f:write(file)
  f:close()
end

M.ghdlupdate=function()
  local path=vim.fn.getcwd()
  local files=io.popen('ls -a "'..path..'"')
  if files==nil then
    print("Could not list files in current directory")
    return
  end
  local f=io.open("./hdl-prj.json","r")
  if f==nil then
    print("could not find ./hdl-prj.json")
    return
  end
  local text=f:read("a")
  f:close()
  local config=utils.jsondecode(text)
  if config == nil then
    print("could not decode json from ./hdl-prg.json")
    return
  end
  for filename in files:lines() do
    if(string.find(filename,'.vhdl')) then
      config=utils.insert(config,filename)
    end
  end
  local file=file1
  local start=0
  for _,val in ipairs(config.files) do
    if(start==0) then
        file=file..line1..val.file..line2
        start=1
      else
        file=file..",\n"..line1..val.file..line2
      end
  end
  file=file..file2
  f=io.open("./hdl-prj.json","w")
  if f==nil then
    print("could not write to ./hdl-prj.json")
    return
  end
  f:write(file)
  f:close()
end

M.ghdlreorder=function()
  local f=io.open("./hdl-prj.json","r")
  if f==nil then
    print(",/hdl-prj.json not found")
    return
  end
  local text=f:read("a")
  f:close()
  local config=utils.jsondecode(text)
  if config == nil then
    print("could not decode json from ./hdl-prg.json")
    return
  end
  local file=file1
  local start=0
  local filelist={}
  print("Decide order of compilation (from top to bottom) by entering the numbers of the files seperated by spaces:")
  local count=0;
  for _,val in ipairs(config.files) do
    print(count..": "..val.file)
    filelist[count]=val.file
    count=count+1
  end
  local order=vim.fn.input("Enter order: ")
  if order=="" then
    for ch=0,(count-1),1 do
      if(start==0) then
        file=file..line1..filelist[tonumber(ch)]..line2
        start=1
      else
        file=file..",\n"..line1..filelist[tonumber(ch)]..line2
      end
    end
  else
    order=order:match('^(.*%S)%s*$')
    for ch in order:gmatch("%S+") do
      if(start==0) then
        file=file..line1..filelist[tonumber(ch)]..line2
        start=1
      else
        file=file..",\n"..line1..filelist[tonumber(ch)]..line2
      end
    end
  end
  file=file..file2
  f=io.open("./hdl-prj.json","w")
  if f==nil then
    print("could not write to ./hdl-prj.json")
    return
  end
  f:write(file)
  f:close()
end
return M
