--- @alias GHLiteStringCallback fun(value: string)
--- @alias GHLiteStringNilCallback fun(value: string|nil)
--- @alias GHLiteSystemStrCallback fun(stdout: string, stderr: string)
--- @alias GHLiteSystemCallback fun(stdout: string)
--- @alias GHLiteVoidCallback fun()
--- @alias GHLiteInputCallback fun(input: string)
--- @alias GHLiteBooleanCallback fun(value: boolean)
--- @alias GHLitePullRequestCallback fun(pr: PullRequest|nil)
--- @alias GHLitePullRequestListCallback fun(prs: PullRequestListItem[])
--- @alias GHLiteGroupedCommentsCallback fun(comments: table<string, GroupedComment[]>)
--- @alias GHLiteFileLineCallback fun(filename: string|nil, start_line: integer|nil, line: integer|nil)
--- @alias GHLiteCommentListsCallback fun(comments: Comment[], conversations: GroupedComment[])
--- @alias GHLiteOpenCommand 'edit'|'tabedit'|'split'|'vsplit'
--- @alias GHLiteDiffTool 'auto'|'diffview'|'codediff'
--- @alias GHLiteSplitCommand ''|'split'|'vsplit'|'tabnew'|string

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

--- @class GHLiteQfEntry
--- @field filename string
--- @field lnum integer
--- @field text string

--- @class GHLiteDiagnostic
--- @field lnum integer
--- @field col integer
--- @field message string
--- @field severity integer
--- @field source string

--- @class Comment
--- @field id integer
--- @field url string
--- @field path string
--- @field line integer
--- @field start_line integer|userdata
--- @field user string
--- @field body string
--- @field updated_at string
--- @field diff_hunk string

--- @class GroupedComment
--- @field id integer
--- @field line integer
--- @field start_line integer|userdata
--- @field url string
--- @field content string
--- @field comments Comment[]

--- @class FileNameAndLinePair
--- @field [1] string filename
--- @field [2] integer line

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
