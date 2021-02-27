LinkLuaModifier( "modifier_item_angel_boots", "items/angel_boots", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_angel_boots_aura", "items/angel_boots", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_angel_boots_aura_low", "items/angel_boots", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_angel_boots_aura_hud", "items/angel_boots", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_angel_boots_aura_low_hud", "items/angel_boots", LUA_MODIFIER_MOTION_NONE )

item_angel_boots = class({})
modifier_item_angel_boots_aura = class({})
modifier_item_angel_boots_aura_low = class({})
modifier_item_angel_boots_aura_hud = class({})
modifier_item_angel_boots_aura_low_hud = class({})

function item_angel_boots:OnSpellStart()
	local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetAbsOrigin(),nil,900,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false)
	for _,target in pairs(targets) do
		local particle = nil
		particle = "particles/units/heroes/hero_omniknight/omniknight_purification.vpcf"
		target:AddNewModifier(self:GetCaster(), self, "modifier_rune_regen", {duration = 30})
		self:GetCaster():EmitSound("Item.GuardianGreaves.Activate")
		self:GetCaster():EmitSound("Hero_Chen.HandOfGodHealHero")
		local particle = ParticleManager:CreateParticle( particle, PATTACH_CUSTOMORIGIN, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetOrigin(), true  );
		ParticleManager:SetParticleControl( particle, 1, Vector( 200, 200, 200 ) );
		ParticleManager:ReleaseParticleIndex( particle );
		target:SetMana(target:GetMana() + 200)
		target:SetHealth(target:GetHealth() + 300)
		target:Purge( false, true, false, true, false)
	end
end

function item_angel_boots:GetAbilityTextureName()
	return "items/angel_boots"
end

function item_angel_boots:GetIntrinsicModifierName() 
return "modifier_item_angel_boots"
end

modifier_item_angel_boots = class({})

function modifier_item_angel_boots:OnCreated()
self.ability = self:GetAbility()
self.movespeed = self.ability:GetSpecialValueFor("movespeed")
self.armor = self.ability:GetSpecialValueFor("bonus_armor")
self.stats = self.ability:GetSpecialValueFor("bonus_stats")
self.mana = self.ability:GetSpecialValueFor("bonus_mana")
self.regen = self.ability:GetSpecialValueFor("bonus_regen")
self.armor_aura = self.ability:GetSpecialValueFor("bonus_armor_aura")
self.regen_aura = self.ability:GetSpecialValueFor("bonus_regen_aura")
self:StartIntervalThink(0.1)
end

function modifier_item_angel_boots:OnIntervalThink()
	local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(),self:GetCaster():GetAbsOrigin(),nil,900,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_CLOSEST,false)
	for _,target in pairs(targets) do
		if target:GetHealth() > target:GetMaxHealth() * 0.2 then
			target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_angel_boots_aura", {duration = 0.3})
			target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_angel_boots_aura_hud", {})
		else
			target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_angel_boots_aura_low", {duration = 0.3})
			target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_angel_boots_aura_low_hud", {})
		end
	end
end

function modifier_item_angel_boots:IsHidden()
return true
end

function modifier_item_angel_boots:DeclareFunctions()
return 	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		}
end

function modifier_item_angel_boots:GetModifierMoveSpeedBonus_Special_Boots()
return self.movespeed
end

function modifier_item_angel_boots:GetModifierPhysicalArmorBonus()
return self.armor
end

function modifier_item_angel_boots:GetModifierBonusStats_Strength()
return self.stats
end

function modifier_item_angel_boots:GetModifierBonusStats_Agility()
return self.stats
end

function modifier_item_angel_boots:GetModifierBonusStats_Intellect()
return self.stats
end

function modifier_item_angel_boots:GetModifierManaBonus()
return self.mana
end

function modifier_item_angel_boots:GetModifierConstantHealthRegen()
return self.regen
end

function modifier_item_angel_boots_aura:IsHidden()
return true
end

function modifier_item_angel_boots_aura:OnCreated()
self.ability = self:GetAbility()
self.armor_aura = self.ability:GetSpecialValueFor("bonus_armor_aura")
self.regen_aura = self.ability:GetSpecialValueFor("bonus_regen_aura")
end

function modifier_item_angel_boots_aura:DeclareFunctions()
return 	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		}
end

function modifier_item_angel_boots_aura:GetModifierConstantHealthRegen()
return self.regen_aura
end

function modifier_item_angel_boots_aura:GetModifierPhysicalArmorBonus()
return self.armor_aura
end

function modifier_item_angel_boots_aura:OnDestroy()
	if IsServer() then
		if self:GetParent():HasModifier("modifier_item_angel_boots_aura_hud") then
			self:GetParent():RemoveModifierByName("modifier_item_angel_boots_aura_hud")
		end
	end
end

function modifier_item_angel_boots_aura_low:IsHidden()
return true
end

function modifier_item_angel_boots_aura_low:OnCreated()
self.ability = self:GetAbility()
self.armor_aura_low = self.ability:GetSpecialValueFor("bonus_armor_aura") * 4
self.regen_aura_low = self.ability:GetSpecialValueFor("bonus_regen_aura") * 2
end

function modifier_item_angel_boots_aura_low:DeclareFunctions()
return 	{
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		}
end

function modifier_item_angel_boots_aura_low:GetModifierConstantHealthRegen()
return self.regen_aura_low
end

function modifier_item_angel_boots_aura_low:GetModifierPhysicalArmorBonus()
return self.armor_aura_low
end

function modifier_item_angel_boots_aura_low:OnDestroy()
	if IsServer() then
		if self:GetParent():HasModifier("modifier_item_angel_boots_aura_low_hud") then
			self:GetParent():RemoveModifierByName("modifier_item_angel_boots_aura_low_hud")
		end
	end
end