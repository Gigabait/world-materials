if not file.Exists( "worldmaterials/"..game.GetMap()..".txt", "DATA") then
	file.Write("worldmaterials/"..game.GetMap()..".txt", util.TableToJSON{} )
end

util.AddNetworkString("worldmaterials_set")
util.AddNetworkString("worldmaterials_restore")
util.AddNetworkString("worldmaterials_set_table")

file.CreateDir("worldmaterials")

WorldMaterials = {}
WorldMaterials.Active = {}
WorldMaterials.Defaults = util.JSONToTable(file.Read("worldmaterials/"..game.GetMap()..".txt"))

function WorldMaterials:Backup( trace, var )
	if not WorldMaterialTypes()[ var ] then return end
	local HITNAME = trace.HitTexture
	
	local Backup = WorldMaterialTypes()[ var ]["store"]( HITNAME )

	if not Backup then return end
	WorldMaterials.Defaults[ HITNAME ] = WorldMaterials.Defaults[ HITNAME ] or {}
	WorldMaterials.Defaults[ HITNAME ][ var ] = WorldMaterials.Defaults[ HITNAME ][ var ] or Backup
	file.Write("worldmaterials/"..game.GetMap()..".txt", util.TableToJSON(WorldMaterials.Defaults) )
end

function WorldMaterials:Set( trace, clientvar, var, pl )
	self:Backup( trace, var )

	local MaterialVerify = Material( clientvar ) or clientvar
	if MaterialVerify.IsError and MaterialVerify:IsError() then 
		pl:SendLua( "chat.PlaySound() chat.AddText( Color( 255, 128, 0 ), 'Invalid texture for " .. var .. "') ")
		return
	end

	local STORE = WorldMaterialTypes()[ var ][ "store" ]( clientvar )

	--WorldMaterials.Active[  ] = {}

	if not STORE then 
		pl:SendLua( "chat.PlaySound() chat.AddText( Color( 255, 128, 0 ), 'Invalid texture for " .. var .. "') ")
		return
	end
	net.Start("worldmaterials_set")
	net.WriteString( var )
	net.WriteString( trace.HitTexture )
	net.WriteString( STORE )
	net.Broadcast()
end

function WorldMaterials:Restore( trace, var )
	self:Backup( trace, var )
	if not WorldMaterialTypes()[ var ] then print( "no?" ) return end
	local HITNAME = trace.HitTexture

	net.Start("worldmaterials_restore")
	net.WriteString( HITNAME )
	net.WriteTable( self.Defaults[ HITNAME ] )
	net.WriteString( var )
	net.Broadcast()
end

function WorldMaterials:RestoreTexture( trace )
	local HIT = trace.HitTexture
	if not self.Defaults[ HIT ] then return end
	

end