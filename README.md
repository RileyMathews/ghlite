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

NOTE: default config here. You can skip all the settings if you are OK with defaults.

```lua
  {
    'daliusd/ghlite.nvim',
    config = function()
      require('ghlite').setup({
        debug = false, -- if set to true debugging information is written to ~/.ghlite.log file
        view_split = 'vsplit', -- set to empty string '' to open in active buffer, use 'tabnew' to open in tab
        diff_tool = 'auto', -- 'diffview', 'codediff', or 'auto' - which tool to use for GHLitePRDiffview
        comment_split = 'split', -- set to empty string '' to open in active buffer, use 'tabnew' to open in tab
        open_command = 'open', -- open command to use, e.g. on Linux you might want to use xdg-open
        html_comments_command = { 'lynx', '-stdin', '-dump' }, -- command to render HTML comments in PR view
        -- override default keymaps with the ones you prefer
        -- set keymap to false or '' to disable it
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
            send_comment = 'c<CR>' -- this one cannot be disabled
          },
          pr = {
            approve = 'cA',
            request_changes = 'cR',
            comment = 'ca',
          },
        },
      })
    end,
    keys = {
      { '<leader>uv', ':GHLitePRView<cr>',          silent = true, desc = 'PR View' },
      { '<leader>uu', ':GHLitePRLoadComments<cr>',  silent = true, desc = 'PR Load Comments' },
      { '<leader>ul', ':GHLitePRDiffview<cr>',      silent = true, desc = 'PR Diffview' },
      { '<leader>ua', ':GHLitePRAddComment<cr>',    silent = true, desc = 'PR Add comment' },
      { '<leader>ua', ':GHLitePRAddComment<cr>',    mode = 'x',    silent = true,             desc = 'PR Add comment' },
      { '<leader>uc', ':GHLitePRUpdateComment<cr>', silent = true, desc = 'PR Update comment' },
      { '<leader>ud', ':GHLitePRDeleteComment<cr>', silent = true, desc = 'PR Delete comment' },
      { '<leader>ug', ':GHLitePROpenComment<cr>',   silent = true, desc = 'PR Open comment' },
    }
  }
```

## PR Review using ghlite.nvim

### Quick PR review

If you want to review a PR without manually checking out branches first:

- Run `:GHLitePROpen <number>` to open a PR by number. This checks out the PR
  branch and opens the PR view.

- Run `:GHLitePRDiffview` to open the PR diff in diffview.nvim or codediff.nvim.
  Review comments are loaded as diagnostics in the diff buffers.

- Run `:GHLitePRAddComment` to comment in existing conversations or start the
  new one directly in diff view. Alternatively you can use
  `:GHLitePROpenComment` to open comments in browser.

- Run `:GHLitePRApprove` to approve PR if everything is OK. you can use
  `ca` in diff and pr views.

- Run `:GHLitePRRequestChanges` to request changes on PR if something is wrong.
  you can use `cr` in diff and pr views.

### Thorough PR review

If you want to review both the diff and the surrounding checked-out code:

- Run `:GHLitePROpen <number>` to check out the PR branch and open the PR view.
  You can open `:GHLitePRView` anytime later to refresh it. If you already have
  the PR branch checked out, the plugin can resolve the PR from the current
  branch.

- Run `:GHLitePRDiffview` to review the PR diff. Comments are shown as
  diagnostics in the diff buffers and in opened files when they map to the PR.

- Run `:GHLitePRLoadComments` to review all comments in the code if diff view
  is not enough. List of comments is loaded to quickfix and shown in file as
  diagnostic messages.

- Run `:GHLitePRAddComment` to comment in existing conversations or start the
  new one. Alternatively you can use `:GHLitePROpenComment` to open comments in
  browser.

- Run `:GHLitePRApprove` to approve PR if everything is OK. you can use
  `ca` in diff and pr views.

- Run `:GHLitePRRequestChanges` to request changes on PR if something is wrong.
  you can use `cr` in diff and pr views.

## Commands

### GHLitePROpen

This command opens a PR by number, checks out its branch, and then opens the PR
view.

### GHLitePRView

This command shows PR information (wrapper for `gh pr view`).

Supported key bindings:

* `cA` to approve PR

* `ca` to write top level PR comment

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

### GHLitePRApprove

This command approves selected PR.

### GHLitePRRequestChanges

This command request changes on PR.

### GHLitePRAddPRComment

This command allows to comment on PR at top level (vs commenting on the code).

### GHLitePRLoadComments

This command loads PR comments. Only non-outdated review comments are loaded,
PR comments are not loaded. Comments are loaded to quickfix list and to buffer
diagnostics on buffer load. Navigate quickfix list using `cnext` and `cprev`
(assumption here that you are using quickfix list in general).

NOTE: You must check out the git branch related to the PR, either with
`:GHLitePROpen <number>` or by using other tools.

### GHLitePRDiffview

This command shows PR diff using either
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

### GHLitePRAddComment

This command opens buffer where you can write your comment.

If you want to create multi-line comment then select multiple lines using
visual mode.

Supported key bindings:

* c-enter:

    * If there is already loaded comment on cursor line (using
      `GHLitePRLoadComments` command) then comment is added as reply to thread.

    * If there is no comment on line then new conversation is started.

### GHLitePRUpdateComment

This command updates selected comment.

### GHLitePRDeleteComment

This command deletes selected comment.

### GHLitePROpenComment

Opens comment under cursor in browser using `open_command` command (default
`open`).
