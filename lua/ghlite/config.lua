--- @alias GHLiteDiffTool 'auto'|'diffview'|'codediff'
--- @alias GHLiteSplitCommand ''|'split'|'vsplit'|'tabnew'|string

--- @class GHLiteConfigMergeOptions
--- @field approved string
--- @field nonapproved string

--- @class GHLiteConfigDiffKeymaps
--- @field open_file string|false
--- @field open_file_tab string|false
--- @field open_file_split string|false
--- @field open_file_vsplit string|false
--- @field approve string|false
--- @field request_changes string|false

--- @class GHLiteConfigCommentKeymaps
--- @field send_comment string

--- @class GHLiteConfigPRKeymaps
--- @field approve string|false
--- @field request_changes string|false
--- @field merge string|false
--- @field comment string|false
--- @field diff string|false

--- @class GHLiteConfigKeymaps
--- @field diff GHLiteConfigDiffKeymaps
--- @field comment GHLiteConfigCommentKeymaps
--- @field pr GHLiteConfigPRKeymaps

--- @class GHLiteConfig
--- @field debug boolean
--- @field view_split GHLiteSplitCommand|false
--- @field diff_split GHLiteSplitCommand|false
--- @field diff_tool GHLiteDiffTool
--- @field comment_split GHLiteSplitCommand|false
--- @field open_command string
--- @field merge GHLiteConfigMergeOptions
--- @field html_comments_command string[]|false
--- @field keymaps GHLiteConfigKeymaps

--- @class GHLiteUserConfigMergeOptions
--- @field approved? string
--- @field nonapproved? string

--- @class GHLiteUserConfigDiffKeymaps
--- @field open_file? string|false
--- @field open_file_tab? string|false
--- @field open_file_split? string|false
--- @field open_file_vsplit? string|false
--- @field approve? string|false
--- @field request_changes? string|false

--- @class GHLiteUserConfigCommentKeymaps
--- @field send_comment? string

--- @class GHLiteUserConfigPRKeymaps
--- @field approve? string|false
--- @field request_changes? string|false
--- @field merge? string|false
--- @field comment? string|false
--- @field diff? string|false

--- @class GHLiteUserConfigKeymaps
--- @field diff? GHLiteUserConfigDiffKeymaps
--- @field comment? GHLiteUserConfigCommentKeymaps
--- @field pr? GHLiteUserConfigPRKeymaps

--- @class GHLiteUserConfig
--- @field debug? boolean
--- @field view_split? GHLiteSplitCommand|false
--- @field diff_split? GHLiteSplitCommand|false
--- @field diff_tool? GHLiteDiffTool
--- @field comment_split? GHLiteSplitCommand|false
--- @field open_command? string
--- @field merge? GHLiteUserConfigMergeOptions
--- @field html_comments_command? string[]|false
--- @field keymaps? GHLiteUserConfigKeymaps

--- @class GHLiteConfigModule
--- @field s GHLiteConfig
local M = {}

--- @type GHLiteConfig
M.s = {
  debug = false,
  view_split = 'vsplit',
  diff_split = 'vsplit',
  diff_tool = 'auto', -- 'diffview', 'codediff', or 'auto'
  comment_split = 'split',
  open_command = 'open',
  merge = {
    approved = '--squash',
    nonapproved = '--auto --squash',
  },
  html_comments_command = { 'lynx', '-stdin', '-dump' },
  keymaps = {
    diff = {
      open_file = 'gf',
      open_file_tab = '',
      open_file_split = 'o',
      open_file_vsplit = 'O',
      approve = 'cA',
      request_changes = 'cR',
    },
    comment = {
      send_comment = 'c<CR>',
    },
    pr = {
      approve = 'cA',
      request_changes = 'cR',
      merge = 'cM',
      comment = 'ca',
      diff = 'cp',
    },
  },
}

--- @param config GHLiteUserConfig|nil
function M.setup(config)
  M.s = vim.tbl_deep_extend('force', {}, M.s, config or {})
end

--- @param key string
--- @param message any
function M.log(key, message)
  if M.s.debug then
    local home = os.getenv('HOME')
    local log_file_name = home .. '/.ghlite.log'
    local log_file = io.open(log_file_name, 'a')
    if log_file then
      log_file:write(os.date('%Y-%m-%d %H:%M:%S') .. ' ' .. key .. ':\n')
      log_file:write(vim.inspect(message))
      log_file:write('\n\n')
      log_file:close()
    end
  end
end

return M
