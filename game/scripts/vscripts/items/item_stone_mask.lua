function StoneMaskActive( event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local targetTeam = target:GetTeamNumber()
	local casterTeam = caster:GetTeamNumber()

	if target == caster or target:HasModifier("modifier_item_stone_mask_active_target") or target:HasModifier("modifier_ram_fura_lift") then 
		ability:OnChannelFinish(false)
		caster:Stop()
		ability:EndCooldown()
		ability:RefundManaCost()
		EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", event.caster:GetPlayerOwner())
		return
	end
	
	if targetTeam == casterTeam then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_item_stone_mask_active_target", {})
		ability:ApplyDataDrivenModifier(caster, target, "modifier_item_stone_mask_target_buff", {})
	else
		if caster:GetHealth() < (caster:GetMaxHealth() / 100 * 51) or target:GetHealth() < (target:GetMaxHealth() / 100 * 51) then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_item_stone_mask_active_target", {})
		else
			ability:OnChannelFinish(false)
			caster:Stop()
			ability:EndCooldown()
			ability:RefundManaCost()
			EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", event.caster:GetPlayerOwner())
			return
		end
	end
	
	local particleName = "particles/units/heroes/hero_pugna/pugna_life_drain.vpcf"
	caster.LifeDrainParticle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(caster.LifeDrainParticle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
end

function StoneMaskDestroy( event )
	local caster = event.caster
	ParticleManager:DestroyParticle(caster.LifeDrainParticle,false)
	caster:Stop()
end

function stop_sound( keys )
	local target = keys.target
	local sound = keys.sound

	StopSoundEvent(sound, target)
end

function StoneMaskDamage( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local targetTeam = target:GetTeamNumber()
	local casterTeam = caster:GetTeamNumber()
	local targethp = target:GetMaxHealth() - target:GetHealth()
	local damage = 40 + targethp * 0.015

	if target:IsIllusion() then
		target:ForceKill(true)
		ability:OnChannelFinish(false)
		caster:Stop()
		return
	else
		local caster_location = caster:GetAbsOrigin()
		local target_location = target:GetAbsOrigin()
		local distance = (target_location - caster_location):Length2D()
		local break_distance = 1200
		local direction = (target_location - caster_location):Normalized()

		if distance >= break_distance then
			ability:OnChannelFinish(false)
			caster:Stop()
			return
		end
		caster:SetForwardVector(direction)
	end

	if target:IsInvulnerable() then
		ability:OnChannelFinish(false)
		caster:Stop()
		ParticleManager:DestroyParticle(caster.LifeDrainParticle,false)
		target:RemoveModifierByName("modifier_item_stone_mask_active_target")
		target:RemoveModifierByName("modifier_item_stone_mask_target_buff")
		return
	end

	if targetTeam == casterTeam then
		if target:GetHealthDeficit() > 0 then
			ApplyDamage({ victim = caster, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE })
			target:Heal( 200, caster)
			
			ParticleManager:SetParticleControl(caster.LifeDrainParticle, 10, Vector(0,0,0))
			ParticleManager:SetParticleControl(caster.LifeDrainParticle, 11, Vector(0,0,0))
		else
			ApplyDamage({ victim = caster, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE })
			target:SetMana( target:GetMana() + 200)

			ParticleManager:SetParticleControl(caster.LifeDrainParticle, 10, Vector(1,0,0))
			ParticleManager:SetParticleControl(caster.LifeDrainParticle, 11, Vector(1,0,0))
		end	
	else
		if caster:GetHealthDeficit() > 0 then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_item_stone_mask_death_target", { duration = 1.5})
			ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE })
			caster:Heal( 200, caster)

			ParticleManager:SetParticleControl(caster.LifeDrainParticle, 10, Vector(0,0,0))
			ParticleManager:SetParticleControl(caster.LifeDrainParticle, 11, Vector(0,0,0))
		else
			ability:ApplyDataDrivenModifier(caster, target, "modifier_item_stone_mask_death_target", { duration = 1.5})
			ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE })
			caster:SetMana( caster:GetMana() + 200)

			ParticleManager:SetParticleControl(caster.LifeDrainParticle, 10, Vector(0,0,0))
			ParticleManager:SetParticleControl(caster.LifeDrainParticle, 11, Vector(0,0,0))
		end
	end
end

function StoneMaskDeath( event )
	local caster = event.caster
	local ability = event.ability
	
	local stone_mask_slot = nil
	for i=0, 5, 1 do
		local current_item = caster:GetItemInSlot(i)
		if current_item ~= nil then			
			if current_item:GetName() == "item_stone_mask" then
				stone_mask_slot = current_item
			end
		end
	end
	
	if stone_mask_slot ~= nil then
		stone_mask_slot:SetCurrentCharges(stone_mask_slot:GetCurrentCharges() + 1)
	end
		
	if not ability.currentStacks then
	    ability.currentStacks = 1 
	end
	
	ability.currentStacks = ability.currentStacks + 1
	
	caster:SetModifierStackCount("modifier_item_stone_mask_caster_buff", ability, ability.currentStacks)
end

function StoneMaskDeathCaster( event )
	local caster = event.caster
	local ability = event.ability
	
	if not ability.currentStacks then
	    ability.currentStacks = 1 
	end
	
	if ability.currentStacks <= 1 then return end
	
	local stone_mask_slot = nil
	for i=0, 5, 1 do
		local current_item = caster:GetItemInSlot(i)
		if current_item ~= nil then			
			if current_item:GetName() == "item_stone_mask" then
				stone_mask_slot = current_item
			end
		end
	end
	
	if stone_mask_slot ~= nil then
		stone_mask_slot:SetCurrentCharges(stone_mask_slot:GetCurrentCharges() / 2)
	end
	
	ability.currentStacks = ability.currentStacks / 2
	
	caster:SetModifierStackCount("modifier_item_stone_mask_caster_buff", ability, ability.currentStacks)
end