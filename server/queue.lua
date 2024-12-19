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

    assert(Config.allowedLobbies[lobby] ~= nil, ('Lobby %s is not allowed.'):format(lobby))
    assert(isInQueue(source) == false, 'Player is already in a queue.')

    Player(source).state:set('inDuelQueue', true, true)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.showNotification(('You joined the queue %s'):format(lobby))
    addToQueue(source, lobby)
end

---@param lobby string The lobby that the player is leaving
---@return nil
local function leaveQueue(lobby)
    local source = source
    
    assert(queues[lobby] ~= nil, ('Queue %s does not exist.'):format(lobby))
    assert(isInQueue(source) == true, 'Player is not in a queue.')

    Player(source).state:set('inDuelQueue', false, true)
    queues[lobby][source] = nil
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.showNotification(('You left the queue: %s'):format(lobby))
end

RegisterNetEvent('esx_duels:joinQueue', joinQueue)
RegisterNetEvent('esx_duels:leaveQueue', leaveQueue)