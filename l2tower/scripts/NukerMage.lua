-- Simple replacement of feature L2Tower "Nuke Attack" for Mage
-- also uses "Mp recharge" skill by CD

if GetMe():GetClass() ~= 143 then 
	ShowToClient("ERROR","You are not Feoh Wizard, so this script is not for you");
	return;
end


BuffDebug = false
MassAttackSkills = {11040, 11034}
SingleAttackSkills = {11011, 11023} --11017};
SingleAttackCounter = 0;
AttackNewTargetDelay = 200;--ms

useBtm = true;
btmSkillId = 11064;


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

function Nuke(target)  
	dprint("Nuke(target)")

	if (target:GetDistance() < 2000 
		and (MobsAroundTarget(target, 150) > 1
			and CastOneByList(MassAttackSkills)
			or CastOneByOneList(SingleAttackSkills, SingleAttackCounter)
		)
		or CastOneByOneList(SingleAttackSkills, SingleAttackCounter)
	)
	then
		return
	end
end


repeat
    if not IsPaused() then

    	-- mp recharge
        if useBtm and GetMe():GetMp() > 1400 and not GetMe():IsBlocked(true) then
			CastSkill(btmSkillId)
		end


		local target = GetTarget()
		if not OldTarget or (OldTarget and target and OldTarget:GetId() ~= target:GetId()) then
			OldTarget = target;
			SingleAttackCounter = 0;
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