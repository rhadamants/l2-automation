-- watch nobles on party members
-- and tries to buff

NOBL_SKill_ID = 1323

function CastSkill(id)
	skill = GetSkills():FindById(id)
	if skill and skill:CanBeUsed() and skill:GetReuse() == 0 then
		UseSkillRaw(id,false,false)
		return true
	end
	return false
end

function CastSkillTarget(id, target)
	local currentTarget = GetMe():GetTarget()--:GetId()
	if currentTarget and currentTarget ~= target:GetId() then
		Target(target)
		Sleep(700)
	else
		currentTarget = nil;
	end
	CastSkill(id)
	Sleep(700)
	if currentTarget then
		Target(currentTarget)
	else
		ClearTargets();
		CancelTarget(false)
	end
end


function baff_nobl( user )
	Target(user)
	Sleep(700)
	UseSkillRaw(NOBL_SKill_ID,false,false)
	Sleep(700)
	ClearTargets();
	CancelTarget(false)
end

function IsNoblOnUser( user )
	return user:GotBuff(NOBL_SKill_ID)
end

repeat
	if not IsPaused() then
		if not IsNoblOnUser(GetMe()) then
			CastSkillTarget(NOBL_SKill_ID, GetMe())
					Sleep(500)
		end

		local party = GetPartyList()
		if party:GetCount() > 0 then
			for user in party.list do
				if not user:IsAlikeDeath() and not IsNoblOnUser(user) and user:GetDistance() < 1000 then
					CastSkillTarget(NOBL_SKill_ID, user)
					Sleep(500)
				end
			end
		end
	end
    Sleep(500)
until false