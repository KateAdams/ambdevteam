AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

list.Set("BuildData", "sent_thumper", {
	MinNormalZ = 0.80,
	Model = "models/props_combine/CombineThumper001a.mdl" })

-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	self:SetModel("models/props_combine/CombineThumper001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysWake()
	self:Activate()
	self:SetUseType(SIMPLE_USE)
	EnableDamage(self, 10000)
end

-----------------------------------------
---- Think
-----------------------------------------
function ENT:Think()
	
end
