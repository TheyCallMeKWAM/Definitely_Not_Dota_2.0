--[[ events.lua ]]

---------------------------------------------------------------------------
-- Event: Game state change handler
---------------------------------------------------------------------------
function COverthrowGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	--print( "OnGameRulesStateChange: " .. nNewState )

	if nNewState == DOTA_GAMERULES_STATE_POST_GAME then
		local couriers = FindUnitsInRadius( 2, Vector( 0, 0, 0 ), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_COURIER, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )

		for i = 0, 64 do
			if PlayerResource:IsValidPlayer( i ) then
				local networth = 0
				local hero = PlayerResource:GetSelectedHeroEntity( i )

				for _, cour in pairs( couriers ) do
					if cour:GetTeam() == cour:GetTeam() then
						for s = 0, 8 do
							local item = cour:GetItemInSlot( s )

							if item and item:GetOwner() == hero then
								networth = networth + item:GetCost()
							end
						end
					end
				end

				for s = 0, 8 do
					local item = hero:GetItemInSlot( s )

					if item then
						networth = networth + item:GetCost()
					end
				end

				networth = networth + PlayerResource:GetGold( i )

				local stats = {
					networth = networth,
					total_damage = PlayerResource:GetRawPlayerDamage( i ),
					total_healing = PlayerResource:GetHealing( i ),
				}

				if newStats and newStats[i] then
					stats.tower_damage = newStats[i].tower_damage
					stats.sentries_count = newStats[i].npc_dota_sentry_wards
					stats.observers_count = newStats[i].npc_dota_observer_wards
					stats.killed_hero = newStats[i].killed_hero
				end

				CustomNetTables:SetTableValue( "custom_stats", tostring( i ), stats )
			end
		end
	end

	if nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		self.heroSelectionStage = 1
	end

	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		local parties = {}
		local party_indicies = {}
		local party_members_count = {}
		local party_index = 1
		-- Set up player colors
		for id = 0, 23 do
			if PlayerResource:IsValidPlayer(id) then
				local party_id = tonumber(tostring(PlayerResource:GetPartyID(id)))
				if party_id and party_id > 0 then
					if not party_indicies[party_id] then
						party_indicies[party_id] = party_index
						party_index = party_index + 1
					end
					local party_index = party_indicies[party_id]
					parties[id] = party_index
					if not party_members_count[party_index] then
						party_members_count[party_index] = 0
					end
					party_members_count[party_index] = party_members_count[party_index] + 1
				end
			end
		end
		for id, party in pairs(parties) do
			-- at least 2 ppl in party!
			if party_members_count[party] and party_members_count[party] < 2 then
				parties[id] = nil
			end
		end
		if parties then
			CustomNetTables:SetTableValue("game_state", "parties", parties)
		end
		
		local mapsForSlow = {
			["way_too_many_based_octet_players"] = true,
			["too_many_based_quintet_players"] = true
		}
		
		if mapsForSlow[GetMapName()] then
			Convars:SetFloat("host_timescale", 0.07)
			
			Timers:CreateTimer({
				useGameTime = false,
				endTime = 2.1,
				callback = function()
					Convars:SetFloat("host_timescale", 1)
					return nil
				end
			})
		end
		
		self.heroSelectionStage = 5
		local numberOfPlayers = PlayerResource:GetPlayerCount()
		if numberOfPlayers > 16 then
			nCOUNTDOWNTIMER = 1801
		elseif numberOfPlayers > 7 then
			nCOUNTDOWNTIMER = 1201
		elseif numberOfPlayers > 4 and numberOfPlayers <= 7 then
			nCOUNTDOWNTIMER = 1081
		else
			nCOUNTDOWNTIMER = 901
		end
		if GetMapName() == "ahh_there_are_too_many_trees_solo" then
			self.TEAM_KILLS_TO_WIN = 25
		elseif GetMapName() == "motherfucking_desert_duo" then
			self.TEAM_KILLS_TO_WIN = 45
		elseif GetMapName() == "possible_three_way_golden_rule" then
			self.TEAM_KILLS_TO_WIN = 40
		elseif GetMapName() == "temple_of_the_quartet_icefrog" then
			self.TEAM_KILLS_TO_WIN = 50
		elseif GetMapName() == "too_many_based_quintet_players" then
			self.TEAM_KILLS_TO_WIN = 80
		elseif GetMapName() == "way_too_many_based_octet_players" then
			self.TEAM_KILLS_TO_WIN = 120
		else
			self.TEAM_KILLS_TO_WIN = 30
		end
		--print( "Kills to win = " .. tostring(self.TEAM_KILLS_TO_WIN) )
		CustomNetTables:SetTableValue( "game_state", "victory_condition", { kills_to_win = self.TEAM_KILLS_TO_WIN } );

		self._fPreGameStartTime = GameRules:GetGameTime()
	end

	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		GPM_Init()
		--print( "OnGameRulesStateChange: Game In Progress" )
		self.countdownEnabled = true
		CustomGameEventManager:Send_ServerToAllClients( "show_timer", {} )
		DoEntFire( "center_experience_ring_particles", "Start", "0", 0, self, self  )
	end
end

--------------------------------------------------------------------------------
-- Event: OnNPCSpawned
--------------------------------------------------------------------------------
function COverthrowGameMode:OnNPCSpawned( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )

	local owner = spawnedUnit:GetOwner()
	local name = spawnedUnit:GetUnitName()

	if owner and owner.GetPlayerID and ( name == "npc_dota_sentry_wards" or name == "npc_dota_observer_wards" ) then
		local player_id = owner:GetPlayerID()

		newStats[player_id] = newStats[player_id] or {
			npc_dota_sentry_wards = 0,
			npc_dota_observer_wards = 0,
			tower_damage = 0,
			killed_hero = {}
		}

		newStats[player_id][name] = newStats[player_id][name] + 1
	end
	--if spawnedUnit:IsCourier() then
	--	local team = spawnedUnit:GetTeamNumber()
	--	if _G.mainTeamCouriers[team] == nil then
	--		_G.mainTeamCouriers[team] = spawnedUnit
	--	end
	--end

	if not spawnedUnit:IsRealHero() then return end
	--local playerId = spawnedUnit:GetPlayerID()
	--local psets = Patreons:GetPlayerSettings(playerId)

	--if psets.level > 1 and _G.personalCouriers[playerId] == nil then
	--	Timers:CreateTimer(2.0, function()
	--		CreatePrivateCourier(playerId, spawnedUnit, spawnedUnit:GetAbsOrigin())
	--	end)
	--end

	Timers:CreateTimer(1, function()
		if spawnedUnit:HasModifier("modifier_silencer_int_steal") then
			spawnedUnit:RemoveModifierByName('modifier_silencer_int_steal')
			spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_silencer_new_int_steal", {})
		end
	end)

	if GetMapName() == "way_too_many_based_octet_players" and spawnedUnit:GetName() == "npc_dota_hero_warlock" then
		if spawnedUnit.firstspawn == nil then
			spawnedUnit.firstspawn = false
			local hMeteor = spawnedUnit:FindAbilityByName( "warlock_fatal_bonds" )
			if hMeteor then
				hMeteor:SetActivated( false )
				local memberID = spawnedUnit:GetPlayerID()
				PlayerResource:ModifyGold( memberID, 1500, true, 0 )
				hMeteor:SetLevel( 4 )
			end
		end
	end

	if GetMapName() == "temple_of_the_quartet_icefrog" then
		local sortedTeams = self:GetSortedTeams()
		local teamNumber = spawnedUnit:GetTeam()
		local TeamsKills = GetTeamHeroKills(teamNumber)
		local LeaderKills = self.leadingTeamScore

		local goldDuration = 0
		if TeamsKills < LeaderKills then
			goldDuration = LeaderKills - TeamsKills
		end
		goldDuration = goldDuration * 3
		spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_core_spawn_movespeed", nil)

		if goldDuration > 0 then
			local xpGranterAbility
			for _, v in ipairs(Entities:FindAllByClassname("npc_dota_creature")) do
				if v:GetUnitName():starts("npc_dota_xp_granter") then
					xpGranterAbility = v:GetAbilityByIndex(0)
					break
				end
			end
			if xpGranterAbility then
				spawnedUnit:AddNewModifier(spawnedUnit, xpGranterAbility, "modifier_get_xp", { duration = goldDuration })
			end
		end

		if not GameRules:IsDaytime() then
			local unit = spawnedUnit
			local position = COverthrowGameMode:GetCoreTeleportTarget(unit:GetTeamNumber())
			local triggerPosition = unit:GetAbsOrigin()

			EmitSoundOnLocationWithCaster(triggerPosition, "Portal.Hero_Appear", unit)
			local startParticleId = ParticleManager:CreateParticle("particles/econ/events/fall_major_2015/teleport_end_fallmjr_2015_ground_flash.vpcf", PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(startParticleId, 0, triggerPosition)

			FindClearSpaceForUnit(unit, position, true)
			unit:Stop()

			unit:EmitSound("Portal.Hero_Appear")
			local endParticleId = ParticleManager:CreateParticle("particles/econ/events/fall_major_2015/teleport_end_fallmjr_2015_ground_flash.vpcf", PATTACH_ABSORIGIN, unit)
			ParticleManager:SetParticleControlEnt(endParticleId, 0, unit, PATTACH_ABSORIGIN, "attach_origin", unit:GetAbsOrigin(), true)

			local playerId = unit:GetPlayerOwnerID()
			local isMainHero = PlayerResource:GetSelectedHeroEntity(playerId) == unit
			if isMainHero then
				PlayerResource:SetCameraTarget(playerId, unit)
				unit:SetContextThink("CoreTeleportUnlockCamera", function() return PlayerResource:SetCameraTarget(playerId, nil) end, 0.1)
			end

			unit:RemoveModifierByName("modifier_core_spawn_movespeed")
			unit:AddNewModifier(unit, nil, "modifier_core_spawn_movespeed", { xp = isMainHero })
		end
	end

	-- Destroys the last hit effects
	local deathEffects = spawnedUnit:Attribute_GetIntValue( "effectsID", -1 )
	if deathEffects ~= -1 then
		ParticleManager:DestroyParticle( deathEffects, true )
		spawnedUnit:DeleteAttribute( "effectsID" )
	end

	local unitTeam = spawnedUnit:GetTeam()
	if not spawnedUnit.firstTimeSpawned then
		spawnedUnit:SetContextThink("AddCourier", function()
			if self.couriers[unitTeam] then return end
			self.couriers[unitTeam] = true
--			local firstSlotItem = spawnedUnit:GetItemInSlot(DOTA_ITEM_SLOT_1)
--			if firstSlotItem then spawnedUnit:TakeItem(firstSlotItem) end
--
--			local playerId = spawnedUnit:GetPlayerID()
--			local courier = spawnedUnit:AddItemByName("item_courier")
--			if courier then
--				spawnedUnit:CastAbilityImmediately(courier, playerId)
--			end

			--Timers:CreateTimer(2, function()
			--	local courier_spawn = spawnedUnit:GetAbsOrigin() + RandomVector(RandomFloat(100, 100))
			--	local cr = CreateUnitByName("npc_dota_courier", courier_spawn, true, nil, nil, unitTeam)
			--
			--	if GetMapName() == "temple_of_the_quartet_icefrog" then
			--		cr:AddNewModifier(cr, nil, "modifier_courier_quartet", nil)
			--	else
			--		cr:AddNewModifier(cr, nil, "modifier_core_courier", {})
			--	end
			--	Timers:CreateTimer(0.1, function()
			--		for i = 0, 24 do
			--			local temp_ply = PlayerResource:GetPlayer(i)
			--			if (temp_ply and IsValidEntity(temp_ply)) then
			--				Timers:CreateTimer(.1, function()
			--					if (temp_ply:GetTeamNumber() == cr:GetTeamNumber()) then
			--						cr:SetControllableByPlayer(i, true)
			--					end
			--				end)
			--			end
			--		end
			--	end)
			--end)

--			spawnedUnit:SetContextThink("AddCourierUpgrade", function()
--				if GetMapName() == "temple_of_the_quartet_icefrog" then
--					for _,courier in ipairs(Entities:FindAllByClassname("npc_dota_courier")) do
--						courier:AddNewModifier(courier, nil, "modifier_courier_quartet", nil)
--					end
--				end
--				if firstSlotItem then
--					spawnedUnit:AddItem(firstSlotItem)
--				end
--			end, 0)
		end, 0)

		spawnedUnit.firstTimeSpawned = true
		spawnedUnit:SetContextThink("HeroFirstSpawn", function()
			local playerId = spawnedUnit:GetPlayerID()
			if spawnedUnit == PlayerResource:GetSelectedHeroEntity(playerId) then
				Patreons:GiveOnSpawnBonus(playerId)
			end
		end, 2/30)
	end

	if self.allSpawned == false then
		if GetMapName() == "mines_trio" then
			--print("mines_trio is the map")
			--print("self.allSpawned is " .. tostring(self.allSpawned) )
			local particleSpawn = ParticleManager:CreateParticleForTeam( "particles/addons_gameplay/player_deferred_light.vpcf", PATTACH_ABSORIGIN, spawnedUnit, unitTeam )
			ParticleManager:SetParticleControlEnt( particleSpawn, PATTACH_ABSORIGIN, spawnedUnit, PATTACH_ABSORIGIN, "attach_origin", spawnedUnit:GetAbsOrigin(), true )
		end
	end
end

---------------------------------------------------------------------------
-- Event: OnTeamKillCredit, see if anyone won
---------------------------------------------------------------------------
function print_d(text)
    CustomGameEventManager:Send_ServerToAllClients("DebugMessage", { msg = text})
end

function COverthrowGameMode:OnTeamKillCredit( event )
--	print( "OnKillCredit" )
--	DeepPrint( event )
	print_d("Unit kill")

	local nKillerID = event.killer_userid
	local nTeamID = event.teamnumber
	local nTeamKills = event.herokills
	local nKillsRemaining = self.TEAM_KILLS_TO_WIN - nTeamKills
	print_d("Kills remaining: "..nKillsRemaining)

	local broadcast_kill_event =
	{
		killer_id = event.killer_userid,
		team_id = event.teamnumber,
		team_kills = nTeamKills,
		kills_remaining = nKillsRemaining,
		victory = 0,
		close_to_victory = 0,
		very_close_to_victory = 0,
	}

	if nKillsRemaining <= 0 then
		print_d("KILL LIMIT --- End Game. Team Leader: "..nTeamID)
		GameRules:SetCustomVictoryMessage( self.m_VictoryMessages[nTeamID] )
		GameRules:SetGameWinner( nTeamID )
		broadcast_kill_event.victory = 1
	elseif nKillsRemaining == 1 then
		EmitGlobalSound( "ui.npe_objective_complete" )
		broadcast_kill_event.very_close_to_victory = 1
	elseif nKillsRemaining <= self.CLOSE_TO_VICTORY_THRESHOLD then
		EmitGlobalSound( "ui.npe_objective_given" )
		broadcast_kill_event.close_to_victory = 1
	end

	CustomGameEventManager:Send_ServerToAllClients( "kill_event", broadcast_kill_event )
end

---------------------------------------------------------------------------
-- Event: OnEntityKilled
---------------------------------------------------------------------------
function COverthrowGameMode:OnEntityKilled( event )
	local extraTime = 0
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	local killedTeam = killedUnit:GetTeam()
	local hero
	local uniqueKey
	local heroTeam

	if event.entindex_attacker then
		hero = EntIndexToHScript( event.entindex_attacker )
		heroTeam = hero:GetTeam()
	end
	if event.entindex_killed and event.entindex_attacker then uniqueKey = event.entindex_attacker .. "_" .. event.entindex_killed end


	if (not (hero == killedUnit)) and killedUnit:IsRealHero() then
		_G.timesOfTheLastKillings[hero] = GameRules:GetGameTime()
	end

	if uniqueKey and hero and killedUnit:IsRealHero() and (PlayerResource:GetSelectedHeroEntity(killedUnit:GetPlayerID()) == killedUnit) then
		local killerClassname = hero:GetClassname()
		if killerClassname == "ent_dota_fountain" or killerClassname == "ent_dota_tower" then
			_G.pairKillCounts[uniqueKey] = (_G.pairKillCounts[uniqueKey] or 0) + 1
		end
	end

	if killedUnit:IsRealHero() and not killedUnit:IsReincarnating() then
		local player_id = -1
		if hero and hero:IsRealHero() and hero.GetPlayerID then
			player_id = hero:GetPlayerID()
		else
			if hero:GetPlayerOwnerID() ~= -1 then
				player_id = hero:GetPlayerOwnerID()
			end
		end
		if player_id ~= -1 then
			local name = killedUnit:GetUnitName()

			newStats[player_id] = newStats[player_id] or {
				npc_dota_sentry_wards = 0,
				npc_dota_observer_wards = 0,
				tower_damage = 0,
				killed_hero = {}
			}

			local kh = newStats[player_id].killed_hero

			kh[name] = kh[name] and kh[name] + 1 or 1
		end
	end

	if killedUnit:IsRealHero() then
		self.allSpawned = true
		--print("Hero has been killed")
		--Add extra time if killed by Necro Ult
		if hero and hero:IsRealHero() then
			if event.entindex_inflictor ~= nil then
				local inflictor_index = event.entindex_inflictor
				if inflictor_index ~= nil then
					local ability = EntIndexToHScript( event.entindex_inflictor )
					if ability ~= nil then
						if ability:GetAbilityName() ~= nil then
							if ability:GetAbilityName() == "necrolyte_reapers_scythe" then
								print("Killed by Necro Ult")
								extraTime = 20
							end
						end
					end
				end
			end
		end
		if hero and hero:IsRealHero() and heroTeam ~= killedTeam then
			--print("Granting killer xp")
			if killedUnit:GetTeam() == self.leadingTeam and self.isGameTied == false then
				local memberID = hero:GetPlayerID()
				PlayerResource:ModifyGold( memberID, 500, true, 0 )
				hero:AddExperience( 100, 0, false, false )
				local name = hero:GetClassname()
				local victim = killedUnit:GetClassname()
				local kill_alert =
					{
						hero_id = hero:GetClassname()
					}
				CustomGameEventManager:Send_ServerToAllClients( "kill_alert", kill_alert )
			else
				if GetMapName() ~= "temple_of_the_quartet_icefrog" then
					hero:AddExperience( 50, 0, false, false )
				end
			end
		end
		--Granting XP to all heroes who assisted
		local allHeroes = HeroList:GetAllHeroes()
		for _,attacker in pairs( allHeroes ) do
			--print(killedUnit:GetNumAttackers())
			for i = 0, killedUnit:GetNumAttackers() - 1 do
				if attacker == killedUnit:GetAttacker( i ) then
					--print("Granting assist xp")
					attacker:AddExperience( 25, 0, false, false )
				end
			end
		end

		if not killedUnit:IsReincarnating() then
			COverthrowGameMode:SetRespawnTime(killedTeam, killedUnit, extraTime)
		end
	end
end

function COverthrowGameMode:SetRespawnTime(killedTeam, killedUnit, extraTime)
	local units = {killedUnit}
	if killedUnit:GetUnitName() == "npc_dota_hero_meepo" then
		local playerId = killedUnit:GetPlayerID()
		for _, unit in ipairs(Entities:FindAllByName("npc_dota_hero_meepo")) do
			if unit:IsRealHero() and unit ~= killedUnit and unit:GetPlayerID() == playerId then
				table.insert(units, unit)
			end
		end
	end

	local baseTime = 15
	local sortedTeams = self:GetSortedTeams()
	if GetMapName() == "way_too_many_based_octet_players	" then
		if killedTeam == sortedTeams[1].team and sortedTeams[1].score - sortedTeams[2].score >= 2 then
			baseTime = 25
		end

		local lastPlace = sortedTeams[#sortedTeams].team
		if killedTeam == lastPlace then
			baseTime = 10
		end
	elseif GetMapName() == "temple_of_the_quartet_icefrog" then
	    local killedTeamScore = GetTeamHeroKills(killedTeam)

		if killedTeamScore == sortedTeams[6].score then
			baseTime = 3
		elseif killedTeamScore == sortedTeams[5].score then
			baseTime = 9
		elseif killedTeamScore == sortedTeams[4].score then
			baseTime = 12
		elseif killedTeamScore == sortedTeams[3].score then
			baseTime = 15
		elseif killedTeamScore == sortedTeams[2].score then
			baseTime = 18
		elseif killedTeamScore == sortedTeams[1].score then
			baseTime = 21
		else
			baseTime = 15
		end

	else
		if killedTeam == sortedTeams[1].team and sortedTeams[1].score ~= sortedTeams[2].score then
			baseTime = 20
		end
	end

	for _,unit in ipairs(units) do
		unit:SetTimeUntilRespawn(baseTime + extraTime)
	end
end


--------------------------------------------------------------------------------
-- Event: OnItemPickUp
--------------------------------------------------------------------------------
function COverthrowGameMode:OnItemPickUp( event )
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner
	if event.HeroEntityIndex then
		owner = EntIndexToHScript(event.HeroEntityIndex)
	elseif event.UnitEntityIndex then
		owner = EntIndexToHScript(event.UnitEntityIndex)
	end

	if event.itemname == "item_bag_of_gold" then
		COverthrowGameMode:AddGoldenCoin(owner)
		UTIL_Remove(item)
	elseif event.itemname == "item_treasure_chest" then
		DoEntFire( "item_spawn_particle_" .. self.itemSpawnIndex, "Stop", "0", 0, self, self )
		if not owner:HasInventory() or owner:GetUnitName() == "npc_dota_hero_meepo" then
			owner = PlayerResource:GetSelectedHeroEntity(owner:GetPlayerOwnerID())
		end
		COverthrowGameMode:SpecialItemAdd(owner)
		UTIL_Remove(item)
	elseif event.itemname == "item_core_pumpkin" then
		for _, spawner in ipairs(self.pumpkin_spawns) do
			if spawner.itemIndex == event.ItemEntityIndex then
				local now = GameRules:GetDOTATime(false, false)
				spawner.nextSpawn = now + 45
				spawner.itemIndex = nil
				break
			end
		end
		owner:EmitSound("Rune.Regen")
		owner:AddNewModifier(owner, item, "modifier_core_pumpkin_regeneration", { duration = 10 })
		UTIL_Remove(item)
	end
end

--------------------------------------------------------------------------------
-- Event: OnNpcGoalReached
--------------------------------------------------------------------------------
function COverthrowGameMode:OnNpcGoalReached( event )
	local npc = EntIndexToHScript( event.npc_entindex )
	if npc:GetUnitName() == "npc_dota_treasure_courier" then
		COverthrowGameMode:TreasureDrop( npc )
	end
end