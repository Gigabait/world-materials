


function WorldMaterialBuildPanel( CPanel )
    local Color1 = CPanel:AddControl("Color", {
        Label = "$color",
        Red = "worldmaterial_1_r",
        Green = "worldmaterial_1_g",
        Blue = "worldmaterial_1_b"
    })

    local Color2 = CPanel:AddControl("Color", {
        Label = "$color2",
        Red = "worldmaterial_2_r",
        Green = "worldmaterial_2_g",
        Blue = "worldmaterial_2_b"
    })

    local base = CPanel:MatSelect("worldmaterial_override", list.Get("OverrideMaterials"), true, 0.25, 0.25)
    local bump = CPanel:MatSelect("worldmaterial_bumpmap_override", list.Get("OverrideMaterials"), true, 0.25, 0.25)

    local function CollapsableItem( pane, label, exp )
        local scroll = vgui.Create("DScrollPanel")
        pane:SetParent(scroll)
        local collapse = vgui.Create("DCollapsibleCategory")
        collapse:SetLabel( label )
        collapse:SetExpanded( exp and 1 or 0 )
        collapse:SetContents(scroll)
        CPanel:AddItem(collapse)
    end
    CollapsableItem( base, "Base ($basetexture)" )
    CollapsableItem( bump, "Bump ($bumpmap)" )
    CollapsableItem( Color1, "Color ($color1)" )
    CollapsableItem( Color2, "Color2 ($color2)" )

    -- collapse.SizeToChildren = function(collapse)
    --     collapse:SetTall(200)
    -- end
    --CPanel:MatSelect("worldmaterial_bumpmap_override", list.Get("OverrideMaterials"), true, 0.25, 0.25)
end

function HitTexture()
    return Material( LocalPlayer():GetEyeTrace().HitTexture )
end
print( Vector( tostring( HitTexture():GetVector("$color") )) )
