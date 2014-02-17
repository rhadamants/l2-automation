-- Allows a poor support for summon Nuke.
-- Script lunches "/useshortcut 01 02" for pat attack.
-- So you can put on your 1st panel, 2nd button pat's attack skill
-- and it will be used every 4 seconds

-- Also uses MP recharge and "Skills split buff" (I don't know proper English name for it)

UseManaRecharge = true;
UseNuke = true;

ManaRechargeSkill = 11269; -- Разделение Маны
SelfBuffSkill = 11288; -- Последнее Разделение Судьбы
AttackNewTargetDelay = 100; --ms

if not (UseNuke or UseManaRecharge) then return; end -- do not waste CPU if there is no job

function CastSkill(id)
	skill = GetSkills():FindById(id)
	if skill and skill:CanBeUsed() and skill:GetReuse() == 0 then
		UseSkillRaw(id,false,false)
		return true
	end
	return false
end


lastUse = 0;
function SumNuke()


	local target = GetTarget()
	if not OldTarget or (OldTarget and target and OldTarget:GetId() ~= target:GetId()) then
		OldTarget = target;
		if AttackNewTargetDelay and AttackNewTargetDelay > 0 then
			Sleep(AttackNewTargetDelay);
			target = GetTarget();
		end
	end
	
    if  GetMe():GetMp() > 200
	--and not GetMe():IsBlocked(true)
	and target
	and not target:IsAlikeDeath()
	and target:IsEnemy()
	then
		if os.time() - lastUse > 2 then
			lastUse = os.time();
			Command("/useshortcut 01 02")
			Command("/useshortcut 01 02")
		end
	end
end

repeat
    if not IsPaused() then		
    	-- mp recharge
        if UseManaRecharge and GetMe():GetMp() > 1400 and not GetMe():IsBlocked(true) then
			CastSkill(ManaRechargeSkill)
		end

		-- self buff
		if not GetMe():GotBuff(SelfBuffSkill) then
			CastSkill(SelfBuffSkill)
		end

		-- nuke
		if UseNuke then
			SumNuke()
		end


		
	end
    Sleep(500)
until false