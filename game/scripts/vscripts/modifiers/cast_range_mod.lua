cast_range_mod = class({})

function cast_range_mod:IsPurgable() return false end
function cast_range_mod:IsHidden() return true end
function cast_range_mod:RemoveOnDeath() return false end
function cast_range_mod:AllowIllusionDuplicate() return true end

function cast_range_mod:DeclareFunctions() 
	return {
		MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
	}
end

-- Property Functions
function cast_range_mod:GetModifierCastRangeBonusStacking()
	return 99999
end