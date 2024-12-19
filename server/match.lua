Match = {}
Match.__index = Match

local activeMatches = {}

---@param lobby string The lobby name
---@param player1 table Player 1 (source, name, etc.)
---@param player2 table Player 2 (source, name, etc.)
---@return table The new match instance
function Match:new(lobby, player1, player2)
    local self = setmetatable({}, Match)
    
    self.lobby = lobby
    self.players = { player1, player2 }
    self.isActive = false
    self.id = ('%s-%s'):format(player1.source, player2.source)
    self.map = pickRandomMap()

    return self
end

function Match:start()
    if self.isActive then return end
    self.isActive = true

    local matchData = {
        lobby = self.lobby,
        map = self.map,
    }

    local teamAssignments = {
        [self.players[1].source] = 'team1',
        [self.players[2].source] = 'team2'
    }

    for _, player in ipairs(self.players) do
        matchData.opponent = self:getOpponent(player.source)
        matchData.opponentName = GetPlayerName(matchData.opponent)
        matchData.team = teamAssignments[player.source]
        TriggerClientEvent('esx_duels:matchStarted', player.source, matchData)
        
        if Config.anticheat then
            TogglePlayerBypass(player.source, true)
        end
    end

    activeMatches[self.id] = self
end

---@param playerId number The source of the current player
---@return number The source of the opponent player
function Match:getOpponent(playerId)
    for _, player in ipairs(self.players) do
        if player.source ~= playerId then
            return player.source
        end
    end
    return nil
end

---@param winnerId number The source of the winning player
function Match:endMatch(winnerId)
    if not self.isActive then return end
    self.isActive = false


    for _, player in ipairs(self.players) do
        local result = (player.source == winnerId) and 'You won the match!' or 'You lost the match!'
        TriggerClientEvent('esx:showNotification', player.source, result)
        TriggerClientEvent('esx_duels:matchEnded', player.source, winnerId, GetPlayerName(self:getOpponent(player.source)))
        
        if Config.anticheat then
            TogglePlayerBypass(player.source, false)
        end
    end

    self.players = nil
    self.lobby = nil
    activeMatches[self.id] = nil
end

---@param playerId number Player id to get match from.
function GetMatchFromPlayer(playerId)
    for _, match in pairs(activeMatches) do
        for _, player in ipairs(match.players) do
            if player.source == playerId then
                return match
            end
        end
    end
    return nil
end