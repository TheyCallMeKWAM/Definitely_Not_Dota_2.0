function butteractive(keys)
	local player = keys.caster:GetPlayerID()	
	keys.caster:EmitSound("DOTA_Item.Butterfly")
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_bf2_active", nil)
end
