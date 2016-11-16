

net.Receive( "worldmaterials_restore", function()
    local str = net.ReadString()
    local tab = net.ReadTable()
    local tvd = WorldMaterialTypes()
    local var = net.ReadString()
    for k, v in pairs( tab ) do 
        if not tvd[ k ] then continue end
        if k ~= var then continue end
        tvd[ k ][ "restore" ]( str, v )
    end
end)

net.Receive( "worldmaterials_set", function()
    local var = net.ReadString()
    local hit = net.ReadString()
    local fst = net.ReadString()
    local tvd = WorldMaterialTypes()

    print( var, hit, fst )
    if not tvd[ var ] then return end
    tvd[ var ][ "restore" ]( hit, fst )
end)

net.Receive( "worldmaterials_get_table", function()
    local tab = net.ReadTable()
    print("TOGE")
    PrintTable(tabw)
    for k, v in pairs( tab ) do
        local mat = Material( k )
        mat:SetTexture( "$basetexture", v.Material )
    end
end)
