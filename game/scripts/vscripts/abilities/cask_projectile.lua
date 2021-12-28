cask_projectile = class({})

function cask_projectile:GetAbilityTextureName()
	return "witch_doctor_paralyzing_cask"
end

-------------------------------------------

function cask_projectile:OnSpellStart()
	if IsServer() then
		--if self.abilities == nil then self.abilities = self:GetCaskAbilities() end
		
		EmitSoundOn("Hero_WitchDoctor.Paralyzing_Cask_Cast", self:GetCaster())
		local hTarget = self:GetCursorTarget()

		-- Parameters
		local caster = self:GetCaster()
		
		local bounces = caster:GetModifierStackCount("cask_bounces", caster)
		
		local info = {
			EffectName = "particles/units/heroes/hero_witchdoctor/witchdoctor_cask.vpcf",
			Ability = self,
			iMoveSpeed = 1000,
			Source = self:GetCaster(),
			Target = self:GetCursorTarget(),
			bDodgeable = false,
			bProvidesVision = false,
			ExtraData =
			{
				bounces = bounces,
				speed = 1000,
				bounce_delay = 0.3,
			}
		}

		ProjectileManager:CreateTrackingProjectile( info )
	end
end

function cask_projectile:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	EmitSoundOn("Hero_WitchDoctor.Paralyzing_Cask_Bounce", hTarget)

	if hTarget then
		-- ability check one more time
		self.abilities = self:GetCaskAbilities()
		self:Punish(hTarget)
	end
	if ExtraData.bounces > 0 then
		Timers:CreateTimer(ExtraData.bounce_delay, function()
			-- Finds all units in the area
			local enemies = FindUnitsInRadius(	self:GetCaster():GetTeamNumber(), 
												Vector(0,0,0), 
												nil, 
												FIND_UNITS_EVERYWHERE, 
												DOTA_UNIT_TARGET_TEAM_ENEMY, 
												DOTA_UNIT_TARGET_ALL, 
												DOTA_UNIT_TARGET_FLAG_NO_INVIS, 
												0, 
												false)

			-- Go through the target tables, checking for the first one that isn't the same as the target
			local tJumpTargets = {}
			-- If the target is an enemy, bounce on an enemy.
			for _,unit in pairs(enemies) do
				if hTarget then
					if (unit ~= hTarget) and (not unit:IsOther()) and (not unit:IsBuilding()) then
						table.insert(tJumpTargets, unit)
					end
				end
			end

			if #tJumpTargets == 0 then
				-- End of spell
				return nil
			end
			
			-- yeet
			local index = math.random(#tJumpTargets)
			local projectile = {
				Target = tJumpTargets[index],
				Source = hTarget,
				Ability = self,
				EffectName = "particles/units/heroes/hero_witchdoctor/witchdoctor_cask.vpcf",
				bDodgable = false,
				bProvidesVision = false,
				iMoveSpeed = ExtraData.speed,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
				ExtraData =
				{
					bounces 			= ExtraData.bounces - 1,
					speed				= ExtraData.speed,
					bounce_delay 		= ExtraData.bounce_delay,
				}
			}
			ProjectileManager:CreateTrackingProjectile(projectile)
		end)
	else
		return nil
	end
end

function cask_projectile:GetCaskAbilities()
	local abilities = {}
	local caster = self:GetCaster()
	
	local bannedBehaviours = {
		--DOTA_ABILITY_BEHAVIOR_HIDDEN,
		DOTA_ABILITY_BEHAVIOR_PASSIVE,
		DOTA_ABILITY_BEHAVIOR_TOGGLE,
		DOTA_ABILITY_BEHAVIOR_ATTACK,
	}
	
	local bannedAbilities = {
		-- Misc
		"cask_projectile",
		"generic_hidden",
		"ability_capture",
		
		-- Invoker
		"invoker_quas",
		"invoker_wex",
		"invoker_exort",
		"invoker_invoke",
		
		-- Phantom Lancer
		"phantom_lancer_doppelwalk",
		
		-- Rubick
		"rubick_empty1",
		"rubick_empty2",
		"rubick_hidden1",
		"rubick_hidden2",
		"rubick_hidden3",
	}
	
	-- abilities
	for index = 0,15 do
		-- Ability in question
		local ability = caster:GetAbilityByIndex(index)
		
		-- Ability checkpoint
		if ability == nil then goto continue end
		for _,behaviour in pairs(bannedBehaviours) do
			if HasBit( ability:GetBehavior(), behaviour ) then goto continue end
		end
		for _,bannedAbility in pairs(bannedAbilities) do
			if ability:GetAbilityName() == bannedAbility then goto continue end
		end
		
		-- Add that ability after checkpoint
		--print(ability:GetAbilityName())
		table.insert(abilities, ability)
		
		-- Skip
		::continue::
	end
	
	-- items
	--[[
	for i = 0,5 do
		local item = hero:GetItemInSlot(i)
		if item == nil then goto continueItem end
		for _,behaviour in pairs(bannedBehaviours) do
			if bit.band( item:GetBehavior(), behaviour ) == behaviour then goto continueItem end
		end
		
		-- Add that ability after checkpoint
		print(ability:GetAbilityName())
		table.insert(abilities, ability)
		
		::continueItem::
	end
	--]]
	
	return abilities
end

function cask_projectile:Punish(hDumbass)
	local caster = self:GetCaster()
	local ability = self.abilities[math.random(#self.abilities)]
	if ability:GetLevel() == 0 then
		return
	end
	
	caster:AddNewModifier(caster, self, "cast_range_mod", {duration = 0.01})
	caster:SetCursorCastTarget(hDumbass)
	ability:OnSpellStart()
end

function HasBit(checker, value)
    local checkVal = checker
    if type(checkVal) == 'userdata' then
        checkVal = tonumber(checker:ToHexString(), 16)
    end
    return bit.band( checkVal, tonumber(value)) == tonumber(value)
end

--[[

does anyone know why this breaks the code?

		local projectile =
			{
				EffectName = "particles/units/heroes/hero_witchdoctor/witchdoctor_cask.vpcf",
				Ability = self,
				Target = hTarget,
				Source = self:GetCaster(),
				
				
				bDodgable = false,
				bProvidesVision = false,
				iMoveSpeed = speed,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
				ExtraData =
				{
					bounces = bounces,
					speed = 1000,
					bounce_delay = 0.3,
				}
			}
		ProjectileManager:CreateTrackingProjectile(projectile)
		--]]