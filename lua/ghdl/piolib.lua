local M = {}

local curl = require("plenary.curl")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local entry_display = require("telescope.pickers.entry_display")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local utils = require("platformio.utils")
local previewers = require("telescope.previewers")

local libentry_maker = function(opts)
  local displayer = entry_display.create({
    separator = "▏",
    items = {
      { width = 20 },
      { width = 20 },
      { remaining = true },
    },
  })

  local make_display = function(entry)
    return displayer({
      entry.value.name,
      entry.value.owner,
      entry.value.description,
    })
  end

  return function(entry)
    return make_entry.set_default_entry_mt({
      value = {
        name = entry.name,
        owner = entry.owner.username,
        description = entry.description,
        data = entry,
      },
      ordinal = entry.name .. " " .. entry.owner.username .. " " .. entry.description,
      display = make_display,
    }, opts)
  end
end

local function pick_library(json_data)
  local opts = {}
  table.sort(json_data["items"], function(lhs, rhs)
    return lhs.popularity_rank > rhs.popularity_rank
  end)
  pickers
      .new(opts, {
        prompt_title = "Libraries",
        finder = finders.new_table({
          results = json_data["items"],
          entry_maker = opts.entry_maker or libentry_maker(opts),
        }),
        attach_mappings = function(prompt_bufnr, _)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            local pkg_name = selection["value"]["owner"] .. "/" .. selection["value"]["name"]
            local command = 'pio pkg install --library "' .. pkg_name .. '"' .. utils.extra
            utils.ToggleTerminal(command, "float")
          end)
          return true
        end,

        previewer = previewers.new_buffer_previewer({
          title = "Package Info",
          define_preview = function(self, entry, _)
            local json = utils.strsplit(vim.inspect(entry["value"]["data"]), "\n")
            local bufnr = self.state.bufnr
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, json)
            vim.defer_fn(function()
              vim.api.nvim_buf_set_option(bufnr, 'wrap', true)
              vim.api.nvim_buf_set_option(bufnr, 'linebreak', true)
              vim.api.nvim_buf_set_option(bufnr, 'wrapmargin', 2)
            end, 0)
          end,
        }),
        sorter = conf.generic_sorter(opts),
      })
      :find()
end

function M.piolib(lib_arg_list)
  if not utils.pio_install_check() then
    return
  end

  local lib_str = ""

  for _, v in pairs(lib_arg_list) do
    lib_str = lib_str .. v .. "+"
  end

  local url = "https://api.registry.platformio.org/v3/search"
  local res = curl.get(url, {
    insecure = true,
    timeout = 20000,
    headers = { content_type = "application/json" },
    query = {
      query = lib_str,
      -- page = 1,
      -- limit = 1,
    },
  })

  if res["status"] == 200 then
    local json_data = vim.json.decode(res["body"])

    pick_library(json_data)
  else
    vim.notify(
      "API Request to platformio return HTTP code: "
      .. res["status"]
      .. "\nplease run `curl -LI "
      .. url
      .. "` for complete information",
      vim.log.levels.ERROR
    )
  end
end

return M