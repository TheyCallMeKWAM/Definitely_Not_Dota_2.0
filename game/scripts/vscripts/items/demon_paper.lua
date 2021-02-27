LinkLuaModifier( "modifier_item_demon_paper", "items/demon_paper", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_demon_paper_active", "items/demon_paper", LUA_MODIFIER_MOTION_NONE )

item_demon_paper = class({})
modifier_item_demon_paper = class({})
modifier_item_demon_paper_active = class({})

function item_demon_paper:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_demon_paper_active", {duration = 5})
	EmitSoundOn("DOTA_Item.Satanic.Activate", self:GetCaster())
	EmitSoundOn("Hero_DoomBringer.Doom", self:GetCaster())
end

function item_demon_paper:GetIntrinsicModifierName() 
return "modifier_item_demon_paper"
end

function modifier_item_demon_paper:OnCreated()
self.ability = self:GetAbility()
self.bonus_strength = self.ability:GetSpecialValueFor("bonus_strength")
self.bonus_damage = self.ability:GetSpecialValueFor("bonus_damage")
self.bonus_hp_regen = self.ability:GetSpecialValueFor("bonus_hp_regen")
self.bonus_armor = self.ability:GetSpecialValueFor("bonus_armor")
self.bonus_attack_speed = self.ability:GetSpecialValueFor("bonus_attack_speed")
self.bonus_lifesteal = self.ability:GetSpecialValueFor("bonus_lifesteal")
self.bonus_resist = self.ability:GetSpecialValueFor("bonus_resist")
end

function modifier_item_demon_paper:IsHidden()
return true
end

function modifier_item_demon_paper:DeclareFunctions()
return 	{
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		}
end

function modifier_item_demon_paper:GetModifierBonusStats_Strength()
return self.bonus_strength
end

function modifier_item_demon_paper:GetModifierPreAttack_BonusDamage	()
return self.bonus_damage
end

function modifier_item_demon_paper:GetModifierConstantHealthRegen()
return self.bonus_hp_regen
end

function modifier_item_demon_paper:GetModifierPhysicalArmorBonus()
return self.bonus_armor
end

function modifier_item_demon_paper:GetModifierAttackSpeedBonus_Constant()
return self.bonus_attack_speed
end

function modifier_item_demon_paper:GetModifierStatusResistanceStacking()
return self.bonus_resist
end

function modifier_item_demon_paper_active:GetEffectName()
	return "particles/items2_fx/satanic_buff.vpcf"
end

function modifier_item_demon_paper_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_demon_paper_active:OnCreated()
	self.Effect = ParticleManager:CreateParticle("particles/econ/items/warlock/warlock_staff_glory/warlock_upheaval_hellborn_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.Effect, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.Effect, 1, self:GetParent():GetAbsOrigin())
end

function modifier_item_demon_paper_active:OnDestroy()
	StopSoundOn("Hero_DoomBringer.Doom", self:GetParent())
	ParticleManager:DestroyParticle(self.Effect, false)
end