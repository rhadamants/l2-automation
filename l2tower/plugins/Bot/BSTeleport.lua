-- watches your dialog actions in order to force bots who are following you to repeat them
-- /wg  activate/deactivate 
BSTeleport = {}

function BSTeleport:reset()
  if self.thread then
  StopThread(self.thread)
  self.thread = nil;
  end
  self.lastHtml = nil;
  self.lastDialogNpc = nil;
end

function BSTeleport:init()
  this:RegisterCommand("dlgAct", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
  this:RegisterCommand("html", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
  this:RegisterCommand("wg", CommandChatType.CHAT_ALLY, CommandAccessLevel.ACCESS_ME);
end

function OnCommand_wg(vCommandChatType, vNick, vCommandParam)
  local self = BSTeleport;
  if self.thread then
    dprint("Stop watchgo");
    return self:reset();
  end
  dprint("start watchgo");
  self.lastHtml = GetDialogHtml();
  self.thread = CreateThread(self, self.watchDialogProc);
end

function OnCommand_dlgAct(vCommandChatType, vNick, vCommandParam)
  local self = BSTeleport;
  if (vCommandParam:GetCount() == 1 and vCommandParam:GetParam(0) ~= nil) then
    local action = vCommandParam:GetParam(0):GetStr(true);
    log("click action ", action)
    action = tonumber(action);
    if self.links[action] then
      SendServerMessage("followersDialogAction", {action="selectDialogItem", param=action})
      QuestReply(self.links[action])
      self.links = {};
    end
  end;
end;

function OnCommand_html(vCommandChatType, vNick, vCommandParam)
  dump(GetDialogHtml())
end;

function dump(text)
  text = text or "none"
  local outputFile = GetDir() .. "\\html.txt"
  local f, err = io.open(outputFile, "w+")
  f:write(text)
  f:flush()
  f:close()
end

-- raplacing links in menues by buttons is possible, but ugly a bit
-- local htmlToShow, c = string.gsub(newHtml, "<a action=\"bypass %-h (.-)\".->(.-)</a>", buildButton)
-- local function buildButton(action, text)
--   text = text:gsub("\"", "\\\"")
--   return "<button action=\"bypass -h /dlgAct ".. action .."\" value=\"".. text .."\" width=300 height=15 back=\"true\" fore=\"true\">"
-- end

local function saveLink(link)
  table.insert(BSTeleport.links, link);
  return "bypass -h /dlgAct "..#BSTeleport.links .."\"";
end

function BSTeleport:watchDialogProc()
  while EventsBus:waitOn("OnLTick500ms") do
    local newHtml = GetDialogHtml();
    if newHtml ~= self.lastHtml then
      log("new dialog appear")
      self.lastHtml = newHtml;
      self.links = {};
      newHtml = newHtml:gsub("msg=\".-\"", "") -- remove popup msg

      local htmlToShow, c = string.gsub(newHtml, "bypass %-h (.-)\"", saveLink)
      
      log("links count ", c)
      dump(htmlToShow)
      ShowHtml(htmlToShow)
      local currentDialogNpc = GetTarget():GetId()

      if self.lastDialogNpc ~= currentDialogNpc then
        self.lastDialogNpc = currentDialogNpc;
        SendServerMessage("followersDialogAction", {action="openDialog", param=GetTarget():GetId()})
      end
    end
  end
end
