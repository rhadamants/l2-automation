dprint = function(...) ShowToClient("debug", ({...})[1]); end

log = function(...)
    local resultLine = "";
    for i = 1, select("#", ...) do
        local line = select(i, ...);
        if (line == nil) then
            resultLine = resultLine .. " NIL";
        elseif type(line) == "table" then
            resultLine = resultLine .. " " .. createTableString(line) .. " ";
        elseif type(line) == "userdata" then
            resultLine = resultLine .. " " .. type(line);
        else
            resultLine = resultLine .. " " .. tostring(line);
        end;
    end;
    dprint(resultLine);
end;

function createTableString(input)
 	local shift = 0;
 	local tablesOpened = {}
 	local function innerCreateTableString(input)
		if type(input) == "table" then
		    if (nil == tablesOpened[input]) then
		        tablesOpened[input] = input;
                local result = {"Table: \n"};
                shift = shift + 1;
                for key, value in pairs (input) do
                    result[#result+1] = string.rep("|   ", shift);
                    result[#result+1] = string.format("[%s] = %s", tostring(key), innerCreateTableString(value));
                end;
                shift = shift - 1;
                return table.concat(result);
            else
                return "[RECURSIVE LINK]\n";
            end
   		 else
      		return tostring(input) .. "\n";
   		 end;
  	end;
  	return innerCreateTableString(input);
end

function CastSkill(id)
	skill = GetSkills():FindById(id)
	if skill and skill:CanBeUsed() and skill:GetReuse() == 0 then
		UseSkillRaw(id,false,false)
		return true
	end
	return false
end

function CastOneByList(list)
	if "table" ~= type(list) then return dprint("CastOneByList(list) - >> list not a table") end
	for _, id in pairs(list) do
		if CastSkill(id) then
			return true;
		end
	end
end

function CastOneByOneList(list, counter)
	if "table" ~= type(list)  then return dprint("CastOneByOneList(list) - >> list not a table") end
	--or "numer" ~= type(counter) or counter < 0
	repeat
		counter = counter + 1;
		if #list < counter then
			counter = 1;
		end
	until CastSkill(list[counter])
	SingleAttackCounter = counter
	return true;
	--[[for _, id in pairs(list) do
		if CastSkill(id) then
			return true;
		end
	end]]
end


function MobsAroundTarget(targer, range)
	
	local mobs = GetMonsterList()
	local i=0
	for m in mobs.list do
		if m:GetHpPercent() ~= 0 and targer:GetRangeTo(m) <= range then
			i = i+1
		end
	end
	return i
	
end

function MobsCount(range)
	mobs = GetMonsterList()
	i=0
	for m in mobs.list do
		 if m:GetDistance() <= range and m:GetHpPercent() ~= 0 then
			 i = i+1
		 end
	end
	return i
end