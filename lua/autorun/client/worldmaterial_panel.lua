

function PopNewMaterialPanel( convar, bump )
    local w, h = ScrW(), ScrH()
    local FRAME = vgui.Create( "DFrame" )
    FRAME:SetSize( w/2, h/2 )
    FRAME:Center()
    FRAME:SetTitle( bump or "")
    FRAME:MakePopup()
    FRAME:ShowCloseButton( true )
    FRAME:DockPadding( 2, 27, 2, 2 )
    FRAME:SetSizable( true )
    FRAME.Paint = function( self, width, height )
        draw.RoundedBox( 0, 0, 0, width, height, Color( 76, 79, 96))
        draw.RoundedBox( 0, 0, 0, width, 25, Color( 255, 118, 76))
    end

    local TEXT = FRAME:Add("DTextEntry")
    TEXT:Dock( TOP )
    TEXT:SetText( GetConVar( convar ):GetString())
    local PROP = FRAME:Add( "DPropertySheet")
    PROP:Dock( FILL )

    local SCROLL = FRAME:Add("DScrollPanel")
    SCROLL:SetSize( FRAME:GetWide() - 2, FRAME:GetTall() - 25 )
    SCROLL:Dock( FILL )
    SCROLL:DockPadding( 2, 2, 2, 2 )

    local ICO = SCROLL:Add( "DIconLayout" )

    ICO:Dock( FILL )
    ICO:SetSpaceX( 2 )
    ICO:SetSpaceY( 2 )


    PROP:AddSheet( "Default", SCROLL, "icon16/contrast.png")

    local sCustom = FRAME:Add("DScrollPanel")
    sCustom:SetSize( FRAME:GetWide() - 2, FRAME:GetTall() - 25 )
    sCustom:Dock( FILL )
    sCustom:DockPadding( 2, 2, 2, 2 )

    local sICO = sCustom:Add( "DIconLayout" )
    sICO:Dock( FILL )
    sICO:SetSpaceX( 2 )
    sICO:SetSpaceY( 2 )

    PROP:AddSheet( "Custom", sCustom, "icon16/star.png")

    if not file.Exists("worldmaterials/custom.txt", "DATA") then
        file.CreateDir( "worldmaterials" )
        file.Write("worldmaterials/custom.txt", util.TableToJSON{} )
    end

    local function RefreshCustomTextures()
        local cTab = util.JSONToTable(file.Read("worldmaterials/custom.txt"))
        for k, v in pairs( cTab ) do
            local PANE = sICO:Add("DImage")
            PANE:SetSize( 64, 64 )
            PANE:SetText("")
            PANE:SetMouseInputEnabled( true )
            PANE:SetCursor( "hand" )
            PANE:SetToolTip( v )
            PANE:SetMaterial( v )
            PANE.PaintOld = PANE.Paint
            PANE.Paint = function(  self, width, height )
                PANE.PaintOld( self, width, height )
                if self.Hovered then
                    draw.RoundedBox( 0, 0, 0, width, height, Color( 255, 255, 255, 50 ))
                    if input.IsMouseDown( MOUSE_LEFT ) then
                        TEXT:SetText( v )
                    end
                    if input.IsMouseDown( MOUSE_RIGHT ) then
                        local cTab = util.JSONToTable(file.Read("worldmaterials/custom.txt"))
                        if table.HasValue( cTab, v ) then
                            table.RemoveByValue( cTab, v )
                            chat.PlaySound()
                            chat.AddText( Color(255,128,0), "Removed \"" .. v .. "\" from custom list." )
                            file.Write("worldmaterials/custom.txt", util.TableToJSON(cTab) )
                            for k, v in pairs(sICO:GetChildren()) do
                                v:Remove()
                            end
                            RefreshCustomTextures()
                        end
                    end
                end
            end
        end
    end
    RefreshCustomTextures()


    local List = list.Get("OverrideMaterials")
    for k, v in pairs( List ) do
        local PANE = ICO:Add("DImage")
        PANE:SetSize( 64, 64 )
        PANE:SetText("")
        PANE:SetMouseInputEnabled( true )
        PANE:SetCursor( "hand" )
        PANE:SetToolTip( v )
        PANE:SetMaterial( v )
        PANE.PaintOld = PANE.Paint
        PANE.Paint = function(  self, width, height )
            PANE.PaintOld( self, width, height )
            if self.Hovered then
                draw.RoundedBox( 0, 0, 0, width, height, Color( 255, 255, 255, 50 ))
                if input.IsMouseDown( MOUSE_LEFT ) then
                    TEXT:SetText( v )
                end
                if input.IsMouseDown( MOUSE_RIGHT ) then
                    local cTab = util.JSONToTable(file.Read("worldmaterials/custom.txt"))
                    if not table.HasValue( cTab, v ) then
                        table.insert( cTab, v )
                        chat.PlaySound()
                        chat.AddText( Color(255,128,0), "Added \"" .. v .. "\" to custom list!" )
                        file.Write("worldmaterials/custom.txt", util.TableToJSON(cTab) )
                        for k, v in pairs(sICO:GetChildren()) do
                            v:Remove()
                        end
                        RefreshCustomTextures()
                    end
                end
            end
        end
    end

    local MODEL = vgui.Create("DModelPanel")
    MODEL:SetSize( 200, FRAME:GetTall() )
    MODEL.ThinkOld = MODEL.Think
    MODEL:SetPos( 500, 500 )
    MODEL:SetFOV( 40 )
    MODEL:SetCamPos( Vector( 0,125,50))
    MODEL.Think = function( self, width, height )
        self.ThinkOld( self, width, height )
        if self:GetPos() ~= FRAME:GetPos() then
            local x, y = FRAME:GetPos()
            self:SetPos( x - 200, y )
        end
        if self:GetTall() ~= FRAME:GetTall() then
            self:SetTall( FRAME:GetTall() )
        end
        if self.Entity and self.Entity:GetMaterial() ~= TEXT:GetText() then
            self.Entity:SetMaterial( TEXT:GetText() )
        end
    end
    MODEL:SetModel( "models/hunter/blocks/cube1x1x1.mdl" )
    FRAME.OnRemove = function()
        MODEL:Remove()
    end

    FRAME.OnClose = function()
        MODEL:Remove()
    end

    local Use = TEXT:Add("DButton")
    Use:Dock( RIGHT )
    Use:SetText("Use")
    Use.Paint = function( self, width, height )
        draw.RoundedBox( 0, 0, 1, width, height - 2, Color( 255, 118, 76))
        if self.Hovered then
            draw.RoundedBox( 0, 0, 1, width, height - 2, Color( 255,255,255,50))
        end
    end
    Use:SetTextColor( Color( 255, 255, 255) )
    Use.DoClick = function()
        GetConVar( convar ):SetString( TEXT:GetText() )
        FRAME:Close()
    end

    local AddCustom = TEXT:Add("DButton")
    AddCustom:Dock( RIGHT )
    AddCustom:SetText("Add to Custom")
    AddCustom:SizeToContents()
    AddCustom.Paint = function( self, width, height )
        draw.RoundedBox( 0, 0, 1, width, height - 2, Color( 255, 118, 76))
        draw.RoundedBox( 0, width - 1, 1, 1, height - 2, Color(255,255,255))
        if self.Hovered then
            draw.RoundedBox( 0, 0, 1, width, height - 2, Color( 255,255,255,50))
        end
    end
    AddCustom:SetTextColor( Color( 255, 255, 255) )
    AddCustom.DoClick = function()
        local cTab = util.JSONToTable(file.Read("worldmaterials/custom.txt"))
        if not table.HasValue( cTab, TEXT:GetText() ) then
            table.insert( cTab, TEXT:GetText() )
            chat.PlaySound()
            chat.AddText( Color(255,128,0), "Added \"" .. TEXT:GetText() .. "\" to custom list!" )
            file.Write("worldmaterials/custom.txt", util.TableToJSON(cTab) )
            for k, v in pairs(sICO:GetChildren()) do
                v:Remove()
            end
            RefreshCustomTextures()
        end
    end
end

local function ImageInfo( var, parent, varname )
    local DPanel = vgui.Create( "DButton", parent )
    DPanel:SetText( varname or "" )
    DPanel:SetSize( 68, 68 )
    DPanel.DoClick = function()
        PopNewMaterialPanel( var, varname )
    end

    return DPanel
end
function WorldMaterialBuildPanel( CPanel )

    local tab = CPanel.vars or {}

    CPanel:AddItem( ImageInfo( "worldmaterial_override", CPanel, "$basetexture"))


    local SET = vgui.Create("DForm")
    SET:SetName"Set Options"
    CPanel:AddItem(SET)
    
    for k, v in pairs( tab ) do
        SET:CheckBox( "Set " .. k, "worldmaterial_" .. v .. "_set" )
    end
    SET:SetExpanded( false )
    SET:Help( "" )

    local COPY = vgui.Create("DForm")
    COPY:SetName"Copy Options"
    CPanel:AddItem(COPY)
    
    for k, v in pairs( tab ) do
        COPY:CheckBox( "Copy " .. k, "worldmaterial_" .. v .. "_copy" )
    end
    COPY:SetExpanded( false )
    COPY:Help( "" )

    local RESET = vgui.Create("DForm")
    RESET:SetName"Reset Options"
    CPanel:AddItem(RESET)
    
    for k, v in pairs( tab ) do
        RESET:CheckBox( "Reset " .. k, "worldmaterial_" .. v .. "_reset" )
    end
    RESET:SetExpanded( false )
    RESET:Help( "" )

    

    --CollapsableItem( COPY_ICON, "wow")

end
