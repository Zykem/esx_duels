local interactions = {}

---@param interaction Interaction
local function createInteraction(interaction)
    if not interaction then
        error('Interaction does not exist.')
    end

    interaction.pedModel = interaction.pedModel or Config.defaultPedModel
    interaction.lobby = interaction.lobby or 'main'

    ESX.Streaming.RequestModel(interaction.pedModel)

    local ped = CreatePed(4, interaction.pedModel, interaction.coords.x, interaction.coords.y, interaction.coords.z, interaction.coords.w or 0.0, false, true)
    
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    interactions[#interactions+1] = {
        pedHandle = ped,
        lobby = interaction.lobby,
        coords = interaction.coords
    }
end

local function setupScript()
    for _, interaction in ipairs(Config.interactions) do
        createInteraction(interaction)
    end
end

local function watchInteractionsLoop()
    if not ESX.PlayerLoaded then
        repeat Wait(500)
        until ESX.PlayerLoaded and ESX.PlayerData.coords
    end

    local sleepMs = 500

    while true do
        local isNearby = false

        for _, data in ipairs(interactions) do
            local distance = #(vector3(ESX.PlayerData.coords.x, ESX.PlayerData.coords.y, ESX.PlayerData.coords.z) - vector3(data.coords.x, data.coords.y, data.coords.z))

            if distance <= 3.0 then
                isNearby = true
                sleepMs = 0

                local helpNotify = ('Press ~INPUT_CONTEXT~ to %s the Duel Queue.'):format(LocalPlayer.state.inDuelQueue and 'leave' or 'join')
                ESX.ShowHelpNotification(helpNotify)

                if IsControlJustReleased(0, 38) then
                    local event = ('esx_duels:%sQueue'):format(LocalPlayer.state.inDuelQueue and 'leave' or 'join')
                    TriggerServerEvent(event, data.lobby)   
                    -- we wait a little bit to make sure the server handled all changes.
                    Wait(300)
                end

                break
            end
        end

        if not isNearby then
            sleepMs = 500
        end

        Wait(sleepMs)
    end
end

CreateThread(setupScript)
CreateThread(watchInteractionsLoop)