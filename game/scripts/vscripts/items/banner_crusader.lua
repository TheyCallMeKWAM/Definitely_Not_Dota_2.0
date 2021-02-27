LinkLuaModifier( "modifier_item_banner_crusader", "items/banner_crusader", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_banner_crusader_aura", "items/banner_crusader", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_banner_crusader_block", "items/banner_crusader", LUA_MODIFIER_MOTION_NONE )

item_banner_crusader = class({})
modifier_item_banner_crusader_aura = class({})
modifier_item_banner_crusader_block = class({})

function item_banner_crusader:OnSpellStart()
	local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetAbsOrigin(),nil,1200,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false)
	for _,target in pairs(targets) do
		target:AddNewModifier(self:GetCaster(), self, "modifier_item_sphere_target", {duration = 15})
		target:AddNewModifier(self:GetCaster(), self, "modifier_item_banner_crusader_aura", {duration = 15})
		self:GetCaster():EmitSound("Hero_LegionCommander.Overwhelming.Cast")
		target:EmitSound("Hero_LegionCommander.Overwhelming.Buff")
		local particle = ParticleManager:CreateParticle( "particles/econ/items/legion/legion_overwhelming_odds_ti7/legion_commander_odds_ti7.vpcf", PATTACH_ABSORIGIN, target )
		ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle, 4, Vector(100*1.5, 100*1.5, 100*1.5))
	end
end

function item_banner_crusader:GetIntrinsicModifierName() 
return "modifier_item_banner_crusader"
end

modifier_item_banner_crusader = class({})

function modifier_item_banner_crusader:OnCreated()
self.ability = self:GetAbility()
self.armor = self.ability:GetSpecialValueFor("bonus_armor")
self.stats = self.ability:GetSpecialValueFor("bonus_stats")
self.hp_regen = self.ability:GetSpecialValueFor("bonus_hp_regen")
self.health = self.ability:GetSpecialValueFor("bonus_health")
self.mana_regen = self.ability:GetSpecialValueFor("bonus_mana_regen")
self.movespeed = self.ability:GetSpecialValueFor("bonus_movespeed")
end

function modifier_item_banner_crusader:OnAttacked(keys)
	if not IsServer() then
		return
	end

	if keys.target ~= self:GetParent() then
		return
	end

	if 50 <= RandomInt(1, 100) then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_banner_crusader_block", {duration = 2})
	end
end

function modifier_item_banner_crusader:IsHidden()
return true
end

function modifier_item_banner_crusader:DeclareFunctions()
return 	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_EVENT_ON_ATTACKED,
		}
end

function modifier_item_banner_crusader:GetModifierPhysicalArmorBonus()
return self.armor
end

function modifier_item_banner_crusader:GetModifierHealthBonus()
return self.health
end

function modifier_item_banner_crusader:GetModifierBonusStats_Strength()
return self.stats
end

function modifier_item_banner_crusader:GetModifierBonusStats_Agility()
return self.stats
end

function modifier_item_banner_crusader:GetModifierBonusStats_Intellect()
return self.stats
end

function modifier_item_banner_crusader:GetModifierConstantHealthRegen()
return self.hp_regen
end

function modifier_item_banner_crusader:GetModifierConstantManaRegen()
return self.mana_regen
end

function modifier_item_banner_crusader:GetModifierMoveSpeedBonus_Percentage()
return self.movespeed
end

function modifier_item_banner_crusader_aura:OnCreated()
self.ability = self:GetAbility()
self.armor_aura = self.ability:GetSpecialValueFor("bonus_armor_active")
self.attackspeed_aura = self.ability:GetSpecialValueFor("bonus_attack_speed")
self.movement_aura = self.ability:GetSpecialValueFor("bonus_movespeed2 ")
self.crimson_guard_pfx = ParticleManager:CreateParticle("particles/items2_fx/vanguard_active.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
ParticleManager:SetParticleControl(self.crimson_guard_pfx, 0, self:GetParent():GetAbsOrigin())
ParticleManager:SetParticleControlEnt(self.crimson_guard_pfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
end

function modifier_item_banner_crusader_aura:DeclareFunctions()
return 	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
		}
end

function modifier_item_banner_crusader_aura:GetModifierPhysicalArmorBonus()
return self.armor_aura
end

function modifier_item_banner_crusader_aura:GetModifierAttackSpeedBonus_Constant()
return self.attackspeed_aura
end

function modifier_item_banner_crusader_aura:GetModifierMoveSpeedBonus_Percentage()
return self.movement_aura
end

function modifier_item_banner_crusader_aura:GetModifierPhysical_ConstantBlock()
return 100
end

function modifier_item_banner_crusader_aura:OnDestroy()
	ParticleManager:DestroyParticle(self.crimson_guard_pfx, false)
end

function modifier_item_banner_crusader_block:IsHidden()
return true
end

function modifier_item_banner_crusader_block:DeclareFunctions()
return 	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
		}
end

function modifier_item_banner_crusader_block:GetModifierPhysical_ConstantBlock()
return 100
end
