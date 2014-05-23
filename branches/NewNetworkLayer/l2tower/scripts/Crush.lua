-- Script is designed to crush cocoons in Fairy Gardens
-- it will attack cocoons in hunting zone (defined by the point where script was started)
-- when there are not much mobs alive

cocons = {
	32920,
	32919
}
crashLimit = 5; -- char will not crash more cocoons than this in a row
rangeToHunt = 1500; -- range to cocoons
mobsSafeZone = 1000; -- area to search for mobs
safeMobsCount = 15; -- when less then this count of mobs around - start crushing

dprint = function(...) ShowToClient("debug", ({...})[1]); end

startPoint = GetMe():GetLocation();

function MobsCount(point, range)
	local mobs = GetMonsterList()
	local i=0
	for m in mobs.list do
		 if GetDistanceVector(point, m:GetLocation()) <= range and m:GetHpPercent() ~= 0 then
			 i = i+1
		 end
	end
	return i
end

function table.contains(tbl, item)
	for k,v in pairs(tbl) do
		if v == item then
			return true;
		end
	end
	return false;
end

function destroy(npc)
	local oid = npc:GetId()
	for i=1,10 do
		Target(oid)
		Sleep(500);
		Action(2, false, true);
		Sleep(1000);
		if npc:IsAlikeDeath() then
			Sleep(500)
			ClearTargets();
			CancelTarget(false)
			return;
		end
	end
	ClearTargets();
	CancelTarget(false)
end

repeat
	if not IsPaused() then

	local mobsAround = MobsCount(startPoint, mobsSafeZone);
	--dprint(tostring(mobsAround))
	if mobsAround < safeMobsCount then
		local coconsToCrash = {};
		local nl = GetNpcList()
		if nl:GetCount() > 0 then
			for npc in nl.list do
				if table.contains(cocons, npc:GetNpcId()) 
					--and npc:GetDistance() <= 1100 
					and GetDistanceVector(startPoint, npc:GetLocation()) <= 1100 
					--and m:GetHpPercent() ~= 0
				then
					table.insert(coconsToCrash, npc)
				end
			end
		end
		if #coconsToCrash > 0 then
			dprint("going to destroy " .. #coconsToCrash)
			table.sort(coconsToCrash, function(a,b) return GetDistanceVector(startPoint, a:GetLocation())<GetDistanceVector(startPoint, b:GetLocation()) end)
			local crushCount = #coconsToCrash > crashLimit and crashLimit or #coconsToCrash;
			for i=1,#coconsToCrash do
				destroy(coconsToCrash[i])
			end
			dprint("done")
		else
			dprint("only " .. mobsAround .. " mobs around");
		end
		Sleep(10000)
	end

	end
	Sleep(1000)
		

until false