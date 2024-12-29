local function sendDuelInvite(invitedBy, inivitedByName)
    ESX.ShowNotification(('You have been invited to a duel by %s.'):format(inivitedByName))

    ESX.CloseContext()
    local elements = {
        { unselectable = true, icon = 'fas fa-gun', title = ('Duel Invite from %s'):format(inivitedByName) },
        { title = 'Accept', value = 'accept' },
        { title = 'Decline', value = 'decline' }
    }

    local inviteExpired = false

    ESX.OpenContext('right', elements, function(menu, element)
        if inviteExpired then
            TriggerServerEvent('esx_duels:declineDuelInvite', invitedBy)
            return
        end
        local event = ('esx_duels:%sDuelInvite'):format(element.value)
        TriggerServerEvent(event, invitedBy)
        ESX.CloseContext()
    end)

    SetTimeout(10000, function()
        inviteExpired = true
    end)
end

RegisterNetEvent('esx_duels:sendDuelInvite', sendDuelInvite)
