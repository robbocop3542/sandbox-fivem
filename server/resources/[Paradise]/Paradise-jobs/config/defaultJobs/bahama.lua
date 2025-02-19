table.insert(_defaultJobData, {
	Type = "Company",
	LastUpdated = 1683997150,
	Id = "bahama",
	Name = "Bahama Mamas",
	Salary = 400,
	SalaryTier = 1,
	Grades = {
		{
			Id = "bartender",
			Name = "Bartender",
			Level = 2,
			Permissions = {
				JOB_STORAGE = true,
				JOB_CRAFTING = true,
			},
		},
		{
			Id = "dancer",
			Name = "Dancer",
			Level = 2,
			Permissions = {
				JOB_STORAGE = true,
				STRIP_POLE = true,
			},
		},
		{
			Id = "manager",
			Name = "Manager",
			Level = 5,
			Permissions = {
				JOB_STORAGE = true,
				JOB_CRAFTING = true,
				JOB_HIRE = true,
				JOB_FIRE = true,
			},
		},
		{
			Id = "owner",
			Name = "Owner",
			Level = 99,
			Permissions = {
				JOB_MANAGEMENT = true,
				JOB_MANAGE_EMPLOYEES = true,
				JOB_HIRE = true,
				JOB_FIRE = true,
				JOB_STORAGE = true,
				JOB_CRAFTING = true,
				TABLET_TWEET = true,
			},
		},
	},
})
