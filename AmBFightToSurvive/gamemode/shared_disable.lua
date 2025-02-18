-- Concommand for control admin rights
-- 0 = disabled
-- 1 = notified
-- 2 = enabled
local AdminRights = CreateConVar( "sv_adminrights", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY} )

-- Gets if the specified player is an admin
function Admin(Player, Message)
	local adminrights = AdminRights:GetInt()
	if Player:IsAdmin() then
		if adminrights == 0 then
			if SERVER then Player:ChatPrint("Can not comply, admin rights is disabled") end
			return false
		end
		if adminrights == 1 then
			for _, p in pairs(player.GetAll()) do
				if SERVER then
					if Message then
						p:ChatPrint(Player:Nick() .. " preformed admin action(" .. Message .. ")")
					else
						p:ChatPrint(Player:Nick() .. " preformed admin action")
					end
				end
			end
			return true
		end
		if adminrights == 2 then
			return true
		end
	end
	return false
end

-- Disable sents from the spawn menu
if SERVER then
	
	--------------------------------------------
	-- Gets if the thing is restricted, thing 
	-- can be a model, class or name of an
	-- object type. Restricted things cant be
	-- player spawned.
	--------------------------------------------
	local function ThingRestricted(Thing)
		if string.find(Thing, "wire") then
			return false
		end
		if string.find(Thing, "gmod") then
			return false
		end
		if Thing == "prop_physics" then
			return false
		end
		return true
	end

	local function NonPropSpawn(Player, Thing)
		if not ThingRestricted(Thing) or Admin(Player, "spawned nonprop " .. Thing or "<unknown>") then
			return true
		else
			Player:ChatPrint("Spawn disallowed, only props may be spawned from the spawn menu" ..
				". You may use the store(F4) to purchase this instead.")
			return false
		end
	end
	hook.Add("PlayerSpawnSENT", "NonPropSpawn", NonPropSpawn)
	hook.Add("PlayerSpawnSWEP", "NonPropSpawn", NonPropSpawn)
	hook.Add("PlayerSpawnVehicle", "NonPropSpawn", NonPropSpawn)
	hook.Add("PlayerSpawnEffect", "NonPropSpawn", NonPropSpawn)
	hook.Add("PlayerSpawnRagdoll", "NonPropSpawn", NonPropSpawn)
	hook.Add("PlayerGiveSWEP","NonPropSpawn",NonPropSpawn)
	hook.Add("PlayerSpawnSWEP","NonPropSpawn",NonPropSpawn)
	
	-- Hook into adv dupe and restrict what can be spawned.
	local function HookAdvDupe()
		-- This will be loaded after AdvDupe
		local ad = AdvDupe
		local ol = ad.CheckOkEnt or nil
		if ol == nil then return end // we dont have adv dupe installed
		
		-- Override adv dupe check ok ent function
		function ad.CheckOkEnt(Player, EntTable)
			local class = EntTable.Class
			if ThingRestricted(class) then
				ad.SendClientError(Player, "Tried to paste gamemode restricted prop.")
				return false
			end
			return ol(Player, EntTable)
		end
	end
	hook.Add("Initialize", "HookAdvDupe", HookAdvDupe)
	
	-- Spawns an object based on its build data function.
	function SpawnBuildDataFunction(Player, BuildDataFunction, Offset)
		local eye = Player:GetEyeTrace()
		local dif = eye.HitPos - Player:GetPos()
		local builddata = BuildDataFunction(Player)
		local offset = Offset or 32
		local posent = function(ent)
			ent:SetPos(eye.HitPos + Vector(0, 0, offset))
		end
		return builddata.OnCreate(posent)
	end
	
	-- Safely spawns an entity of the specified class 
	-- in front of the player. returns the spawned
	-- entity.
	function Spawn(Player, Class, Model, Keys, Offset)
		return SpawnBuildDataFunction(Player, GetBuildDataFunction(Class, Model, Keys), Offset)
	end
	
	-- Vehicles spawn differently
	function SpawnVehicle(Player, Name)
		return SpawnBuildDataFunction(Player, GetVehicleBuildDataFunction(Name), 64)
	end
	
	-- Gets a function that will create build data for the specified
	-- params when supplied with a player.
	function GetBuildDataFunction(Class, Model, Keys)
		return function(Player)
			local bd = { }
			local li = list.Get("BuildData")[Class] or { }
			bd.Model = Model or li.Model
			bd.MinNormalZ = li.MinNormalZ or 0.95
			bd.Class = Class
			bd.OnCreate = function(posent)
				local ent = ents.Create(Class)
				if Model then
					ent:SetModel(Model)
				end
				if ent:IsNPC() then
					ent:SetKeyValue("spawnflags", SF_NPC_FADE_CORPSE | SF_NPC_ALWAYSTHINK)
				end
				if Keys then
					for k, v in pairs(Keys) do
						ent:SetKeyValue(k, v)
					end
				end
				posent(ent)
				if li.Health then
					EnableDamage(ent, li.Health)
				end
				ent.Team = Player:Team()
				ent.Owner = Player
				ent:Spawn()
				ent:Activate()
				for _,const in pairs(constraint.GetAllConstrainedEntities(ent)) do
					if const:GetClass() == "prop_physics" then
						RegisterProp(const)
						const.Team = nil
						const:SetState(STATE_CONSTRUCTED)
					end
				end
				return ent
			end
			return bd
		end
	end
	
	
	
	-- Similar to GetBuildDataFunction, but for vehicles.
	function GetVehicleBuildDataFunction(Name)
		local vehicle = list.Get("Vehicles")[Name]
		if vehicle then
			return GetBuildDataFunction(vehicle.Class, vehicle.Model, vehicle.KeyValues)
		else
			return nil
		end
	end
end

-- Only props may be picked up with the physgun
local function PhysgunPickup(Player, Entity)
	if Entity:GetClass() ~= "prop_physics" then
		return Admin(Player, "picked up " .. Entity:GetClass() .. " with physgun")
	end
end
hook.Add("PhysgunPickup", "DisablePhysgunPickup", PhysgunPickup)

/*
function StopWeapons(Player, Bind, Pressed)
	print(Bind)
	if string.find(Bind,"gm_spawnswep") or string.find(Bind,"gm_giveswep") then
	print("yes")
		return Admin(Player, "Spawned Weapon")
	end
end
*/
//hook.Add("PlayerBindPress","f2s.disableweps",StopWeapons)

/*---------------------------------------------------------
	// Give a swep.. duh.
---------------------------------------------------------*/
if CLIENT then return end

timer.Simple( 20, function()

	function CCGiveSWEP( player, command, arguments )

		if ( arguments[1] == nil ) then return end

		// Make sure this is a SWEP
		local swep = weapons.GetStored( arguments[1] )
		if (swep == nil) then return end
		
		// You're not allowed to spawn this!
		if ( !swep.Spawnable && !player:IsAdmin() ) then
			return
		end
		
		//if ( !Admin(player,"Spawned SWEP") ) then return end
		
		if ( !gamemode.Call( "PlayerGiveSWEP", player, arguments[1], swep ) ) then return end
		
		MsgAll( "Giving "..player:Nick().." a "..swep.Classname.."\n" )
		player:Give( swep.Classname )
		
		// And switch to it
		player:SelectWeapon( swep.Classname )
		
	end

	concommand.Add( "gm_giveswep", CCGiveSWEP )

	/*---------------------------------------------------------
		// Give a swep.. duh.                                           ---- why are there no hooks for this?!!?!
	---------------------------------------------------------*/
	function CCSpawnSWEP( player, command, arguments )

		if ( arguments[1] == nil ) then return end

		// Make sure this is a SWEP
		local swep = weapons.GetStored( arguments[1] )
		if (swep == nil) then return end
		
		// You're not allowed to spawn this!
		if ( !swep.Spawnable && !player:IsAdmin() ) then
			return
		end
		
		if ( !gamemode.Call( "PlayerSpawnSWEP", player, arguments[1], swep ) ) then return end
		
		local tr = player:GetEyeTraceNoCursor()

		if ( !tr.Hit ) then return end
		
		//if ( !Admin(player,"Spawned SWEP") ) then return end
		
		local entity = ents.Create( swep.Classname )
		
		if ( ValidEntity( entity ) ) then
		
			entity:SetPos( tr.HitPos + tr.HitNormal * 32 )
			entity:Spawn()
		
		end
		
	end

	concommand.Add( "gm_spawnswep", CCSpawnSWEP )
end)