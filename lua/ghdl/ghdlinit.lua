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
local utils=require("ghdl.utils")
local json_pretty=require("ghdl.luajson")
-- local pickers = require("telescope.pickers")
--   
-- local finders = require("telescope.finders")
-- local conf = require("telescope.config").values
-- local actions = require("telescope.actions")
-- local action_state = require("telescope.actions.state")
-- local entry_display = require("telescope.pickers.entry_display")
-- local make_entry = require("telescope.make_entry")
-- local utils = require("platformio.utils")
-- local previewers = require("telescope.previewers")

M.ghdlinit=function()
  local path=vim.fn.getcwd()
  local files=io.popen('ls -a "'..path..'"')
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
  local so=false
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
  f:write(file)
  f:close()
end

M.ghdlupdate=function()
  local path=vim.fn.getcwd()
  local files=io.popen('ls -a "'..path..'"')
  local f=io.open("./hdl-prj.json","r")
  text=f:read("a")
  f:close()
  local config=utils.jsondecode(text)
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
  f:write(file)
  f:close()
end

M.ghdlreorder=function()
  local f=io.open("./hdl-prj.json","r")
  text=f:read("a")
  f:close()
  local config=utils.jsondecode(text)
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
  local f=io.open("./hdl-prj.json","w")
  f:write(file)
  f:close()
end
-- local boardentry_maker = function(opts)
--   local displayer = entry_display.create({
--     separator = "▏",
--     items = {
--       { width = 35 },
--       { width = 20 },
--       { width = 15 },
--     },
--   })
--
--   local make_display = function(entry)
--     return displayer({
--       entry.value.name,
--       entry.value.vendor,
--       entry.value.platform,
--     })
--   end
--
--   return function(entry)
--     return make_entry.set_default_entry_mt({
--       value = {
--         id = entry.id,
--         name = entry.name,
--         vendor = entry.vendor,
--         platform = entry.platform,
--         data = entry,
--       },
--       ordinal = entry.name .. " " .. entry.vendor .. " " .. entry.platform,
--       display = make_display,
--     }, opts)
--   end
-- end
--
-- local function pick_framework(board_details)
--   local opts = {}
--   pickers
--       .new(opts, {
--         prompt_title = "frameworks",
--         finder = finders.new_table({
--           results = board_details["frameworks"],
--         }),
--         attach_mappings = function(prompt_bufnr, _)
--           actions.select_default:replace(function()
--             actions.close(prompt_bufnr)
--             local selection = action_state.get_selected_entry()
--             local selected_framework = selection[1]
--             local command = "pio project init --ide=vim --board "
--                 .. board_details["id"]
--                 .. ' --project-option "framework='
--                 .. selected_framework
--                 .. '"'
--                 .. utils.extra
--             utils.ToggleTerminal(command, "float")
--           end)
--           return true
--         end,
--         sorter = conf.generic_sorter(opts),
--       })
--       :find()
-- end
--
-- local function pick_board(json_data)
--   local opts = {}
--   pickers
--       .new(opts, {
--         prompt_title = "Boards",
--         finder = finders.new_table({
--           results = json_data,
--           entry_maker = opts.entry_maker or boardentry_maker(opts),
--         }),
--         attach_mappings = function(prompt_bufnr, _)
--           actions.select_default:replace(function()
--             actions.close(prompt_bufnr)
--             local selection = action_state.get_selected_entry()
--             pick_framework(selection["value"]["data"])
--           end)
--           return true
--         end,
--         previewer = previewers.new_buffer_previewer({
--           title = "Board Info",
--           define_preview = function(self, entry, _)
--             local json = utils.strsplit(vim.inspect(entry["value"]["data"]), "\n")
--             local bufnr = self.state.bufnr
--             vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, json)
--             vim.defer_fn(function()
--               vim.api.nvim_buf_set_option(bufnr, 'wrap', true)
--               vim.api.nvim_buf_set_option(bufnr, 'linebreak', true)
--               vim.api.nvim_buf_set_option(bufnr, 'wrapmargin', 2)
--             end, 0)
--           end,
--         }),
--         sorter = conf.generic_sorter(opts),
--       })
--       :find()
-- end
--
-- function M.pioinit()
--   if not utils.pio_install_check() then
--     return
--   end
--
--   -- Read stdout
--   local command = "pio boards --json-output"
--   local handel = io.popen(command .. utils.devNul)
--   if not handel then
--     return
--   end
--   local json_str = handel:read("*a")
--   handel:close()
--
--   if #json_str == 0 then
--     -- read stderr
--     handel = io.popen(command .. " 2>&1")
--     if not handel then
--       return
--     end
--     local command_output = handel:read("*a")
--     handel:close()
--     vim.notify("Some error occured while executing `" .. command .. "`', command output: \n", vim.log.levels.WARN)
--     print(command_output)
--     return
--   end
--
--   local json_data = vim.json.decode(json_str)
--   pick_board(json_data)
-- end

return M
