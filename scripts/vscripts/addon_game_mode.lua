--常数
local rules_flag = 1
local GameMode
--玩家数量
PLAYER_COUNT = 0 --总玩家数
PLAYER_COUNT_GOODGUYS = 0 --天辉
PLAYER_COUNT_BADGUYS = 0 --夜魇
--性能优化
MAX_CREEP_COUNT = 150 --最大怪物数 受性能限制
CURRENT_CREEP_COUNT = 0 --实时怪物数 平衡性能参数
--英雄等级和经验表
MAX_LEVEL = 40 --最大英雄等级
XP_PER_LEVEL_TABLE = {} --经验表
--设置经验表
XP_PER_LEVEL_TABLE[0] = 0
for i=1,MAX_LEVEL do 
	XP_PER_LEVEL_TABLE[i] = i * 100 + XP_PER_LEVEL_TABLE[i-1] + 100
end 
--BOSS变量
--BOSS红龙的相关变量
local npc_boss_red_dragon_point --红龙位置
local npc_boss_red_dragon --红龙BOSS
--自动刷怪相关变量
CREEP_SPAWN_COUNT = 23 --刷怪点总个数
CREEP_SPAWN = {
	"creep_spawn01" ,
	"creep_spawn02" ,
	"creep_spawn03" ,
	"creep_spawn04" ,
	"creep_spawn05" ,
	"creep_spawn06" ,
	"creep_spawn07" ,
	"creep_spawn08" ,
	"creep_spawn09" ,
	"creep_spawn10" ,
	"creep_spawn11" ,
	"creep_spawn12" ,
	"creep_spawn13" ,
	"creep_spawn14" ,
	"creep_spawn15" ,
	"creep_spawn16" ,
	"creep_spawn17" ,
	"creep_spawn18" ,
	"creep_spawn19" ,
	"creep_spawn20" ,
	"creep_spawn21" ,
	"creep_spawn22" ,
	"creep_spawn23" ,
	"creep_spawn24" ,
	"creep_spawn25" ,
	"creep_spawn26" ,
	"creep_spawn27" ,
	"creep_spawn28" ,
	"creep_spawn29" ,
	"creep_spawn30" 
} --每个刷怪点
CREEP_UNIT = {
	"npc_dota_creature_new_skeleton" ,--近战普通 - 小骷髅 lv1
	"npc_dota_creature_new_direcreep" ,--近战技能 - 僵尸 lv1
	"npc_dota_creature_new_sprder" ,--远程普通 - 大蜘蛛 lv1
	"npc_dota_creature_new_woodfang" ,--远程技能 - 树精 lv1
	"npc_dota_creature_new_boss_renma" ,--光环技能小boss - 人马 lv1 - 耐久光环
	"npc_dota_creature_new_boss_xiong" ,--光环技能小boss - 熊 lv1 - 护甲生命回复光环
	"npc_dota_creature_new_boss_lang" --光环技能小boss - 狼 lv1 - 攻击力吸血光环
} --每个怪
CREEP_NEUTRAL_UNIT = {
	"npc_dota_creature_mech" , --小蜘蛛lv1
	"npc_dota_creature_skeleton" , --小骷髅lv1
	"npc_dota_creature_sprit_bear" , --熊lv3
	"npc_dota_creature_torchbearer" , --torchbearer熊 lv5
	"npc_dota_creature_direcreep" , --僵尸lv7
	"npc_dota_creature_sprder" , --大蜘蛛lv9
	"npc_dota_creature_woodfang" , --树精lv11
	"npc_dota_creature_ghost" , --幽灵lv13
	"npc_dota_creature_nian" , --年兽lv15
	"npc_dota_creature_black_dragon" --黑龙lv17
} --每个野怪
CREEP_BOSS = {
	"npc_dota_creature_boss_roshan" --roshan_lv20
} --记录每个BOSS
CREEP_LEVEL = 0 --怪物升级等级 及初始值
CREEP_TYPE_COUNT = 4 --刷出怪物数量 及初始值
CREEP_CREATE_TIME = 1 --刷怪间隔
--物品掉落系统参数
DROP_ITEM_COUNT = 9 --掉落物品数量
DROP_ITEM_LIST = {
	"item_boots" , --鞋子lv1
	"item_mithril_hammer" , --减防-秘银锤lv1
	"item_claymore" , --分裂-大剑lv1
	"item_javelin" , --多重-标枪lv1
	"item_weapon_wizardry_lv1" , --法杖lv1
	"item_armor_Chainmail_lv1" , --锁子甲lv1
	"item_armor_evasion_lv1" , --闪避护符lv1
	"item_armor_cloak_lv1" , --魔抗斗篷lv1
	"item_armor_lifesteal_lv1" , --吸血面具lv1
	"item_ultimate_orb" --关键-合成球-特殊概率-不计入掉落数量DROP_ITEM_COUNT
}
DROP_ITEM_CHANCE = 5 --物品掉率百分比（整数）
DROP_ITEM_O_CHANCE = 100 --合成球掉率百分比（整数）
--胜负判断：roshan击杀数
ROSHAN_KILLS = 0 --当前roshan击杀数
ROSHAN_KILLS_NEED = 0 --需要击杀roshan数

--游戏脚本开始
if CLivingGameMode == nil then
	CLivingGameMode = class({})
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	--boom_game资源预载
	PrecacheResource("particle", "particles/econ/items/techies/techies_arcana/techies_suicide_base_arcana.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/techies/techies_arcana/techies_base_attack_arcana_a.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_rattletrap/rattletrap_rocket_flare.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_invoker/invoker_deafening_blast.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_invoker/invoker_deafening_blast_knockback_debuff.vpcf", context)	
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_enigma.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_bane/bane_enfeeble.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_enigma/enigma_blackhole.vpcf", context)
	--living新增资源预载
	PrecacheResource("model", "models/items/broodmother/spiderling/thistle_crawler/thistle_crawler.vmdl", context)
	PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_troll_skeleton/n_creep_skeleton_melee.vmdl", context)
	PrecacheResource("model", "models/items/lone_druid/bear/spirit_of_anger/spirit_of_anger.vmdl", context)
	PrecacheResource("model", "models/items/warlock/golem/the_torchbearer/the_torchbearer.vmdl", context)
	PrecacheResource("model", "models/creeps/lane_creeps/creep_bad_melee_diretide/creep_bad_melee_diretide.vmdl", context)
	PrecacheResource("model", "models/items/broodmother/spiderling/virulent_matriarchs_spiderling/virulent_matriarchs_spiderling.vmdl", context)
	PrecacheResource("model", "models/items/furion/treant/ravenous_woodfang/ravenous_woodfang.vmdl", context)
	PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_ghost_b/n_creep_ghost_red.vmdl", context)
	PrecacheResource("model", "models/creeps/nian/nian_creep.vmdl", context)
	PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_black_dragon/n_creep_black_dragon.vmdl", context)
	PrecacheResource("model", "models/heroes/dragon_knight/dragon_knight_dragon.vmdl", context)
	PrecacheResource("particle", "particles/econ/items/dragon_knight/dk_immortal_dragon/dragon_knight_dragon_tail_dragonform_iron_dragon.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_venomancer/venomancer_base_attack.vpcf", context)
	PrecacheResource("particle", "particles/neutral_fx/gnoll_base_attack.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_medusa.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_medusa/medusa_bow_split_shot_cast.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_medusa/medusa_base_attack.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_bounty_hunter.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_bounty_hunter/bounty_hunter_windwalk.vpcf", context)
	PrecacheResource("particle", "particles/generic_hero_status/status_invisibility_start.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_naga_siren.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_siren/naga_siren_mirror_image.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_tidehunter.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tidehunter/tidehunter_ravage_tentacle_a.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tidehunter/tidehunter_ravage_tentacle_b.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tidehunter/tidehunter_ravage_tentacle_c.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tidehunter/tidehunter_ravage_tentacle_d.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tidehunter/tidehunter_ravage_tentacle_model.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tidehunter/tidehunter_ravage_tentacle_model_rocks.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tidehunter/tidehunter_spell_ravage.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tidehunter/tidehunter_spell_ravage_hit.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tidehunter/tidehunter_spell_ravage_pool_c.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_windrunner.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_tusk.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tusk/tusk_snowball.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tusk/tusk_snowball_dummy.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tusk/tusk_snowball_impact_flashb.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tusk/tusk_snowball_load.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tusk/tusk_snowball_start.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_tinker.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_tinker/tinker_machine.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_magnataur.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_magnataur/magnataur_shockwave_cast.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_magnataur/magnataur_shockwave_cast_b.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_magnataur/magnataur_shockwave_cast_c.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_crystalmaiden.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf", context)
	PrecacheResource("particle", "particles/generic_gameplay/generic_slowed_cold.vpcf", context)
	PrecacheResource("model", "models/heroes/techies/fx_techiesfx_mine.vmdl", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_techies.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_rubick.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_rubick/rubick_fade_bolt_impact_burst.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_rubick/rubick_fade_bolt_head.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_rubick/rubick_fade_bolt_debuff.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_rubick/rubick_fade_bolt.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_omniknight.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_omniknight/omniknight_purification_hit.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_omniknight/omniknight_purification_cast.vpcf", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_ogre_magi.vsndevts", context)
	PrecacheResource("particle", "particles/econ/items/pudge/pudge_bloodlust_fork/pudge_bloodlust_fork.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff_arcs.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff_g.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff_pnt.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff_symbol_old.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_cast.vpcf", context)
	PrecacheResource("model", "models/creeps/roshan/roshan.vmdl", context)
	--living new 新增资源
	PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_centaur_lrg/n_creep_centaur_lrg.vmdl", context)
	PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_worg_large/n_creep_worg_large.vmdl", context)
	PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_furbolg/n_creep_furbolg_disrupter.vmdl", context)
	PrecacheResource("model", "models/heroes/ogre_magi/ogre_magi.vmdl", context)
	PrecacheResource("model", "models/heroes/ogre_magi/ogre_magi_weapon.vmdl", context)
	PrecacheResource("model", "models/heroes/ogre_magi/ogre_magi_bracers.vmdl", context)
	PrecacheResource("model", "models/heroes/ogre_magi/ogre_magi_belt.vmdl", context)
	PrecacheResource("model", "models/heroes/ogre_magi/ogre_magi_hats.vmdl", context)
	PrecacheResource("model", "models/heroes/magnataur/magnataur.vmdl", context)
	PrecacheResource("model", "models/heroes/magnataur/magnataur_belt.vmdl", context)
	PrecacheResource("model", "models/heroes/magnataur/magnataur_bracers.vmdl", context)
	PrecacheResource("model", "models/heroes/magnataur/magnataur_hair.vmdl", context)
	PrecacheResource("model", "models/heroes/magnataur/magnataur_horn.vmdl", context)
	PrecacheResource("model", "models/heroes/magnataur/magnataur_weapon.vmdl", context)
	PrecacheResource("particle", "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_fire.vpcf", context)
	PrecacheResource("model", "models/items/terrorblade/dotapit_s3_fallen_light_metamorphosis/dotapit_s3_fallen_light_metamorphosis.vmdl", context)
	PrecacheResource("particle", "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_base_attack.vpcf", context)
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_ogre_magi", context )
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_slardar", context )
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_magnataur", context )
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_tidehunter", context )
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_slardar.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_drow_ranger.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_drowranger.vsndevts", context)
	PrecacheResource("particle", "particles/units/heroes/hero_drow/drow_frost_arrow.vpcf", context)
	PrecacheResource("particle", "particles/generic_gameplay/generic_slowed_cold.vpcf", context)

end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CLivingGameMode()
	GameRules.AddonTemplate:InitGameMode()
end

function CLivingGameMode:InitGameMode()
	print( "living_game is loaded." )
	--设置天辉队员5人 夜魇0人
	--PlayerResource:SetCustomTeamAssignment(0 , DOTA_TEAM_BADGUYS)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS,5)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS,1)
	--初始化红龙boss位置和实体
	--npc_boss_red_dragon_point = Entities:FindByName(nil, "npc_boss_red_dragon"):GetOrigin()
	--npc_boss_red_dragon = Entities:FindByName(nil, "npc_boss_red_dragon")
	--GameMode
	GameMode = GameRules:GetGameModeEntity() 
	--禁止储物箱购买物品设置
	--GameMode:SetStashPurchasingDisabled(true)
	--开始时间设置
	GameRules:SetPreGameTime(0) --[[Returns:void
	Sets the amount of time players have between picking their hero and game start.
	]]
	GameRules:SetHeroSelectionTime(13.0) --[[Returns:void
	Sets the amount of time players have to pick their hero.
	]]
	--设置神符刷新间隔1分钟
	GameRules:SetRuneSpawnTime(60) --[[Returns:void
	Sets the amount of time between rune spawns.
	]]
	--不允许选择重复英雄
	GameRules:SetSameHeroSelectionEnabled(false) --[[Returns:void
	When true, players can repeatedly pick the same hero.
	]]
	--设置最大英雄等级
	GameMode:SetUseCustomHeroLevels(true)
	GameMode:SetCustomHeroMaxLevel( MAX_LEVEL )
	--设置经验表
	GameMode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
	--禁止显示推荐装备
	GameMode:SetRecommendedItemsDisabled(true)
	--关闭偷塔保护
	GameMode:SetTowerBackdoorProtectionEnabled(false)
	--设置禁止买活
	GameMode:SetBuybackEnabled(false)
	--设置迷雾规则
	--CLivingGameMode:CloseFogOfWar()
	--打开计时器部分
	--CLivingGameMode:ThisThinker()
	--监听器
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(CLivingGameMode, "OnNPCSpawned"), self)
	ListenToGameEvent("entity_killed", Dynamic_Wrap(CLivingGameMode, "OnNPCKilled"), self)
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(CLivingGameMode,"OnGameRulesStateChange"), self)
	ListenToGameEvent("dota_player_gained_level", Dynamic_Wrap(CLivingGameMode, "OnHeroLevelUp"), self)
end

--监听单位创建或重生
function CLivingGameMode:OnNPCSpawned( keys )
	local unit = EntIndexToHScript(keys.entindex) --[[Returns:handle
	Turn an entity index integer to an HScript representing that entity's script instance.
	]]
	--计数器
	CURRENT_CREEP_COUNT = CURRENT_CREEP_COUNT + 1
	--游戏规则提醒
	if rules_flag == 1 and unit:IsHero() then
		CLivingGameMode:OnOpen()
		rules_flag = 0
		GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("game_rules_time"),
			function (  )
				rules_flag = 1
				return nil
			end,120)
	end
	--随机英雄复活地点机制
	if unit:IsHero() and unit:IsIllusion() == false then
		--测试用
		RandomTeam(unit)
		--测试结束
		local point_entity = Entities:FindByName(nil, CREEP_SPAWN[RandomInt(1, CREEP_SPAWN_COUNT)])
		unit:SetOrigin( point_entity:GetOrigin() )
		unit:AddNewModifier(nil, nil, "modifier_phased", {duration = 0.1})
		GameMode:SetContextThink(DoUniqueString("function_random_hero_swpan"),
			function (  )
				if unit:GetOrigin() == point_entity:GetOrigin() then
					return nil
				end
				unit:SetOrigin( point_entity:GetOrigin() )
				unit:AddNewModifier(nil, nil, "modifier_phased", {duration = 0.1})
				PlayerResource:SetCameraTarget(unit:GetPlayerOwnerID() , unit) 
				GameMode:SetContextThink(DoUniqueString("function_random_hero_camera"),
					function (  )
					PlayerResource:SetCameraTarget(unit:GetPlayerOwnerID() , nil) 
					return nil
				end,1)
				return nil
			end,0.1)
	end
end

--监听单位被击杀事件
function CLivingGameMode:OnNPCKilled( keys )
	local unit = EntIndexToHScript(keys.entindex_killed)
	local attacker = EntIndexToHScript(keys.entindex_attacker)
	--计数器
	CURRENT_CREEP_COUNT = CURRENT_CREEP_COUNT - 1
	--英雄重生设置
	local time_respawn = unit:GetLevel()
	if time_respawn>10 then
		time_respawn = 20
	end
	if unit:IsHero() then
		--关于英雄自杀 
		if keys.entindex_attacker == keys.entindex_killed then
			unit:SetTimeUntilRespawn(5)
		else
			unit:SetTimeUntilRespawn(time_respawn+4)
		end
	end
	--复活boss红龙
	--[[if unit:GetUnitName() == "npc_dota_creature_boss_red_dragon" then
		GameMode:SetContextThink(DoUniqueString("function_spawn_boss_red_dragon"),
		function (  )
			unit = CreateUnitByName("npc_dota_creature_boss_red_dragon", npc_boss_red_dragon_point, false, nil, nil, DOTA_TEAM_BADGUYS) 
			unit:CreatureLevelUp(CREEP_LEVEL) 
			npc_boss_red_dragon = unit
			return nil
		end,150)
	end]]

	--[[判断游戏胜负
	if unit:IsHero() then
		if PlayerResource:GetTeamKills(attacker:GetTeam()) >= 50 then
			GameRules:SetGameWinner(attacker:GetTeam())
		end
	end]]
	--物品掉落系统
	if unit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
		--普通单位
		if unit:GetUnitName() ~= "npc_dota_creature_new_skeleton" and unit:GetUnitName() ~= "npc_dota_creature_new_direcreep" 
			and unit:GetUnitName() ~= "npc_dota_creature_new_sprder" and unit:GetUnitName() ~= "npc_dota_creature_new_sprder" then
			if RandomInt(1, 100) <= DROP_ITEM_CHANCE*2 then
				local item_flag = RandomInt(1,DROP_ITEM_COUNT)
		    	local item_drop = CreateItem(DROP_ITEM_LIST[item_flag], attacker, attacker)
		    	--item_drop:LaunchLoot(false, RandomInt(1, 200), RandomInt(200, 400), unit:GetAbsOrigin() )
				CreateItemOnPositionSync(unit:GetAbsOrigin(), item_drop) --[[Returns:handle
				Create a physical item at a given location
				]]
			end
		else
			if RandomInt(1, 100) <= DROP_ITEM_CHANCE then
				local item_flag = RandomInt(1,DROP_ITEM_COUNT)
		    	local item_drop = CreateItem(DROP_ITEM_LIST[item_flag], attacker, attacker)
		    	--item_drop:LaunchLoot(false, RandomInt(1, 200), RandomInt(200, 400), unit:GetAbsOrigin() )
				CreateItemOnPositionSync(unit:GetAbsOrigin(), item_drop) --[[Returns:handle
				Create a physical item at a given location
				]]
			end
		end
		--boss通用部分
		if unit:GetUnitName() == "npc_dota_creature_new_boss_ogre_magi" or unit:GetUnitName() == "npc_dota_creature_new_boss_magnataur" 
			or unit:GetUnitName() == "npc_dota_creature_new_boss_dragon" or unit:GetUnitName() == "npc_dota_creature_new_boss_demo" then
			if RandomInt(1, 100) <= DROP_ITEM_O_CHANCE then
			    local item_drop = CreateItem(DROP_ITEM_LIST[DROP_ITEM_COUNT+1], attacker , attacker)
			    --item_drop:LaunchLoot(false, RandomInt(1, 200), RandomInt(200, 400), unit:GetAbsOrigin() )
				CreateItemOnPositionSync(unit:GetAbsOrigin(), item_drop) --[[Returns:handle
				Create a physical item at a given location
				]]
				item_drop = CreateItem(DROP_ITEM_LIST[DROP_ITEM_COUNT+1], attacker , attacker)
			    --item_drop:LaunchLoot(false, RandomInt(1, 200), RandomInt(200, 400), unit:GetAbsOrigin() )
				CreateItemOnPositionSync(unit:GetAbsOrigin(), item_drop) --[[Returns:handle
				Create a physical item at a given location
				]]
			end
		end
		--roshan部分
		if unit:GetUnitName() == "npc_dota_creature_boss_roshan" then
			if RandomInt(1, 100) <= DROP_ITEM_O_CHANCE then
			    local item_drop = CreateItem(DROP_ITEM_LIST[DROP_ITEM_COUNT+1], attacker , attacker)
			    --item_drop:LaunchLoot(false, RandomInt(1, 200), RandomInt(200, 400), unit:GetAbsOrigin() )
				CreateItemOnPositionSync(unit:GetAbsOrigin(), item_drop) --[[Returns:handle
				Create a physical item at a given location
				]]
			end
		end
	end
	--boss更替
	if unit:GetUnitName() == "npc_dota_creature_new_boss_ogre_magi" then
		GameMode:SetContextThink(DoUniqueString("function_new_boss_2"),
			function (  )
				local creep_entity = Entities:FindByName(nil,"dota_boss_swpan")
				local creep_this = CreateUnitByName("npc_dota_creature_new_boss_magnataur", creep_entity:GetOrigin(), false, nil, nil, DOTA_TEAM_BADGUYS) 
				creep_this:AddNewModifier(nil, nil, "modifier_phased", {duration = 0.1})
				creep_this:CreatureLevelUp(3)
				local text = "<font color='#0033CC'>new boss magnataur spawn!!!</font>"
				GameRules:SendCustomMessage(text, 0, 1)
		end,20)
	end
	if unit:GetUnitName() == "npc_dota_creature_new_boss_magnataur" then
		GameMode:SetContextThink(DoUniqueString("function_new_boss_3"),
			function (  )
				local creep_entity = Entities:FindByName(nil,"dota_boss_swpan")
				local creep_this = CreateUnitByName("npc_dota_creature_new_boss_dragon", creep_entity:GetOrigin(), false, nil, nil, DOTA_TEAM_BADGUYS) 
				creep_this:AddNewModifier(nil, nil, "modifier_phased", {duration = 0.1})
				creep_this:CreatureLevelUp(6)
				local text = "<font color='#0033CC'>new boss Dragon spawn!!!</font>"
				GameRules:SendCustomMessage(text, 0, 1)
		end,20)
	end
	if unit:GetUnitName() == "npc_dota_creature_new_boss_dragon" then
		GameMode:SetContextThink(DoUniqueString("function_new_boss_2"),
			function (  )
				local creep_entity = Entities:FindByName(nil,"dota_boss_swpan")
				local creep_this = CreateUnitByName("npc_dota_creature_new_boss_demo", creep_entity:GetOrigin(), false, nil, nil, DOTA_TEAM_BADGUYS) 
				creep_this:AddNewModifier(nil, nil, "modifier_phased", {duration = 0.1})
				creep_this:CreatureLevelUp(10)
				local text = "<font color='#0033CC'>new boss Demo spawn!!!</font>"
				GameRules:SendCustomMessage(text, 0, 1)
		end,20)
	end
	--野怪重生
	if unit:GetUnitName() == "npc_dota_creature_nian" or unit:GetUnitName() == "npc_dota_creature_black_dragon"
		or unit:GetUnitName() == "npc_dota_creature_ghost" or unit:GetUnitName() == "npc_dota_creature_boss_roshan"
		or unit:GetUnitName() == "npc_dota_creature_sprit_bear" or unit:GetUnitName() == "npc_dota_creature_mech" then
			local point_old = unit.__point
			local name_old = unit:GetUnitName() 
			GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("creep_spawn_old_nw"),
				function (  )
					CreepThink(point_old , name_old)
					return nil
				end,60)
	end
	--游戏胜利标准
	if unit:GetUnitName() == "npc_dota_creature_new_boss_demo" then
		GameRules:SetGameWinner(attacker:GetTeam())
		
	end
end

--监听游戏状态改变
function CLivingGameMode:OnGameRulesStateChange( keys )
	--获取游戏进度
	local newState = GameRules:State_Get() 
	--游戏开始
	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--获取天辉玩家数量
		PLAYER_COUNT_GOODGUYS = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
		--设置刷怪间隔
		CREEP_CREATE_TIME = 4 - math.floor(PLAYER_COUNT_GOODGUYS/2)
		--设置游戏roshan需要击杀数 
		ROSHAN_KILLS_NEED = math.floor(PLAYER_COUNT_GOODGUYS/2 + 1) * 10
		--开启游戏流程
		CLivingGameMode:OnOpen() --游戏提醒
		CreateCreep()		--刷怪
		--刷新第一个boss
		local creep_entity = Entities:FindByName(nil,"dota_boss_swpan")
		local creep_this = CreateUnitByName("npc_dota_creature_new_boss_ogre_magi", creep_entity:GetOrigin(), false, nil, nil, DOTA_TEAM_BADGUYS) 
		--creep_this:SetInitialGoalEntity( creep_entity ) 
		creep_this:AddNewModifier(nil, nil, "modifier_phased", {duration = 0.1})
		creep_this:CreatureLevelUp(0) 
		local text = "<font color='#0033CC'>new boss Ogre_magi spawn!!!</font>"
		GameRules:SendCustomMessage(text, 0, 1)
		--游戏开始刷新野怪
		CreateCre()
	end
end

--监听英雄等级提升
function CLivingGameMode:OnHeroLevelUp ( keys )
	-- 获取玩家实体
  	local player = PlayerInstanceFromIndex( keys.player )
  	-- 获取玩家所使用的英雄
  	local hero = player:GetAssignedHero()

  	-- 获取英雄的等级
  	local level = hero:GetLevel()

  	-- 如果英雄的等级大于25的倍数，那么这个等级就不给技能点
  	if level > 25 then
    	-- 获取现有未分配技能点
    	local p = hero:GetAbilityPoints()
    	-- 减掉这个等级所赋予的技能点
    	hero:SetAbilityPoints(p - 1)
  	end
end
--定时关闭战争迷雾
function CLivingGameMode:CloseFogOfWar( )
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("game_colse_fogofwar"),
		function (  )
			GameRules:GetGameModeEntity():SetFogOfWarDisabled(true) 
			GameRules:SendCustomMessage("战争迷雾关闭,快定位对手位置", 0, 1) 
			--print("OFF")
			GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("game_colse_fogofwar_2"),
				function (  )
					GameRules:GetGameModeEntity():SetFogOfWarDisabled(false)
					GameRules:SendCustomMessage("战争迷雾关闭", 0, 1) 
					--print("ON")
					return nil
				end,10)
			return 60
		end,60)
end

--计时器部分（自动增加经验金钱等）
--[[
function CLivingGameMode:ThisThinker(unit)
	local point_center = Vector(4288,3584,512)
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("game_give_exp"),
		function (  )
			unit:AddExperience(25, 0,false,false)
			if ((unit:GetAbsOrigin()-point_center):Length()) <= 1800 then
				unit:AddExperience(35, 0,false,false)
			end
			if ((unit:GetAbsOrigin()-point_center):Length()) <= 900 then
				unit:AddExperience(40, 0,false,false)
			end
			return 7
		end,1)
end]]

function CLivingGameMode:OnOpen( )
	--[[
	local text0 = "<font color='#FF0000'>how to live?</font>"
	local text1 = "<font color='#0033CC'>你可以在商店查看物品合成公式</font>"
	local text2 = "<font color='#0033CC'>You can see the item compounds method in the shop.</font>"
	local text3 = "<font color='#00CC00'>坚持40分钟并杀死所有肉山以获得游戏胜利</font>"
	local text4 = "<font color='#00CC00'>Persist in 40 minutes,and kill all roshan to win the game</font>"
	local text5 = "<font color='#FF8000'>you need kill "..ROSHAN_KILLS_NEED.." roshan,roshan kills:</font>"..ROSHAN_KILLS
	GameRules:SendCustomMessage(text0, 0, 1)
	GameRules:SendCustomMessage(text1, 0, 1)
	GameRules:SendCustomMessage(text2, 0, 1)
	GameRules:SendCustomMessage(text3, 0, 1)
	GameRules:SendCustomMessage(text4, 0, 1)
	GameRules:SendCustomMessage(text5, 0, 1)
	]]
end
--刷怪函数
function CreateCreep(  )
	--设置刷怪成长
	GameMode:SetContextThink(DoUniqueString("function_CreateCreep_Grow_up"),
		function (  )
			--怪物等级增加
			if CREEP_LEVEL < 40 then
				CREEP_LEVEL = CREEP_LEVEL + 1
			end
			local flag = RandomInt(1, CREEP_SPAWN_COUNT) 
			local creep_entity = Entities:FindByName(nil,CREEP_SPAWN[flag])
			local creep_flag = RandomInt(1, CREEP_TYPE_COUNT) 
			local creep_this = CreateUnitByName("npc_dota_creature_new_boss_renma", creep_entity:GetOrigin(), false, nil, nil, DOTA_TEAM_BADGUYS) 
			--creep_this:SetInitialGoalEntity( creep_entity ) 
			creep_this:AddNewModifier(nil, nil, "modifier_phased", {duration = 0.1})
			creep_this:CreatureLevelUp(CREEP_LEVEL) 
			local creep_skill_level = CREEP_LEVEL+1
			if creep_skill_level > 11 then
				creep_skill_level = 11
			end
			creep_this:FindAbilityByName("creep_lvlup"):SetLevel(creep_skill_level)
			local flag = RandomInt(1, CREEP_SPAWN_COUNT) 
			local creep_entity = Entities:FindByName(nil,CREEP_SPAWN[flag])
			local creep_flag = RandomInt(1, CREEP_TYPE_COUNT) 
			local creep_this = CreateUnitByName("npc_dota_creature_new_boss_xiong", creep_entity:GetOrigin(), false, nil, nil, DOTA_TEAM_BADGUYS) 
			--creep_this:SetInitialGoalEntity( creep_entity ) 
			creep_this:AddNewModifier(nil, nil, "modifier_phased", {duration = 0.1})
			creep_this:CreatureLevelUp(CREEP_LEVEL) 
			local creep_skill_level = CREEP_LEVEL+1
			if creep_skill_level > 11 then
				creep_skill_level = 11
			end
			creep_this:FindAbilityByName("creep_lvlup"):SetLevel(creep_skill_level)
			local flag = RandomInt(1, CREEP_SPAWN_COUNT) 
			local creep_entity = Entities:FindByName(nil,CREEP_SPAWN[flag])
			local creep_flag = RandomInt(1, CREEP_TYPE_COUNT) 
			local creep_this = CreateUnitByName("npc_dota_creature_new_boss_lang", creep_entity:GetOrigin(), false, nil, nil, DOTA_TEAM_BADGUYS) 
			--creep_this:SetInitialGoalEntity( creep_entity ) 
			creep_this:AddNewModifier(nil, nil, "modifier_phased", {duration = 0.1})
			creep_this:CreatureLevelUp(CREEP_LEVEL) 
			local creep_skill_level = CREEP_LEVEL+1
			if creep_skill_level > 11 then
				creep_skill_level = 11
			end
			creep_this:FindAbilityByName("creep_lvlup"):SetLevel(creep_skill_level)
			return 160
		end,160)
	--刷怪
	GameMode:SetContextThink(DoUniqueString("function_CreateCreep"),
		function (  )
			--判断是否达到怪物上限
			if CURRENT_CREEP_COUNT >= MAX_CREEP_COUNT then
				--print(CURRENT_CREEP_COUNT)
				--print(MAX_CREEP_COUNT)
				return 10
			end
			local flag = RandomInt(1, CREEP_SPAWN_COUNT) 
			local creep_entity = Entities:FindByName(nil,CREEP_SPAWN[flag])
			local creep_flag = RandomInt(1, CREEP_TYPE_COUNT) 
			local creep_this = CreateUnitByName(CREEP_UNIT[creep_flag], creep_entity:GetOrigin(), false, nil, nil, DOTA_TEAM_BADGUYS) 
			--creep_this:SetInitialGoalEntity( creep_entity ) 
			creep_this:AddNewModifier(nil, nil, "modifier_phased", {duration = 0.1})
			creep_this:CreatureLevelUp(CREEP_LEVEL) 
			local creep_skill_level = CREEP_LEVEL+1
			if creep_skill_level > 11 then
				creep_skill_level = 11
			end
			creep_this:FindAbilityByName("creep_lvlup"):SetLevel(creep_skill_level)
			--测试附加代码
			--结束
			return CREEP_CREATE_TIME
		end,0)
end

--创建所有野怪
--变量
CREEP_OLD_SPWAN = {
	"creep_nian_01" ,
	"creep_nian_02" ,
	"creep_nian_03" ,
	"creep_nian_04" ,
	"creep_nian_05" ,
	"creep_nian_06" ,
	"creep_nian_07" ,
	"creep_nian_08" ,
	"creep_nian_09" ,
	"creep_nian_10" ,
	"creep_ghost_01" ,
	"creep_ghost_02" ,
	"creep_ghost_03" ,
	"creep_ghost_04" ,
	"creep_ghost_05" ,
	"creep_ghost_06" ,
	"creep_ghost_07" ,
	"creep_ghost_08" ,
	"creep_ghost_09" ,
	"creep_ghost_10" ,
	"creep_ghost_11" ,
	"creep_ghost_12" ,
	"creep_ghost_13" ,
	"creep_ghost_14" ,
	"creep_ghost_15" ,
	"creep_ghost_16" ,
	"creep_ghost_17" ,
	"creep_ghost_18" ,
	"creep_ghost_19" ,
	"creep_ghost_20" ,
	"creep_ghost_21" ,
	"creep_ghost_22" ,
	"creep_ghost_23" ,
	"creep_ghost_24" ,
	"creep_ghost_25" ,
	"creep_ghost_26" ,
	"creep_ghost_27" ,
	"creep_black_01" ,
	"creep_black_02" ,
	"creep_black_03" ,
	"creep_black_04" ,
	"creep_black_05" ,
	"creep_black_06" ,
	"creep_black_07" ,
	"creep_black_08" ,
	"creep_black_09" ,
	"creep_black_10" ,
	"creep_black_11" ,
	"creep_black_12" ,
	"creep_black_13" ,
	"creep_black_14" ,
	"creep_black_15" ,
	"creep_bear_01" ,
	"creep_bear_02" ,
	"creep_bear_03" ,
	"creep_bear_04" ,
	"creep_bear_05" ,
	"creep_bear_06" ,
	"creep_bear_07" ,
	"creep_bear_08" ,
	"creep_mech_01" ,
	"creep_mech_02" ,
	"creep_mech_03" ,
	"creep_mech_04" ,
	"creep_mech_05" ,
	"creep_mech_06" ,
	"creep_roshan_01" 

}
function CreateCre(  )
	for i,entity_str in pairs(CREEP_OLD_SPWAN) do
		local creep_entity = Entities:FindByName(nil,entity_str)
		local point = creep_entity:GetOrigin() 
		entity_str = string.sub(entity_str,1,10)
		if entity_str == "creep_nian" then
			local unit_name = "npc_dota_creature_nian" 
			local creep_this = CreateUnitByName(unit_name, point, false, nil, nil, DOTA_TEAM_BADGUYS) 
			--creep_this:SetInitialGoalEntity( creep_entity ) 
			creep_this:AddNewModifier(nil, nil, "modifier_phased", {duration = 0.1})
			creep_this:CreatureLevelUp(CREEP_LEVEL) 
			creep_this.__point = point
		elseif entity_str == "creep_ghos" then
			local unit_name = "npc_dota_creature_ghost" 
			local creep_this = CreateUnitByName(unit_name, point, false, nil, nil, DOTA_TEAM_BADGUYS) 
			--creep_this:SetInitialGoalEntity( creep_entity ) 
			creep_this:AddNewModifier(nil, nil, "modifier_phased", {duration = 0.1})
			creep_this:CreatureLevelUp(CREEP_LEVEL) 
			creep_this.__point = point
		elseif entity_str == "creep_blac" then
			local unit_name = "npc_dota_creature_black_dragon" 
			local creep_this = CreateUnitByName(unit_name, point, false, nil, nil, DOTA_TEAM_BADGUYS) 
			--creep_this:SetInitialGoalEntity( creep_entity ) 
			creep_this:AddNewModifier(nil, nil, "modifier_phased", {duration = 0.1})
			creep_this:CreatureLevelUp(CREEP_LEVEL) 
			creep_this.__point = point
		elseif entity_str == "creep_bear" then
			local unit_name = "npc_dota_creature_sprit_bear" 
			local creep_this = CreateUnitByName(unit_name, point, false, nil, nil, DOTA_TEAM_BADGUYS) 
			--creep_this:SetInitialGoalEntity( creep_entity ) 
			creep_this:AddNewModifier(nil, nil, "modifier_phased", {duration = 0.1})
			creep_this:CreatureLevelUp(CREEP_LEVEL) 
			creep_this.__point = point
		elseif entity_str == "creep_mech" then
			local unit_name = "npc_dota_creature_mech" 
			local creep_this = CreateUnitByName(unit_name, point, false, nil, nil, DOTA_TEAM_BADGUYS) 
			--creep_this:SetInitialGoalEntity( creep_entity ) 
			creep_this:AddNewModifier(nil, nil, "modifier_phased", {duration = 0.1})
			creep_this:CreatureLevelUp(CREEP_LEVEL) 
			creep_this.__point = point
		elseif entity_str == "creep_rosh" then
			local unit_name = "npc_dota_creature_boss_roshan" 
			local creep_this = CreateUnitByName(unit_name, point, false, nil, nil, DOTA_TEAM_BADGUYS) 
			--creep_this:SetInitialGoalEntity( creep_entity ) 
			creep_this:AddNewModifier(nil, nil, "modifier_phased", {duration = 0.1})
			creep_this:CreatureLevelUp(CREEP_LEVEL) 
			creep_this.__point = point
		end
	end
	return nil
end
--重生野怪
function CreepThink(point_old , name_old)
	local point = point_old
	local unit_name = name_old
	local creep_this = CreateUnitByName(unit_name, point, false, nil, nil, DOTA_TEAM_BADGUYS) 
	--creep_this:SetInitialGoalEntity( creep_entity ) 
	creep_this:AddNewModifier(nil, nil, "modifier_phased", {duration = 0.1})
	creep_this:CreatureLevelUp(CREEP_LEVEL) 
	creep_this.__point = point
	return nil
end
flag111 = 1
function RandomTeam( unit )
	if flag111 ~= 1 then
		return nil
	end
	flag111 = 0
	local playerID = unit:GetPlayerID()
	print(playerID)
	print("now team ID")
	print(PlayerResource:GetCustomTeamAssignment(playerID))
	--PlayerResource:SetCustomTeamAssignment(playerID , DOTA_TEAM_BADGUYS)
	unit:GetPlayerOwner():SetTeam(DOTA_TEAM_BADGUYS)
	unit:SetTeam(DOTA_TEAM_BADGUYS)
	print(PlayerResource:GetCustomTeamAssignment(playerID))
     
end