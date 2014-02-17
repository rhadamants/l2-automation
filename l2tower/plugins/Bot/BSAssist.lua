BSAssist = {}

function BSAssist:init()
	BotCommandFactory:registerCommand("assist", self, self.cmdAssist)
	this:RegisterCommand("assist", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
end
function OnCommand_assist(vCommandChatType, vNick, vCommandParam)
	local target = GetTarget()
	local targetId = target and target:GetId() or 0;
	
	BotNetworkDispatcher:sendMessage({
		m = "Assist",
		d = {
			target = targetId,
		}
	});
	
end;

function BSAssist:cmdAssist(jsonCfg)	
	local cfg = json.decode(jsonCfg);
	local target = cfg.target;
	if (tonumber(target) == nil) then
		return; end

	CreateThread(self, function ()
		SelectTargetByOId(target)
	end)
end

