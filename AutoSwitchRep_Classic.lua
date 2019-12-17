local AutoSwitchRep = CreateFrame'Frame'

AutoSwitchRep:RegisterEvent'CHAT_MSG_COMBAT_FACTION_CHANGE'
AutoSwitchRep:RegisterEvent'PLAYER_LOGIN'

AutoSwitchRep:SetScript('OnEvent', function(self, event, ...)
  self[event](self, event, ...)
end)

local pattern_standing_inc = string.gsub(string.gsub(FACTION_STANDING_INCREASED, "(%%s)", "(.+)"), "(%%d)", "(%%d+)")
local pattern_standing_dec = string.gsub(string.gsub(FACTION_STANDING_DECREASED, "(%%s)", "(.+)"), "(%%d)", "(%%d+)")
local pattern_standing_inc_generic = string.gsub(FACTION_STANDING_INCREASED_GENERIC, "(%%s)", "(.+)")
local factions = {}

AutoSwitchRep.PLAYER_LOGIN = function(...)
  factions = {}

  for i = 1, GetNumFactions() do
    local name, _, _, _, _, _, _, _, isHeader, isCollapsed, _, _, _, factionID, _, _ = GetFactionInfo(i)
    if isHeader == false then
      factions[name] = i
    end
  end

  --for k,v in pairs(factions) do print(k .. " : " .. v) end
end

AutoSwitchRep.CHAT_MSG_COMBAT_FACTION_CHANGE = function(...)
  local _, _, arg1 = ...

  -- Check standing message for faction increase or decrease
  local s1, e1, faction, amount = string.find(arg1, pattern_standing_inc)
  -- If increase not found check for decrease
  if (s1 == nil) then
    s1, e1, faction, amount = string.find(arg1, pattern_standing_dec)
    if (s1 ~= nil) then
        dec = true
    end
  end
  -- check for generic gain
  if (s1 == nil) then
    s1, e1, faction = string.find(arg1, pattern_standing_inc_generic)
  end

  if (s1 ~= nil) then
    local _, _, _, _, _, currentlyWatchedID = GetWatchedFactionInfo()
    local name, _, _, _, _, _, _, _, isHeader, isCollapsed, _, _, _, factionID, _, _ = GetFactionInfo(factions[faction])
    --print("currentlyWatchedID : " .. currentlyWatchedID .. "factionID : " ..factionID)
    if (currentlyWatchedID ~= factionID) then
      SetWatchedFactionIndex(factions[faction])
      print(format(autorep_string["CHANGE_REPUTATION_BAR"], faction))
    end
  end
end