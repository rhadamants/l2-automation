-- Just another script to give Iss Buff.
-- uses the same algorithm as in IssBuff plugin

BuffDebug = false
OOPmode = false; -- should leave party after buff
InviteMode = false; -- should invite character for buff
InviteName = "ACat" -- name of char to invite

local ClassesType = {
	[17] = "Wizard",	-- Prophet
	[21] = "Warrior",	-- Swordsinger
	[34] = "Warrior",	-- Bladedancer
	[49] = "Wizard",	-- Orc Mystic
	[50] = "Wizard",	-- Orc Shaman
	[51] = "Wizard",	-- Overlord
	[52] = "Wizard",	-- Warcryer
	[98] = "Wizard",	-- Hierophant
	[100] = "Warrior",	-- Sword Muse
	[107] = "Warrior",	-- Spectral Dancer
	[115] = "Wizard",	-- Dominator
	[116] = "Wizard",	-- Doomcryer
	[144] = "Wizard",	-- Iss Enchanter
	[15] = "Wizard",	-- Cleric
	[16] = "Wizard",	-- Bishop
	[29] = "Wizard",	-- Elven Oracle
	[30] = "Wizard",	-- Elven Elder
	[97] = "Wizard",	-- Cardinal
	[42] = "Wizard",	-- Shillien Oracle
	[43] = "Wizard",	-- Shillien Elder
	[105] = "Wizard",	-- Eva's Saint
	[112] = "Wizard",	-- Shillien Saint
	[146] = "Wizard",	-- Aeore Healer
	[10] = "Wizard",	-- Human Mystic
	[11] = "Wizard",	-- Human Wizard
	[12] = "Wizard",	-- Sorceror
	[13] = "Wizard",	-- Necromancer
	[25] = "Wizard",	-- Elven Mystic
	[26] = "Wizard",	-- Elven Wizard
	[27] = "Wizard",	-- Spellsinger
	[38] = "Wizard",	-- Dark Mystic
	[39] = "Wizard",	-- Dark Wizard
	[40] = "Wizard",	-- Spellhowler
	[94] = "Wizard",	-- Archmage
	[95] = "Wizard",	-- Soultaker
	[103] = "Wizard",	-- Mystic Muse
	[110] = "Wizard",	-- Storm Screamer
	[143] = "Wizard",	-- Feoh Wizard
	[14] = "Warrior",	-- Warlock
	[28] = "Warrior",	-- Elemental Summoner
	[41] = "Warrior",	-- Phantom Summoner
	[96] = "Warrior",	-- Arcana Lord
	[104] = "Warrior",	-- Elemental Master
	[111] = "Warrior",	-- Spectral Master
	-- We try to determine Wynn Summoner's Harmony dynamically
	-- if there is no 'nil' then it will not dynamically assign
	-- and use whatever stands here instead, so you can force
	-- different buff or put it manually if dynamical doesn't work
	-- { [145], nil},	-- Wynn Summoner
	[0] = "Warrior",	-- Human Fighter
	[1] = "Warrior",	-- Warrior
	[2] = "Warrior",	-- Gladiator
	[3] = "Warrior",	-- Warlord
	[18] = "Warrior",	-- Elven Fighter
	[19] = "Warrior",	-- Elven Knight
	[31] = "Warrior",	-- Dark Fighter
	[44] = "Warrior",	-- Orc Fighter
	[45] = "Warrior",	-- Orc Raider
	[46] = "Warrior",	-- Destroyer
	[47] = "Warrior",	-- Monk
	[48] = "Warrior",	-- Tyrant
	[53] = "Warrior",	-- Dwarven Fighter
	[56] = "Warrior",	-- Artisan
	[57] = "Warrior",	-- Warsmith
	[88] = "Warrior",	-- Duelist
	[89] = "Warrior",	-- Dreadnought
	[113] = "Warrior",	-- Titan
	[114] = "Warrior",	-- Grand Khavatari
	[118] = "Warrior",	-- Maestro
	[123] = "Warrior",	-- Male Soldier
	[124] = "Warrior",	-- Female Soldier
	[125] = "Warrior",	-- Dragoon
	[126] = "Warrior",	-- Warder
	[127] = "Warrior",	-- Berserker
	[128] = "Warrior",	-- Male Soul Breaker
	[129] = "Warrior",	-- Female Soul Breaker
	[131] = "Warrior",	-- Doombringer
	[132] = "Warrior",	-- Male Soul Hound
	[133] = "Warrior",	-- Female Soul Hound
	[135] = "Warrior",	-- Inspector
	[136] = "Warrior",	-- Judicator
	[140] = "Warrior",	-- Tyrr Warrior
	[7] = "Warrior",	-- Rogue
	[8] = "Warrior",	-- Treasure Hunter
	[22] = "Warrior",	-- Elven Scout
	[23] = "Warrior",	-- Plainswalker
	[35] = "Warrior",	-- Assassin
	[36] = "Warrior",	-- Abyss Walker
	[54] = "Warrior",	-- Scavenger
	[55] = "Warrior",	-- Bounty Hunter
	[93] = "Warrior",	-- Adventurer
	[101] = "Warrior",	-- Wind Rider
	[108] = "Warrior",	-- Ghost Hunter
	[117] = "Warrior",	-- Fortune Seeker
	[141] = "Warrior",	-- Othell Rogue
	[9] = "Warrior",	-- Hawkeye
	[24] = "Warrior",	-- Silver Ranger
	[37] = "Warrior",	-- Phantom Ranger
	[92] = "Warrior",	-- Sagittarius
	[102] = "Warrior",	-- Moonlight Sentinel
	[109] = "Warrior",	-- Ghost Sentinel
	[130] = "Warrior",	-- Arbalester
	[134] = "Warrior",	-- Trickster
	[142] = "Warrior",	-- Yul Archer
	[4] = "Warrior",	-- Human Knight
	[5] = "Knight",	-- Paladin
	[6] = "Knight",	-- Dark Avenger
	[20] = "Knight",	-- Temple Knight
	[32] = "Warrior",	-- Palus Knight
	[33] = "Knight",	-- Shillien Knight
	[90] = "Knight",	-- Phoenix Knight
	[91] = "Knight",	-- Hell Knight
	[99] = "Knight",	-- Eva's Templar
	[106] = "Knight",	-- Shillien Templar
	[139] = "Knight",	-- Sigel Knight
}

BaffPersonal = {
	Knight = 11523, -- Гармония Стража
	Warrior = 11524, -- Гармония Берсерка
	Wizard = 11525, -- Гармония Мага
};
Baff20min = {
	11517, -- Поэма Рога
	11521, -- Поэма Арфы
	11520, -- Поэма Гитары
	11519, -- Поэма Органа
	11518, -- Поэма Барабана
	11522, -- Поэма Лютни
	11567, -- Сопротивление Психическим Атакам
	11565, -- Сопротивление Стихиям
	11566, -- Сопротивление Божественному
};
Baff5min = {
	11530, -- Соната Движения
	11529, -- Соната Битвы
	11532, -- Соната Расслабления
};

BuffsConfig = {
	{	-- personal buffs are processed by separate function
		lastUsed = 0,
		useInterval = 30 * 60,
		saveInterval = 2 * 60,
		isPersonal = true,
		--skillList = Baff20min;
	},
	{
		lastUsed = 0,
		useInterval = 30 * 60,
		saveInterval = 2 * 60,
		skillList = Baff20min;
	},
	{
		lastUsed = 0,
		useInterval = 5 * 60, -- in min
		saveInterval = 1 * 60,
		skillList = Baff5min;
	},
};

function dprint(msg)
	if BuffDebug then
		ShowToClient("DEBUG",msg);
	end
end

function eprint(msg)
	ShowToClient("ERROR",msg);
end

function CastSkill(id)
	--if nil == tonumber(list) then return dprint("CastSkill(id) - >> id not a number") end
	skill = GetSkills():FindById(id)
	--dprint("CastSkill(id) ->> skill ".. (nil ~= skill).. " skill:CanBeUsed()" .. skill:CanBeUsed())
	if skill and skill:CanBeUsed() then
		UseSkillRaw(id,false,false)
		return true
	end
	return false
end

function CastAllByList(list)
	if "table" ~= type(list) then return dprint("CastAllByList(list) - >> list not a table") end
	SetPause(true)
	CancelTarget(false)
	for _, id in pairs(list) do
		if CastSkill(id) then
			Sleep(900)
		else
			--ShowToClient("SYS", "Fail to cast " .. id)
		end
	end
	SetPause(false)
end

function MobsCount(range)
	mobs = GetMonsterList()
	i=0
	for m in mobs.list do
		 if m:GetDistance() <= range and m:GetHpPercent() ~= 0 then
			 i = i+1
		 end
	end
	return i
end

function ProcessPersonalBuffs()
	local function buffPersonalByName(user)
		local skillName = ClassesType[user:GetClass()]
		if not skillName then return false; end
		local skill = GetSkills():FindById(BaffPersonal[skillName])
		-- wait for skill ready
		if skill and skill:GetReuse() > 0 then Sleep(skill:GetReuse() + 100) end
		if skill and skill:CanBeUsed() then
			Target(user:GetName())
			UseSkillRaw(BaffPersonal[skillName],false,false)
			Sleep(700)
			ClearTargets();
			CancelTarget(false)
			return true
		 end
	end
	
	buffPersonalByName(GetMe())
	
	local party = GetPartyList()
	if party:GetCount() > 0 then
		for user in party.list do
			buffPersonalByName(user)
		end
	end
end


function IssBuff()
	local wasProcessed = false;
	for _, buffCfg in pairs(BuffsConfig) do
		local timeSinceUse = os.time() - buffCfg.lastUsed;
		if ( -- force use
			(timeSinceUse > buffCfg.useInterval - 10) -- -10 is just a delay before all bufs disappear 
			and (not buffCfg.isPersonal) -- just don't do personal buffs under mobs attack
		) or ( -- use when we are safe
			(timeSinceUse > (buffCfg.useInterval - buffCfg.saveInterval)) 
			and (MobsCount(150) == 0)
		) then
			if (InviteMode and not IsInParty()) then
				Command("/invite "..InviteName)
				for i=1, (5000/500) do -- wait for party for 4s, check every 500ms
					if IsInParty() then break; end
					Sleep(500)
				end
				if not IsInParty() then eprint("Fail to get party") return; end
			end
			buffCfg.lastUsed = os.time()
			wasProcessed = true;
			if buffCfg.isPersonal and (MobsCount(150) == 0) then
				ProcessPersonalBuffs()
			else
				CastAllByList(buffCfg.skillList)
			end
		end
	end
	return wasProcessed
end

function IsInParty()
	return (GetPartyMaster() ~= nil);
end

repeat
    if not IsPaused()
	and (InviteMode or (OOPmode and IsInParty()) or not OOPmode)
	then
		if IssBuff() and (OOPmode or InviteMode) then
			LeaveParty();
		end
    end
    Sleep(5000)
until false