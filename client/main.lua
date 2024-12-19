local function sendDuelInvite(invitedBy, inivitedByName)
    ESX.ShowNotification(('You have been invited to a duel by %s.'):format(inivitedByName))

    ESX.CloseContext()
    local elements = {
        { unselectable = true, icon = 'fas fa-gun', title = ('Duel Invite from %s'):format(inivitedByName) },
        { title = 'Accept', value = 'accept' },
        { title = 'Decline', value = 'decline' }
    }

    ESX.OpenContext('right', elements, function(menu, element)
        local event = ('esx_duels:%sDuelInvite'):format(element.value)
        TriggerServerEvent(event, invitedBy)
        ESX.CloseContext()
    end)
end

RegisterNetEvent('esx_duels:sendDuelInvite', sendDuelInvite)