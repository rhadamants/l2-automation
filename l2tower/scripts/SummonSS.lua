-- Uses summon pat's SoulShots skill when there are few of them left in bag

cryR = 17371;
ss = 35670;
ssLimit = 1000;
bss = 35671;
bssLimit = 0;
summonSkill = 11316; -- Призыв Зарядов Души

dprint = function(...) ShowToClient("debug", ({...})[1]); end

repeat
	local cryRCount = 0;
	local ssCount = 0;
	local bssCount = 0;

	local invList = GetInventory();
	for item in invList.list do
		if item.displayId == cryR then
			cryRCount = item.ItemNum;
		elseif item.displayId == ss then
			ssCount = item.ItemNum;
		elseif item.displayId == bss then
			bssCount = item.ItemNum;
		end
	end;

	if ssCount < ssLimit then or bssCount < bssLimit then
		if cryRCount == 0 then
			--dprint("shutdown")
		else
			local skill = GetSkills():FindById(summonSkill)
			if not skill then
				ShowToClient("error","no skill")
			end
			-- wait for skill ready
			if skill and skill:GetReuse() > 0 then Sleep(skill:GetReuse() + 100) end
			if skill and skill:CanBeUsed() then
				UseSkillRaw(summonSkill,false,false)
			end
		end
	end

	Sleep(1000)
		

until false