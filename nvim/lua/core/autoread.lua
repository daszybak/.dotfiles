-- Auto-reload files changed outside of Neovim
-- Essential for working with Claude Code and other external editors

local M = {}

function M.setup()
	-- Enable autoread - check for file changes when focus returns
	vim.o.autoread = true

	-- Create augroup for file watching
	local augroup = vim.api.nvim_create_augroup("AutoReload", { clear = true })

	-- Check for file changes when:
	-- 1. Focus returns to Neovim
	-- 2. Entering a buffer
	-- 3. After a short idle period
	vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
		group = augroup,
		pattern = "*",
		callback = function()
			-- Only check if buffer is valid and not in command-line mode
			if vim.fn.getcmdwintype() == "" then
				vim.cmd("checktime")
			end
		end,
		desc = "Check for external file changes",
	})

	-- Notify when file was changed externally
	vim.api.nvim_create_autocmd("FileChangedShellPost", {
		group = augroup,
		pattern = "*",
		callback = function()
			vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
		end,
		desc = "Notify on external file change",
	})

	-- Auto-reload when switching tabs/windows in Zellij/tmux
	vim.api.nvim_create_autocmd({ "VimResume", "TermLeave" }, {
		group = augroup,
		pattern = "*",
		callback = function()
			vim.cmd("checktime")
		end,
		desc = "Check for changes on terminal resume",
	})

	-- Reduce CursorHold time for faster detection
	-- (already set in main config but ensure it's reasonable)
	if vim.o.updatetime > 300 then
		vim.o.updatetime = 250
	end
end

return M

