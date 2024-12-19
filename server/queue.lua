local queues = {}

---@param playerId number The source of the player
---@return boolean: True if the player is in a queue, false otherwise
local function isInQueue(playerId)
    for lobby, players in pairs(queues) do
        if players[playerId] then
            return true
        end
    end
    return false
end

---@param source number The source of the player
---@param lobby string The lobby the player is joining
local function addToQueue(source, lobby)
    queues[lobby] = queues[lobby] or {}

    queues[lobby][source] = true

    local playerSources = {}
    for player in pairs(queues[lobby]) do
        playerSources[#playerSources+1] = player
    end

    if #playerSources >= 2 then
        local player1 = { source = playerSources[1] }
        local player2 = { source = playerSources[2] }

        queues[lobby][player1.source] = nil
        queues[lobby][player2.source] = nil

        Player(player1.source).state:set('inDuelQueue', false, true)
        Player(player2.source).state:set('inDuelQueue', false, true)

        local match = Match:new(lobby, player1, player2)
        match:start()
    end
end

---@param lobby string The queue
---@return nil
local function joinQueue(lobby)
    local source = source
    lobby = lobby or 'main'

    if not Config.allowedLobbies[lobby] then
        print(('Invalid lobby (%s) tried to be joined by playerId %s'):format(lobby, source))
        return
    end

    if isInQueue(source) then
        print(('playerId %s is trying to join a queue when he already is in one.'):format(source))
        return
    end

    Player(source).state:set('inDuelQueue', true, true)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.showNotification(('You joined the queue %s'):format(lobby))
    addToQueue(source, lobby)
end

---@param lobby string The lobby that the player is leaving
---@return nil
local function leaveQueue(lobby)
    local source = source
    if not isInQueue(source) then
        return
    end

    if not queues[lobby] then
        return
    end

    if not queues[lobby][source] then
        return
    end

    Player(source).state:set('inDuelQueue', false, true)
    queues[lobby][source] = nil
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.showNotification(('You left the queue: %s'):format(lobby))
end

RegisterNetEvent('esx_duels:joinQueue', joinQueue)
RegisterNetEvent('esx_duels:leaveQueue', leaveQueue)