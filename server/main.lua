local duelInvites = {}

---@param data table The data related to the player's death
local function onPlayerDeath(data)
    local source = source
    local match = GetMatchFromPlayer(source)

    if not match then
        return
    end

    local winner = match:getOpponent(source)
    match:endMatch(winner)
end

---@return DuelMap The randomly selected map
function pickRandomMap()
    return Config.maps[math.random(#Config.maps)]
end

---@param source number The source of the player sending the invite
---@param args table The command arguments
local function duelCommand(source, args)
    local target = args[1]
    local xPlayer = ESX.GetPlayerFromId(source)

    if not target then
        xPlayer.showNotification('You did not specify a player to duel. Correct usage: /duel [playerId]')
        return
    end


    TriggerClientEvent('esx_duels:sendDuelInvite', target, source, GetPlayerName(source))
    duelInvites[source] = tonumber(target)
end

local function acceptDuelInvite(invitedBy)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    local target = duelInvites[invitedBy]

    if not target or target ~= source then
        xPlayer.showNotification('You have not been invited to a duel by this player or the player invited someone else.')
        return
    end

    local xInviter = ESX.GetPlayerFromId(invitedBy)

    if not xInviter then
        xPlayer.showNotification('The player who invited you to a duel is no longer online.')
        return
    end

    Player(xPlayer.source).state:set('inDuelQueue', false, true)
    Player(xInviter.source).state:set('inDuelQueue', false, true)
    duelInvites[invitedBy] = nil
    xInviter.showNotification(('Player %s accepted your invite, creating match...'):format(source))
    xPlayer.showNotification('Accepted invite, creating match...')

    SetTimeout(2000, function()
        local player1 = { source = xPlayer.source }
        local player2 = { source = xInviter.source }

        local match = Match:new('main', player1, player2)
        match:start()
    end)
end

---@param invitedBy number The source of the player who sent the invite
local function declineDuelInvite(invitedBy)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xInviter = ESX.GetPlayerFromId(invitedBy)

    if xInviter then
        xInviter.showNotification(('Player %s declined your duel invite.'):format(source))
    end

    duelInvites[invitedBy] = nil
end

CreateThread(function()
    for _, player in ipairs(GetPlayers()) do
        Player(player).state.inDuelQueue = false
    end
end)

RegisterNetEvent('esx:onPlayerDeath', onPlayerDeath)
RegisterCommand('duel', duelCommand, false)
RegisterNetEvent('esx_duels:acceptDuelInvite', acceptDuelInvite)
RegisterNetEvent('esx_duels:declineDuelInvite', declineDuelInvite)
