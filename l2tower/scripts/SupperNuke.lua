-- UNDER CONSTRUCTIION

dofile(package.path .. "..\\..\\scripts\\GameActionsLib.lua");


BuffDebug = false
CharSkills = {
	[139] = { -- Sigel Knight
		jumpSkill = 10015,
		massAttackSkills = {10013, 10014},
		singleAttackSkills = {10011, 10009, 10008, 10010},
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
	[142] = { -- Yul Archer
		jumpSkill = 0,
		debuff = 10801;
		massAttackSkills = {
		    --10760, -- Выстрел Торнадо
			10771, -- Туча Стрел
			10772, -- Проливной Дождь Стрел
		},
		singleAttackSkills = {
			10762, -- Скоростной Выстрел
			10763, -- Точечный Удар
			10760, -- Выстрел Торнадо
		},
	};
	
}

function Nuke(target)  
	dprint("Nuke(target)")
	if (target:GetDistance() < 500 
		and (MobsCount(250) > 1 
				and CastOneByList(MassAttackSkills)
				or CastOneByList(SingleAttackSkills)
		)
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
		
		if not OldTarget or (OldTarget and target and OldTarget:GetId() ~= target:GetId()) then
			OldTarget = target;
			RangedAttackCounter = 0;
			if AttackNewTargetDelay and AttackNewTargetDelay > 0 then
				Sleep(AttackNewTargetDelay);
				target = GetTarget();
			end
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














BuffDebug = false
AttackNewTargetDelay = 100;--ms

Debuff = 10801;

RangeAttackSkills = {
			10762, -- Скоростной Выстрел
			10763, -- Точечный Удар
			10760, -- Выстрел Торнадо
		};

MeleeAttackSkills = {
			10761, -- Удар Луком
			10774, -- Отступление
		};
MassAttackSkills = {
		    --10760, -- Выстрел Торнадо
			10771, -- Туча Стрел
			10772, -- Проливной Дождь Стрел
		}
RangedAttackCounter = 0;

function InitDebuffSkill()
	DebuffSkill = GetSkills():FindById(Debuff)
	return DebuffSkill ~= nil
end

function Nuke(target)  
	dprint("Nuke(target)")
	local dist = target:GetDistance();
	if 
		InitDebuffSkill() and DebuffSkill:CanBeUsed() and DebuffSkill:GetReuse() == 0 and CastSkill(Debuff)
		or target:GetHp() > 1000 and dist < 40 and CastOneByOneList(MeleeAttackSkills, 0)
		or dist < 1100 and MobsAroundTarget(target, 150) > 1 and CastOneByList(MassAttackSkills)
		or target:GetHp() > 2000 and dist < 1100 and CastOneByOneList(RangeAttackSkills, RangedAttackCounter)
	then
		return
	end
end

repeat
    if not IsPaused() then
		local target = GetTarget()
		if not OldTarget or (OldTarget and target and OldTarget:GetId() ~= target:GetId()) then
			OldTarget = target;
			RangedAttackCounter = 0;
			if AttackNewTargetDelay and AttackNewTargetDelay > 0 then
				Sleep(AttackNewTargetDelay);
				target = GetTarget();
			end
		end
		
        if  GetMe():GetMp() > 200
		and not GetMe():IsBlocked(true)
		and target
		and not target:IsAlikeDeath()
		and target:IsEnemy()
		then
			Nuke(target);
		end
	end
    Sleep(400)
until false