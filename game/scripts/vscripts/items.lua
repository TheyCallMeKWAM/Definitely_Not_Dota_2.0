--[[ items.lua ]]

--Spawns Bags of Gold in the middle
function COverthrowGameMode:ThinkGoldDrop()
	local r = RandomInt( 1, 100 )
	if r > ( 100 - self.m_GoldDropPercent ) then
		self:SpawnGold()
	end
end

function COverthrowGameMode:SpawnGold()
	local overBoss = Entities:FindByName( nil, "@overboss" )
	local throwCoin = nil
	local throwCoin2 = nil
	if overBoss then
		throwCoin = overBoss:FindAbilityByName( 'dota_ability_throw_coin' )
		throwCoin2 = overBoss:FindAbilityByName( 'dota_ability_throw_coin_long' )
	end

	-- sometimes play the long anim
	if throwCoin2 and RandomInt( 1, 100 ) > 80 then
		overBoss:CastAbilityNoTarget( throwCoin2, -1 )
	elseif throwCoin then
		overBoss:CastAbilityNoTarget( throwCoin, -1 )
	else
		self:SpawnGoldEntity( Vector( 0, 0, 0 ) )
	end
end

function COverthrowGameMode:SpawnGoldEntity( spawnPoint )
	EmitGlobalSound("Item.PickUpGemWorld")
	local newItem = CreateItem( "item_treasure_chest", nil,  nil )
	local drop = CreateItemOnPositionForLaunch( spawnPoint, newItem )
	local dropRadius = RandomFloat( self.m_GoldRadiusMin, self.m_GoldRadiusMax )
	newItem:LaunchLootInitialHeight( false, 0, 500, 0.75, spawnPoint + RandomVector( dropRadius ) )
	newItem:SetContextThink( "KillLoot", function() return self:KillLoot( newItem, drop ) end, 30 )
end


--Removes Bags of Gold after they expire
function COverthrowGameMode:KillLoot( item, drop )

	if drop:IsNull() then
		return
	end

	local nFXIndex = ParticleManager:CreateParticle( "particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, drop )
	ParticleManager:SetParticleControl( nFXIndex, 0, drop:GetOrigin() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 35, 35, 25 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	EmitGlobalSound("Item.PickUpWorld")

	UTIL_Remove( item )
	UTIL_Remove( drop )
end

function COverthrowGameMode:AddGoldenCoin(owner)
	local gold = RandomInt( 1000, 5000 )
	local goblinsGreed = owner:FindAbilityByName("alchemist_goblins_greed_custom")
	if goblinsGreed and goblinsGreed:GetLevel() > 0 then
		local bonusGold = gold * (goblinsGreed:GetSpecialValueFor("gold_coin_multiplier") - 1)
		gold = gold + bonusGold
		goblinsGreed.coinBonusGold = (goblinsGreed.coinBonusGold or 0) + bonusGold
	end
	PlayerResource:ModifyGold(owner:GetPlayerOwnerID(), gold, true, 0)
	SendOverheadEventMessage(owner, OVERHEAD_ALERT_GOLD, owner, gold, nil)
end

function COverthrowGameMode:SpecialItemAdd(owner)
	local tier = {}

	tier[1] =	{
		"item_keen_optic",
		"item_unstable_wand",
		"item_ironwood_tree",
		"item_royal_jelly",
		"item_ocean_heart",
		"item_broom_handle",
		"item_pogo_stick",
		"item_trusty_shovel",
		"item_faded_broach",
		"item_arcane_ring",
		"item_winter_embrace",
		"item_ogre_seal_totem",
		"item_oblivions_locket",
		"item_precious_egg",
		"item_mysterious_hat",
		"item_possessed_mask",
		"item_chipped_vest",
		"item_grove_bow",
		"item_ring_of_aquila",
		"item_pupils_gift",
		"item_imp_claw",
		"item_misericorde",
		"item_philosophers_stone",
		"item_nether_shawl",
		"item_dragon_scale",
		"item_essence_ring",
		"item_vambrace",
		"item_dimensional_doorway",
		"item_ambient_sorcery",
		"item_bear_cloak",
		"item_bogduggs_baldric",
		"item_bogduggs_cudgel",
		"item_bogduggs_lucky_femur",
		"item_lifestone",
		"item_pelt_of_the_old_wolf",
		"item_sign_of_the_arachnid",
		"item_quicksilver_amulet",
		"item_bullwhip",
		"item_paintball",	
	}

	tier[2] =	{
		"item_quickening_charm",
		"item_mind_breaker",
		"item_spider_legs",
		"item_enchanted_quiver",
		"item_paladin_sword",
		"item_orb_of_destruction",
		"item_black_powder_bag",
		"item_titan_sliver",
		"item_horizon",
		"item_gravel_foot",
		"item_preserved_skull",
		"item_slippers_of_the_abyss",
		"item_treads_of_ermacor",
		"item_wand_of_the_brine",
		"item_watchers_gaze",
		"item_stony_coat",
		"item_elven_tunic",
		"item_cloak_of_flames",
		"item_psychic_headband",
		"item_ceremonial_robe",
	}

	tier[3] =	{
		"item_spy_gadget",
		"item_timeless_relic",
		"item_spell_prism",
		"item_flicker",
		"item_ninja_gear",
		"item_illusionsts_cape",
		"item_guardian_shell",
		"item_ice_dragon_maw",
		"item_paw_of_lucius",
		"item_stonework_pendant",
		"item_unhallowed_icon",
		"item_carapace_of_qaldin",
		"item_rhyziks_eye",
		"item_the_leveller",
		"item_penta_edged_sword",
		"item_stormcrafter",
		"item_trickster_cloak",
		"item_heavy_blade",
	}

	tier[4] =	{
		"item_force_boots",
		"item_desolator_2",
		"item_seer_stone",
		"item_mirror_shield",
		"item_fusion_rune",
		"item_ballista",
		"item_demonicon",
		"item_fallen_sky",
		"item_pirate_hat",
		"item_ex_machina",
		"item_apex",
		"item_the_caustic_finale",
		"item_glimmerdark_shield",
		"item_dredged_trident",
		"item_book_of_shadows",
		"item_giants_ring",
		"item_greater_mango",
	}

	local hero = owner:GetClassname()
	local ownerTeam = owner:GetTeamNumber()
	local sortedTeams = self:GetSortedTeams()

	local item_tier = 1

	for i = 1, #sortedTeams do
		if sortedTeams[i].team == ownerTeam then
			if i <= (1 + math.max(#sortedTeams - 3, 0) / 3) then
			elseif i >= (#sortedTeams - math.max(#sortedTeams - 3, 0) / 3) then
				item_tier = item_tier + 2
				print("+1 item tier: losing team")
			else
				--item_tier = item_tier + 1
				--print("+1 item tier: not leading team")
			end
		end
	end

	if self.leadingTeamScore >= (self.TEAM_KILLS_TO_WIN * 3 / 4) then
		item_tier = item_tier + 2
		print("+2 item tier: close to end")
	elseif self.leadingTeamScore >= (self.TEAM_KILLS_TO_WIN / 2) then
		item_tier = item_tier + 1
		print("+1 item tier: not far from end")
	end

	item_tier = math.min(item_tier, 4)

	local spawnedItem = {}
	for i = 1, 4 do
		while true do
			local repeated_item = false
			local potential_item = tier[item_tier][RandomInt(1, #tier[item_tier])]

			if owner:HasItemInInventory(potential_item) then
				repeated_item = true
			end

			for _, previous_item in pairs(spawnedItem) do
				if previous_item == potential_item then
					repeated_item = true
				end
			end

			if not repeated_item then
				spawnedItem[i] = potential_item
				break
			end
		end
	end

	-- present item choices to the player
	self:StartItemPick(owner, spawnedItem)
end


function COverthrowGameMode:StartItemPick(owner, items)
	if (not owner:IsRealHero()) and owner:GetOwnerEntity() then
		owner = owner:GetOwnerEntity()
	end
	local player_id = owner:GetPlayerID()
	if PlayerResource:IsValidPlayer(player_id) then
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(player_id), "overthrow_item_choice", items)
	end
end

function COverthrowGameMode:FinishItemPick(keys)
	local owner = EntIndexToHScript(keys.owner_entindex)
	local hero = owner:GetClassname()

	-- Add the item to the inventory and broadcast
	owner:AddItemByName(keys.item)
	EmitGlobalSound("powerup_04")
	local overthrow_item_drop =
	{
		hero_id = hero,
		dropped_item = keys.item
	}
	CustomGameEventManager:Send_ServerToAllClients( "overthrow_item_drop", overthrow_item_drop)
end

function COverthrowGameMode:ThinkSpecialItemDrop()
	-- Stop spawning items after 30
	if self.nNextSpawnItemNumber >= 30 then
		return
	end
	-- Don't spawn if the game is about to end
	if nCOUNTDOWNTIMER < 20 then
		return
	end
	local t = GameRules:GetDOTATime( false, false )
	local tSpawn = ( self.spawnTime * self.nNextSpawnItemNumber )
	local tWarn = tSpawn - 15

	if not self.hasWarnedSpawn and t >= tWarn then
		-- warn the item is about to spawn
		self:WarnItem()
		self.hasWarnedSpawn = true
	elseif t >= tSpawn then
		-- spawn the item
		self:SpawnItem()
		self.nNextSpawnItemNumber = self.nNextSpawnItemNumber + 1
		self.hasWarnedSpawn = false
	end
end

function COverthrowGameMode:PlanNextSpawn()
	local missingSpawnPoint =
	{
		origin = "0 0 384",
		targetname = "item_spawn_missing"
	}

	local r = RandomInt( 1, 8 )
	if GetMapName() == "too_many_based_quintet_players" or GetMapName() == "way_too_many_based_octet_players" or GetMapName() == "temple_of_the_quartet_icefrog" then
		r = RandomInt( 1, 6 )
	elseif GetMapName() == "temple_of_the_quartet_icefrog" then
		r = RandomInt( 1, 4 )
	end
	local path_track = "item_spawn_" .. r
	local spawnPoint = Vector( 0, 0, 700 )
	local spawnLocation = Entities:FindByName( nil, path_track )

	if spawnLocation == nil then
		spawnLocation = SpawnEntityFromTableSynchronous( "path_track", missingSpawnPoint )
		spawnLocation:SetAbsOrigin(spawnPoint)
	end

	self.itemSpawnLocation = spawnLocation
	self.itemSpawnIndex = r
end

function COverthrowGameMode:WarnItem()
	-- find the spawn point
	self:PlanNextSpawn()

	local spawnLocation = self.itemSpawnLocation:GetAbsOrigin();

	-- notify everyone
	CustomGameEventManager:Send_ServerToAllClients( "item_will_spawn", { spawn_location = spawnLocation } )
	EmitGlobalSound( "powerup_03" )

	-- fire the destination particles
	DoEntFire( "item_spawn_particle_" .. self.itemSpawnIndex, "Start", "0", 0, self, self )

	-- Give vision to the spawn area (unit is on goodguys, but shared vision)
	local visionRevealer = CreateUnitByName( "npc_vision_revealer", spawnLocation, false, nil, nil, DOTA_TEAM_GOODGUYS )
	visionRevealer:SetContextThink( "KillVisionRevealer", function() return visionRevealer:RemoveSelf() end, 35 )
	local trueSight = ParticleManager:CreateParticle( "particles/econ/wards/f2p/f2p_ward/f2p_ward_true_sight_ambient.vpcf", PATTACH_ABSORIGIN, visionRevealer )
	ParticleManager:SetParticleControlEnt( trueSight, PATTACH_ABSORIGIN, visionRevealer, PATTACH_ABSORIGIN, "attach_origin", visionRevealer:GetAbsOrigin(), true )
	visionRevealer:SetContextThink( "KillVisionParticle", function() return trueSight:RemoveSelf() end, 35 )
end

function COverthrowGameMode:SpawnItem()
	-- notify everyone
	CustomGameEventManager:Send_ServerToAllClients( "item_has_spawned", {} )
	EmitGlobalSound( "powerup_05" )

	-- spawn the item
	local startLocation = Vector( 0, 0, 700 )
	local treasureCourier = CreateUnitByName( "npc_dota_treasure_courier" , startLocation, true, nil, nil, DOTA_TEAM_NEUTRALS )
	local treasureAbility = treasureCourier:FindAbilityByName( "dota_ability_treasure_courier" )
	treasureAbility:SetLevel( 1 )
    --print ("Spawning Treasure")
    targetSpawnLocation = self.itemSpawnLocation
    treasureCourier:SetInitialGoalEntity(targetSpawnLocation)
    local particleTreasure = ParticleManager:CreateParticle( "particles/items_fx/black_king_bar_avatar.vpcf", PATTACH_ABSORIGIN, treasureCourier )
	ParticleManager:SetParticleControlEnt( particleTreasure, PATTACH_ABSORIGIN, treasureCourier, PATTACH_ABSORIGIN, "attach_origin", treasureCourier:GetAbsOrigin(), true )
	treasureCourier:Attribute_SetIntValue( "particleID", particleTreasure )
end

function COverthrowGameMode:ForceSpawnItem()
	self:WarnItem()
	self:SpawnItem()
end

function COverthrowGameMode:KnockBackFromTreasure( center, radius, knockback_duration, knockback_distance, knockback_height )
	local targetType = bit.bor( DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_HERO )
	local knockBackUnits = FindUnitsInRadius( DOTA_TEAM_NOTEAM, center, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, targetType, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )

	local modifierKnockback =
	{
		center_x = center.x,
		center_y = center.y,
		center_z = center.z,
		duration = knockback_duration,
		knockback_duration = knockback_duration,
		knockback_distance = knockback_distance,
		knockback_height = knockback_height,
	}

	for _,unit in pairs(knockBackUnits) do
--		print( "knock back unit: " .. unit:GetName() )
		unit:AddNewModifier( unit, nil, "modifier_knockback", modifierKnockback );
	end
end


function COverthrowGameMode:TreasureDrop( treasureCourier )
	--Create the death effect for the courier
	local spawnPoint = treasureCourier:GetInitialGoalEntity():GetAbsOrigin()
	spawnPoint.z = 400
	local fxPoint = treasureCourier:GetInitialGoalEntity():GetAbsOrigin()
	fxPoint.z = 400
	local deathEffects = ParticleManager:CreateParticle( "particles/treasure_courier_death.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( deathEffects, 0, fxPoint )
	ParticleManager:SetParticleControlOrientation( deathEffects, 0, treasureCourier:GetForwardVector(), treasureCourier:GetRightVector(), treasureCourier:GetUpVector() )
	EmitGlobalSound( "lockjaw_Courier.Impact" )
	EmitGlobalSound( "lockjaw_Courier.gold_big" )

	--Spawn the gold at the selected item spawn location
	local newItem = CreateItem( "item_bag_of_gold", nil, nil )
	local drop = CreateItemOnPositionForLaunch( spawnPoint, newItem )
	drop:SetForwardVector( treasureCourier:GetRightVector() ) -- oriented differently
	newItem:LaunchLootInitialHeight( false, 0, 50, 0.25, spawnPoint )
	
	--Stop the particle effect
	DoEntFire( "item_spawn_particle_" .. self.itemSpawnIndex, "stopplayendcap", "0", 0, self, self )

	--Knock people back from the treasure
	self:KnockBackFromTreasure( spawnPoint, 375, 0.25, 400, 100 )

	--Destroy the courier
	UTIL_Remove( treasureCourier )
end

function COverthrowGameMode:ForceSpawnGold()
	self:SpawnGold()
end

function COverthrowGameMode:ThinkPumpkins()
	local now = GameRules:GetDOTATime(false, false)
	for _, spawner in ipairs(self.pumpkin_spawns) do
		if not spawner.itemIndex and now >= spawner.nextSpawn then
			local item = CreateItem("item_core_pumpkin", nil, nil)
			spawner.itemIndex = item:GetEntityIndex()
			local container = CreateItemOnPositionForLaunch(spawner.position, item)
			ParticleManager:CreateParticle("particles/items3_fx/fish_bones_active.vpcf", PATTACH_ABSORIGIN, container)
			item:LaunchLootInitialHeight(false, 0, 0, 0.5, spawner.position)
		end
	end
end
