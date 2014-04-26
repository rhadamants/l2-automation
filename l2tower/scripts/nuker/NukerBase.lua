

dofile(package.path .. "..\\..\\scripts\\lib\\GameActionsLib.lua");

ScriptsForClass = {
	[139] = {s="NukerMelee.lua", n="Sigel Knight"},
	[141] = {s="NukerMelee.lua", n="Othell Rogue"},
	[140] = {s="NukerMelee.lua", n="Tyrr Warrior"},
	[144] = {s="NukerMelee.lua", n="ISS"},
	[142] = {s="NukerBow.lua", n="Yul Archer"},
	[143] = {s="NukerMage.lua", n="Feoh Wizard"},
	[145] = {s="NukerSum.lua", n="Wynn Summoner"},
}

local charCfg = ScriptsForClass[GetMe():GetClass()];
if not charCfg then
	return eprint("Unable to init nuker script for class: " .. GetMe():GetClass());
end

iprint("Starting nuker for class " .. charCfg.n)

dofile(package.path .. "..\\..\\scripts\\nuker\\" .. charCfg.s);


