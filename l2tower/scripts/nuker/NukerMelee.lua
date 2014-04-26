-- should be loaded from script DD.lua

--UseMassSkills - set by the environment

CharSkills = {
	[139] = { -- Sigel Knight
		cube = 10043, -- Призыв Куба Рыцаря
		jumpSkill = 10015,
		massAttackSkills = {10013, 10014},
		singleAttackSkills = {10008, 10011, 10009},--10011, 10008, 10010},
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
		selfBuffSkills = {
			10292, -- 10270	Последняя Энергия
			10297, -- Дух Убийцы

		},
		massAttackSkills = {
			10288,
			10265, -- Взрыв Энергии (tend to be mass)
		},
		singleAttackSkills = {
			10258, 
			10262, -- Мощный Бомбардир (push mobs)
			10260, 
			
		},
	};
	[144] = { -- ISS
		jumpSkill = 11508,
		massAttackSkills = {11513, 11514},
		singleAttackSkills = {11509, 11510, 11511},
	};
	
}


LastCubeSummonTime = 0;
function SumCube()
	if SummonCubeSkill then 
		local timeSinceUse = os.time() - LastCubeSummonTime;
		if timeSinceUse > 5 * 60 and CastSkill(SummonCubeSkill) then
			LastCubeSummonTime = os.time();
		end
	end
end

function ProcessSelfBuffs()
	if SelfBuffSkills then
		for _,buffSkill in ipairs(SelfBuffSkills) do
			if not GetMe():GotBuff(buffSkill) and CastSkill(buffSkill) then
				Sleep(700)
			end
		end
	end
end

function Nuke(target)
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

	MassAttackSkills = UseMassSkills and charCfg.massAttackSkills or {}
	JumpSkill = charCfg.jumpSkill
	SingleAttackSkills = charCfg.singleAttackSkills
	SelfBuffSkills = charCfg.selfBuffSkills;
	SummonCubeSkill = charCfg.cube;
end

Init()

repeat
    if not IsPaused() then
    	ProcessSelfBuffs();
		SumCube();

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