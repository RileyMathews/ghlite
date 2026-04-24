# ghlite.nvim

Neovim plugin to work GitHub PRs quickly.

Main idea of this plugin to have tools that augment GitHub PR review using web
instead of replacing it like other plugins do.

[![ghlite.nvim intro](https://img.youtube.com/vi/TwzA3bhLrE4/0.jpg)](https://www.youtube.com/watch?v=TwzA3bhLrE4)

## Requirements

- nvim 0.10+

- [GitHub CLI (gh)](https://cli.github.com/)

- If you are using fzf-lua or telescope you might want to checkout how to
  override UI select. E.g. `vim.cmd('FzfLua register_ui_select')`

- [Diffview.nvim](https://github.com/sindrets/diffview.nvim) (optional, for enhanced diff viewing)

- [codediff.nvim](https://github.com/esmuellert/codediff.nvim) (optional, alternative for enhanced diff viewing)

## Installation

Using lazyvim.

Recommended config. This reproduces the current intended workflow using the Lua API directly.

```lua
  {
    'daliusd/ghlite.nvim',
    config = function()
      local ghlite = require('ghlite')

      ghlite.setup({
        debug = false, -- if set to true debugging information is written to ~/.ghlite.log file
        view_split = 'vsplit', -- set to empty string '' to open in active buffer, use 'tabnew' to open in tab
        diff_tool = 'auto', -- 'diffview', 'codediff', or 'auto' - which tool to use for ghlite.load_pr_diffview()
        html_comments_command = { 'lynx', '-stdin', '-dump' }, -- command to render HTML comments in PR view
      })

      vim.keymap.set('n', '<leader>uv', ghlite.load_pr_view, { silent = true, desc = 'PR View' })
      vim.keymap.set('n', '<leader>uu', ghlite.load_comments, { silent = true, desc = 'PR Load Comments' })
      vim.keymap.set('n', '<leader>ul', ghlite.load_pr_diffview, { silent = true, desc = 'PR Diffview' })
      vim.keymap.set('n', '<leader>up', function()
        local pr_number = tonumber(vim.fn.input('PR number: '))
        if pr_number ~= nil then
          ghlite.open_pr(pr_number)
        end
      end, { silent = true, desc = 'Open PR by number' })
      vim.keymap.set('n', '<leader>us', ghlite.submit_review, { silent = true, desc = 'PR Submit review' })
      vim.keymap.set('n', '<leader>uc', ghlite.comment_on_pr, { silent = true, desc = 'PR top-level comment' })
      vim.keymap.set('n', '<leader>um', ghlite.comment_on_line, { silent = true, desc = 'PR Add comment' })
      vim.keymap.set('x', '<leader>um', ghlite.comment_on_line, { silent = true, desc = 'PR Add comment' })
      vim.keymap.set('n', '<leader>ue', ghlite.update_comment, { silent = true, desc = 'PR Update comment' })
      vim.keymap.set('n', '<leader>ud', ghlite.delete_comment, { silent = true, desc = 'PR Delete comment' })
      vim.keymap.set('n', '<leader>ug', ghlite.open_comment, { silent = true, desc = 'PR Open comment' })
    end,
  }
```

## PR Review using ghlite.nvim

### Quick PR review

If you want to review a PR without manually checking out branches first:

- Call `require('ghlite').open_pr(<number>)` to open a PR by number. This checks
  out the PR branch and opens the PR view.

- Call `require('ghlite').load_pr_diffview()` to open the PR diff in
  diffview.nvim or codediff.nvim. Review comments are loaded as diagnostics in
  the diff buffers.

- Call `require('ghlite').comment_on_line()` to comment in existing
  conversations or start a new one directly in diff view. Alternatively you can
  use `require('ghlite').open_comment()` to open the comment thread under the
  cursor in a floating buffer.

- Call `require('ghlite').submit_review()` to choose whether to approve,
  request changes, or submit a normal review comment on the selected PR.

### Thorough PR review

If you want to review both the diff and the surrounding checked-out code:

- Call `require('ghlite').open_pr(<number>)` to check out the PR branch and
  open the PR view. You can call `require('ghlite').load_pr_view()` anytime
  later to refresh it. If you already have the PR branch checked out, the
  plugin can resolve the PR from the current branch.

- Call `require('ghlite').load_pr_diffview()` to review the PR diff. Comments
  are shown as diagnostics in the diff buffers and in opened files when they
  map to the PR.

- Call `require('ghlite').load_comments()` to review all comments in the code if
  diff view is not enough. List of comments is loaded to quickfix and shown in
  file as diagnostic messages.

- Call `require('ghlite').comment_on_line()` to comment in existing
  conversations or start a new one. Alternatively you can use
  `require('ghlite').open_comment()` to open the comment thread under the cursor
  in a floating buffer.

- Call `require('ghlite').submit_review()` to choose whether to approve,
  request changes, or submit a normal review comment on the selected PR.

## Lua API

### `open_pr(number)`

Opens a PR by number, checks out its branch, and then opens the PR view.

### `load_pr_view()`

Shows PR information (wrapper for `gh pr view`).

Note: You can use default vim shortcuts as well, like `gx` to open links in
this view.

HTML comments is the thing too and they look bad in text. To render HTML as
text `html_comments_command` settings can be used to specify command. You can
use any command here that accepts html via stdin and outputs text to stdout. By
default `lynx` is used, but if something works better for you feel free to use
it.

Plugin searches for html tag and only then passes comment through
`html_comments_command`. You can disable this functionality by setting
`html_comments_command` as `false`.

### `submit_review()`

Opens a picker to approve, request changes, or submit a normal review comment
on the selected PR.

### `comment_on_pr()`

Comments on the PR at the top level, instead of commenting on code.

### `load_comments()`

Loads PR comments. Only non-outdated review comments are loaded, PR comments are
not loaded. Comments are loaded to quickfix list and to buffer diagnostics on
buffer load. Navigate quickfix list using `cnext` and `cprev` (assumption here
that you are using quickfix list in general).

NOTE: You must check out the git branch related to the PR, either with
`require('ghlite').open_pr(<number>)` or by using other tools.

### `load_pr_diffview()`

Shows PR diff using either
[Diffview.nvim](https://github.com/sindrets/diffview.nvim) or
[codediff.nvim](https://github.com/esmuellert/codediff.nvim), depending on the
`diff_tool` configuration option:

- `diff_tool = 'auto'` (default): Uses diffview.nvim if installed, otherwise
  codediff.nvim. If both are installed, diffview.nvim is preferred.
- `diff_tool = 'diffview'`: Always uses diffview.nvim (shows error if not
  installed)
- `diff_tool = 'codediff'`: Always uses codediff.nvim (shows error if not
  installed)

This command will not show correct diff sometimes if you have gh older than
2.63.0 (details here https://github.com/cli/cli/pull/9938).

### `comment_on_line()`

Opens a floating buffer where you can write your comment.

If you want to create multi-line comment then select multiple lines using
visual mode.

- `:w` submits the comment buffer and closes it.
- `q` closes the comment buffer in normal mode.
- If there is already loaded comment on cursor line (using `load_comments()`)
  then comment is added as reply to thread.
- If there is no comment on line then new conversation is started.

### `update_comment()`

Updates selected comment.

### `delete_comment()`

Deletes selected comment.

### `open_comment()`

Opens the comment thread under cursor in a floating buffer.
