return {
	{
		"folke/snacks.nvim",
		keys = {
			{ "<leader>gd", false },
			{ "<leader>gD", false },
		},
	},
	{
		"esmuellert/codediff.nvim",
		cmd = "CodeDiff",
		keys = {
			{ "<leader>gd", "<cmd>CodeDiff<cr>", desc = "Git Diff (CodeDiff)" },
			{ "<leader>gD", "<cmd>CodeDiff origin...<cr>", desc = "Git Diff origin (CodeDiff)" },
		},
	},
}
