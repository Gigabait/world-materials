
local WorldMaterialDatatypes = {}

local function MaterialType( variable, store, restore )
	WorldMaterialDatatypes[ variable ] = {}
	WorldMaterialDatatypes[ variable ][ "store" ] = store
	WorldMaterialDatatypes[ variable ][ "restore" ] = restore 
end

MaterialType( "$basetexture", function( tex )
	local mat = Material( tex )
	return mat:GetString( "$basetexture" )
end,
function( mat, res )
	local mm = Material( mat )
	mm:SetTexture( "$basetexture", res )
end)

MaterialType( "$bumpmap", function( tex )
	local mat = Material( tex )
	return mat:GetString( "$bumpmap" )
end,
function( mat, res )
	local mm = Material( mat )
	mm:SetTexture( "$bumpmap", res )
end)

function WorldMaterialTypes()
	return WorldMaterialDatatypes
end