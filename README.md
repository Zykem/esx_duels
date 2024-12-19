# esx_duels
 A FiveM 1vs1 Duels system
This resource is fully dependent on newest version of the ESX Framework.

```lua
-- Export function to check if player is in active duel [client/match.lua]
local isInDuel = exports['esx_duels']:isInDuel()
-- State bag to check if player is in queue for duel [client/interactions.lua]
LocalPlayer.state.inDuelQueue
-- Command to send a duel invite to any player on the server [server.main.lua / client/main.lua]
/duel [playerId]
```
