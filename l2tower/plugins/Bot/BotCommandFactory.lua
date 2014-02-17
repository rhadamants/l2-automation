BotCommandFactory = {
	commands = {}
}

function BotCommandFactory:registerCommand(cmdName, inst, func)
	self.commands[cmdName] = {inst = inst, func = func};
end

function BotCommandFactory:runCommand(cmdData, ...)
	local cmdArr = split(cmdData, " ")
	local cmd = self.commands[cmdArr[1]];
	if not cmd then
		return eprint("No such command :" .. tostring(cmdData)); end

	cmd.func(cmd.inst, #cmdArr>1 and cmdArr[2] or nil)
end

