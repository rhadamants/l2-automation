BSResurrect = {
	ressurrectSkillsCfg = {
		[144] = 11564, -- Воскрешение Ангела
		[146] = 11784, -- Милосердное Воскрешение
	},
	resSkillId = nil,
	knownDeads = nil;
}

function BSResurrect:init()
	local userClass = GetMe():GetClass();
	if (not self.ressurrectSkillsCfg[userClass]) then
		return; end

	self.resSkillId = self.ressurrectSkillsCfg[userClass]
	BotCommandFactory:registerCommand("ressurrect", self, self.cmdResurrect)

	EventsBus:addCallback("OnDie", function(user, spoiled)
		self:checkForDead()
	end)

	CreateThread(self, self.checkingProcess)
end

function BSResurrect:checkForDead()
	local deads = {}
	local pl = GetPlayerList()
	if pl:GetCount() > 0 then
		for user in pl.list do
			if user:IsAlikeDeath() then
				table.insert(deads, self:createDeadUserRecord(user));
			end
		end
	end

	if GetMe():IsAlikeDeath() then
		table.insert(deads, self:createDeadUserRecord(GetMe()));
	end

	if self:isDeadsChanged(deads) then
		self.knownDeads = deads;
		BotNetworkDispatcher:sendMessage({m="UpdateDeadUsers",d={deads=deads}})
	end
end

function BSResurrect:createDeadUserRecord(user)
	return {n=user:GetName(),c=user:GetClass(),i=user:GetId()};
end

function BSResurrect:isDeadsChanged(deads)
	if not self.knownDeads or #self.knownDeads ~= #deads then
		return true;
	end

	for _,newDead in pairs(deads) do
		if not table.any(self.knownDeads, function(dead) return dead.i == newDead.i; end) then
			return true;
		end
	end
end

function BSResurrect:checkingProcess()
	while EventsBus:waitOn("OnLTick1s") do
		self:checkForDead()
	end
end

function BSResurrect:cmdResurrect(jsonCfg)

	local cfg = json.decode(jsonCfg);
	local userId = cfg.target;
	local canDelegate = cfg.canDelegate;
	if (tonumber(userId) == nil) then
		return; end

	if self.thread ~= nil then
		return; end

	self.thread = CreateThread(self, function ()
		self:resurrectUser(userId, canDelegate)
	end)
end

function BSResurrect:resurrectUser(userId, canDelegate)
	local user = GetUserById(userId)
	local resSkill = GetSkills():FindById(self.resSkillId)
	
	if not user or not user:IsAlikeDeath() then
		self.thread = nil;
		return eprint("Resurrect: User is not dead");
		
	elseif resSkill and resSkill:CanBeUsed() then
		local resSkillReuse = resSkill:GetReuse();

		dprint("Going to ressurrect ".. user:GetName().." in " .. tostring(resSkillReuse))
		if resSkillReuse > 0 then
			ThreadSleepMs(resSkillReuse + 100)
		end

		if not user or not user:IsAlikeDeath() then
			self.thread = nil;
			return eprint("Resurrect: User is not dead"); end

		LockPause()
		SelectTargetByOId(userId)
		CastSkill(self.resSkillId, 3);
		SelectTargetByOId(0)
		UnlockPause()

	else
		self.thread = nil;
		return eprint("Resurrect: Not able to res user");
	end
end