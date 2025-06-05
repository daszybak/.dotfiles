return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- optional but recommended
		"MunifTanjim/nui.nvim",
	},
	keys = {
		{
			"<C-n>",
			function()
				require("neo-tree.command").execute({ toggle = true })
			end,
			desc = "Toggle Neo-tree",
		},
	},
}
