function uebatoractive(keys)
	local caster = keys.caster
	local ability = keys.ability
	local player = caster:GetPlayerID()
	
	if caster:HasModifier("modifier_item_uebator_blood") or caster:HasModifier("modifier_item_uebator_blood_donate") then return end

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_uebator_blood", nil)
	caster:EmitSound("Hero_LifeStealer.Consume")
	ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_emerge_bloody.vpcf", PATTACH_ABSORIGIN, caster)
	ability.bonus_strength = (caster:GetHealth() / 4) / 20
	caster:SetHealth(caster:GetHealth() - (caster:GetHealth() / 4))
	caster:SetBaseStrength(caster:GetBaseStrength() + ability.bonus_strength)
	caster:CalculateStatBonus()
end

function uebatorunactive(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:SetBaseStrength(caster:GetBaseStrength() - ability.bonus_strength)
	caster:CalculateStatBonus()
end