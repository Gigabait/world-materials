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

function TOOL:LeftClick(trace)
	local NewBase = GetConVarString("worldmaterial_override")
	local Current = Material(trace.HitTexture)
	self.DefaultMaterials[trace.HitTexture] = self.DefaultMaterials[trace.HitTexture] or {}
	self.DefaultMaterials[trace.HitTexture].Old = self.DefaultMaterials[trace.HitTexture].Old or Current:GetString("$basetexture")
	self.DefaultMaterials[trace.HitTexture].New = NewBase
	local Newer = Material(trace.HitTexture)

	timer.Simple(0.05, function()
		Newer:SetTexture("$basetexture", NewBase)
	end)

	return true
end

-- Right click copies the material
function TOOL:RightClick(trace)
	return true
end

-- Reload reverts the material
function TOOL:Reload(trace)
	if not self.DefaultMaterials or not self.DefaultMaterials[trace.HitTexture] or not self.DefaultMaterials[trace.HitTexture].Old then return false end
	local Old = self.DefaultMaterials[trace.HitTexture].Old
	local New = Material(trace.HitTexture)
	New:SetTexture("$basetexture", Old)

	return true
end

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", {
		Description = "Set the World's materials!"
	})

	CPanel:MatSelect("worldmaterial_override", list.Get("OverrideMaterials"), true, 0.25, 0.25)
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
	surface.DrawTexturedRect(self.ScrollX, 0, width, height)
	surface.DrawTexturedRect(0, 0, width, height)

end
