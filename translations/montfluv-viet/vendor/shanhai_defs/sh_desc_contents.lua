
local sh_lan = TUNING.SHANHE_LAN or "ch"
local desc_name = "sh_desc_"..sh_lan
local desc_file = "shanhai_defs/"..desc_name
local desc_contents = require(desc_file)

local sh_desc_contents = 
{

	------------------------------------------------
	-- 机制+地形
	------------------------------------------------

	["generation"] = 
	{
		shanhai_deepseacave = {
			priority = 1.1,
			desc_build = "sh_islands",
			desc_bank = "sh_islands",
			desc_anim = "dsc",
			resize = 1.2,
			y_offset = 45,
		},
		shanhai_deepseacave_two = {
			priority = 1.2,
			desc_build = "sh_islands",
			desc_bank = "sh_islands",
			desc_anim = "dsc_2",
			-- resize = 0.9,
			y_offset = 45,
		},
		deepseacave_pool = {
			priority = 1.3,
			desc_build = "deepseacave_pool",
			desc_bank = "deepseacave_pool",
			desc_anim = "idle",
			resize = 0.5,
			y_offset = 45,
		},
		deepseacave_exit = {
			priority = 1.4,
			desc_build = "dsc_exit",
			desc_bank = "dsc_exit",
			desc_anim = "idle",
			resize = 0.9,
			y_offset = -30,
			skins = {
				{
					fn = function(item_anim)
						item_anim:GetAnimState():Show("hay")
					end
				},
				{
					fn = function(item_anim)
						item_anim:GetAnimState():Hide("hay")
					end
				},
			},
		},
		sh_tictactoe_game = {
			priority = 1.4,
			desc_build = "sh_tictactoe_board",
			desc_bank = "sh_tictactoe_board",
			desc_anim = "idle",
			resize = 1.3,
			y_offset = 40,
		},
		shanhai_hiddenexit = {
			priority = 1.5,
			desc_build = "farm_decor",
			desc_bank = "farm_decor",
			desc_anim = "1",
			resize = 1.5,
			y_offset = 0,
		},
		shanhai_kunlunisland = {
			priority = 2.1,
			desc_build = "sh_islands",
			desc_bank = "sh_islands",
			desc_anim = "kunlun",
			resize = 1.2,
			y_offset = 50,
		},
		shanhai_secretplace = {
			priority = 2.2,
			desc_build = "sh_zhulong_base",
			desc_bank = "sh_zhulong_base",
			desc_anim = "idle",
			resize = 0.7,
			y_offset = 45,
		},
		shanhai_secretorder = {
			priority = 2.3,
			desc_build = "shanhai_secretorder",
			desc_bank = "shanhai_secretorder",
			desc_anim = "desc",
			resize = 2,
			y_offset = 40,
			skins = {
				{
					fn = function(item_anim)
						item_anim:GetAnimState():ClearOverrideSymbol("symbol0")
					end
				},
				{
					fn = function(item_anim)
						item_anim:GetAnimState():OverrideSymbol("symbol0",  "shanhai_secretorder", "shang")
					end
				},
				{
					fn = function(item_anim)
						item_anim:GetAnimState():OverrideSymbol("symbol0",  "shanhai_secretorder", "jue")
					end
				},
				{
					fn = function(item_anim)
						item_anim:GetAnimState():OverrideSymbol("symbol0",  "shanhai_secretorder", "zhi")
					end
				},
				{
					fn = function(item_anim)
						item_anim:GetAnimState():OverrideSymbol("symbol0",  "shanhai_secretorder", "yu")
					end
				},
				{
					fn = function(item_anim)
						item_anim:GetAnimState():OverrideSymbol("symbol0",  "shanhai_secretorder", "submit")
					end
				},
			},
		},
		sh_zhuyan_spawner = {
			priority = 2.4,
			desc_build = "zhuyan_mountain",
			desc_bank = "zhuyan_mountain",
			desc_anim = "idle",
			-- resize = 0.9,
			y_offset = -40,
		},
		-- dsc_light = {
		-- 	priority = 4,
		-- 	desc_build = "sh_fire",
		-- 	desc_bank = "sh_fire",
		-- 	desc_anim = "loop",
		-- 	y_offset = 0,
		-- 	speed = 0.7,
		-- },
		xuanhe_fall = {
			priority = 2.5,
			desc_build = "xuanhe_fall",
			desc_bank = "xuanhe_fall",
			desc_anim = "idle",
			resize = 0.5,
			y_offset = -50,
			speed = 0.5,
		},
		xuanhe_pond = {
			priority = 3.1,
			desc_build = "shanhai_pond",
			desc_bank = "shanhai_pond",
			desc_anim = "phase_3",
			speed = 0.5,
			resize = 0.8,
			y_offset = -20,
			skins = {
				{
					fn = function(item_anim)
						item_anim:GetAnimState():PlayAnimation("phase_3", true)
					end
				},
				{
					fn = function(item_anim)
						item_anim:GetAnimState():PlayAnimation("idle", true)
					end
				},
				{
					fn = function(item_anim)
						item_anim:GetAnimState():PlayAnimation("phase_1", true)
					end
				},
				{
					fn = function(item_anim)
						item_anim:GetAnimState():PlayAnimation("phase_2", true)
					end
				},
			},
		},
		sh_abysspillar = {
			priority = 3.2,
			desc_build = "sh_abysspillar",
			desc_bank = "sh_abysspillar",
			desc_anim = "idle_a",
			resize = 1.5,
			y_offset = 30,
			skins = {
				{
					name = "sh_abysspillar",
					fn = function(item_anim)
						item_anim:GetAnimState():SetBank("sh_abysspillar")
						item_anim:GetAnimState():SetBuild("sh_abysspillar")
					end
				},
				{
					name = "sh_abysspillar_stone_1",
					rarity = "Rare",
					fn = function(item_anim)
						item_anim:GetAnimState():SetBank("sh_abysspillar_stone_1")
						item_anim:GetAnimState():SetBuild("sh_abysspillar_stone_1")
					end
				},
				{
					name = "sh_abysspillar_stone_2",
					rarity = "Rare",
					fn = function(item_anim)
						item_anim:GetAnimState():SetBank("sh_abysspillar_stone_2")
						item_anim:GetAnimState():SetBuild("sh_abysspillar_stone_2")
					end
				},
				{
					name = "sh_abysspillar_lotus",
					rarity = "Rare",
					fn = function(item_anim)
						item_anim:GetAnimState():SetBank("sh_abysspillar_lotus")
						item_anim:GetAnimState():SetBuild("sh_abysspillar_lotus")
					end
				},
			},
		},
		sh_marsh_plant = {
			priority = 3.31,
			desc_build = "marsh_plant",
			desc_bank = "marsh_plant",
			desc_anim = "idle",
			resize = 1.5,
			y_offset = 0,
		},
		sh_pond_algae = {
			priority = 3.32,
			desc_build = "pond_plant_cave",
			desc_bank = "pond_rock",
			desc_anim = "idle",
			resize = 1.5,
			y_offset = 0,
		},
		sh_seastack = {
			priority = 3.33,
			desc_build = "water_rock_01",
			desc_bank = "water_rock01",
			desc_anim = "1_full",
			oversymbolfn = function(item_anim)
				item_anim:GetAnimState():Hide("paint_a")
			    item_anim:GetAnimState():Hide("paint_b")
			end,
			y_offset = -40,
			skins = {
				{
					fn = function(item_anim)
						item_anim:GetAnimState():PlayAnimation("1_full")
					end
				},
				{
					fn = function(item_anim)
						item_anim:GetAnimState():PlayAnimation("2_full")
					end
				},
				{
					fn = function(item_anim)
						item_anim:GetAnimState():PlayAnimation("3_full")
					end
				},
				{
					fn = function(item_anim)
						item_anim:GetAnimState():PlayAnimation("4_full")
					end
				},
				{
					fn = function(item_anim)
						item_anim:GetAnimState():PlayAnimation("5_full")
					end
				},
			},
		},
		sh_fly = {
			priority = 3.4,
			desc_build = "wilson",
			desc_bank = "wilson",
			desc_anim = "sh_broom_fly",
			y_offset = -20,
			resize = 1.3,
			oversymbolfn = function(item_anim)
				item_anim:GetAnimState():OverrideSymbol("swap_object", "sh_magicshanshen", "swap_sh_migutwig")
			end,
			facing = FACING_RIGHT,
		},
		sh_boat = {
			priority = 3.5,
			desc_build = "sh_boat",
			desc_bank = "sh_boat",
			desc_anim = "run_loop",
			y_offset = -20,
			resize = 1,
			facing = FACING_RIGHT,
		},
		sh_cookpotfire = {
			priority = 4.1,
			desc_build = "cook_pot",
			desc_bank = "sh_cookpotfire",
			desc_anim = "cooking_loop",
			-- y_offset = -20,
			oversymbolfn = function(item_anim)
				item_anim:GetAnimState():OverrideSymbol("flames_wide", "sh_cookpotfire", "flames_wide")
			end,
			resize = 1.3,
			skins = {
				{
					fn = function(item_anim)
						item_anim:GetAnimState():ClearOverrideSymbol("lid")
						item_anim:GetAnimState():ClearOverrideSymbol("pot")
						item_anim:GetAnimState():ClearOverrideSymbol("coals")
						item_anim:GetAnimState():ClearOverrideSymbol("wood")
					end
				},
				{
					fn = function(item_anim)
						item_anim:GetAnimState():OverrideSymbol("lid",  "cookpot_archive", "lid")
						item_anim:GetAnimState():OverrideSymbol("pot",  "cookpot_archive", "pot")
						item_anim:GetAnimState():OverrideSymbol("coals",  "cookpot_archive", "coals")
						item_anim:GetAnimState():OverrideSymbol("wood",  "cookpot_archive", "wood")
					end
				},
			},
		},	
	},


	------------------------------------------------
	-- 生物+群落
	------------------------------------------------

	["mobs"] = 
	{
		deepseacave_pigman = {
			priority = 0.9,
			friendly = true,
			location = "洞天塔",
			desc_build = "pig_guard_build",
			desc_bank = "pigman",
			desc_anim = "pose1_loop",
			resize = 1.7,
			speed = 0.7,
			y_offset = -35,
		},
		deepseacave_crow = {
			priority = 1,
			friendly = true,
			location = "洞天塔",
			desc_build = "crow_kids",
			desc_bank = "crow_kids",
			desc_override_build = "shanhai_crow_build",
			desc_anim = "idle",
			resize = 1.2,
			speed = 0.9,
			oversymbolfn = function(item_anim)
				item_anim:GetAnimState():OverrideSymbol("left_wing",  "shanhai_crow_build", "shanhai_left_wing")
			    item_anim:GetAnimState():OverrideSymbol("right_wing", "shanhai_crow_build", "shanhai_right_wing")
			    item_anim:GetAnimState():OverrideSymbol("tail",       "shanhai_crow_build", "shanhai_tail")
			    item_anim:GetAnimState():OverrideSymbol("head",       "shanhai_crow_build", "shanhai_head")
		        item_anim:GetAnimState():OverrideSymbol("scarf_1",    "shanhai_crow_build", "shanhai_scarf_2")
			end,
			skins = {
				{
					name = "SH_CROW_MOON",
					rarity = "Legendary",
					fn = function(item_anim)
						item_anim:GetAnimState():OverrideSymbol("scarf_1",    "shanhai_crow_build", "shanhai_scarf_2")
				    end
				},
				{
					name = "SH_CROW_GOUMANG",
					rarity = "Legendary",
					fn = function(item_anim)
				        item_anim:GetAnimState():OverrideSymbol("scarf_1",    "shanhai_crow_build", "shanhai_scarf")
				    end
				},
			},
			facing = FACING_DOWNRIGHT,
			y_offset = 0,
		},
		dsc_elderswampig = {
			priority = 1.1,
			friendly = true,
			location = "洞天塔",
			desc_build = "quagmire_elderswampig",
			desc_bank = "quagmire_elderswampig",
			desc_anim = "idle",
			resize = 0.8,
			speed = 0.9,
			y_offset = 0,
		},
		shanhai_zhuyan = {
			priority = 2,
			friendly = false,
			location = "小次山",
			desc_build = "sh_zhuyan",
			desc_bank = "sh_zhuyan",
			desc_anim = "idle_loop",
			speed = 0.8,
			resize = 0.8,
			facing = FACING_DOWN,
			y_offset = -60,
		},
		kun_rider = {
			priority = 3,
			friendly = true,
			location = "昆仑龙脉",
			desc_build = "kun_test",
			desc_bank = "kun_test",
			desc_anim = "idle",
			speed = 0.4,
			y_offset = 0,
		},
		sh_qinyuan = {
			priority = 4,
			friendly = true,
			location = "永恒大陆",
			desc_build = "sh_qinyuan",
			desc_bank = "sh_qinyuan",
			desc_anim = "idle_loop",
			y_offset = -120,
		},
		sh_paperbird = {
			priority = 5,
			friendly = true,
			location = "桦树林",
			desc_build = "sh_paperbird_build",
			desc_bank = "sh_paperbird",
			desc_anim = "idle",
			resize = 1.5,
			y_offset = 0,
		},
		deepseacave_fish = {
			priority = 5,
			friendly = true,
			location = "洞天塔",
			desc_build = "dsc_fish",
			desc_bank = "dsc_fish",
			desc_anim = "yu_idle",
			resize = 1.2,
			speed = 0.5,
			y_offset = 40,
			x_offset = 20,
		},
		sh_fishspawner = {
			priority = 5,
			friendly = true,
			location = "洞天塔",
			desc_build = "fishSchool",
			desc_bank = "fishSchool",
			desc_anim = "idle_loop_full",
			resize = 0.4,
			y_offset = 50,
			x_offset = -30,
		},
		shanhai_phoenix = {
			priority = 5,
			friendly = true,
			location = "永恒大陆",
			desc_build = "shanhai_phoenix",
			desc_bank = "shanhai_phoenix",
			desc_anim = "flap",
			resize = 0.1,
			speed = 0.6,
			y_offset = 40,
			x_offset = 20,
		},
		sh_migutree = {
			priority = 6,
			friendly = true,
			location = "蜂后区域",
			desc_build = "sh_migutree",
			desc_bank = "sh_migutree",
			desc_anim = "idle",
			resize = 0.8,
			y_offset = -40,
		},
		dsc_oceantree_pillar = {
			priority = 6,
			friendly = true,
			location = "洞天塔",
			desc_build = "dsc_watertree_basic",
			desc_bank = "dsc_watertree",
			desc_anim = "idle",
			desc_override_build = "dsc_watertreeot01",
			y_offset = -40,
			resize = 0.4,
		},
		shanhai_goumang_plant = {
			priority = 7,
			friendly = true,
			location = "昆仑龙脉、洞天塔",
			desc_build = "shanhai_goumang",
			desc_bank = "shanhai_goumang",
			desc_anim = "idle",
			speed = 0.9,
			y_offset = -50,
			skins = {
				{
					fn = function(item_anim)
						item_anim:GetAnimState():PlayAnimation("grow")
						item_anim:GetAnimState():PushAnimation("idle", true)
				    end
				},
				{
					fn = function(item_anim)
				        item_anim:GetAnimState():PlayAnimation("picked")
				        item_anim:GetAnimState():PushAnimation("normal", true)
				    end
				},
				{
					fn = function(item_anim)
				        item_anim:GetAnimState():PlayAnimation("normal_to_dead")
				        item_anim:GetAnimState():PushAnimation("dead")
				    end
				},
				{
					fn = function(item_anim)
				        item_anim:GetAnimState():PlayAnimation("dead_to_normal")
				        item_anim:GetAnimState():PushAnimation("normal", true)
				    end
				},
			},
		},
		shanhai_shanshen_planted = {
			priority = 8,
			friendly = true,
			location = "昆仑龙脉、洞天塔",
			desc_build = "shanhai_shanshen",
			desc_bank = "shanhai_shanshen",
			desc_anim = "ground",
			resize = 1.5,
			speed = 0.8,
			y_offset = 0,
		},
		shanhai_xirang = {
			priority = 9,
			friendly = true,
			location = "昆仑龙脉",
			desc_build = "shanhai_xirang",
			desc_bank = "shanhai_xirang",
			desc_anim = "idle",
			speed = 0.8,
			y_offset = 10,
		},
		shanhai_ginkgo_tree = {
			priority = 10,
			friendly = true,
			location = "昆仑龙脉",
			desc_build = "shanhai_ginkgo_tree",
			desc_bank = "shanhai_ginkgo_tree",
			desc_anim = "sway2_loop_tall_yellow",
			speed = 0.7,
			y_offset = -40,
			skins = {
				{
					fn = function(item_anim)
						item_anim:GetAnimState():PlayAnimation("grow_tall_to_tall_yellow")
						item_anim:GetAnimState():PushAnimation("sway2_loop_tall_yellow", true)
				    end
				},
				{
					fn = function(item_anim)
				        item_anim:GetAnimState():PlayAnimation("grow_tall_yellow_to_short")
				        item_anim:GetAnimState():PushAnimation("sway2_loop_short", true)
				    end
				},
				{
					fn = function(item_anim)
				        item_anim:GetAnimState():PlayAnimation("grow_short_to_normal")
				        item_anim:GetAnimState():PushAnimation("sway2_loop_normal", true)
				    end
				},
				{
					fn = function(item_anim)
				        item_anim:GetAnimState():PlayAnimation("grow_normal_to_tall")
				        item_anim:GetAnimState():PushAnimation("sway2_loop_tall", true)
				    end
				},
			},
		},
		shanhai_ganoderma = {
			priority = 11,
			friendly = false,
			location = "昆仑龙脉",
			desc_build = "shanhai_mushrooms",
			desc_bank = "shanhai_mushrooms",
			desc_anim = "ganoderma",
			resize = 1.5,
			y_offset = 0,
			skins = {
				{
					fn = function(inst)
						inst:GetAnimState():PlayAnimation("open_inground")
						inst:GetAnimState():PushAnimation("open_ganoderma")
						inst:GetAnimState():PushAnimation("ganoderma")
					end
				},
				{
					fn = function(inst)
						inst:GetAnimState():PlayAnimation("close_ganoderma")
						inst:GetAnimState():PushAnimation("inground")
					end
				},	
			},
		},
		shanhai_mushroomguard2 = {
			priority = 12,
			friendly = true,
			location = "昆仑龙脉",
			desc_build = "deer_antler",
			desc_bank = "deer_antler",
			desc_anim = "planted1",
			resize = 1,
			y_offset = 0,
			skins = {
				{
					fn = function(inst)
						inst:GetAnimState():PlayAnimation("planted1")
					end
				},
				{
					fn = function(inst)
						inst:GetAnimState():PlayAnimation("planted2")
					end
				},
				{
					fn = function(inst)
						inst:GetAnimState():PlayAnimation("planted3")
					end
				},	
			},
		},
		sh_flower = {
			priority = 13,
			friendly = true,
			location = "昆仑龙脉",
			desc_build = "sh_flowers",
			desc_bank = "sh_flowers",
			desc_anim = "f3",
			resize = 1.5,
			y_offset = -20,
			skins = {
				{
					name = "SH_FLOWER_WHITE",
					fn = function(item_anim)
						item_anim:GetAnimState():PlayAnimation("f3")
				    end
				},
				{
					name = "SH_FLOWER_ORANGE",
					fn = function(item_anim)
				        item_anim:GetAnimState():PushAnimation("f1")
				    end
				},
				{
					name = "SH_FLOWER_YELLOW",
					fn = function(item_anim)
				        item_anim:GetAnimState():PushAnimation("f2")
				    end
				},
			},
		},
		shanhai_orangefly = {
			priority = 13.1,
			friendly = true,
			location = "昆仑龙脉",
			desc_build = "shanhai_orangefly",
			desc_bank = "shanhai_orangefly",
			desc_anim = "idle_flight_loop",
			resize = 1.5,
			y_offset = -20,
			speed = 0.7,
			skins = {
				{
					fn = function(item_anim)
						item_anim:GetAnimState():SetBuild("shanhai_orangefly")
				    end
				},
				{
					fn = function(item_anim)
						item_anim:GetAnimState():SetBuild("shanhai_greenfly")
				    end
				},
			},
		},
		shanhai_flowervine = {
			priority = 13.2,
			friendly = true,
			location = "洞天塔",
			desc_build = "shanhai_flowervine",
			desc_bank = "shanhai_flowervine",
			desc_anim = "idle_1",
			y_offset = -150,
			resize = 0.7,
			skins = {
				{
					name = "shanhai_flowervine",
					fn = function(item_anim)
						item_anim:GetAnimState():SetBuild("shanhai_flowervine")
						item_anim:GetAnimState():SetBank("shanhai_flowervine")
				    end
				},
				{
					name = "shanhai_flowervine_1",
					rarity = "Rare",
					fn = function(item_anim)
						item_anim:GetAnimState():SetBuild("shanhai_flowervine_1")
						item_anim:GetAnimState():SetBank("shanhai_flowervine_1")
				    end
				},
				{
					name = "shanhai_flowervine_2",
					rarity = "Rare",
					fn = function(item_anim)
						item_anim:GetAnimState():SetBuild("shanhai_flowervine_2")
						item_anim:GetAnimState():SetBank("shanhai_flowervine_2")
				    end
				},
			},
		},
		shanhaivine_moon = {
			priority = 14,
			friendly = true,
			location = "洞天塔",
			desc_build = "shanhai_decovine",
			desc_bank = "shanhai_decovine",
			desc_anim = "idle_fruit",
			resize = 1.1,
			y_offset = -110,
			speed = 0.7,
			skins = {
				{
					name = "shanhai_decovine",
					fn = function(item_anim)
						item_anim:GetAnimState():SetBuild("shanhai_decovine")
						item_anim:GetAnimState():SetBank("shanhai_decovine")
				    end
				},
				{
					name = "shanhai_decovine2",
					rarity = "Rare",
					fn = function(item_anim)
						item_anim:GetAnimState():SetBuild("shanhai_decovine2")
						item_anim:GetAnimState():SetBank("shanhai_decovine2")
				    end
				},
				{
					name = "shanhai_decovine3",
					rarity = "Rare",
					fn = function(item_anim)
						item_anim:GetAnimState():SetBuild("shanhai_decovine3")
						item_anim:GetAnimState():SetBank("shanhai_decovine3")
				    end
				},
				
			},
		},
		shanhaivine_gem = {
			priority = 14.1,
			friendly = true,
			location = "洞天塔",
			desc_build = "sh_oceanvine",
			desc_bank = "sh_oceanvine",
			desc_override_build = "sh_vinegem_build",
			desc_anim = "idle_fruit",
			resize = 1.1,
			y_offset = -110,
			speed = 0.7,
		},
		shanhaivine_night = {
			priority = 14.2,
			friendly = true,
			location = "洞天塔",
			desc_build = "sh_oceanvine",
			desc_bank = "sh_oceanvine",
			desc_override_build = "sh_vinenight_build",
			desc_anim = "idle_fruit",
			resize = 1.1,
			y_offset = -110,
			speed = 0.7,
		},
		dsc_eggvine = {
			priority = 14.3,
			friendly = true,
			location = "洞天塔",
			desc_build = "sh_oceanvine",
			desc_bank = "sh_oceanvine",
			desc_override_build = "dsc_eggvine_build",
			desc_anim = "idle_fruit",
			resize = 1.1,
			y_offset = -110,
			speed = 0.7,
		},
	},

	------------------------------------------------
	-- 雕塑建筑
	------------------------------------------------

	["structures"] =
	{
		statue_chaofeng = {
			priority = 1,
			desc_build = "statue_chaofeng",
			desc_bank = "statue_chaofeng",
			desc_anim = "idle",
			resize = 0.8,
			y_offset = -40,
			type = "雕塑",
			recipe = {
				{"opalpreciousgem", 1},
				{"featherhat", 1},
				{"marble", 3},
			},
		},
		statue_zhulong = {
			priority = 1,
			desc_build = "statue_zhulong",
			desc_bank = "statue_zhulong",
			desc_anim = "idle",
			oversymbolfn = function(item_anim)
				item_anim:GetAnimState():OverrideSymbol("statue", "statue_zhulong", "eyesopen")
		    end,
			resize = 0.8,
			y_offset = -35,
			type = "雕塑",
			recipe = {
				{"purplegem", 5},
				{"dragon_scales", 1},
				{"marble", 3},
			},
		},
		statue_niepan = {
			priority = 2,
			desc_build = "statue_niepan",
			desc_bank = "statue_niepan",
			desc_anim = "idle",
			resize = 0.8,
			y_offset = -30,
			type = "雕塑",
			recipe = {
				{"redgem", 5},
				{"shanhai_goumang_item", 3},
				{"charcoal", 3},
			},
		},
		statue_eatmoon = {
			priority = 3,
			desc_build = "statue_eatmoon",
			desc_bank = "statue_eatmoon",
			desc_anim = "light",
			y_offset = -30,
			type = "雕塑",
			recipe = {
				{"moonrocknugget", 3},
				{"houndstooth", 3},
				{"marble", 3},
			},
		},
		sh_cherrystatue = {
			priority = 4,
			desc_build = "sh_cherrystatue",
			desc_bank = "sh_statue",
			desc_anim = "idle",
			resize = 0.9,
			y_offset = -30,
			type = "雕塑",
			recipe = {
				{"fig", 1},
				{"feather_crow", 1},
				{"marble", 1},
			},
		},
		sh_seasonaquarium = {
			priority = 5,
			desc_build = "sh_seasonaquarium",
			desc_bank = "sh_seasonaquarium",
			desc_override_build = "oceanfish_small_7",
			desc_anim = "fish_idle",
			y_offset = -30,
			type = "建筑",
			recipe = {
				{"log", 2},
				{"shanhai_goumang", 3},
				{"ice", 3},
			},
		},
		deepseacave_pighouse = {
			priority = 6,
			desc_build = "dsc_pighouse",
			desc_bank = "dsc_pighouse",
			desc_anim = "idle",
			resize = 0.8,
			y_offset = -40,
			type = "建筑",
		},
		dsc_pig_shop = {
			priority = 6,
			desc_build = "dscpig_shop",
			desc_bank = "dscpig_shop",
			desc_anim = "idle_pig",
			-- resize = 0.8,
			y_offset = -40,
			type = "建筑",
			recipe = {
				{"boards", 10},
				{"cutgrass", 10},
				{"goldnugget", 5},
			},
		},
		shanhai_shellchest = {
			priority = 7,
			desc_build = "shanhai_shellchest",
			desc_bank = "shanhai_shellchest",
			desc_anim = "unlock_closed",
			y_offset = -10,
			type = "箱子",
			recipe = {
				{"rope", 2},
				{"slurtle_shellpieces", 4},
			},
		},
		shanhai_hiddencellar_use = {
			priority = 8,
			desc_build = "shanhai_hiddencellar",
			desc_bank = "shanhai_hiddencellar",
			desc_anim = "closed",
			resize = 1.3,
			y_offset = 20,
			type = "箱子",
			recipe = {
				{"cutstone", 3},
			},
		},
		sh_rock_1 = {
			priority = 9,
			desc_build = "sh_rock_1",
			desc_bank = "sh_rock_1",
			desc_anim = "idle",
			y_offset = -10,
			type = "装饰",
			recipe = {
				{"rocks", 3},
				{"flint", 3},
			},
			skins = {
				{
					name = "sh_rock_1",
					fn = function(item_anim)
						item_anim:GetAnimState():SetBank("sh_rock_1")
						item_anim:GetAnimState():SetBuild("sh_rock_1")
					end
				},
				{
					name = "sh_rock_2",
					rarity = "Rare",
					fn = function(item_anim)
						item_anim:GetAnimState():SetBank("sh_rock_2")
						item_anim:GetAnimState():SetBuild("sh_rock_2")
					end
				},
			},
		},
		sh_basefan = {
			priority = 10,
			desc_build = "sh_basefan",
			desc_bank = "sh_basefan",
			desc_anim = "idle_loop",
			resize = 1.5,
			y_offset = -10,
			type = "装饰",
			recipe = {
				{"transistor", 2},
				{"gears", 1},
				{"minifan", 1},
			},
		},
		sh_ironopenwork_base = {
			priority = 11,
			desc_tex = "sh_ironopenwork_base_kit.tex",
			desc_atlas = "images/inventoryimages/sh_items.xml",
			desc_build = "sh_ironopenwork_base",
			desc_bank = "sh_ironopenwork_base",
			desc_anim = "place",
			resize = 1.3,
			speed = 0.6,
			y_offset = -10,
			type = "装饰",
			recipe = {
				{"twigs", 2},
				{"nitre", 1},
				{"charcoal", 2},
			},
		},
		-- sh_seanest = {
		-- 	priority = 12,
		-- 	desc_tex = "sh_seanest_kit.tex",
		-- 	desc_atlas = "images/inventoryimages/sh_items.xml",
		-- 	desc_build = "sh_seanest",
		-- 	desc_bank = "sh_seanest",
		-- 	desc_anim = "idle",
		-- 	resize = 0.6,
		-- 	y_offset = -40,
		-- 	type = "建筑",
		-- 	recipe = {
		-- 		{"twigs", 3},
		-- 		{"shanhai_goumang_item", 1},
		-- 		{"rope", 2},
		-- 	},
		-- },
		shanhai_ginkgoleave_ground = {
			priority = 13,
			desc_tex = "shanhai_ginkgoleave.tex",
			desc_atlas = "images/inventoryimages/sh_items.xml",
			desc_build = "shanhai_ginkgoleave",
			desc_bank = "shanhai_ginkgoleave",
			desc_anim = "idle",
			resize = 1.5,
			y_offset = 10,
			type = "建筑",
			recipe = {
				{"shanhai_ginkgoleave", 1},
			},
		},
	},

	------------------------------------------------
	-- 道具+科技
	------------------------------------------------

	["items"] = 
	{
		deepseacave = {
			priority = 1,
			type = "道具",
			desc_build = "deepseacave",
			desc_bank = "deepseacave",
			desc_anim = "idle_deploy",
			y_offset = -10,
			resize = 0.8,
		},
		deepseacave_seal = {
			priority = 2,
			type = "道具",
			desc_build = "shj_seal",
			desc_bank = "shj_seal",
			desc_anim = "idle",
			y_offset = 10,
			resize = 1.5,
		},
		sh_desc = {
			priority = 2.1,
			unlock_method = 1,
			unique = false,
			type = "道具",
			recipe = {
				{"papyrus", 1},
				{"shanhai_redrope", 1},
			},
			desc_build = "sh_desc",
			desc_bank = "sh_desc",
			desc_anim = "idle",
			y_offset = 10,
			resize = 1.7,
		},
		sh_redpaper = {
			priority = 3,
			type = "道具",
			desc_build = "sh_redpaper",
			desc_bank = "sh_redpaper",
			desc_anim = "idle",
			y_offset = 10,
			resize = 1.5,
		},
		shanhai_goumang = {
			priority = 4,
			type = "道具",
			recipe = {
				{"shanhai_goumang_item", 10},
				{"reviver", 1},
			},
			desc_build = "shanhai_goumang_ball",
			desc_bank = "shanhai_goumang_ball",
			desc_anim = "idle",
			y_offset = 10,
			resize = 1.7,
		},
		xuanhe_passport = {
			priority = 5,
			type = "道具",
			desc_build = "gems",
			desc_bank = "gems",
			desc_anim = "bluegem_idle",
			desc_override_build = "xuanhe_passport",
			oversymbolfn = function(item_anim)
				item_anim:GetAnimState():OverrideSymbol("bluegem", "xuanhe_passport", "xuanhe_passport")
		    end,
		    y_offset = 10,
		    resize = 1.5,
		},
		sh_qystick = {
			priority = 5.1,
			type = "道具",
			recipe = {
				{"shanhai_goumang", 1},
				{"stinger", 3},
			},
			desc_build = "sh_qystick",
			desc_bank = "sh_qystick",
			desc_anim = "idle",
		    y_offset = 10,
			resize = 1.5,
		},
		sh_zybell = {
			priority = 5.2,
			type = "道具",
			desc_build = "sh_zybell",
			desc_bank = "sh_zybell",
			desc_anim = "idle",
		    y_offset = 10,
			resize = 1.5,
		},
		sh_panflute = {
			priority = 5.3,
			type = "道具",
			recipe = {
				{"sh_zybell", 1},
				{"shanhai_cookedshanshen", 1},
				{"shanhai_redrope", 1},
			},
			desc_build = "wilson",
			desc_bank = "wilson",
			desc_anim = "sh_playflut_loop",
			oversymbolfn = function(item_anim)
				item_anim:GetAnimState():OverrideSymbol("tools", "player_actions_sh_flute", "tools")
			end,
		    y_offset = -20,
			resize = 1.4,
		},
		sh_backpack_leaf = {
			priority = 5.4,
			type = "道具",
			recipe = {
				{"krampus_sack", 1},
				{"eyebrellahat", 1},
				{"nightmarefuel", 3},
			},
			desc_build = "sh_backpack_leaf",
			desc_bank = "sh_backpack_leaf",
			desc_anim = "desc",
		    y_offset = -30,
		    resize = 1.3,
		},
		sh_feather_phoenix = {
			priority = 5.5,
			type = "道具",
			desc_build = "sh_feather_phoenix",
			desc_bank = "sh_feather_phoenix",
			desc_anim = "idle",
		    y_offset = 10,
			resize = 1.7,
		},
		shanhai_starfly = {
			priority = 6,
			type = "道具",
			recipe = {
				{"moonrocknugget", 3},
				{"shanhai_goumang_item", 3},
				{"featherpencil", 1},
			},
			desc_build = "shanhai_jadeslip",
			desc_bank = "shanhai_jadeslip",
			desc_anim = "sparkle",
			desc_override_build = "shanhai_starfly",
			y_offset = 10,
			resize = 1.5,
		},
		shanhai_moonfall = {
			priority = 6.1,
			type = "道具",
			recipe = {
				{"moonrocknugget", 3},
				{"shanhai_goumang_item", 3},
				{"featherpencil", 1},
			},
			desc_build = "shanhai_jadeslip",
			desc_bank = "shanhai_jadeslip",
			desc_anim = "sparkle",
			desc_override_build = "shanhai_moonfall",
			y_offset = 10,
			resize = 1.5,
		},
		dsc_copytool = {
			priority = 6.2,
			type = "道具",
			desc_build = "dsc_copytool",
			desc_bank = "dsc_copytool",
			desc_anim = "loop",
		    y_offset = 10,
			resize = 1.7,
		},
		sh_migutwig = {
			priority = 7,
			type = "道具",
			desc_build = "sh_migutwig",
			desc_bank = "sh_migutwig",
			desc_anim = "idle",
			y_offset = 10,
			resize = 1.5,
		},
		sh_magicshanshen = {
			priority = 7.1,
			type = "道具",
			desc_build = "sh_magicshanshen",
			desc_bank = "sh_magicshanshen",
			desc_anim = "idle",
			x_offset = -10,
			y_offset = 10,
			resize = 1.5,
		},
		sh_killall_weapon = {
			priority = 7.2,
			type = "武器",
			desc_build = "sh_killall_weapon",
			desc_bank = "sh_killall_weapon",
			desc_anim = "idle",
			y_offset = 10,
			resize = 1.5,
		},
		sh_leafboat_item = {
			priority = 7.3,
			type = "道具",
			recipe = {
				{"shanhai_goumang_item", 3},
				{"shanhai_redrope", 2},
			},
			desc_build = "sh_leafboat_item",
			desc_bank = "sh_leafboat_item",
			desc_anim = "idle",
			y_offset = 10,
			resize = 1.5,
		},
		sh_boat_torch = {
			priority = 7.4,
			type = "道具",
			recipe = {
				{"lightbulb", 1},
				{"twigs", 1},
			},
			desc_build = "swap_sh_torch_boat",
			desc_bank = "sh_torch_boat",
			desc_anim = "idle",
			y_offset = 10,
			resize = 1.5,
		},
		shanhai_seed_gem = {
			priority = 8,
			type = "道具",
			recipe = {
				{"shanhai_goumang", 1},
				{"ancientfruit_gem", 1},
			},
			desc_build = "sh_seeds",
			desc_bank = "sh_seeds",
			desc_anim = "idle",
			y_offset = 10,
			resize = 1.5,
		},
		shanhai_seed_night = {
			priority = 9,
			type = "道具",
			recipe = {
				{"shanhai_goumang", 1},
				{"ancientfruit_nightvision", 1},
			},
			desc_build = "sh_seeds",
			desc_bank = "sh_seeds",
			desc_anim = "idle",
			oversymbolfn = function(item_anim)
				item_anim:GetAnimState():OverrideSymbol("symbol0",  "sh_seeds", "night")
		    end,
		    y_offset = 10,
		    resize = 1.6,
		},
		shanhai_seed_tallbirdegg = {
			priority = 10,
			type = "道具",
			recipe = {
				{"shanhai_goumang", 1},
				{"tallbirdegg", 1},
			},
			desc_build = "sh_seeds",
			desc_bank = "sh_seeds",
			desc_anim = "idle",
			oversymbolfn = function(item_anim)
				item_anim:GetAnimState():OverrideSymbol("symbol0",  "sh_seeds", "tallbirdegg")
		    end,
		    y_offset = 10,
		    resize = 1.5,
		},
		shanhai_seed_shanshen = {
			priority = 10.1,
			type = "道具",
			recipe = {
				{"shanhai_goumang", 1},
				{"shanhai_cookedshanshen", 1},
			},
			desc_build = "sh_seeds",
			desc_bank = "sh_seeds",
			desc_anim = "idle",
			oversymbolfn = function(item_anim)
				item_anim:GetAnimState():OverrideSymbol("symbol0",  "sh_seeds", "shanshen")
		    end,
		    y_offset = 10,
		    resize = 1.6,
		},
		shpighat = {
			priority = 10.5,
			type = "道具",
			recipe = {
				{"pigskin", 1},
				{"shanhai_redrope", 1},
			},
			desc_build = "hat_shpig",
			desc_bank = "shpighat",
			desc_anim = "anim",
		    y_offset = 10,
		    resize = 1.5,
		},
		shanhai_goumang_item = {
			priority = 11,
			type = "食物",
			caneat = true,
			health = TUNING.HEALING_SMALL,
			hunger = TUNING.CALORIES_TINY,
			desc_build = "shanhai_goumang_item",
			desc_bank = "shanhai_goumang_item",
			desc_anim = "idle",
			y_offset = 10,
			resize = 1.5,
		},
		ganoderma_cap = {
			priority = 12,
			type = "食物",
			caneat = true,
			sanity = TUNING.SANITY_MEDLARGE,
	        health = TUNING.HEALING_SUPERHUGE,
	        hunger = TUNING.CALORIES_SMALL,
	        desc_build = "shanhai_mushrooms",
			desc_bank = "shanhai_mushrooms",
			desc_anim = "ganoderma_cap",
			y_offset = 10,
			resize = 2,
		},
		ganoderma_cap_cooked = {
			priority = 12.5,
			type = "食物",
			caneat = true,
			sanity = TUNING.SANITY_HUGE,
        	health = TUNING.HEALING_SUPERHUGE,
        	hunger = TUNING.CALORIES_SUPERHUGE,
        	desc_build = "shanhai_mushrooms",
			desc_bank = "shanhai_mushrooms",
			desc_anim = "ganoderma_cap_cooked",
			y_offset = 10,
			resize = 2,
		},
		shanhai_shanshen = {
			priority = 13,
			type = "食物",
			caneat = true,
			health = TUNING.HEALING_HUGE,
    		hunger = TUNING.CALORIES_HUGE,
    		desc_build = "shanhai_shanshen",
			desc_bank = "shanhai_shanshen",
			desc_anim = "object",
			y_offset = 10,
			resize = 1.5,
		},
		shanhai_cookedshanshen = {
			priority = 13,
			type = "食物",
			caneat = true,
			health = TUNING.HEALING_SUPERHUGE,
    		hunger = TUNING.CALORIES_SUPERHUGE,
    		desc_build = "shanhai_shanshen",
			desc_bank = "shanhai_shanshen",
			desc_anim = "cooked",
			y_offset = 10,
			resize = 1.5,
		},
		shanhai_ginkgo = {
			priority = 14,
			type = "食物",
			caneat = true,
			hunger = TUNING.CALORIES_TINY,
            health = TUNING.HEALING_SMALL,
            desc_build = "shanhai_pinecone",
			desc_bank = "shanhai_pinecone",
			desc_anim = "idle",
			y_offset = 10,
			resize = 1.5,
		},
		shanhai_ginkgoleave = {
			priority = 14.1,
			type = "道具",
			desc_build = "shanhai_ginkgoleave",
			desc_bank = "shanhai_ginkgoleave",
			desc_anim = "idle",
			y_offset = 10,
			resize = 1.5,
		},
		dug_shanhai_goumang_plant = {
			priority = 15,
			type = "道具",
			recipe = {
				{"refined_dust", 4},
				{"shanhai_goumang_item", 1},
				{"reviver" , 1}
			},
			desc_build = "dug_shanhai_goumang_plant",
			desc_bank = "dug_shanhai_goumang_plant",
			desc_anim = "idle",
			y_offset = 10,
			resize = 1.5,
		},
		shanhai_xirang_item = {
			priority = 15,
			type = "道具",
			desc_build = "shanhai_xirang_item",
			desc_bank = "shanhai_xirang_item",
			desc_anim = "idle",
			y_offset = 10,
			resize = 1.5,
		},
		shanhai_redrope = {
			priority = 16,
			type = "道具",
			recipe = {
				{"rope", 1},
				{"sh_health", 10},
			},
			desc_build = "shanhai_redrope",
			desc_bank = "shanhai_redrope",
			desc_anim = "idle",
			y_offset = 10,
			resize = 1.5,
		},
		shanhai_pinecone = {
			priority = 17,
			type = "道具",
			recipe = {
				{"shanhai_goumang", 1},
				{"pinecone", 1},
			},
			desc_build = "shanhai_pinecone",
			desc_bank = "shanhai_pinecone",
			desc_anim = "idle2",
			y_offset = 10,
			resize = 1.5,
		},
		saddle_kun_ground = {
			priority = 18,
			unlock_method = 2,
			unique = false,
			type = "道具",
			recipe = {
				{"feather_robin_winter", 3},
				{"silk", 3},
				{"sewing_kit", 1},
			},
			desc_build = "saddle_kun",
			desc_bank = "saddlebasic",
			desc_anim = "idle",
			y_offset = 10,
			resize = 1.5,
		},
		sh_fireworks = {
			priority = 19,
			unlock_method = 1,
			unique = false,
			type = "道具",
			recipe = {
				{"twigs", 2},
				{"nitre", 1},
				{"charcoal", 2},
			},
			desc_build = "flare",
			desc_bank = "flare",
			desc_anim = "idle",
			desc_override_build = "sh_fireworks",
			oversymbolfn = function(item_anim)
				item_anim:GetAnimState():OverrideSymbol("twig_parts",  "sh_fireworks", "sh_twig_parts")
			    item_anim:GetAnimState():OverrideSymbol("grass_parts", "sh_fireworks", "sh_grass_parts")
			end,
			y_offset = -30,
			resize = 1.5,
		},
		sh_ironopenwork_base_kit = {
			priority = 20,
			unlock_method = 1,
			unique = false,
			type = "道具",
			recipe = {
				{"twigs", 2},
				{"nitre", 1},
				{"charcoal", 2},
			},
			desc_build = "sh_ironopenwork_base",
			desc_bank = "sh_ironopenwork_base",
			desc_anim = "kit_item",
			y_offset = 10,
			resize = 1.5,
		},
		shanhai_bubbletea = {
			priority = 22,
			unlock_method = 1,
			unique = false,
			type = "食物",
			caneat = true,
			health = TUNING.HEALING_MEDLARGE,
			hunger = TUNING.CALORIES_MED,
			sanity = TUNING.SANITY_TINY,
			recipe = {
				{"shanhai_goumang_item", 1},
				{"ice", 1},
				{"ice", 1},
				{"cave_banana", 1},
			},
			desc_build = "cook_pot_food",
			desc_bank = "cook_pot_food",
			desc_override_build = "cook_pot_food_sh",
			oversymbolfn = function(item_anim)
				item_anim:GetAnimState():OverrideSymbol("swap_food", "cook_pot_food_sh", "shanhai_bubbletea")
			end,
			desc_anim = "idle",
			y_offset = 10,
			resize = 1.7,
		},
		sh_ganodermaice = {
			priority = 23,
			unlock_method = 1,
			unique = false,
			type = "食物",
			caneat = true,
			health = TUNING.HEALING_HUGE,
			hunger = TUNING.CALORIES_MED,
			sanity = TUNING.SANITY_HUGE,
			recipe = {
				{"ganoderma_cap", 1},
				{"ganoderma_cap", 1},
				{"ice", 1},
				{"cave_banana", 1},
			},
			desc_build = "cook_pot_food",
			desc_bank = "cook_pot_food",
			desc_override_build = "cook_pot_food_sh",
			oversymbolfn = function(item_anim)
				item_anim:GetAnimState():OverrideSymbol("swap_food", "cook_pot_food_sh", "sh_ganodermaice")
			end,
			desc_anim = "idle",
			y_offset = 10,
			resize = 1.7,
		},
		sh_neverold = {
			priority = 24,
			unlock_method = 1,
			unique = false,
			type = "食物",
			caneat = true,
			health = TUNING.HEALING_SUPERHUGE,
			hunger = TUNING.CALORIES_SUPERHUGE,
			sanity = TUNING.SANITY_HUGE,
			recipe = {
				{"shanhai_shanshen", 1},
				{"deer_antler1", 1},
				{"ganoderma_cap", 1},
				{"trinket_35", 1},
			},
			desc_build = "cook_pot_food",
			desc_bank = "cook_pot_food",
			desc_override_build = "cook_pot_food_sh",
			oversymbolfn = function(item_anim)
				item_anim:GetAnimState():OverrideSymbol("swap_food", "cook_pot_food_sh", "sh_neverold")
			end,
			desc_anim = "idle",
			y_offset = 10,
			resize = 1.7,
		},
		sh_taco = {
			priority = 25,
			unlock_method = 1,
			unique = false,
			type = "食物",
			caneat = true,
			health = TUNING.HEALING_MED,
			hunger = TUNING.CALORIES_MED,
			sanity = TUNING.SANITY_MED,
			recipe = {
				{"shanhai_goumang_item", 1},
				{"corn", 1},
				{"quagmire_onion", 1},
				{"meat", 1},
			},
			desc_build = "cook_pot_food",
			desc_bank = "cook_pot_food",
			desc_override_build = "cook_pot_food_sh",
			oversymbolfn = function(item_anim)
				item_anim:GetAnimState():OverrideSymbol("swap_food", "cook_pot_food_sh", "sh_taco")
			end,
			desc_anim = "idle",
			y_offset = 10,
			resize = 1.9,
		},
		sh_zhulong_taco = {
			priority = 26,
			unlock_method = 1,
			unique = false,
			type = "食物",
			caneat = true,
			-- health = TUNING.HEALING_SUPERHUGE,
			-- hunger = TUNING.CALORIES_SUPERHUGE,
			-- sanity = TUNING.SANITY_HUGE,
			-- recipe = {
			-- 	{"shanhai_shanshen", 1},
			-- 	{"deer_antler1", 1},
			-- 	{"ganoderma_cap", 1},
			-- 	{"trinket_35", 1},
			-- },
			speed = 0.5,
			desc_build = "sh_zhulong_taco",
			desc_bank = "sh_zhulong_taco",
			desc_anim = "idle",
			y_offset = -20,
			resize = 1.5,
		},
	},
	------------------------------------------------
	-- 关于+赞赏
	------------------------------------------------

	["about"] = 
	{
		about_me = {
			str_pre = [[
MOD进展非常、相当、及其以及特别的慢，当前除贴图外的所有内容都由威吊一人负责。
奇怪的BUG、神奇的脑洞、UI的建议等等，都可以在steam介绍页或者群聊进行反馈。
			]],
			str_ques = [[
MOD其它
			]],
			str_pst = [[
本MOD涉及的代码借鉴都已取得了对应MOD作者的授权，如果你有代码相关的问题，欢迎询问，威吊会尽可能帮忙。

======================================
关于世外岛屿的代码设计，威吊暂时不会公开，且有进行代码混淆，请不要破解、重新发布或自用！
======================================

代码来源：你要帮帮威吊（大部分）、Jerry（世外岛屿）
贴图来源：什么什么狗（大部分）、咸鱼杰（鲲鹏）、神都（月坠、小乌鸦烟花）、zeroguzok（纸燕、线索纸、碎石地皮）、悉茗茗（XMM地皮）、陌坊（稍大的土堆）
动画来源：你要帮帮威吊（大部分）、老张（洞天塔锦鲤）
音效来源：你要帮帮威吊（很烂）
部分文本：光风霁月醉星辰
			]],
			str_back = [[
【MOD故事线——远古文明时期】
W来达永恒领域游历樱花林，并意外接触到了远古文明。
W帮助远古文明建造了档案馆、远古大门...
远古大门打开了通往山海经世界的传送门，W与小乌鸦、猪哥掉入山海经世界。
...

【MOD故事线——山海经时期】
W与小乌鸦、猪哥一起游历山海经世界，结实了各种异兽。
W向小乌鸦讲述了樱花林的故事，造成小乌鸦对樱桃的执念。
猪哥改名'朱源'，拜入当康门下。
小乌鸦改名'羽润'，拜入凤凰门下。
山海经世界中的凶兽觊觎永恒领域的能量，暗中污染噩梦燃料，挑拨远古文明。
远古人过度使用被污染的噩梦燃料，远古文明倒台。
W借助烛龙的能力，封印了大部分凶兽到洞天塔，将洞天塔镇压在昆仑龙脉岛屿。
W留在山海经世界，朱源、羽润在洞天塔内负责看守异兽。
...

【MOD故事线——饥荒：联机版】
麦斯威尔、查理到达永恒领域。
威尔逊短暂代替麦斯威尔坐上梦魇王座，查理夺取王座。
瓦格斯塔夫的传送门重新撕开与山海经世界的传送门，昆仑龙脉岛屿的一部分被传送到了永恒领域。
巨大月亮碎片掉落形成月岛，其中一小块碎片砸坏了洞天塔。
洞天塔封印的朱厌发现缺口，成功从洞天塔逃出，经过之处在永恒大陆留下了稍大的土堆。
朱源、羽润察觉到异兽出逃，羽润施法催生扭曲的大树，堵住了洞天塔缺口。
朱源、羽润将塔重新封印，埋在烛龙法阵之下，朱源开始尝试用纸燕向猪人部落传递求救信息。
...

以上是一个大致的脑洞，更多内容建议探险家自行摸索。故事背景与樱花林的交织与作者ADM进行过交涉！
			]],
		},
		for_wilson = {
			str_qq = [[
----群聊【QQ】：962910391----
			]],
			str_pre = [[
预计更新计划：冰封洞穴、法术技能
（PS：威吊个人精力有限，更新速度不会很快）
			]],
			str_mid = [[
请威吊喝杯咖啡吗？
您的赞助款将用于购买贴图素材、维护代码模块、威吊脑洞续杯，以为玩家带来更丰富的游戏体验。
无论是否赞助，您的游玩体验、BUG反馈和社区分享，都是对MOD最大的支持！
衷心致谢，希望【山河表里】走得更远。

理性打赏提醒:
赞助纯属自愿行为，请勿因赞助影响个人正常生活开支。
学生党请优先保证学业与生活需要！！！
精神支持同样珍贵，steam点个收藏就是鼓励！
			]],
			str_pst = [[
感谢您对【山河表里】的喜爱！
			]],
		},
	},
}

-- 兼容山海密藏
if TUNING.MZ_MOD_ENABLE then
	local sh_fsm_monkey_zhuyan = {
		priority = 2.1,
		friendly = false,
		location = "绿洲沙漠",
		desc_build = "fsm_monkey_zhuyan",
		desc_bank = "fsm_monkey_zhuyan",
		desc_anim = "idle",
		speed = 0.6,
		resize = 1.3,
		facing = FACING_DOWN,
		y_offset = -20,
	}
	-- 插入新条目到 mobs 表（字典形式）
	sh_desc_contents.mobs["sh_fsm_monkey_zhuyan"] = sh_fsm_monkey_zhuyan 
end

for n, k in pairs(sh_desc_contents) do
	if n ~= "about" then
		for u, v in pairs(k) do
			v.desc_tex = v.desc_tex or u..".tex"
			v.desc_atlas = v.desc_atlas or "images/inventoryimages/sh_"..n..".xml"
			v.priority = v.priority or 99
			v.x_offset = v.x_offset or 0
			v.y_offset = v.y_offset or 0
			v.description = desc_contents[u] or [[]]
		end
	end
end

return { sh_desc_contents = sh_desc_contents }