BotNetworkDispatcher = {
	messagesToSend = {},
	connection = nil,
}

function BotNetworkDispatcher:start()
	self:sendMessage(self:getLoginMessage());
	--self.thread = coroutine.create(function () self:networkDispatcherThreadProc() end)
	--RunThread(self.thread);
	CreateThread(self, self.networkDispatcherThreadProc, self.dispose)
	--return self.thread;
end

function BotNetworkDispatcher:sendMessage(msg)
	if "table" == type(msg) then
		msg = json.encode(msg)
	elseif "string" == type(msg) then
		-- OK
	else
		return eprint("BotNetworkDispatcher:sendMessage() incorrect message type: " .. type(msg));
	end
	table.insert(self.messagesToSend, msg)
end

function SendServerMessage(serverMethod, data)
	BotNetworkDispatcher:sendMessage({
		m = serverMethod,
		d = data
	});
end

function BotNetworkDispatcher:networkDispatcherThreadProc()
	-- local lastAttempt = 0;
	-- while EventsBus:waitOn("OnLTick1s") do
	-- 	if os.time() - lastAttempt > 10 then
	-- 		lastAttempt = os.time();
	-- 		--log(pcall(function()self:handleConnection()end))
	-- 	end
	-- end
	self:handleConnection()
end

function BotNetworkDispatcher:handleConnection()
	local c = assert(socket.connect("192.168.0.105", 8888))
	self.connection = c;
	c:settimeout(0)   -- do not block
	while EventsBus:waitOn("OnLTick") do
		local r, w = socket.select({c}, {c}, 0)
		if r then
			local s, status = c:receive("*l")
			if (s) then
				log("process command: ", s)
				--BotCommandController:processCommand(s)
				BotCommandFactory:runCommand(s)
			end

			if status == "closed" then 
				log("connection was closed")
				break; -- todo reconnect
			end
		end
		local messagesToSend = BotNetworkDispatcher.messagesToSend;
		if w and #messagesToSend > 0 then
			for _,message in ipairs(messagesToSend) do
				c:send(message.."\n\r")
			end
			BotNetworkDispatcher.messagesToSend = {};
		end
	end
end

-- called when this thread is going to be removed
function BotNetworkDispatcher:dispose()
	self.connection:close();
	self.connection = nil;
end

function BotNetworkDispatcher:getLoginMessage()
	local me = GetMe()
	return {
		m = "SignIn",
		d = {
			i = me:GetId(),
			n = me:GetName(),
			nn = me:GetNickName(),
			c = me:GetClass(),
		}
	}
end

