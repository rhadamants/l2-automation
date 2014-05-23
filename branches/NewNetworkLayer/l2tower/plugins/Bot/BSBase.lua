BSBase = {}

function BSBase:init()
	BotCommandFactory:registerCommand("inviteUser", self, self.cmdInviteUser)
	BotCommandFactory:registerCommand("acceptInvite", self, self.cmdAcceptInvite)
	BotCommandFactory:registerCommand("getUserInfo", self, self.cmdGetUserInfo)
	BotCommandFactory:registerCommand("setBotState", self, self.cmdSetBotState)
end

function BSBase:cmdInviteUser(dto)
	local cfg = json.decode(dto);
	local target = cfg.target or false;

	CreateThread(self, function ()
		Command("/invite "..target)
	end)
end

function BSBase:cmdAcceptInvite(dto)
	CreateThread(self, function ()
		AcceptPartyInvite(true);
	end)
end

function BSBase:cmdGetUserInfo(dto)
	local me = GetMe()
	SendServerMessage("MethodSetUserInfo", {
			i = me:GetId(),
			n = me:GetName(),
			nn = me:GetNickName(),
			c = me:GetClass(),
		})
end

function BSBase:cmdSetBotState(dto)
	local cfg = json.decode(dto);
	local state = not (cfg.pauseState or false);
	SetPause(state);
	iprint("L2Tower is now " .. (IsPaused() and "paused" or "resumed"));
end
