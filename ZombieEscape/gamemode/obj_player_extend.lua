
local meta = FindMetaTable( "Player" )
if (!meta) then return end

// In this file we're adding functions to the player meta table.
// This means you'll be able to call functions here straight from the player object
// You can even override already existing functions.

function meta:GetScriptedVehicle()

	return self:GetNetworkedEntity( "ScriptedVehicle", NULL )

end

function meta:SetScriptedVehicle( veh )

	self:SetNetworkedEntity( "ScriptedVehicle", veh )
	self:SetViewEntity( veh )

end


/*---------------------------------------------------------
   Name:	AddFrozenPhysicsObject
   Desc:	For the Physgun, adds a frozen object to the player's list
---------------------------------------------------------*/  
function meta:AddFrozenPhysicsObject( ent, phys )

	// Get the player's table
	local tab = self:GetTable()
	
	// Make sure the physics objects table exists
	tab.FrozenPhysicsObjects = tab.FrozenPhysicsObjects or {}
	
	// Make a new table that contains the info
	local entry = {}
	entry.ent 	= ent
	entry.phys 	= phys
	
	table.insert( tab.FrozenPhysicsObjects, entry )
	
	gamemode.Call( "PlayerFrozeObject", self, ent, phys )
	
end

local function PlayerUnfreezeObject( ply, ent, object )

	// Not frozen!
	if ( object:IsMoveable() ) then return 0 end
	
	// Unfreezable means it can't be frozen or unfrozen.
	// This prevents the player unfreezing the gmod_anchor entity.
	if ( ent:GetUnFreezable() ) then return 0 end
	
	// NOTE: IF YOU'RE MAKING SOME KIND OF PROP PROTECTOR THEN HOOK "CanPlayerUnfreeze"
	if ( !gamemode.Call( "CanPlayerUnfreeze", ply, ent, object ) ) then return 0 end

	object:EnableMotion( true )
	object:Wake()
	
	gamemode.Call( "PlayerUnfrozeObject", ply, ent, object )
	
	return 1
	
end


/*---------------------------------------------------------
   Name:	UnfreezePhysicsObjects
   Desc:	For the Physgun, unfreezes all frozen physics objects
---------------------------------------------------------*/  
function meta:PhysgunUnfreeze( weapon )

	// Get the player's table
	local tab = self:GetTable()
	if (!tab.FrozenPhysicsObjects) then return 0 end

	// Detect double click. Unfreeze all objects on double click.
	if ( tab.LastPhysUnfreeze && CurTime() - tab.LastPhysUnfreeze < 0.25 ) then
		return self:UnfreezePhysicsObjects()
	end
		
	local tr = self:GetEyeTrace()
	if ( tr.HitNonWorld && ValidEntity( tr.Entity ) ) then
	
		local Ents = constraint.GetAllConstrainedEntities( tr.Entity )
		local UnfrozenObjects = 0
		
		for k, ent in pairs( Ents ) do
					
			local objects = ent:GetPhysicsObjectCount()
	
			for i=1, objects do
	
				local physobject = ent:GetPhysicsObjectNum( i-1 )
				UnfrozenObjects = UnfrozenObjects + PlayerUnfreezeObject( self, ent, physobject )
		
			end
		
		end
	

		
		return UnfrozenObjects
	
	end
	
	tab.LastPhysUnfreeze = CurTime()	
	return 0

end

/*---------------------------------------------------------
   Name:	UnfreezePhysicsObjects
   Desc:	For the Physgun, unfreezes all frozen physics objects
---------------------------------------------------------*/  
function meta:UnfreezePhysicsObjects()

	// Get the player's table
	local tab = self:GetTable()
	
	// If the table doesn't exist then quit here
	if (!tab.FrozenPhysicsObjects) then return 0 end
	
	local Count = 0
	
	// Loop through each table in our table
	for k, v in pairs( tab.FrozenPhysicsObjects ) do
	
		// Make sure the entity to which the physics object
		// is attached is still valid (still exists)
		if (v.ent:IsValid()) then
		
			// We can't directly test to see if EnableMotion is false right now
			// but IsMovable seems to do the job just fine.
			// We only test so the count isn't wrong
			if (v.phys && !v.phys:IsMoveable()) then
			
				// We need to freeze/unfreeze all physobj's in jeeps to stop it spazzing
				if (v.ent:GetClass() == "prop_vehicle_jeep") then
				
					// How many physics objects we have
					local objects = v.ent:GetPhysicsObjectCount()
	
					// Loop through each one
					for i=0, objects-1 do
		
						local physobject = v.ent:GetPhysicsObjectNum( i )
						PlayerUnfreezeObject( self, v.ent, physobject )
				
					end
					
				end
			
				local physobject = v.ent:GetPhysicsObjectNum( i )
				Count = Count + PlayerUnfreezeObject( self, v.ent, v.phys )
				
			end
		
		end
	
	end
			
	// Remove the table
	tab.FrozenPhysicsObjects = nil
	
	return Count

end


/*---------------------------------------------------------
   Name: meta:SetCrouchedWalkSpeed( multiplier )
---------------------------------------------------------*/
function meta:SetCrouchedWalkSpeed( var_in )

	self:SetNetworkedFloat( "CrouchedWalkSpeed", var_in )
	
end


/*---------------------------------------------------------
   Name: meta:SetWalkSpeed( speed )
---------------------------------------------------------*/
function meta:SetWalkSpeed( var_in )

	self:SetNetworkedFloat( "WalkSpeed", var_in )
	
end


/*---------------------------------------------------------
   Name: meta:SetRunSpeed( speed )
---------------------------------------------------------*/
function meta:SetRunSpeed( var_in )

	self:SetNetworkedFloat( "SprintSpeed", var_in )
	
end


/*---------------------------------------------------------
   Name: meta:SetDuckSpeed( time_amount )
---------------------------------------------------------*/
function meta:SetDuckSpeed( var_in )

	self:SetNetworkedFloat( "TimeToDuck", var_in )
	
end


/*---------------------------------------------------------
   Name: meta:SetUnDuckSpeed( time_amount )
---------------------------------------------------------*/
function meta:SetUnDuckSpeed( var_in )

	self:SetNetworkedFloat( "TimeToUnDuck", var_in )
	
end


local g_UniqueIDTable = {}

/*---------------------------------------------------------
	This table will persist between client deaths and reconnects
---------------------------------------------------------*/
function meta:UniqueIDTable( key )

	local id = 0
	if ( SERVER ) then id = self:UniqueID() end
	
	g_UniqueIDTable[ id ] = g_UniqueIDTable[ id ]  or {}
	g_UniqueIDTable[ id ][ key ] = g_UniqueIDTable[ id ][ key ] or {}
	
	return g_UniqueIDTable[ id ][ key ]

end

/*---------------------------------------------------------
	Player Eye Trace
---------------------------------------------------------*/
function meta:GetEyeTrace()

	if ( self.LastPlayerTrace == CurTime() ) then
		return self.PlayerTrace
	end

	self.PlayerTrace = util.TraceLine( util.GetPlayerTrace( self, self:GetCursorAimVector() ) )
	self.LastPlayerTrace = CurTime()
	
	return self.PlayerTrace

end

/*---------------------------------------------------------
	GetEyeTraceIgnoreCursor
	Like GetEyeTrace but doesn't use the cursor aim vector..
---------------------------------------------------------*/
function meta:GetEyeTraceNoCursor()

	if ( self:GetTable().LastPlayerAimTrace == CurTime() ) then
		return self:GetTable().PlayerAimTrace
	end

	self:GetTable().PlayerAimTrace = util.TraceLine( util.GetPlayerTrace( self ) )
	self:GetTable().LastPlayertAimTrace = CurTime()
	
	return self:GetTable().PlayerAimTrace

end
