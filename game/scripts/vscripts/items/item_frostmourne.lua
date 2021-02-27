function frostmourneskadi(keys)
	if keys.caster:IsRangedAttacker() then
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_frostmourne_skadi_debuff", {duration = keys.ColdDurationRanged})
	else
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_frostmourne_skadi_debuff", {duration = keys.ColdDurationMelee})
	end
end

function frostmournehex(keys)
	local target = keys.target
	local model = keys.model
	local ability = keys.ability
	local ability_level = ability:GetLevel()
	local player = keys.caster:GetPlayerID()
	
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_item_frostmorn_debuff", {duration = 2})

	if target.caster_model == nil then 
		target.caster_model = target:GetModelName()
	end	

	if IsUnlockedInPass(player, "reward88") then
		target:SetModel("models/items/courier/flightless_dod/flightless_dod.vmdl")
		target:SetOriginalModel("models/items/courier/flightless_dod/flightless_dod.vmdl")
	else
		target:SetModel("models/props_gameplay/pig_blue.vmdl")
		target:SetOriginalModel("models/props_gameplay/pig_blue.vmdl")
	end


	
end

function frostmournehexend(keys)
	local target = keys.target
	local model = keys.model
	local ability = keys.ability
	local ability_level = ability:GetLevel()

	if target:HasModifier("modifier_DemonicForm") then
		target:SetModel("models/items/warlock/golem/hellsworn_golem/hellsworn_golem.vmdl")
		target:SetOriginalModel("models/items/warlock/golem/hellsworn_golem/hellsworn_golem.vmdl")
		return
	end

	if target:HasModifier("modifier_guts_DarkArmor") then
		target:SetModel("models/heroes/nightstalker/nightstalker.vmdl")
		target:SetOriginalModel("models/heroes/nightstalker/nightstalker.vmdl")
		return
	end

	if target:HasModifier("modifier_versuta_dog_ultimate") then
		target:SetModel("models/items/lycan/ultimate/thegreatcalamityti4/thegreatcalamityti4.vmdl")
		target:SetOriginalModel("models/items/lycan/ultimate/thegreatcalamityti4/thegreatcalamityti4.vmdl")
		return
	end

	if target:HasModifier("modifier_silver_owl_buff") then
		target:SetModel("models/items/beastmaster/hawk/legacy_of_the_nords_legacy_of_the_nords_owl/legacy_of_the_nords_legacy_of_the_nords_owl.vmdl")
		target:SetOriginalModel("models/items/beastmaster/hawk/legacy_of_the_nords_legacy_of_the_nords_owl/legacy_of_the_nords_legacy_of_the_nords_owl.vmdl")
		return
	end

	if target:HasModifier("modifier_bogdan_cower") then
		target:SetModel("models/courier/smeevil_magic_carpet/smeevil_magic_carpet_flying.vmdl")
		target:SetOriginalModel("models/courier/smeevil_magic_carpet/smeevil_magic_carpet_flying.vmdl")
		return
	end

	if target:HasModifier("modifier_yakubovich_car") then
		target:SetModel("models/items/courier/carty_dire/carty_dire.vmdl")
		target:SetOriginalModel("models/items/courier/carty_dire/carty_dire.vmdl")
		return
	end
	
	target:SetModel(target.caster_model)
	target:SetOriginalModel(target.caster_model)
end