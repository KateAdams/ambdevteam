AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

MISSILE_VELOCITY = 1500

-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	self:SetModel("models/weapons/W_missile_launch.mdl")
	self.Ignited = false
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetHealth(1)
	self:PhysWake()
	self:Activate()
	timer.Simple( 0, function(self)
		if !ValidEntity(self) then return end
		self:SetModel("models/weapons/W_missile.mdl")
		self.Ignited = true
		-- TODO: /////////////////////
		-- Create sounds and shit here!
	end,self)
end

-----------------------------------------
---- Think
-----------------------------------------
function ENT:Think()
	if self.Ignited then
		self:GetPhysicsObject():SetVelocity( self:GetForward() * MISSILE_VELOCITY )
	end
end

function ENT:PhysicsCollide( data, physobj )
	self:Boom()
	self:Remove()
end

function ENT:OnTakeDamage(dmg)
	self:Boom()
	self:Remove()
end
 
function ENT:Boom()
	if not self.Boomed then
		local position = self:GetPos()
		local damage = 70*4.5
		local radius = 250
		local attacker = self.Owner or self
		local inflictor = self.Entity or self
		self.Boomed = true
		util.BlastDamage(inflictor, attacker, position, radius, damage)
		
		local effectdata = EffectData()
		effectdata:SetStart( position )
		effectdata:SetOrigin( position )
		effectdata:SetScale( 1 )
		
		--HelicopterMegaBomb    Explosion
		util.Effect( "Explosion", effectdata )
		
	end
end

/// thanks to wiremod
function ENT:GetBar( vec )
	local DeltaPos = self.Entity:WorldToLocal(vec)
	brng = DeltaPos:Angle()
	local yaw = brng.y
	if (yaw > 180) then yaw = yaw - 360 end
	return -yaw
end

function ENT:GetElv( vec )
	local DeltaPos = self.Entity:WorldToLocal(vec)
	brng = DeltaPos:Angle()
	local pitch = brng.p
	if (pitch > 180) then pitch = pitch - 360 end
	return -pitch
end
/////