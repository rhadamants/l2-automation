-- its a simple oop heal for iss
-- when HP of known character is below barrier % it will get heal from ISS 

playerHealLevel = 60;--%
petHealLevel = 60;--%

TRASTED_CHARS = {"Name1", "Name2", "Name3"}

dprint = function(...) ShowToClient("debug", ({...})[1]); end

function CastSkill(id)
	skill = GetSkills():FindById(id)
	if skill and skill:CanBeUsed() and skill:GetReuse() == 0 then
		UseSkillRaw(id,false,false)
		return true
	end
	return false
end

function IsOneOf(subj, list)
	for k,v in pairs(list) do
		if subj == v then
			return true
		end
	end
	return false;
end

function TryHealTarget(user, belowHP)
	belowHP = belowHP or 60
	if not user:IsAlikeDeath()  then
		if user:GetHpPercent() < belowHP then 
			Target(user)
			Sleep(700)
			UseSkillRaw(11570,false,false)
			Sleep(700)
			ClearTargets();
			CancelTarget(false)
		end
	end
end

repeat
    if not IsPaused() then
    	-- self heal
    	TryHealTarget(GetMe(), playerHealLevel);
    	-- PLAYER HEAL
    	local pl = GetPlayerList()
		if pl:GetCount() > 0 then
			for user in pl.list do
				if IsOneOf(user:GetName(), TRASTED_CHARS) then
					TryHealTarget(user, playerHealLevel);
				end
			end
		end
    	-- PET HEAL
    	local petList = GetPetList()
    	if petList:GetCount() > 0 then
    		for user in petList.list do
    			if IsOneOf(user:GetNickName(), TRASTED_CHARS) then
    				TryHealTarget(user, petHealLevel);
    			end
    		end
    	else
    		-- this:Log("No pets")
    	end
		
	end

    Sleep(500)
until false