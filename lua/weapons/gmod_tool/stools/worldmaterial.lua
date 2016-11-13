if CLIENT then
	language.Add("tool.worldmaterial.name", "World Material Tool")
	language.Add("tool.worldmaterial.desc", "Override any given non-displacement map texture!")
	language.Add("tool.worldmaterial.left", "Override the current texture.")
	language.Add("tool.worldmaterial.right", "Copy the current texture")
	language.Add("tool.worldmaterial.reload", "Reset the current maptexture")
end

TOOL.Category = "Render"
TOOL.Name = "World Material"
TOOL.ClientConVar["override"] = "debug/env_cubemap_model"
TOOL.ClientConVar["bumpmap_override"] = "models/props_pipes/GutterMetal01a"
TOOL.ClientConVar["1_r"] = "255"
TOOL.ClientConVar["1_g"] = "255"
TOOL.ClientConVar["1_b"] = "255"
TOOL.ClientConVar["2_r"] = "255"
TOOL.ClientConVar["2_g"] = "255"
TOOL.ClientConVar["2_b"] = "255"

TOOL.Information = {
	{
		name = "left"
	},
	{
		name = "right"
	},
	{
		name = "reload"
	}
}

TOOL.DefaultMaterials = TOOL.DefaultMaterials or {}

local function BackupOld(TOOL, trace, convar, name, str, color)
	local New = GetConVarString(convar)
	local Current = Material(trace.HitTexture)
	TOOL.DefaultMaterials[trace.HitTexture] = TOOL.DefaultMaterials[trace.HitTexture] or {}
	TOOL.DefaultMaterials[trace.HitTexture]["Old" .. name] = TOOL.DefaultMaterials[trace.HitTexture]["Old" .. name] or Current:GetString(str)
	TOOL.DefaultMaterials[trace.HitTexture]["New" .. name] = New
	TOOL.DefaultMaterials[trace.HitTexture]["$color"] = (1 / 255 * GetConVarString"worldmaterial_1_r") .. " " .. (1 / 255 * GetConVarString"worldmaterial_1_g") .. " " .. (1 / 255 * GetConVarString"worldmaterial_1_b")
	TOOL.DefaultMaterials[trace.HitTexture]["$color2"] = (1 / 255 * GetConVarString"worldmaterial_2_r") .. " " .. (1 / 255 * GetConVarString"worldmaterial_2_g") .. " " .. (1 / 255 * GetConVarString"worldmaterial_2_b")

	return New
end

local function RestoreOld(TOOL, trace, name, str)
	if not TOOL.DefaultMaterials or not TOOL.DefaultMaterials[trace.HitTexture] or not TOOL.DefaultMaterials[trace.HitTexture]["Old" .. name] then return false end
	local Old = TOOL.DefaultMaterials[trace.HitTexture]["Old" .. name]
	local New = Material(trace.HitTexture)
	New:SetTexture(str, Old)
	New:SetVector( "$color", Vector( "1 1 1") )
	New:SetVector( "$color2", Vector( "1 1 1"))
	TOOL.DefaultMaterials[trace.HitTexture]["New" .. name] = nil

	return true
end

function TOOL:LeftClick(trace)
	local NewTexture = BackupOld(self, trace, "worldmaterial_override", "Base", "$basetexture")
	local TraceMaterial = Material(trace.HitTexture)

	timer.Simple(0.01, function()
		TraceMaterial:SetTexture("$basetexture", NewTexture)
		TraceMaterial:SetVector( "$color", Vector( (1 / 255 * GetConVarString"worldmaterial_1_r") .. " " .. (1 / 255 * GetConVarString"worldmaterial_1_g") .. " " .. (1 / 255 * GetConVarString"worldmaterial_1_b") ) )
		TraceMaterial:SetVector( "$color2", Vector( (1 / 255 * GetConVarString"worldmaterial_2_r") .. " " .. (1 / 255 * GetConVarString"worldmaterial_2_g") .. " " .. (1 / 255 * GetConVarString"worldmaterial_2_b") ) )

	end)

	return true
end

-- Right click copies the material
function TOOL:RightClick(trace)
	if SERVER then return end

	if trace.HitTexture ~= "**displacement**" then
		GetConVar("worldmaterial_override"):SetString(Material(trace.HitTexture):GetString("$basetexture"))

		if CLIENT then
			chat.AddText(Color(255, 128, 0), "Copied " .. GetConVar("worldmaterial_override"):GetString())
		end
	end

	return true
end

-- Reload reverts the material
function TOOL:Reload(trace)
	RestoreOld(self, trace, "Base", "$basetexture")

	return true
end

function TOOL.BuildCPanel(CPanel)
	WorldMaterialBuildPanel(CPanel)
end

TOOL.BackupMaterial = Material("debug/debugwhite")

if CLIENT then
	TOOL.CurrentActiveMaterial = Material(GetConVarString("worldmaterial_override"))
	TOOL.CurrentMat = GetConVarString("worldmaterial_override")
end

function TOOL:DrawToolScreen(width, height)
	if self.CurrentMat ~= GetConVarString("worldmaterial_override") then
		self.CurrentActiveMaterial = Material(GetConVarString("worldmaterial_override"))
		self.CurrentMat = GetConVarString("worldmaterial_override")
	end

	surface.SetDrawColor(Color(255, 255, 255))
	surface.DrawRect(0, 0, width, height)
	surface.SetMaterial(self.CurrentActiveMaterial or self.BackupMaterial)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0, 0, width, height)
end
