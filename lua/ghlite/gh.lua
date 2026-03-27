local comments_utils = require('ghlite.comments_utils')
local config = require('ghlite.config')
local utils = require('ghlite.utils')

--- @class GHLiteGitHubUser
--- @field login string

--- @class GHLiteLabel
--- @field name string

--- @class GHLiteReview
--- @field author GHLiteGitHubUser
--- @field state string

--- @class GHLitePRComment
--- @field author GHLiteGitHubUser
--- @field body string
--- @field createdAt string

--- @class PullRequest
--- @field number integer
--- @field baseRefName string
--- @field baseRefOid string|nil
--- @field headRefName string
--- @field headRefOid string
--- @field reviewDecision string|nil

--- @class PullRequestListItem: PullRequest
--- @field title string
--- @field author GHLiteGitHubUser
--- @field createdAt string
--- @field isDraft boolean
--- @field labels GHLiteLabel[]

--- @class PullRequestInfo: PullRequestListItem
--- @field url string
--- @field comments GHLitePRComment[]
--- @field reviews GHLiteReview[]
--- @field body string
--- @field changedFiles integer

--- @class GHLiteRawCommentUser
--- @field login string

--- @class GHLiteRawComment
--- @field id integer
--- @field html_url string
--- @field path string
--- @field line integer|userdata
--- @field start_line integer|userdata
--- @field user GHLiteRawCommentUser
--- @field body string
--- @field updated_at string
--- @field diff_hunk string
--- @field in_reply_to_id integer|nil

--- @class GHLiteResponseWithErrors
--- @field errors? table

local f = string.format

--- @class GHLiteGhModule
local M = {}

--- @generic T
--- @param str string
--- @param default T
--- @return T
local function parse_or_default(str, default)
  local success, result = pcall(vim.json.decode, str)
  if success then
    return result
  end

  return default
end

--- @param cb GHLitePullRequestCallback
function M.get_current_pr(cb)
  utils.system_str_cb(
    'gh pr view --json headRefName,headRefOid,number,baseRefName,baseRefOid,reviewDecision',
    function(result, stderr)
      local prefix = 'Unknown JSON field'
      if result == nil then
        cb(nil)
        return
      elseif string.sub(stderr, 1, #prefix) == prefix then
        utils.system_str_cb(
          'gh pr view --json headRefName,headRefOid,number,baseRefName,reviewDecision',
          function(result2)
            if result2 == nil then
              cb(nil)
              return
            end
            cb(parse_or_default(result2, nil))
          end
        )
      else
        cb(parse_or_default(result, nil))
      end
    end
  )
end

--- @param pr_number integer
--- @param cb fun(pr_info: PullRequestInfo|nil)
function M.get_pr_info(pr_number, cb)
  utils.system_str_cb(
    f(
      'gh pr view %s --json url,author,title,number,labels,comments,reviews,body,changedFiles,isDraft,createdAt',
      pr_number
    ),
    function(result)
      if result == nil then
        cb(nil)
        return
      end
      config.log('get_pr_info resp', result)

      cb(parse_or_default(result, nil))
    end
  )
end

--- @param cb GHLiteStringCallback
local function get_repo(cb)
  utils.system_str_cb('gh repo view --json nameWithOwner -q .nameWithOwner', function(result)
    if result ~= nil then
      cb(vim.split(result, '\n')[1])
    end
  end)
end

--- @param pr_number integer
--- @param cb GHLiteGroupedCommentsCallback
function M.load_comments(pr_number, cb)
  get_repo(function(repo)
    config.log('repo', repo)
    utils.system_str_cb(f('gh api repos/%s/pulls/%d/comments', repo, pr_number), function(comments_json)
      --- @type GHLiteRawComment[]
      local comments = parse_or_default(comments_json, {})
      config.log('comments', comments)

      --- @param comment GHLiteRawComment
      --- @return boolean
      local function is_valid_comment(comment)
        return comment.line ~= vim.NIL
      end

      comments = utils.filter_array(comments, is_valid_comment)
      config.log('Valid comments count', #comments)
      config.log('comments', comments)

      comments_utils.group_comments(comments, function(grouped_comments)
        config.log('Valid comments groups count:', #grouped_comments)
        config.log('grouped comments', grouped_comments)

        cb(grouped_comments)
      end)
    end)
  end)
end

--- @param pr_number integer
--- @param body string
--- @param reply_to integer
--- @param cb fun(resp: GHLiteResponseWithErrors)
function M.reply_to_comment(pr_number, body, reply_to, cb)
  get_repo(function(repo)
    --- @type string[]
    local request = {
      'gh',
      'api',
      '--method',
      'POST',
      f('repos/%s/pulls/%d/comments', repo, pr_number),
      '-f',
      'body=' .. body,
      '-F',
      'in_reply_to=' .. reply_to,
    }
    config.log('reply_to_comment request', request)

    utils.system_cb(request, function(result)
      --- @type GHLiteResponseWithErrors
      local resp = parse_or_default(result, { errors = {} })

      config.log('reply_to_comment resp', resp)
      cb(resp)
    end)
  end)
end

--- @param selected_pr PullRequest
--- @param body string
--- @param path string
--- @param start_line integer
--- @param line integer
--- @param cb fun(resp: GHLiteRawComment|GHLiteResponseWithErrors)
function M.new_comment(selected_pr, body, path, start_line, line, cb)
  get_repo(function(repo)
    local commit_id = selected_pr.headRefOid

    --- @type string[]
    local request = {
      'gh',
      'api',
      '--method',
      'POST',
      f('repos/%s/pulls/%d/comments', repo, selected_pr.number),
      '-f',
      'body=' .. body,
      '-f',
      'commit_id=' .. commit_id,
      '-f',
      'path=' .. path,
      '-F',
      'line=' .. line,
      '-f',
      'side=RIGHT',
    }

    if start_line ~= line then
      table.insert(request, '-F')
      table.insert(request, 'start_line=' .. start_line)
    end

    config.log('new_comment request', request)

    utils.system_cb(request, function(result)
      --- @type GHLiteRawComment|GHLiteResponseWithErrors
      local resp = parse_or_default(result, { errors = {} })
      config.log('new_comment resp', resp)
      cb(resp)
    end)
  end)
end

--- @param selected_pr PullRequest
--- @param body string
--- @param cb GHLiteSystemCallback
function M.new_pr_comment(selected_pr, body, cb)
  --- @type string[]
  local request = {
    'gh',
    'pr',
    'comment',
    f('%d', selected_pr.number),
    '--body',
    body,
  }

  config.log('new_pr_comment request', request)

  utils.system_cb(request, function(result)
    config.log('new_pr_comment resp', result)
    cb(result)
  end)
end

--- @param comment_id integer
--- @param body string
--- @param cb fun(resp: GHLiteResponseWithErrors)
function M.update_comment(comment_id, body, cb)
  get_repo(function(repo)
    --- @type string[]
    local request = {
      'gh',
      'api',
      '--method',
      'PATCH',
      f('repos/%s/pulls/comments/%s', repo, comment_id),
      '-f',
      'body=' .. body,
    }
    config.log('update_comment request', request)

    utils.system_cb(request, function(result)
      --- @type GHLiteResponseWithErrors
      local resp = parse_or_default(result, { errors = {} })
      config.log('update_comment resp', resp)
      cb(resp)
    end)
  end)
end

--- @param comment_id integer
--- @param cb GHLiteSystemCallback
function M.delete_comment(comment_id, cb)
  get_repo(function(repo)
    --- @type string[]
    local request = {
      'gh',
      'api',
      '--method',
      'DELETE',
      f('repos/%s/pulls/comments/%s', repo, comment_id),
    }
    config.log('delete_comment request', request)

    utils.system_cb(request, function(resp)
      config.log('delete_comment resp', resp)
      cb(resp)
    end)
  end)
end

--- @param number integer
--- @param cb GHLitePullRequestCallback
function M.get_pr_by_number(number, cb)
  utils.system_str_cb(
    string.format('gh pr view %d --json number,title,author,createdAt,isDraft,reviewDecision,headRefName,headRefOid,baseRefName,baseRefOid,labels', number),
    function(resp, stderr)
      config.log('get_pr_by_number resp', resp)
      --- @type PullRequestListItem
      cb(parse_or_default(resp, {}))
    end
  )
end

--- @param number integer
--- @param cb GHLiteSystemStrCallback
function M.checkout_pr(number, cb)
  utils.system_str_cb(f('gh pr checkout %d', number), cb)
end

--- @param number integer
--- @param cb GHLiteSystemStrCallback
function M.approve_pr(number, cb)
  utils.system_str_cb(f('gh pr review %s -a', number), cb)
end

--- @param number integer
--- @param body string
--- @param cb GHLiteSystemCallback
function M.request_changes_pr(number, body, cb)
  --- @type string[]
  local request = {
    'gh',
    'pr',
    'review',
    f('%d', number),
    '-r',
    '--body',
    body,
  }

  config.log('request_changes_pr request', request)

  utils.system_cb(request, function(result)
    config.log('request_changes_pr resp', result)
    cb(result)
  end)
end

--- @param cb GHLiteStringCallback
function M.get_user(cb)
  utils.system_str_cb('gh api user -q .login', function(result)
    if result ~= nil then
      cb(vim.split(result, '\n')[1])
    end
  end)
end

return M
