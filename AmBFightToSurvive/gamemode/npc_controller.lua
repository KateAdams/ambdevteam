local NPCRadius = 3000
local NPCs = { }
local TimerName = "NPCUpdateTimer"
local TimerCreated = false
local TimerDelay = 1

--------------------------------------------
-- Updates all the npc's targets.
--------------------------------------------
local function UpdateNPCs()
	for npc, a in pairs(NPCs) do
		if a and npc:IsValid() then
			local team = npc.Team
			local near = ents.FindInSphere(npc:GetPos(), NPCRadius)
			for _, e in pairs(near) do
				local oteam = e.Team
				if e:IsPlayer() then
					oteam = e:Team()
				end
				if oteam then
					if oteam == team then
						npc:AddEntityRelationship(e, D_LI, 99)
					else
						if Visible(npc, e) then
							npc:AddEntityRelationship(e, D_HT, 75)
						else
							npc:AddEntityRelationship(e, D_NU, 75)
						end
					end
				else
					npc:AddEntityRelationship(e, D_NU, 50)
				end
			end
		else
			NPCs[npc] = nil
		end
	end
end

--------------------------------------------
-- Spawns an npc of the specified class to
-- the player and the players team.
--------------------------------------------
function SpawnNPC(Player, Class)
	local data = list.Get("NPC")[Class]
	if data then
		local npc = Spawn(Player, data.Class, data.Model, data.KeyValues, Vector(0, 0, data.Offset or 0))
		npc.Team = Player:Team()
		NPCs[npc] = true
		if not TimerCreated then
			timer.Create(TimerName, TimerDelay, 0, UpdateNPCs)
		end
		UpdateNPCs()
		return npc
	else
		return nil
	end
end