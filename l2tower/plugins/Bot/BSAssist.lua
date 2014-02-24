-- under development

BSAssist = {
	enabled = false;
}

function BSAssist:init()
	--BotCommandFactory:registerCommand("assist", self, self.cmdAssist)
	BotCommandFactory:registerCommand("startAssist", self, self.cmdStartAssist)
	BotCommandFactory:registerCommand("stopAssist", self, self.cmdStopAssist)
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
	
end


function BSAssist:cmdStartAssist(jsonCfg)
	local cfg = json.decode(jsonCfg);
	local masterId = cfg.master;
	
	--check for master from Follow script
	--self.masterId = masterId;
	--self.master = todo;
	
	if not self.enabled then
		self:startAssist()
	end
	
	self.enabled = true;
end

function BSAssist:startAssist()
	self.assistCallbacks = {}
	self.assistCallbacks["OnTargetSelected"] = 
		EventsBus:addCallback("OnTargetSelected", 
			function(user, target)
				if user:GetId() == self.masterId then
					self:masterTargetChanged(user, target)
				end
			end
		);
	self.assistCallbacks["OnTargetUnselected"] = 
		EventsBus:addCallback("OnTargetUnselected", 
			function(user)
				if user:GetId() == self.masterId then
					self:masterTargetCleared(user, target)
				end
			end
		);
end

function BSAssist:cmdStopAssist()
	if not self.enabled then
		return; end
		
	self.enabled = false;
	for eventName,handler in pairs(self.assistCallbacks) do
		EventsBus:removeCallBack(eventName, handler);
	end
end

function BSAssist:masterTargetChanged(master, target)
	local targetId = target:GetId();
	if targetId ~= GetMe():GetTarget():GetId() then
		if not master:IsInCombat() then
			SelectTargetByOId(targetId);
		end
	end
end

function BSAssist:masterTargetCleared(master)
	SelectTargetByOId(0);
end

