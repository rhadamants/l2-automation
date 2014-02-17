BSSpamBlock = {}

function BSSpamBlock:init()
	BotCommandFactory:registerCommand("blockChatUser", self, self.cmdBlockChatUser)

	EventsBus:addCallback("OnChatUserMessage", function(chatType, nick, msg)
		if (chatType == 2) then
			BotNetworkDispatcher:sendMessage({m="NewPM",d={msnger=nick}})
		end
		
	end)
end

function BSSpamBlock:cmdBlockChatUser(jsonCfg)	
	local cfg = json.decode(jsonCfg);
	local userName = cfg.userName;

	Command("/block "..userName);

	-- if (tonumber(target) == nil) then
	-- 	return; end

	-- CreateThread(self, function ()
	-- 	SelectTargetByOId(target)
	-- end)
end