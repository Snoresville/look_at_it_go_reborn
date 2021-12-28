cask_bounces = class({})

function cask_bounces:IsPurgable() return false end
function cask_bounces:IsHidden() return false end
function cask_bounces:RemoveOnDeath() return false end
function cask_bounces:AllowIllusionDuplicate() return true end

function cask_bounces:GetTexture()
	return "witch_doctor_paralyzing_cask"
end

function cask_bounces:OnCreated()
	if IsClient() then return end
	self.bounce_base = BUTTINGS.CASK_BOUNCE_BASE or 3
	self:StartIntervalThink(1)
end

function cask_bounces:OnIntervalThink()
	local newBounce = math.min(self.bounce_base + (self:GetParent():GetLevel() - 1) * BUTTINGS.CASK_BOUNCE_LEVEL, BUTTINGS.CASK_BOUNCE_LIMIT)
	self:SetStackCount(newBounce)
end