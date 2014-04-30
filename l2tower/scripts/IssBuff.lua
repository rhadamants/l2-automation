-- Just another script to give Iss Buff.
-- uses the same algorithm as in IssBuff plugin

CheckPartyBuff = true;
PartyBuffBySchedule = true;

BuffDebug = false
OOPmode = false; -- should leave party after buff
InviteMode = false; -- should invite character for buff
InviteName = "ACat" -- name of char to invite

IssBuff = {}

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
	11522, -- Поэма Лютни
	11520, -- Поэма Гитары
	11518, -- Поэма Барабана
	11517, -- Поэма Рога
	11521, -- Поэма Арфы
	11519, -- Поэма Органа
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
		minTimeout = 1 * 60,
		isPersonal = true,
		--skillList = Baff20min;
	},
	{
		name = "poems",
		lastUsed = 0,
		useInterval = 30 * 60,
		saveInterval = 2 * 60,
		minTimeout = 1 * 60,
		skillList = Baff20min;
	},
	{
		name = "sonates",
		lastUsed = 0,
		useInterval = 5 * 60, -- in min
		saveInterval = 1 * 60,
		minTimeout = 30,
		skillList = Baff5min;
	},
};

function IssBuff:dprint(msg)
	if BuffDebug then
		ShowToClient("DEBUG",msg);
	end
end

function IssBuff:eprint(msg)
	ShowToClient("ERROR",msg);
end

function IssBuff:printf(msg, ...)
	ShowToClient("IssBuff",string.format(msg, ...));
end

function IssBuff:ValidateSkillUse(id, waitReuse, count, timeout)
	waitReuse = waitReuse or false;
	count = count or 0;
	timeout = timeout or 250;

	local skill = GetSkills():FindById(id)
	if not skill then
		self:eprint("No skill "..tostring(id))
		return false; end

	if waitReuse and skill:GetReuse() > 0 then Sleep(skill:GetReuse() + 100) end

	while not skill:CanBeUsed() and count > 0 do
		Sleep(timeout);
		count = count - 1;
	end

	if not skill:CanBeUsed() then
		self:eprint("Failed to cast skill (can't be used):"..tostring(id));
		return false; end

	return true;
end

function IssBuff:CastSkill(id, waitReuse, count, timeout)
	if not self:ValidateSkillUse(id, waitReuse, count, timeout) then
		return false;
	end

	UseSkillRaw(id,false,false);
	return true;
end

function IssBuff:CastAllByList(list, waitReuse, count, timeout)
	if "table" ~= type(list) then return self:dprint("CastAllByList(list) - >> list not a table") end
	SetPause(true)
	CancelTarget(false)
	local res = true;
	for _, id in pairs(list) do
		if not self:CastSkill(id, waitReuse, count, timeout) then
			res = false;
		end
		Sleep(900)
	end
	SetPause(false)
	return res;
end

function IssBuff:MobsCount(range)
	mobs = GetMonsterList()
	i=0
	for m in mobs.list do
		 if m:GetDistance() <= range and m:GetHpPercent() ~= 0 then
			 i = i+1
		 end
	end
	return i
end

PatsMasterBuff = {
	[14930] = "Warrior", -- Saber Tooth Cougar
	[14954] = "Warrior", -- Saber Tooth Cougar
	[14955] = "Warrior", -- Saber Tooth Cougar
	[14956] = "Warrior", -- Saber Tooth Cougar
	[14957] = "Warrior", -- Saber Tooth Cougar
	[14958] = "Warrior", -- Saber Tooth Cougar
	[14959] = "Warrior", -- Saber Tooth Cougar
	[14960] = "Warrior", -- Saber Tooth Cougar
	[14972] = "Warrior", -- Saber Tooth Cougar
	
	[14931] = "Wizard", -- Summon Soul Reaper
	[14961] = "Wizard", -- Summon Soul Reaper
	[14962] = "Wizard", -- Summon Soul Reaper
	[14963] = "Wizard", -- Summon Soul Reaper
	[14964] = "Wizard", -- Summon Soul Reaper
	[14965] = "Wizard", -- Summon Soul Reaper
	[14966] = "Wizard", -- Summon Soul Reaper
	[14967] = "Wizard", -- Summon Soul Reaper
	[14973] = "Wizard", -- Summon Soul Reaper
}

function IssBuff:DefineBuffBySummon(playerName)
	local playerPat = nil;
	local pets = GetPetList();
	for Apet in pets.list do
		if Apet:GetNickName() == playerName then
			playerPat = Apet;
			break;
		end
	end
	if playerPat ~= nil then
		if not PatsMasterBuff[playerPat:GetNpcId()] then
			self:eprint("Sum has unknown pet: " .. tostring(playerPat:GetNpcId()));
			return nil;
		end
		return PatsMasterBuff[playerPat:GetNpcId()];
	else
		self:eprint("No pets for " .. tostring(playerName));
	end
end

function IssBuff:BuffPersonalByName(user)
	local skillName = ClassesType[user:GetClass()]
	local userClass = user:GetClass();
	local skillName = userClass == 145 and (self:DefineBuffBySummon(user:GetName()) or "Wizard") or ClassesType[user:GetClass()];
	local skillId = BaffPersonal[skillName];
	
	if self:ValidateSkillUse(skillId, true, 4, 250) then
		Target(user:GetId())
		UseSkillRaw(skillId,false,false);
		Sleep(700)
		ClearTargets();
		CancelTarget(false)
		return true;
	end
end

function IssBuff:ProcessPersonalBuffs()
	self:BuffPersonalByName(GetMe())
	
	local res = true;
	local party = GetPartyList()
	if party:GetCount() > 0 then
		for user in party.list do
			if not user:IsAlikeDeath() and user:GetDistance() < 1000 then
				if not self:BuffPersonalByName(user) then
					self:eprint("Fail to buff user "..user:GetName())
					res = false;
				end
			else
				self:printf("Fail to buff user %s (dead %s, dist %s)", user:GetName(), user:IsAlikeDeath(), user:GetDistance());
			end
		end
	end
	return res;
end

function IssBuff:IssBuff()
	local wasProcessed = false;
	for _, buffCfg in pairs(BuffsConfig) do
		local timeSinceUse = (GetTime() - buffCfg.lastUsed) / 1000;
		if ( -- force use
			(timeSinceUse > buffCfg.useInterval - 10) -- -10 is just a delay before all bufs disappear 
			and (not buffCfg.isPersonal) -- just don't do personal buffs under mobs attack
		) or ( -- use when we are safe
			(timeSinceUse > (buffCfg.useInterval - buffCfg.saveInterval)) 
			and (self:MobsCount(150) == 0)
		) then
			if (InviteMode and not self:IsInParty()) then
				Command("/invite "..InviteName)
				for i=1, (5000/500) do -- wait for party for 4s, check every 500ms
					if self:IsInParty() then break; end
					Sleep(500)
				end
				if not self:IsInParty() then self:eprint("Fail to get party") return; end
			end

			wasProcessed = true;
			if buffCfg.isPersonal and (self:MobsCount(150) == 0) and self:ProcessPersonalBuffs() then
				buffCfg.lastUsed = GetTime();
			elseif self:CastAllByList(buffCfg.skillList, false, 4, 250) then
				buffCfg.lastUsed = GetTime();
			else
				self:eprint("Fail to buff")
			end
		end
	end
	return wasProcessed
end

function IssBuff:IsInParty()
	return (GetPartyMaster() ~= nil);
end

-- we should not stuck on rebuffing some skill continuesly. So we save last use time per skill
BuffRenewLastUsage = {
	--[skillId] = lastUse
}

function IssBuff:ensureUserHasBuff(user, skillId, minTimeout)
	if user:IsAlikeDeath() or user:GetDistance() > 1000 then
		return; end

	local buff = user:GetBuff(skillId);
	if (not buff or buff.endTime - minTimeout*1000 < GetTime())
		and (not BuffRenewLastUsage[skillId] or BuffRenewLastUsage[skillId] + 15*1000 < GetTime()) then
		--self:printf("Buf endTime %s; os.time %s", buff.endTime, GetTime());
		BuffRenewLastUsage[skillId] = GetTime();

		if self:CastSkill(skillId, false, 4, 250) then
			Sleep(700);
		end
	end
end

function IssBuff:checkPartyBuff()
	for _, buffCfg in pairs(BuffsConfig) do
		if buffCfg.isPersonal then
			-- todo
		else
			for _,skillId in pairs(buffCfg.skillList) do
				self:ensureUserHasBuff(GetMe(), skillId, buffCfg.minTimeout);
				local party = GetPartyList()
				if party:GetCount() > 0 then
					for user in party.list do
						self:ensureUserHasBuff(user, skillId, buffCfg.minTimeout);
					end
				end
			end
		end
	end
end

function safeIndex(object, firstKey, ...)
    if ("table" == type(object) or "userdata" == type(object)) and "nil" ~= type(firstKey) then
        -- continue indexing
        return safeIndex(object[firstKey], ...);
    elseif not ("table" == type(object) or "userdata" == type(object)) and "nil" ~= type(firstKey) then
        -- hit missed subkey
        return nil;
    else -- either no value or no index; both situations treated as successful
        return object;
    end
end

-- in case party members already have some buff we are trying to init buff schedule according to them
function IssBuff:rescheduleBuffs()
	if PartyBuffBySchedule then
		for _, buffCfg in pairs(BuffsConfig) do
			if buffCfg.isPersonal then
				-- todo
			else
				local minBuffEndTime = 4000000000; --4kkk lua doesn't have int.Max
				for _,skillId in pairs(buffCfg.skillList) do
					minBuffEndTime = math.min(minBuffEndTime, safeIndex(GetMe():GetBuff(skillId), "endTime") or 0);
					if minBuffEndTime then
						local party = GetPartyList()
						for user in party.list do
							minBuffEndTime = math.min(minBuffEndTime, safeIndex(user:GetBuff(skillId), "endTime") or 0);
						end
					end
				end
				if minBuffEndTime > 0 then
					buffCfg.lastUsed = minBuffEndTime - buffCfg.useInterval*1000
					self:printf("%s valid for ~%s min", buffCfg.name, math.floor((minBuffEndTime - GetTime()) / 1000 / 60))
				end
			end
		end
	end
end

-- dofile(package.path .. "..\\..\\scripts\\lib\\RuntimeLogs.lua");
-- RuntimeLogs:interceptByName("IssBuff")


IssBuff:rescheduleBuffs()

repeat
	local self = IssBuff;
    if not IsPaused() then

    	-- todo: validate party members buff level

		if PartyBuffBySchedule and (InviteMode or (OOPmode and self:IsInParty()) or not OOPmode) then
			if self:IssBuff() and (OOPmode or InviteMode) then
				LeaveParty();
			end
	    end

	    if CheckPartyBuff and self:IsInParty() then
    		self:checkPartyBuff();
    	end
    end

    Sleep(5000)
until false

