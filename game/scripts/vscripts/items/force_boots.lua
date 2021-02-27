LinkLuaModifier( "modifier_item_birzha_force_boots", "items/force_boots", LUA_MODIFIER_MOTION_NONE )

item_birzha_force_boots = class({})
modifier_item_birzha_force_boots = class({})

function item_birzha_force_boots:OnSpellStart()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, 'modifier_item_forcestaff_active', {push_length = self:GetSpecialValueFor("push_length")})
    EmitSoundOn('DOTA_Item.ForceStaff.Activate', self:GetCaster())
end

function item_birzha_force_boots:GetIntrinsicModifierName() 
	return "modifier_item_birzha_force_boots"
end

function modifier_item_birzha_force_boots:IsHidden()
	return true
end

function modifier_item_birzha_force_boots:DeclareFunctions()
return 	{
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		}
end

function modifier_item_birzha_force_boots:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_int")
end

function modifier_item_birzha_force_boots:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
end