RuntimeLogs = {
	foldingShift = 0
}


function RuntimeLogs:interceptByName(tableName)
    if (_G[tableName] ~= nil) then
        self:interceptClass(_G[tableName], tableName);
    end
end

function RuntimeLogs:interceptClass(classLink, className)
    local folding = true;
    local silent = false;
    
    classLink._className = className;
    classLink.OriginalMethods = classLink.OriginalMethods or {};
    for classFunctionName, classFunction in pairs(classLink) do
        if (type(classFunction) == "function") and (nil == classLink.OriginalMethods[classFunctionName]) then
            -- save original function
            classLink.OriginalMethods[classFunctionName] = classFunction;
            -- define debug function
            classLink[classFunctionName] = function (...)
                
                if not silent then
                    self.currentClass = className;
                    self.currentFunction = classFunctionName;
                    -- build log string
                    local out = string.format("[trace]%s%s.%s", string.rep("|   ", self.foldingShift), className, classFunctionName);
                    out = out .. self:buildInputParameters(...);
                    this:Log(out);
                end

                self.foldingShift = self.foldingShift + 1;
                
                local function callWrapper(noErr, ...)
                    self.foldingShift = self.foldingShift - 1;

                    if not noErr then
                    	this:Log(({...})[1]);
						return nil;
					end
                    return ...;
                end
                
                return callWrapper(pcall(classLink.OriginalMethods[classFunctionName], ...));
            end; -- >> interceptor function
        end -- >> if we trap on function in class
    end -- >> for each element in class
end

function RuntimeLogs:buildInputParameters(...)
    local result = {};
    for i = 1, select("#", ...) do
        result[i] = type(select(i, ...));

    end
    return "(".. table.concat(result, ", ") .. ")";
end
