-- Allows a poor support for summon Nuke.
-- Script lunches "/useshortcut 01 02" for pat attack.
-- So you can put on your 1st panel, 2nd button pat's attack skill
-- and it will be used every 4 seconds

-- Also uses MP recharge and "Skills split buff" (I don't know proper English name for it)

-- CONFIG
-- Sum_UseManaRecharge = true;
-- Sum_UseNuke = true;
-- Sum_SummonCube = true;

-- Sum_SummonSoulshotsEnabled = true;
SummonSSLimit = 5000;
SummonBSSLimit = 0; -- 0 to disable

-- Sum_RequiredSummonsCount = 2;
-- SummonServitorSkillId = 11257; -- 11257 - Saber Tooth Cougar; 11258 - for Summon Soul Reaper; 11256 - for Summon Armored Bear

-- CONSTANTS
ManaRechargeSkill = 11269; -- Разделение Маны
SelfBuffSkill = 11288; -- Последнее Разделение Судьбы
SkillId_Cube = 11268; -- Вызвать Карающий Куб
SkillId_Aura = 1937; -- Аура Веньо
AttackNewTargetDelay = 100; --ms

ItemId_CryR = 17371;
ItemId_SS = 35670;
ItemId_BSS = 35671;
SkillId_SummonSS = 11316; -- Призыв Зарядов Души

ShotsActivated = false;

-- Only for summon
if GetMe():GetClass() ~= 145 then 
	ShowToClient("ERROR","You are not Wynn Summoner, so this script is not for you");
	return;
end

dofile(package.path .. "..\\..\\scripts\\lib\\GameActionsLib.lua");

function GetSummonCount()
	local me = GetMe();
	local petlistaround = GetPetList();
	local count = 0;
	for Apet in petlistaround.list do
		if (Apet:GetNickName() == me:GetName() and not Apet:IsAlikeDeath()) then
			count = count +1;
		end
	end
	return count;
end

function GetPartyMinMpPercent()
	local min = 100;
	local party = GetPartyList();
	local count = 0;
	for player in party.list do
		if (player:GetMpPercent() < min) then
			min = player:GetMpPercent();
		end
	end
	return min;
end

TimeNukeLastUse = 0;
IsAttaking = false;
function SumNuke()
	local target = GetTarget();
	local me = GetMe();
	if not OldTarget or (OldTarget and target and OldTarget:GetId() ~= target:GetId()) then
		OldTarget = target;
		if AttackNewTargetDelay and AttackNewTargetDelay > 0 then
			Sleep(AttackNewTargetDelay);
			target = GetTarget();
		end
	end
	
    if target
	and not target:IsAlikeDeath()
	and target:IsEnemy()
	then
		IsAttaking = true;
		if os.time() - TimeNukeLastUse > 2 then
			TimeNukeLastUse = os.time();
			Command("/useshortcut 01 02")
			Command("/useshortcut 01 02")
		end

	-- if target is not attacable and it's not me or summon, then stop sum's attack
	elseif IsAttaking and (not target or (target:GetNickName() ~= me:GetName() and target:GetName() ~= me:GetName())) then
		IsAttaking = false;
		Action(23,false,false)
	end
end

function SumSummonSS()
	if not Sum_SummonSoulshotsEnabled or GetItemAmountById(ItemId_CryR) == 0 then
		return; end

	if (SummonSSLimit > 0 and GetItemAmountById(ItemId_SS) < SummonSSLimit) 
	or (SummonBSSLimit > 0 and GetItemAmountById(ItemId_BSS) < SummonBSSLimit) 
	then
		if CastSkill(SkillId_SummonSS) then
			Sleep(1000);
		end
	end
end

function SumSummons()
	if (GetSummonCount() < Sum_RequiredSummonsCount) then
		if (GetSummonCount() == 0) then
			ActivateShots(false);
		end;
		UseSkillRaw(SummonServitorSkillId,false,false); 
		Sleep(2000);
	end;
end

function ActivateShots(state)
	ShotsActivated = state;
	if GetItemAmountById(ItemId_SS) > 5 then
		ActivateSoulShot(ItemId_SS, state);
		
		Sleep(700);
	end
	if GetItemAmountById(ItemId_BSS) > 5 then
		ActivateSoulShot(ItemId_BSS, state);
		Sleep(700);
	end
end

LastCubeSummonTime = 0;
function SumCube()
	if Sum_SummonCube then 
		local timeSinceUse = os.time() - LastCubeSummonTime;
		if timeSinceUse > 5 * 60 and CastSkill(SkillId_Cube) then
			LastCubeSummonTime = os.time();
		end
	end
end

repeat
    if not IsPaused() then
    	SumSummonSS();
    	SumSummons();
    	if not (ShotsActivated) and (GetSummonCount() > 0) then
    		ActivateShots(true);
    	end
    	SumCube();

		local me = GetMe();
    	-- mp recharge
        if Sum_UseManaRecharge and me:GetMp() > 1400 and GetPartyList():GetCount() > 2 and GetPartyMinMpPercent() < 90 and not me:IsBlocked(true) then
			CastSkill(ManaRechargeSkill);
			Sleep(700)
		end
		-- self buff
		if not me:GotBuff(SelfBuffSkill) then
			CastSkill(SelfBuffSkill);
			Sleep(700)
		end
		-- aura
		if not me:GotBuff(SkillId_Aura) then
			CastSkill(SkillId_Aura);
			Sleep(700)
		end
		-- nuke
		if Sum_UseNuke then
			SumNuke();
		end
	end
    	

    Sleep(500)
until false