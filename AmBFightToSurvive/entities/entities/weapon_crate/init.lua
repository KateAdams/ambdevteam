AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

list.Set("BuildData", "weapon_crate", {
	MinNormalZ = 0.99,
	Health = 500,
	Model = "models/Items/ammocrate_smg1.mdl" })
-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	self:SetModel("models/Items/ammocrate_smg1.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysWake()
	self:Activate()
	self:SetUseType(SIMPLE_USE)
	self:GetPhysicsObject():SetMass(250)
	EnableDamage(self, 500)
end

-----------------------------------------
---- Think
-----------------------------------------
function ENT:Think()
	
end