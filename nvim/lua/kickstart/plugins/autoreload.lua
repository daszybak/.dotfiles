-- Auto-reload plugin configuration
-- Handles external file changes (essential for Claude Code workflow)

return {
	-- No external plugin needed - using built-in Neovim functionality
	-- This file sets up the autocommands for file watching

	{
		"lewis6991/gitsigns.nvim",
		-- gitsigns already handles refreshing on file changes,
		-- but we add explicit refresh on focus for reliability
		config = function(_, opts)
			require("gitsigns").setup(opts)

			-- Refresh gitsigns when returning to buffer (helps with external edits)
			vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
				callback = function()
					if vim.bo.filetype ~= "" then
						pcall(function()
							require("gitsigns").refresh()
						end)
					end
				end,
				desc = "Refresh gitsigns on focus",
			})
		end,
	},
}

