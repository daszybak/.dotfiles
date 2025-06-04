return {
	settings = {
		gopls = {
			gofumpt = true,
			["ui.semanticTokens"] = true,
			analyses = {
				unusedparams = true,
				shadow = true, -- detect variable shadowing
				nilness = true, -- detect redundant or impossible nil checks
				unusedwrite = true, -- detect unused writes to struct fields
				unreachable = true, -- detect unreachable code
			},
			codelenses = {
				references = true,
			},
			staticcheck = true, -- enable additional diagnostics
			hoverKind = "FullDocumentation", -- full docs in hover popup
			completeUnimported = true, -- suggest imports for completions
			usePlaceholders = true, -- auto-fill function parameters
			linksInHover = true, -- clickable links in hover
			verboseOutput = false, -- can be turned on for debugging
		},
	},
}
