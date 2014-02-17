BuffDebug = false
CharSkills = {
	[139] = { -- Sigel Knight
		jumpSkill = 10015,
		massAttackSkills = {10013, 10014},
		singleAttackSkills = {10008, 10011},--10011, 10009, 10008, 10010},
	};
	[141] = { -- Othell Rogue
		singleAttackSkills = {
			10509, -- Разбивание Сердца
			10508, -- Кровавый Шаг
			10511, -- Удар с Разворота
		},
		massAttackSkills = {
			10512, -- Взрывающийся Кинжал
			10510, -- Цепной Импульс
			--10548 -- Обман
		},
	},
	[140] = { -- Tyrr Warrior
		jumpSkill = 10267,
		selfBuffSkill = 10292,
		massAttackSkills = {10288},
		singleAttackSkills = {10262, 10260, 10265, 10258}
	};
	[144] = { -- ISS
		jumpSkill = 11508,
		massAttackSkills = {11513, 11514},
		singleAttackSkills = {11509, 11510, 11511},
	};
	
}

function dprint(msg)
	if BuffDebug then
		ShowToClient("DEBUG",msg);
	end
end

function eprint(msg)
	ShowToClient("ERROR",msg);
end

function CastSkill(id)
	skill = GetSkills():FindById(id)
	if skill and skill:CanBeUsed() and skill:GetReuse() == 0 then
		UseSkillRaw(id,false,false)
		return true
	end
	return false
end

function CastOneByList(list)
	if "table" ~= type(list) then return dprint("CastOneByList(list) - >> list not a table") end
	for _, id in pairs(list) do
		if CastSkill(id) then
			return true;
		end
	end
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

function Nuke(target)  
	dprint("Nuke(target)")
	if (target:GetDistance() < 500 
		and (MobsCount(250) > 1 
				and CastOneByList(MassAttackSkills)
				or CastOneByList(SingleAttackSkills)
		)
		--or (target:GetDistance() < 600 and target:GetDistance() > 200
		--	and CastSkill(JumpSkill)
		--)
	)
	then
		return;
	end
end

function Init()
	local charCfg = CharSkills[GetMe():GetClass()];
	if not charCfg then
		return eprint("Unable to init nuker script for class: " .. GetMe():GetClass());
	end

	MassAttackSkills = charCfg.massAttackSkills
	JumpSkill = charCfg.jumpSkill
	SingleAttackSkills = charCfg.singleAttackSkills
	SelfBuffSkill = charCfg.selfBuffSkill;
end

Init()

repeat
    if not IsPaused() then
    	if SelfBuffSkill and not GetMe():GotBuff(SelfBuffSkill) then
			CastSkill(SelfBuffSkill)
		end

		local target = GetTarget()
        if  --GetMe():GetMp() > 200 and 
		 not GetMe():IsBlocked(true)
		and target
		and not target:IsAlikeDeath()
		and target:IsEnemy()
		then
			Nuke(target);
		end
	end
    Sleep(200)
until false