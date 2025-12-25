-- Provides VSCode/GoLand-style side-by-side diff view for git changes
-- See staged, unstaged, and commit history in a familiar layout

return {
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles', 'DiffviewFileHistory' },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = '[G]it [D]iff view (unstaged)' },
      { '<leader>gs', '<cmd>DiffviewOpen --staged<cr>', desc = '[G]it [S]taged diff view' },
      { '<leader>gc', '<cmd>DiffviewClose<cr>', desc = '[G]it diff [C]lose' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = '[G]it file [H]istory' },
      { '<leader>gH', '<cmd>DiffviewFileHistory<cr>', desc = '[G]it branch [H]istory' },
      -- Full file blame view
      {
        '<leader>gb',
        function()
          require('gitsigns').blame()
        end,
        desc = '[G]it [B]lame (full file)',
      },
      -- Telescope git pickers
      { '<leader>gl', '<cmd>Telescope git_commits<cr>', desc = '[G]it [L]og (commits)' },
      { '<leader>gL', '<cmd>Telescope git_bcommits<cr>', desc = '[G]it buffer [L]og' },
      { '<leader>gB', '<cmd>Telescope git_branches<cr>', desc = '[G]it [B]ranches' },
      { '<leader>gS', '<cmd>Telescope git_status<cr>', desc = '[G]it [S]tatus' },
      { '<leader>gf', '<cmd>Telescope git_stash<cr>', desc = '[G]it stash' },
    },
    opts = {
      diff_binaries = false,
      enhanced_diff_hl = true,
      use_icons = true,
      show_help_hints = true,
      watch_index = true,
      view = {
        default = {
          layout = 'diff2_horizontal', -- Side-by-side like VSCode/GoLand
          winbar_info = true,
        },
        merge_tool = {
          layout = 'diff3_horizontal',
          disable_diagnostics = true,
          winbar_info = true,
        },
        file_history = {
          layout = 'diff2_horizontal',
          winbar_info = true,
        },
      },
      file_panel = {
        listing_style = 'tree', -- 'list' or 'tree'
        tree_options = {
          flatten_dirs = true,
          folder_statuses = 'only_folded', -- 'never', 'only_folded', 'always'
        },
        win_config = {
          position = 'left',
          width = 35,
        },
      },
      file_history_panel = {
        log_options = {
          git = {
            single_file = {
              diff_merges = 'combined',
            },
            multi_file = {
              diff_merges = 'first-parent',
            },
          },
        },
        win_config = {
          position = 'bottom',
          height = 16,
        },
      },
      keymaps = {
        view = {
          { 'n', 'q', '<cmd>DiffviewClose<cr>', { desc = 'Close diffview' } },
          { 'n', '<leader>e', '<cmd>DiffviewToggleFiles<cr>', { desc = 'Toggle file panel' } },
        },
        file_panel = {
          { 'n', 'q', '<cmd>DiffviewClose<cr>', { desc = 'Close diffview' } },
          { 'n', 's', '<cmd>DiffviewOpen --staged<cr>', { desc = 'View staged changes' } },
          { 'n', 'u', '<cmd>DiffviewOpen<cr>', { desc = 'View unstaged changes' } },
        },
        file_history_panel = {
          { 'n', 'q', '<cmd>DiffviewClose<cr>', { desc = 'Close diffview' } },
        },
      },
    },
  },
}

