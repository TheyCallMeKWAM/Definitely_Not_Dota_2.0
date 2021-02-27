function HasteBoots( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local player = caster:GetPlayerID()
	local duration = ability:GetLevelSpecialValueFor("phase_duration", ability_level)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_imba_phase_boots_2_move_speed", {})
	EmitSoundOnClient("DOTA_Item.PhaseBoots.Activate", PlayerResource:GetPlayer(caster:GetPlayerID()))
end