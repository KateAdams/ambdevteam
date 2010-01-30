TeamsRes = TeamsRes or {}

function GetResP( t )
	if TeamsRes[t] == nil then return 0 end
	return TeamsRes[t].ResP or 0
end

function UpdateResources( um )
	local Index = um:ReadLong() or 0
	local ResP = um:ReadLong() or 0
	local SciP = um:ReadLong() or 0
	TeamsRes[Index] = {}
	TeamsRes[Index].ResP = ResP
	TeamsRes[Index].SciP = SciP
end
usermessage.Hook( "resources_update", UpdateResources )