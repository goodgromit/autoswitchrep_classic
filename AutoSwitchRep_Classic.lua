local AutoSwitchRep = CreateFrame("Frame")

-- 이벤트 등록
AutoSwitchRep:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
AutoSwitchRep:RegisterEvent("PLAYER_LOGIN")

-- 패턴 미리 생성 (성능 최적화)
local pattern_inc = FACTION_STANDING_INCREASED:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)")
local pattern_dec = FACTION_STANDING_DECREASED:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)")
local pattern_gen = FACTION_STANDING_INCREASED_GENERIC:gsub("%%s", "(.+)")

-- 평판 이름을 ID로 매핑할 테이블
local factionNameToID = {}

-- 평판 목록 갱신 함수
local function UpdateFactionList()
    wipe(factionNameToID)
    for i = 1, GetNumFactions() do
        local name, _, _, _, _, _, _, _, isHeader, _, _, _, _, factionID = GetFactionInfo(i)
        if name and not isHeader and factionID then
            factionNameToID[name] = i
        end
    end
end

AutoSwitchRep:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        UpdateFactionList()
        
    elseif event == "CHAT_MSG_COMBAT_FACTION_CHANGE" then
        local msg = ...
        local factionName
        
        -- 메시지에서 평판 이름 추출
        local f, a = msg:match(pattern_inc)
        if not f then f, a = msg:match(pattern_dec) end
        if not f then f = msg:match(pattern_gen) end
        
        factionName = f
        
        if factionName and factionNameToID[factionName] then
            local i = factionNameToID[factionName]
            
            -- 현재 추적 중인 평판 데이터 가져오기 (최신 API)
            local watchedData = C_Reputation.GetWatchedFactionData()
            local currentName = watchedData and watchedData.name
            
            -- 현재 추적 중인 평판과 다를 때만 교체
            if currentName ~= factionName then
                SetWatchedFactionIndex(i)
                
                -- 메시지 출력 (autorep_string이 없을 경우를 대비한 방어 코드)
                local outputMsg = (autorep_string and autorep_string["CHANGE_REPUTATION_BAR"]) or "평판 바 전환: %s"
                -- print(format("|cff99CCFF" .. outputMsg .. "|r", factionName))
            end
        else
            -- 목록에 없는 새로운 평판일 수 있으므로 갱신 후 재시도
            UpdateFactionList()
        end
    end
end)