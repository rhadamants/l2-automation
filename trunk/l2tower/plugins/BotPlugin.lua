
--if true then return; end

IsDebugEnabled = true;

function InitLA()
	const_scripts_path = package.path .. "..\\..\\plugins\\Bot\\";

	dofile(package.path .. "socket.lua");
	socket = require("socket")
	dofile(package.path .. "json.lua");
	json = require("json")

	dprint = function(...) if IsDebugEnabled then ShowToClient("debug", ({...})[1]); end end
	eprint = function(...) ShowToClient("ERROR", ({...})[1]); end
end

function InitLua()
	const_scripts_path = "D:\\!gam\\l2tower\\plugins\\Bot\\";
	dofile(const_scripts_path .. "L2TowerEnv.lua");
	socket = require("socket")
	dofile("D:\\!gam\\l2tower\\libs\\Lua\\json.lua");
	json = require("json")

	dprint = function(...) if IsDebugEnabled then print(...) end end
	eprint = function(...) print("ERROR ", ...) end
end

if arg and arg[1] == "lua" then
	InitLua()
else
	InitLA()
end

local modules = {
	"BotEventsHook.lua", 
	"BotNetworkDispatcher.lua", 
	"BotCommandFactory.lua",
	"BotUtil.lua",
	"BSIssbuff.lua",
	"BSAssist.lua",
	"BSResurrect.lua",
	"BSBase.lua",
	"BSSpamBlock.lua",
	"BSFollow.lua",
	"LinkedList.lua",

	"BSTeleport.lua",
}
for _,file in pairs(modules) do xpcall(function() dofile(const_scripts_path .. file); end, dprint) end


EventsBus:init();


IsInitDone = false;
--- init is called only once
function Init()
	if IsInitDone then 
		return; end
	IsInitDone = true;
	BSBase:init();
	BSIssBuff:init();
	BSAssist:init();
	BSResurrect:init();
	BSSpamBlock:init();
	BSFollow:init();

	BSTeleport:init();
end

IsStarted = false
--- called for each user login
function Start()
	if IsStarted then 
		return; end
	IsStarted = true;
	BotNetworkDispatcher:start();
end

EventsBus:addCallback("OnCreate", function ()
	dprint("OnCreate")
	if IsLogedIn() then
		Init();
		Start();
	end
end, true)

EventsBus:addCallback("OnLogin", function ()
	dprint("OnLogin")
	Init();
	Start();
end, true)



EventsBus:addCallback("OnLogout", function ()
	IsStarted = false
end, true)
EventsBus:addCallback("OnDestroy", function ()
	IsStarted = false
end, true)







