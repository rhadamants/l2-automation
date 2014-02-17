--[[
Sorry for redistributing this script. If you have some questions/notes please go to L2Tower forum and find author.

This is a Plugin For those who plan to AFK Play tank in fixed spots, or aid you at tanking while not afk aswell.
* Add this following plugin in plugins folders (Its not script).
* With this plugin you will have access to 4 different in-game commands:
1- /tank this command will turn on/off the tanking mode, it disregard your start position, all it cares about is agroing nearby mobs or protecting your party members.
2- /tankonspot this command will turn on/off the tanking mode but a difference from the previous command it will try to stay on same spot all time.
3- /pvpmode is command where you switch between the tank mode you planning to do PvE(agroing mobs only) or PvP(agroing non friendly players).
4- /outspot this command saves the current location your tank at, so if someone in party says "out", "go out", "come out" , if the tank on auto mode then it will go to this location, can be useful for full afk tanking such as in harnak zone.
NB saying "go tank", "tank go" will make the tank resume the tanking! 
Listening to party chat requires tank to be running on /tankonspot]]

TankStatus = false;
tankonspot = false;
pvp = false;
AuraOfHateRdy = GetTime();
AgressionRdy = GetTime();
ShieldStrike = GetTime(); 
movestamp = GetTime();
outspot = nil;
myptidpetlist =	{} ;
AllowedMass = GetTime() + 40000;

function OnCreate()
	this:RegisterCommand("tank", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("tankonspot", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("pvpmode", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
	this:RegisterCommand("outspot", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
end;

function OnCommand_tank(vCommandChatType, vNick, vCommandParam)
	if (TankStatus == false) then
		TankStatus = true;
		FarmPoint = GetMe():GetLocation();
		retreat = false;
		ShowToClient("Tank Plugin","Tanking Is Activated.");
	else
		TankStatus = false;
		tankonspot = false;
		retreat = false;
		ShowToClient("Tank Plugin","Tanking Is Is Deactivated.");	
	end;
end;

function OnCommand_outspot(vCommandChatType, vNick, vCommandParam)
	if (outspot == nil) then
		outspot = GetMe():GetLocation();
		ShowToClient("Tank Plugin","Safe Position is saved.");
	else
		outspot = nil;
		ShowToClient("Tank Plugin","Safe Position is removed.");
	end;
end;

function OnCommand_pvpmode(vCommandChatType, vNick, vCommandParam)
	if (pvp == false) then
		pvp = true;
		retreat = false;
		ShowToClient("Tank Plugin","Switched to PvP Tank Mode.");
	else
		pvp = false;
		retreat = false;
		ShowToClient("Tank Plugin","Switched to PvE Tank Mode.");	
	end;
end;

function OnCommand_tankonspot(vCommandChatType, vNick, vCommandParam)
	if (TankStatus == false) then
		TankStatus = true;
		tankonspot = true;
		retreat = false;
		FarmPoint = GetMe():GetLocation();
		ShowToClient("Tank Plugin","Tanking Is Activated.");
	else
		TankStatus = false;
		tankonspot = false;
		retreat = false;
		ShowToClient("Tank Plugin","Tanking Is Is Deactivated.");	
	end;
end;

function CheckSorrounding()
	if (pvp == false) then
		if (AnyFlaggedAround() == false) and (IsThereMobsAround()) then
			return true;
		end;
	else
		if (AnyFlaggedAround() == true) then
			return true;
		end;
	end;
	return false;
end;

function OnLTick500ms()
	CurrentTime = GetTime();
	myself = GetMe();
	MyCurrentTarget = GetTarget();
	if (myself ~= nil) and (myself:GetClass() == 139) then
		if (TankStatus == true) then 
			if (myself:IsAlikeDeath() == false) and (GetDistanceVector(FarmPoint,myself:GetLocation()) < 5000) then	
				if (AuraOfHateRdy < CurrentTime) and (AllowedMass < GetTime()) and CheckSorrounding() then
					local ChainHydra = GetSkills():FindById(10016);
					if (ChainHydra ~= nil) and (ChainHydra:IsSkillAvailable() == true) then 
						UseSkillRaw(10016,false,false);
						AllowedMass = GetTime() + 2000;
					else
						UseSkillRaw(10027, false, false); -- Superior Hate Aura
					end;
				elseif (MyCurrentTarget ~= nil) and (MyCurrentTarget:IsAlikeDeath() == false) and ((MyCurrentTarget:IsMonster()) or ((pvp == true) and (MyCurrentTarget:IsEnemy() and (MyCurrentTarget:GetTarget() ~= myself:GetId()) and (MyCurrentTarget:GetTarget() ~= 0)) and (DoINeedNewTarget() == false))) then 
					if (MyCurrentTarget:GetRangeTo(myself) < 650) and (MyCurrentTarget:GetRangeTo(myself) > 100) and (ShieldStrike < CurrentTime) and (MyCurrentTarget:GetTarget() ~= myself:GetId()) and (myself:GetMp() > 2000) then
						UseSkillRaw(10015, false, false); -- Chain Strike
					elseif (MyCurrentTarget:GetRangeTo(myself) < 900) and (AgressionRdy < CurrentTime) then
						UseSkillRaw(10026, false, false); -- Superior Hate
					else
						movetospot();
					end;
				else
					movetospot();
				end;
			end;
			
			if (pvp == false) then
				if (DoINeedNewTarget()) then
					TargetAMobThatNeedAgro();
				end;
			else
				if (DoINeedNewTarget()) or IsMyHealerExposed() then
					TargetAnEnemyThatNeedAgro();
				end;
			end;
			
		end;
		if (retreat == true) then
			movetospot();
		end;
	end;
end;

function movetospot()
if (retreat == false) then
	if (tankonspot == true) and (movestamp +2000 < GetTime()) and (GetDistanceVector(GetMe():GetLocation(),FarmPoint) > 150) and (GetDistanceVector(FarmPoint,GetMe():GetLocation()) < 5000) then
		local m = 50;
		loc =  FarmPoint;
		lX = loc.X + math.random(-m, m);
		lY = loc.Y + math.random(-m, m);
		MoveToNoWait(lX, lY, loc.Z);
		movestamp = GetTime();
	end;
elseif (outspot ~= nil) and (movestamp + 500 < GetTime()) and (GetDistanceVector(GetMe():GetLocation(),outspot) > 150) and (GetDistanceVector(outspot,GetMe():GetLocation()) < 5000)  then
	MoveToNoWait(outspot);
end;
end;

function IsMyHealerExposed()
	if (MyCurrentTarget ~= nil) then 
		if (MyCurrentTarget:IsEnemy()) and (MyCurrentTarget:GetRangeTo(myself) < 1000)  then
				if (MyCurrentTarget:GetTarget() == findmypthealer()) then
					return false;
				end;
		end;
		local playerlist = GetPlayerList();
		for player in playerlist.list do
			if player:IsEnemy() and player:GetTarget() == findmypthealer() and (player:GetRangeTo(myself) < 1000) then
				return true;
			end;
		end;
	end;
	return false;
end;

function TargetAnEnemyThatNeedAgro()
	local playerlist = GetPlayerList();
	myptidpetlist = GetMyPartyPetIDList();
	local priority = 0;
	local playerid = nil;
	for player in playerlist.list do
		if (player:IsEnemy()) and (player:GetRangeTo(myself) < 850) then
			playertarget = GetUserById(player:GetTarget());
			if (playertarget ~= nil) then
				if (playertarget:GetId() == findmypthealer()) and (priority <= 5) then
					playerid = player:GetId();
					priority = 5;
				end;
				if (playertarget:IsMyPartyMember()) and (priority <= 2) then
					playerid = player:GetId();
					priority = 2
				end;				
			end;
			if CheckIfInsideList(player:GetTarget(),myptidpetlist) and (priority <= 1)   then
				playerid = player:GetId();
				priority = 1;
			end;
		end;
	end;

	if (playerid ~= nil)  then -- and (myself:GetTarget() ~= playerid) 
		ClearTargets();
		TargetRaw(playerid);
	end;
end;

function findmypthealer()
	local ptmembers = GetPartyList();
	for member in ptmembers.list do
		if (member:GetClass() == 146) then
			return member:GetId();
		end;
	end;
	return nil;
end;

function TargetAMobThatNeedAgro()
	local moblist = GetMonsterList();
	myptidpetlist = GetMyPartyPetIDList();
	local priority = 0;
	local mobid = nil;
	for mob in moblist.list do		
		mobtarget = GetUserById(mob:GetTarget());
		if (mobtarget ~= nil) then 
			if (mobtarget:IsMyPartyMember()) then
				if (mob:GetRangeTo(myself) < 900) and (mobtarget:GetId() == findmypthealer()) and (findmypthealer() ~= 0) then
					mobid = mob:GetId();
					priority = 7;
				end
				if (mob:GetRangeTo(myself) < 400) and (priority <= 4) then
					if (mob:GetRangeTo(myself) > 100) and (priority <= 5) then
						mobid = mob:GetId();
						priority = 5;
					elseif (priority <= 3) then
						mobid = mob:GetId();
						priority = 4;
					end;
				end;
				if (mob:GetRangeTo(myself) < 850) and (priority <= 2) then
					if (mob:GetRangeTo(myself) > 100) then
						mobid = mob:GetId();
						priority = 3;
					else
						mobid = mob:GetId();
						priority = 2;
					end;
				end;
			end;	
		end;
		if CheckIfInsideList(mob:GetTarget(),myptidpetlist) and (mob:GetRangeTo(myself) < 850) and (priority < 1)   then
			mobid = mob:GetId();
			priority = 1;
		end;
		
	end;
	if (mobid ~= nil) then --and (myself:GetTarget() ~= mobid) 
		ClearTargets();
		TargetRaw(mobid);
	end;
end;

function GetMyPartyPetIDList()
	local tempreturnlist = {} ;
	local tempptmembersnames = {} ;
	local myptmembers = GetPartyList();
	local petlist = GetPetList();
	for member in myptmembers.list do
		table.insert(tempptmembersnames,member:GetName());	
	end;
	for pet in petlist.list do
		if (CheckIfInsideList(pet:GetNickName(),tempptmembersnames) == true) then
			table.insert(tempreturnlist,pet:GetId());	
		end;
	end;	
	return tempreturnlist;
end;

function CheckIfInsideList(thevalue,thelist) 
	for x,y in pairs(thelist) do
		if (y == thevalue) then
			return true;
		end;
	end;
	return false;
end;

function DoINeedNewTarget()
	if (MyCurrentTarget ~= nil) then 
		if (MyCurrentTarget:IsAlikeDeath() == false) then
			if ((MyCurrentTarget:IsMonster()) and (pvp == false)) or ((MyCurrentTarget:IsEnemy()) and (pvp == true)) then
				if ((MyCurrentTarget:GetRangeTo(myself) < 600) and (ShieldStrike < CurrentTime)) or (MyCurrentTarget:GetRangeTo(myself) < 900) then
					local MyTargetTarget = GetUserById(MyCurrentTarget:GetTarget());
					if (MyTargetTarget ~= nil) then
						if (MyTargetTarget:IsMyPartyMember()) or CheckIfInsideList(MyTargetTarget:GetId(),myptidpetlist) then
							return false;
						end;			
					end;
				end;
			end;
		end;
	end;
	return true;	
end;

function IsThereMobsAround()
	local monsterlist = GetMonsterList();
	local count = 0;
	for mob in monsterlist.list do
		if (mob:GetRangeTo(myself) < 350) then
			count = count +1;
		end;
	end;
	if (count > 1) then
		return true;
	end;
	return false;
end;



function AnyFlaggedAround()
	local playerlist = GetPlayerList();
	for player in playerlist.list do
		if (player:IsMyPartyMember() == false) and (player:IsEnemy()) then
			if (player:IsPvPFlag() == true) then
				if (player:GetRangeTo(myself) < 800) then
					return true;
				end;
			end;
		end;
	end;
	return false;
end;

function OnMagicSkillUse(user, target, skillId, skillvl, skillHitTime, skillReuse)
	if (user:IsMe()) then	
		if (skillId == 10027) then
			AuraOfHateRdy = GetTime()+skillReuse;
		elseif (skillId == 10026) then
			AgressionRdy = GetTime()+skillReuse;
		elseif (skillId == 10015) then 
			ShieldStrike = GetTime()+skillReuse; 
		end;
		--ShowToClient("skillid",tostring(skillId));
	end;	
end;

function FindSubStringInString(thesub,thestring) -- build it myself the lua built-in one is not working exactly as needed.
	for x = 1, 1 + string.len(thestring)-string.len(thesub),1 do
		if (string.sub(thestring,x,x+string.len(thesub)-1) == thesub) then
			return true;
		end;
	end;
	return false;
end;

function OnChatUserMessage(chatType, nick, msg)
	if (chatType == L2ChatType.CHAT_PARTY) and (outspot ~= nil) then
		Message = string.lower(msg); -- Converts message to lower case letters.
		Message = Message:gsub("^%s*(.-)%s*$", "%1"); -- Trimming message of spaces on start.
		if (tankonspot == true) and (Message == "out") or FindSubStringInString("go out",Message) or FindSubStringInString("come out",Message) then
			retreat = true;
			TankStatus = false;
		end;
		if FindSubStringInString("go tank",Message) or FindSubStringInString("tank go",Message) then
			retreat = false;
			TankStatus = true;
		end;
	end;
end;