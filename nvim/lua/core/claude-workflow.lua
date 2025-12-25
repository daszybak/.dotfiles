-- Claude Code workflow keymaps and helpers
-- These keymaps help when working alongside Claude Code

local M = {}

function M.setup()
	local map = vim.keymap.set

	-- ── Buffer management ───────────────────────────────────────────────
	-- Quick reload current buffer (force refresh from disk)
	map("n", "<leader>r", "<cmd>e!<cr>", { desc = "[R]eload buffer from disk" })

	-- Reload all buffers
	map("n", "<leader>R", function()
		vim.cmd("bufdo e!")
		vim.notify("All buffers reloaded", vim.log.levels.INFO)
	end, { desc = "[R]eload all buffers" })

	-- ── Quick save ──────────────────────────────────────────────────────
	map("n", "<leader>w", "<cmd>w<cr>", { desc = "[W]rite buffer" })
	map("n", "<leader>W", "<cmd>wa<cr>", { desc = "[W]rite all buffers" })

	-- ── Git helpers for reviewing Claude changes ────────────────────────
	-- NOTE: Most git keymaps are defined in kickstart/plugins/diffview.lua
	-- Only adding the one that's unique here:
	map("n", "<leader>gD", "<cmd>DiffviewOpen HEAD~1<cr>", { desc = "[G]it [D]iff last commit" })
end

return M

