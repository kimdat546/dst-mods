AddRecipe2("hh_suit_build",
        {
            Ingredient("goldnugget", 10),
            Ingredient("rocks", 10),
        },
        TECH["MAGIC_TWO"],
        {
            ["placer"] = "hh_suit_build_placer",
            ["min_spacing"] = 2.5,
            ["atlas"] = "images/hh_icon/hh_suit_build.xml",
            ["image"] = "hh_suit_build.tex"
        },
        { "MAGIC", "STRUCTURES", }
)
AddRecipe2("hh_staff_dis",
        {
            Ingredient("goldnugget", 10),
            Ingredient("rocks", 10),
        },
        TECH["NONE"],
        {
            ["numtogive"] = 1
        },
        { "MAGIC", "WEAPONS", }
)
--星星法杖
AddRecipe2("hh_staff_star",
        {
            Ingredient("hh_essence", 50),
            Ingredient("opalpreciousgem", 5),
            Ingredient("nightmarefuel", 50),
        },
        TECH["MAGIC_THREE"],
        {
            --无法拆解
            ["no_deconstruction"] = true,
            ["numtogive"] = 1
        },
        { "MAGIC", "WEAPONS", }
)
--冰刀
AddRecipe2("hh_ice_knife",
        {
            Ingredient("hh_essence", 25),
            Ingredient("opalpreciousgem", 1),
            Ingredient("nightmarefuel", 40),
        },
        TECH["MAGIC_THREE"],
        {
            --无法拆解
            ["no_deconstruction"] = true,
            ["numtogive"] = 1
        },
        { "MAGIC", "WEAPONS", }
)
--附魔盒子
AddRecipe2("hh_cat_box",
        {
            Ingredient("goldnugget", 10),
            Ingredient("rocks", 10),
        },
        TECH["NONE"],
        {
            ["numtogive"] = 1
        },
        { "MAGIC", "CONTAINERS", }
)
--水晶小人
AddRecipe2("hh_essence",
        {
            Ingredient("hh_effect_tally", 1),
            Ingredient("hh_remove_stone", 2),
        },
        TECH["NONE"],
        {
            ["numtogive"] = 1
        },
        { "MAGIC", "REFINE", }
)
--寻宝卷轴
AddRecipe2("hh_treasure_tally_a",
        {
            Ingredient("stinger", 40),
        },
        TECH["NONE"],
        {
            ["product"] = "hh_treasure_tally",
            ["numtogive"] = 1
        },
        { "REFINE", }
)
AddRecipe2("hh_treasure_tally_b",
        {
            Ingredient("silk", 20),
            Ingredient("spidergland", 20),
        },
        TECH["NONE"],
        {
            ["product"] = "hh_treasure_tally",
            ["numtogive"] = 1
        },
        { "REFINE", }
)
--配置是否可以制作
local can_build = GetModConfigData("can_build_duck_box")
if can_build then
    --鸭鸭盒子
    AddRecipe2("hh_duck_box",
            {
                Ingredient("redgem", 2),
                Ingredient("pigskin", 3),
                Ingredient("goldnugget", 10),
            },
            TECH["NONE"],
            {
                ["numtogive"] = 1
            },
            { "MAGIC", "CONTAINERS", }
    )
end
AddRecipe2("hh_egg_nest",
        {
            Ingredient("goldnugget", 1),
            Ingredient("rocks", 2),
        },
        TECH["SCIENCE_ONE"],
        {
            ["placer"] = "hh_egg_nest_placer",
            ["min_spacing"] = 2.5,
            ["atlas"] = "images/hh_icon/hh_egg_nest.xml",
            ["image"] = "hh_egg_nest.tex"
        },
        {  "STRUCTURES", }
)
AddRecipe2("hh_egg_exhibition_table",
        {
            Ingredient("goldnugget", 1),
            Ingredient("rocks", 2),
        },
        TECH["SCIENCE_ONE"],
        {
            ["placer"] = "hh_egg_exhibition_table_placer",
            ["min_spacing"] = 2.5,
            ["atlas"] = "images/hh_icon/hh_egg_nest.xml",
            ["image"] = "hh_egg_nest.tex"
        },
        {  "STRUCTURES", }
)