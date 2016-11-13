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

local function BackupOld(TOOL, trace, convar, name, str)
	local New = GetConVarString(convar)
	local Current = Material(trace.HitTexture)
	TOOL.DefaultMaterials[trace.HitTexture] = TOOL.DefaultMaterials[trace.HitTexture] or {}
	TOOL.DefaultMaterials[trace.HitTexture]["Old" .. name] = TOOL.DefaultMaterials[trace.HitTexture]["Old" .. name] or Current:GetString(str)
	TOOL.DefaultMaterials[trace.HitTexture]["New" .. name] = New

	return New
end

local function RestoreOld(TOOL, trace, name, str)
	if not TOOL.DefaultMaterials or not TOOL.DefaultMaterials[trace.HitTexture] or not TOOL.DefaultMaterials[trace.HitTexture]["Old" .. name] then return false end
	local Old = TOOL.DefaultMaterials[trace.HitTexture]["Old" .. name]
	local New = Material(trace.HitTexture)
	New:SetTexture(str, Old)

	return true
end

function TOOL:LeftClick(trace)
	local New = BackupOld(self, trace, "worldmaterial_override", "Base", "$basetexture")
	local BumNew = BackupOld(self, trace, "worldmaterial_bumpmap_override", "Bump", "$bumpmap")
	local Newer = Material(trace.HitTexture)

	timer.Simple(0.2, function()
		Newer:SetTexture("$basetexture", New)
		Newer:SetTexture("$bumpmap", BumNew)
	end)

	return true
end

-- Right click copies the material
function TOOL:RightClick(trace)
	return true
end

-- Reload reverts the material
function TOOL:Reload(trace)
	RestoreOld(self, trace, "Base", "$basetexture")
	RestoreOld(self, trace, "Bump", "$bumpmap")

	return true
end

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", {
		Description = "Set the World's materials!"
	})

	CPanel:MatSelect("worldmaterial_override", list.Get("OverrideMaterials"), true, 0.25, 0.25)
	CPanel:MatSelect("worldmaterial_bumpmap_override", list.Get("OverrideMaterials"), true, 0.25, 0.25)
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

	surface.SetMaterial(self.CurrentActiveMaterial or self.BackupMaterial)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0, 0, width, height)
	surface.DrawTexturedRect(0, 0, width, height)
end
