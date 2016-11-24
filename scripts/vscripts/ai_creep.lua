--[[
creep ai -标准怪物行为
]]

function Spawn(	entityKeyValues )
	local unit_name = thisEntity:GetUnitName() 
	--print(unit_name)
	if unit_name == "npc_dota_creature_new_woodfang" then
		local ability_frost_arrows = thisEntity:FindAbilityByName("creep_ranger_frost_arrows") 
		ability_frost_arrows:ToggleAutoCast() 
	end
	if unit_name == "npc_dota_creature_new_direcreep" then
		thisEntity:SetContextThink("NewDirecreepThink", NewDirecreepThink, 5) 
	end
end

--npc_dota_creature_new_direcreep
function NewDirecreepThink(  )
	local radius = 400
	local point = thisEntity:GetOrigin() 
	local ability_amplify_damage = thisEntity:FindAbilityByName("creep_amplify_damage") 
	local targets = FindUnitsInRadius(thisEntity:GetTeam(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 
					DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, true)
	for i,unit in pairs(targets) do
		thisEntity:CastAbilityOnTarget(unit, ability_amplify_damage, thisEntity:GetPlayerOwnerID() ) 
		return 15
	end
	return 5
end