function SWEP:Initialize()
 
        if( SERVER ) then
        
                self:SetWeaponHoldType( "melee" );
        
        end
end
 

SWEP.Category				= "SA Sweps"

SWEP.PrintName		= "Medkit"
SWEP.Slot			= 2
SWEP.SlotPos		= 2
if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV		= 55
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= true
	
end

SWEP.Category				= "SA Sweps"

SWEP.PrintName		= "Medkit"
SWEP.Slot			= 2
SWEP.SlotPos		= 2
SWEP.DrawAmmo		= true
SWEP.DrawCrosshair	= true

SWEP.Weight			= 5
SWEP.AutoSwitchTo	= false
SWEP.AutoSwitchFrom	= false

SWEP.Author			= ".:AmB:. Nick"
SWEP.Contact		= "www.amb-clan.com"
SWEP.Purpose		= "Heal Yourself and allies"
SWEP.Instructions	= "Left click to heal an ally, right click to heal yourself. We don't take credit for model because we do not know who made it"

SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true

SWEP.ViewModel		= "models/weapons/v_healthkit.mdl"
SWEP.WorldModel		= "models/weapons/w_healthkit.mdl"

SWEP.Primary.Recoil			= 0.1
SWEP.Primary.Damage			= 0
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.01
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= .5
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.NumShots		= 1
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

local ShootSound = Sound ("items/smallmedkit1.wav")
local FailSound = Sound ("items/medshotno1.wav")

function SWEP:Reload()
end

function SWEP.Think()
end

function SWEP:Initialize()
	if ( SERVER ) then
		self:SetWeaponHoldType( "slam" )
	end
end 


function SWEP:PrimaryAttack()
   	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	local trace = self.Owner:GetEyeTrace()
	if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 100 then

		local ent = self.Owner:GetEyeTrace().Entity
		if CLIENT then return end
		if ent:IsPlayer() || ent:IsNPC() then
			local current = ent:Health()
			local max = ent:GetMaxHealth()
			self.Weapon:EmitSound( ShootSound, 60, 100 )
			if current <= (max - 50) then
				timer.Create( "heal", 0.1, 50, function(pl) pl:SetHealth( pl:Health() + 1 ) end, ent )
				self:Fire("kill","1")
				self.Owner:ConCommand("lastinv")
				ent:Extinguish()
			else
				ent:SetHealth( max )
				self.Weapon:Fire("kill","1")
				self.Owner:ConCommand("lastinv")
				ent:Extinguish()
			end
		end 
	else
		self.Weapon:EmitSound(FailSound, 60, 100)
	end

end



function SWEP:SecondaryAttack()
	local max = self.Owner:GetMaxHealth()
	if self.Owner:Health() >= max then
		self.Weapon:EmitSound( FailSound, 60, 100 )
	else
		timer.Create( "heal", 0.1, 50, function(pl) pl:SetHealth( pl:Health() + 1 ) end, self.Owner )
		self.Weapon:EmitSound( ShootSound, 60, 100 )
		self:Fire("kill","1")
		self.Owner:Extinguish()
		self.Owner:ConCommand("lastinv")
		if self.Owner:Health() >= max then
			self.Owner:SetHealth( max)
			self:Fire("kill","1")
			self.Owner:ConCommand("lastinv")
			self.Owner:Extinguish()
		end
	end
	self.Weapon:SetNextSecondaryFire(CurTime() + 1)
end

