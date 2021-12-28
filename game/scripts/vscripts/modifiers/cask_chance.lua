cask_chance = class({})

function cask_chance:IsPurgable() return false end
function cask_chance:IsHidden() return false end
function cask_chance:RemoveOnDeath() return false end
function cask_chance:AllowIllusionDuplicate() return true end

function cask_chance:GetTexture()
	return "witch_doctor_paralyzing_cask"
end

function cask_chance:OnCreated()
	if IsClient() then return end
	self.chance = BUTTINGS.CASK_CHANCE_BASE or 15
	self:StartIntervalThink(1)
end

function cask_chance:OnIntervalThink()
	local newChance = math.min(self.chance + (self:GetParent():GetLevel() - 1) * BUTTINGS.CASK_CHANCE_LEVEL, BUTTINGS.CASK_CHANCE_LIMIT)
	self:SetStackCount(newChance)
end

function cask_chance:DeclareFunctions() 
	return {
		MODIFIER_EVENT_ON_ATTACK,
	}
end

function cask_chance:OnAttack(kv)
	if IsClient() then return end
	if kv.attacker ~= self:GetParent() then return end
	
	local target = kv.target
	local cask = self:GetParent():FindAbilityByName("cask_projectile")
	
	if cask then
		self:GetParent():SetCursorCastTarget(target)
		local chance_meter = self:GetStackCount()
		
		-- Yeet a lot
		while(chance_meter >= 100) do
			chance_meter = chance_meter - 100
			cask:OnSpellStart()
		end
		
		local rng = math.random(100)
		if chance_meter > rng then cask:OnSpellStart() end
	end
end