-- Simple replacement of feature L2Tower "Nuke Attack" for Bow

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


	function dprint(msg)
		if BuffDebug then
			ShowToClient("DEBUG",msg);
		end
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

	function CastOneByOneList(list, counter)
		if "table" ~= type(list)  then return dprint("CastOneByOneList(list) - >> list not a table") end
		--or "numer" ~= type(counter) or counter < 0
		repeat
			counter = counter + 1;
			if #list < counter then
				counter = 1;
			end
		until CastSkill(list[counter])
		SingleAttackCounter = counter
		return true;
		--[[for _, id in pairs(list) do
			if CastSkill(id) then
				return true;
			end
		end]]
	end

	function MobsAroundTarget(targer, range)
		
		local mobs = GetMonsterList()
		local i=0
		for m in mobs.list do
			if m:GetHpPercent() ~= 0 and targer:GetRangeTo(m) <= range then
				i = i+1
			end
		end
		return i
		
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