Teams = Teams or {}
include( 'shared.lua' )
include( 'cl_store.lua' )
include( 'shared_store_items.lua' )
include( 'cl_gui.lua' )
include( 'cl_scoreboard.lua' )
include( 'cl_damageoverlay.lua' )
include( 'cl_recource_systems.lua' )

language.Add( "worldspawn", "Slipt And Fell" )
language.Add( "prop_physics", "Zooming Prop" )
language.Add( "func_door", "Door" )
language.Add( "trigger_hurt", "Mystic Force" )

function GM:CalcView(ply,pos,ang,fov)
	local rag = ply:GetRagdollEntity()
	if ValidEntity(rag) then
		local att = rag:GetAttachment(rag:LookupAttachment("eyes"))
		return self.BaseClass:CalcView(ply,att.Pos,att.Ang,fov)
	end
	return self.BaseClass:CalcView(ply,pos,ang,fov)
end

 
function UpdateTeamStats( um )
    /*
		umsg.Long( i )
		umsg.String( Teams[i].Name )
		umsg.Vector( Teams[i].Color )
		umsg.Entity( Teams[i].Owner )
	*/
	local Index = um:ReadLong()
	local Name = um:ReadString()
	local Col = um:ReadVector()
	local Owner = um:ReadEntity() -- not needed now but maybe later versions
	RealCol = Color(Col.x, Col.y, Col.z, 255)
	Teams[Index] = {}
	Teams[Index].Name = Name
	Teams[Index].Color = RealCol
	Teams[Index].Owner = Owner
	team.SetUp( Index, Name, RealCol )
end
usermessage.Hook("teamstats", UpdateTeamStats)

function GM:GetSENTMenu()
	local ply = LocalPlayer()
	if !ply:IsAdmin() then return {} end
end

function GM:GetSWEPMenu()
	local ply = LocalPlayer()
	if !ply:IsAdmin() then return {} end
end

function GM:GetVehicles()
	local ply = LocalPlayer()
	if !ply:IsAdmin() then return {} end
end

function ShowSpawnMenu()
	local frame = vgui.Create("DFrame")
	frame:SetSize(200, 200)
	frame:Center()
	frame:SetTitle("Pick your spawn point")
	frame:SetDraggable(false)
	frame:ShowCloseButton(true)
	frame:MakePopup()
	
	local spawns = vgui.Create("DListView")
	spawns:SetParent(frame)
	spawns:SetPos(10, 24)
	spawns:SetSize( 200-10-10, 200-10-24 )
	spawns:SetMultiSelect(false)
	spawns:AddColumn("Spawn Name")
	
	spawns:AddLine("Defualt").OnSelect = function()
		RunConsoleCommand("selected_spawn_point", "def")
		frame:Close()
	end
	
	spawns:AddLine("Tatical Insertion").OnSelect = function()
		RunConsoleCommand("selected_spawn_point", "ti")
		frame:Close()
	end
	
	local dontspawn_enemydist = 1000
	for k,ref in pairs( ents.FindByClass("refinery") ) do
		local spawnok = true
		for i,ply in pairs( ents.FindInSphere( ref:GetPos(), dontspawn_enemydist ) ) do
			if ply:IsPlayer() then
				if ply:Team() != ref.Team then spawnok = false end
			end
		end
		
		if ref.Team == LocalPlayer():Team() && spawnok then
			spawns:AddLine("Refinery: " .. k).OnSelect = function()
				frame:Close()
				RunConsoleCommand("selected_spawn_point", k)
			end
		end
	end
end
usermessage.Hook( "show_spawn_menu", ShowSpawnMenu )