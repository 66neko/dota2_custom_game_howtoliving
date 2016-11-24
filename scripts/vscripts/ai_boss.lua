--[[
boss ai -标准boss行为
]]

function Spawn(	entityKeyValues )
	local unit_name = thisEntity:GetUnitName() 
	--print(unit_name)
	if unit_name == "npc_dota_creature_new_boss_ogre_magi" then
		thisEntity:SetContextThink("NewOgreThink", NewOgreThink, 5)
	end
	if unit_name == "npc_dota_creature_new_boss_magnataur" then
		thisEntity:SetContextThink("NewMagThink", NewMagThink, 5)
	end
	if unit_name == "npc_dota_creature_new_boss_demo" then
		thisEntity:SetContextThink("NewDemoThink", NewDemoThink, 5)
	end
end

--npc_dota_creature_new_boss_ogre_magi
function NewOgreThink(  )
	local radius = 600
	local point = thisEntity:GetOrigin() 
	local ability_boss_fireblast = thisEntity:FindAbilityByName("boss_fireblast") 
	local ability_boss_ignite = thisEntity:FindAbilityByName("boss_ignite") 
	if ability_boss_ignite:IsCooldownReady() then
		local targets = FindUnitsInRadius(thisEntity:GetTeam(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 
					DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, true)
		for i,unit in pairs(targets) do
			thisEntity:CastAbilityOnTarget(unit, ability_boss_ignite, thisEntity:GetPlayerOwnerID() ) 
			return 5
		end
	end
	if ability_boss_fireblast:IsCooldownReady() then
		local targets = FindUnitsInRadius(thisEntity:GetTeam(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 
					DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, true)
		for i,unit in pairs(targets) do
			thisEntity:CastAbilityOnTarget(unit, ability_boss_fireblast, thisEntity:GetPlayerOwnerID() ) 
			return 5
		end
	end
	return 5
end

--npc_dota_creature_new_boss_magnataur
function NewMagThink(  )
	local radius = 600
	local point = thisEntity:GetOrigin() 
	local ability_reverse_polarity = thisEntity:FindAbilityByName("boss_reverse_polarity") 
	if ability_reverse_polarity:IsCooldownReady() then
		local targets = FindUnitsInRadius(thisEntity:GetTeam(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 
					DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, true)
		for i,unit in pairs(targets) do
			thisEntity:CastAbilityNoTarget(ability_reverse_polarity, thisEntity:GetPlayerOwnerID() ) 
			return 21
		end
	end
	return 5
end

--npc_dota_creature_new_boss_demo
function NewDemoThink(  )
	local radius = 650
	local point = thisEntity:GetOrigin() 
	local ability_ravage = thisEntity:FindAbilityByName("boss_ravage") 
	if ability_ravage:IsCooldownReady() then
		local targets = FindUnitsInRadius(thisEntity:GetTeam(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 
					DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, true)
		for i,unit in pairs(targets) do
			thisEntity:CastAbilityNoTarget(ability_ravage, thisEntity:GetPlayerOwnerID() ) 
			return 21
		end
	end
	return 5
end

