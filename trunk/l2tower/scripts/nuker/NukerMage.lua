-- Simple replacement of feature L2Tower "Nuke Attack" for Mage
-- also uses "Mp recharge" skill by CD

if GetMe():GetClass() ~= 143 then 
	ShowToClient("ERROR","You are not Feoh Wizard, so this script is not for you");
	return;
end


BuffDebug = false
MassAttackSkills = UseMassSkills and {11040, 11034} or {}
SingleAttackSkills = {11011, 11023, 11017};
SingleAttackCounter = 0;
--AttackNewTargetDelay = 200;--ms

-- Mage_UseBTM - should be set by base script
btmSkillId = 11064;


function Nuke(target)

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
        if Mage_UseBTM and GetMe():GetMpPercent() < 90 and not GetMe():IsBlocked(true) then
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