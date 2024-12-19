local currentMatch, initialPosition = nil, nil

local function handleBorder()
    assert(currentMatch.map.centerCoords ~= nil, 'Map center coords are missing.')

    currentMatch.map.radius = currentMatch.map.radius or 50.0
    currentMatch.map.drawBorderDistance = currentMatch.map.drawBorderDistance or 40.0

    local sleepMs = 1000

    while currentMatch do
        local distance = #(ESX.PlayerData.coords - currentMatch.map.centerCoords)

        if distance >= currentMatch.map.radius then
            local sleepMs = GetEntityHealth(ESX.PlayerData.ped)
            SetEntityHealth(ESX.PlayerData.ped, sleepMs - 10.0)
            ESX.ShowNotification('Return to the map area or you will take damage!')
        end

        if currentMatch.map.drawBorder and distance >= currentMatch.map.drawBorderDistance and distance < currentMatch.map.radius then
            sleepMs = 0
            DrawSphere(currentMatch.map.centerCoords.x, currentMatch.map.centerCoords.y, currentMatch.map.centerCoords.z, currentMatch.map.radius, 200, 10, 10, 0.3)
        else
            sleepMs = 1000
        end

        Wait(sleepMs)
    end
end

local function handleWeapons()
    if not currentMatch.map.weapon then 
        return -- early return, no need to have a loop running if currentMatch->weapon is nil
    end
    ESX.AssertType(currentMatch.map.weapon, 'string', 'currentMatch->weapon is not a weapon name (string).')

    if Config.oxInventory then
        -- Enabling weapon wheel so we can use weapons that arent in the inventory
        exports.ox_inventory:weaponWheel(true)
    end

    local requiredWeapon = joaat(currentMatch.map.weapon)

    while currentMatch do
        if currentMatch.map.weapon and GetSelectedPedWeapon(ESX.PlayerData.ped) ~= requiredWeapon then
            GiveWeaponToPed(ESX.PlayerData.ped, requiredWeapon, 250, false, true)
            SetCurrentPedWeapon(ESX.PlayerData.ped, requiredWeapon, true)
        end
        Wait(500)
    end

    local tries = 0
    repeat
        RemoveWeaponFromPed(ESX.PlayerData.ped, requiredWeapon)
        SetCurrentPedWeapon(ESX.PlayerData.ped, `WEAPON_UNARMED`, true)
        Wait(100)
    until GetSelectedPedWeapon(ESX.PlayerData.ped) or tries >= 10

    if Config.oxInventory then
        exports.ox_inventory:weaponWheel(false)
    end
end

---@param opponent string The name of the opponent
local function startCountdown(opponent)
    SendNUIMessage({
        action = 'startCountdown',
        opponent = opponent
    })
    Wait(5000)
end

---@param matchData table The data for the match
local function matchStarted(matchData)
    assert(matchData ~= nil, 'matchData should not be nil.')
    
    if not Config.allowedLobbies[matchData.lobby] then
        error('Tried to start match in disallowed lobby.')
    end
    
    if not matchData.map then
        error('Match Map is nil, something went wrong.')
    end

    if LocalPlayer.state.isDead then
        TriggerEvent(Config.reviveEvent)
        Wait(Config.reviveDelay or 0)
    end

    currentMatch = matchData
    initialPosition = ESX.PlayerData.coords
    local spawnCoords = matchData.map.teamSpawns[matchData.team]

    assert(spawnCoords ~= nil, 'spawnCoords should not be nil.')

    ESX.Game.Teleport(ESX.PlayerData.ped, spawnCoords)
    FreezeEntityPosition(ESX.PlayerData.ped, true)

    -- make sure ped can't shoot before countdown ended
    local countdownEnded = false
    CreateThread(function()
        while not countdownEnded do
            DisablePlayerFiring(ESX.playerId, true)
            Wait(0)
        end
    end)

    startCountdown(matchData.opponentName or 'Invalid')

    countdownEnded = true

    -- Countdown ended, we can unfreeze the player
    FreezeEntityPosition(ESX.PlayerData.ped, false)

    CreateThread(handleWeapons)
    CreateThread(handleBorder)
end

---@param winner number The server ID of the winner
---@param opponentName string The name of the opponent
local function matchEnded(winner, opponentName)
    local isWinner = winner == ESX.serverId
    local color = isWinner and '~g~' or '~r~'
    local str = ('You %s %s ~s~the duel against %s'):format(color, isWinner and 'won' or 'lost', opponentName or 'Opponent')
    ESX.Scaleform.ShowFreemodeMessage('Duels', str, 3)

    -- Teleport player back to the initial position 
    if initialPosition then
        ESX.Game.Teleport(ESX.PlayerData.ped, initialPosition)
        initialPosition = nil
    end

    if (Config.checkDeathMethod == 'natives' and IsPedDeadOrDying(ESX.PlayerData.ped, true)) or (Config.checkDeathMethod == 'stateBags' and LocalPlayer.state.isDead) then
        TriggerEvent(Config.reviveEvent)
    end

    currentMatch = nil
end

---@return boolean: True if the player is in a duel, false otherwise
local function isInDuel()
    return currentMatch ~= nil
end

RegisterNetEvent('esx_duels:matchStarted', matchStarted)
RegisterNetEvent('esx_duels:matchEnded', matchEnded)
exports('isInDuel', isInDuel)