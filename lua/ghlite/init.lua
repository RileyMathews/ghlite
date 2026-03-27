local comments = require('ghlite.comments')
local config = require('ghlite.config')
local diff = require('ghlite.diff')
local pr_commands = require('ghlite.pr_commands')

--- @class GHLiteModule
local M = {}

local augroup = vim.api.nvim_create_augroup('GHLite', { clear = true })

local function del_user_command(name)
  pcall(vim.api.nvim_del_user_command, name)
end

--- @param user_config GHLiteUserConfig|nil
M.setup = function(user_config)
  config.setup(user_config)

  -- delete commands first so setup() can be safely rerun
  del_user_command('GHLitePRSelect')
  del_user_command('GHLitePROpen')
  del_user_command('GHLitePRCheckout')
  del_user_command('GHLitePRView')
  del_user_command('GHLitePRApprove')
  del_user_command('GHLitePRRequestChanges')
  del_user_command('GHLitePRMerge')
  del_user_command('GHLitePRAddPRComment')
  del_user_command('GHLitePRLoadComments')
  del_user_command('GHLitePRDiff')
  del_user_command('GHLitePRDiffview')
  del_user_command('GHLitePRAddComment')
  del_user_command('GHLitePRUpdateComment')
  del_user_command('GHLitePROpenComment')
  del_user_command('GHLitePRDeleteComment')

  vim.api.nvim_create_user_command('GHLitePROpen', function(opts)
    local pr_number = tonumber(opts.args)

    if pr_number == nil then
      vim.notify('PR number must be an integer', vim.log.levels.ERROR)
      return
    end

    pr_commands.open_pr_by_number(pr_number)
  end, { nargs = 1 })
  vim.api.nvim_create_user_command('GHLitePRView', pr_commands.load_pr_view, {})
  vim.api.nvim_create_user_command('GHLitePRApprove', pr_commands.approve_pr, {})
  vim.api.nvim_create_user_command('GHLitePRRequestChanges', pr_commands.request_changes_pr, {})
  vim.api.nvim_create_user_command('GHLitePRMerge', pr_commands.merge_pr, {})
  vim.api.nvim_create_user_command('GHLitePRAddPRComment', pr_commands.comment_on_pr, {})
  vim.api.nvim_create_user_command('GHLitePRLoadComments', comments.load_comments, {})
  vim.api.nvim_create_user_command('GHLitePRDiff', diff.load_pr_diff, {})
  vim.api.nvim_create_user_command('GHLitePRDiffview', diff.load_pr_diffview, {})
  vim.api.nvim_create_user_command('GHLitePRAddComment', comments.comment_on_line, { range = true })
  vim.api.nvim_create_user_command('GHLitePRUpdateComment', comments.update_comment, {})
  vim.api.nvim_create_user_command('GHLitePROpenComment', comments.open_comment, {})
  vim.api.nvim_create_user_command('GHLitePRDeleteComment', comments.delete_comment, {})

  -- clear old autocmds each time before recreating them
  vim.api.nvim_clear_autocmds({ group = augroup })

  vim.api.nvim_create_autocmd('BufReadPost', {
    group = augroup,
    pattern = '*',
    callback = function(args)
      comments.load_comments_on_buffer(args.buf)
    end,
  })

  vim.api.nvim_create_autocmd('BufEnter', {
    group = augroup,
    pattern = '*',
    callback = function(args)
      comments.load_comments_on_buffer(args.buf)
    end,
  })
end

return M
