-- local _G = GLOBAL
-- local STRINGS = _G.STRINGS
local ___________NAMES = STRINGS.NAMES
local _________ACTIONS = STRINGS.ACTIONS
local _______SKINNAMES = STRINGS.SKIN_NAMES
local ________ANNOUNCE = STRINGS.CHARACTERS.GENERIC
local ________DESCRIBE = STRINGS.CHARACTERS.GENERIC.DESCRIBE
local _____RECIPE_DESC = STRINGS.RECIPE_DESC
local ___OPEN_CRAFTING = STRINGS.ACTIONS.OPEN_CRAFTING
local CRAFTING_FILTERS = STRINGS.UI.CRAFTING_FILTERS
local ___CUSTOMIZATION = STRINGS.UI.CUSTOMIZATIONSCREEN
local ________COOKBOOK = STRINGS.UI.COOKBOOK
local ________CRAFTING = STRINGS.UI.CRAFTING


STRINGS.SH_MODNAME = "Montfluv"
___CUSTOMIZATION.DSC_WITH_VINES = "Tower with parasitic vines"
___CUSTOMIZATION.DSC_YURUN_FRIEND = "Yurun starts friendly"
___CUSTOMIZATION.DSC_WITH_BAN = "Tower-attached isle taboos"
___CUSTOMIZATION.DSC_WITH_KOI = "Tower inside with koi"
___CUSTOMIZATION.ZHUYAN_DIFFICULTY_LEVEL = "Zhuyan kill difficulty"
___CUSTOMIZATION.QINYUAN_DIFFICULTY_LEVEL = "Qinyuan kill difficulty"
___CUSTOMIZATION.GOUMANG_DROP_CHANCE = "Goumang Fruit drop chance"
___CUSTOMIZATION.TACO_DROP_CHANCE = "Time Taco drop chance"
___CUSTOMIZATION.GOUMANG_GROW_SPEED = "Goumang regrowth"
___CUSTOMIZATION.GANODERMA_GROW_SPEED = "Ganoderma regrowth"
___CUSTOMIZATION.MIGUTREE_GROW_SPEED = "Migutree regrowth"
___CUSTOMIZATION.SEANEST_GROW_SPEED = "Seanest regrowth"
___CUSTOMIZATION.XIRANG_CD_SPEED = "Xirang CD"
___CUSTOMIZATION.CLOUDMOVE_CD_SPEED = "Cloudmove CD"
___CUSTOMIZATION.KUNPENG_WITH_PACK = "Kunpeng gives Pack"
---------------------------------------------------------------
------------------------动作 名称-------------------------------
---------------------------------------------------------------
_________ACTIONS.ACTIVATE.KNOCKPIG = "Knock knock"
_________ACTIONS.ACTIVATE.PUSHSTONE = "Push"
_________ACTIONS.ACTIVATE.JUMPHOLE = "Jump"
_________ACTIONS.ACTIVATE.SH_SPIN_MIGU = "Lead"
_________ACTIONS.ACTIVATE.DSC_UPGRADE = "Upgrade"
_________ACTIONS.DEPLOY.DSC_PLACE = "Place"
_________ACTIONS.DEPLOY.SH_BOAT_PLACE = "Place"
_________ACTIONS.DEPLOY.UNROLL_SCROLL = "Unroll"
_________ACTIONS.DEPLOY.SH_PIECE_PLACE = "Place"
_________ACTIONS.DEPLOY.SH_ABYSS_PLACE = "Place"
_________ACTIONS.SHBOATMOUNT = "Mount"
_________ACTIONS.SHBOATDISMOUNT = "Land"
_________ACTIONS.SHACTIVATELIGHT = "Light on"
_________ACTIONS.SHDESACTIVATELIGHT = "Light off"
_________ACTIONS.SHRETRIEVE = "Retrieve"

---------------------------------------------------------------
------------------------制作提示------------------------------
---------------------------------------------------------------
________CRAFTING.NEEDSPDSPIG_SHOP = "We need some help from Zhuyuan"

---------------------------------------------------------------
------------------------N P C昵称------------------------------
---------------------------------------------------------------
-- 固定NPC，珠圆玉润组合
-- 后期解密塔的封印，可以让朱源愿意出门，让羽润可以从塔里出来
STRINGS.DEEPSEACAVE_CROW    = { "Yurun", }  -- { "梧芽", "芽羽", "羽润", "润梧" }
STRINGS.DEEPSEACAVE_PIGMAN  = { "Zhuyuan", }    -- { "振株", "株源", "源泽", "泽振" }

---------------------------------------------------------------
------------------------物品名称--------------------------------
---------------------------------------------------------------
___________NAMES.SHANHAI_KUNLUNISLAND = "Island Kunlun"
___________NAMES.SHANHAI_DEEPSEACAVE = "Island Montluv"
___________NAMES.SHANHAI_DEEPSEACAVE_TWO = "Island Montluv Two"
___________NAMES.SH_FLY = "Montfluv Fly"
___________NAMES.SH_COOKPOTFIRE = "Cookpot Fire"
___________NAMES.SH_BOAT = "Montfluv Boat"
___________NAMES.SH_HELPER = "Ancient Voice"
___________NAMES.SH_SEASTACK = "Seastack"
___________NAMES.SH_MARSH_PLANT = "Plant"
___________NAMES.SH_POND_ALGAE = "Algae"
___________NAMES.SH_TICTACTOE_GAME = "Tictactoe"

___________NAMES.TORTOISE_CUSTARD = "Tortoise Custard"
___________NAMES.SHANHAI_BUBBLETEA = "Montfluv Tea"
___________NAMES.SH_GANODERMAICE = "Ganoderma Ice"
___________NAMES.SH_NEVEROLD = "Elixir of Immortality"
___________NAMES.SH_TACO = "Montfluv Taco"
___________NAMES.SH_ZHULONG_TACO = "Time Taco"
___________NAMES.SH_BACKYOUNG = "Elixir of Life"

___________NAMES.STATUE_CHAOFENG = "Phoenix Statue"
___________NAMES.STATUE_ZHULONG_USE = "Dragon Statue"
___________NAMES.STATUE_NIEPAN = "Rebirth Statue"
___________NAMES.STATUE_EATMOON = "Eatmoon Statue"
___________NAMES.STATUE_ZHUYAN = "Fightinside Statue"
___________NAMES.SH_CHERRYSTATUE = "Splicing Blueprint Statue"
___________NAMES.DEEPSEACAVE_UPGRADER = "Upgrader"
___________NAMES.SH_SEASONAQUARIUM = "Seasonal Fish Tank"
___________NAMES.SHANHAI_SHELLCHEST = "Shell Chest"
___________NAMES.SHANHAI_HIDDENCELLAR_USE = "Rocky Chest"
___________NAMES.SHANHAI_SMALLSTATUE = "Small Memorial Statue"
___________NAMES.XUANHE_POND = "Montfluv Pond"
___________NAMES.DEEPSEACAVE = "Montfluv Tower"
___________NAMES.DEEPSEACAVE_SEAL = "Tower's Seal"
___________NAMES.DEEPSEACAVE_EXIT = "Tower's Exit"
___________NAMES.DEEPSEACAVE_WALL = "Tower's Wall"
___________NAMES.DEEPSEACAVE_POOL = "Little Rocky Pond"
___________NAMES.DSC_POOL = "Little Rocky Pond"
___________NAMES.DEEPSEACAVE_PIGHOUSE = "Zhuyuan's House"
___________NAMES.SHANHAI_NORMALPILE = "Larger Pile"
___________NAMES.SHANHAI_SECRETPLACE = "Zhulong's Sigil Array"
___________NAMES.SHANHAI_SECRETORDER = "Scale"
___________NAMES.SHANHAI_GONG = "Do"
___________NAMES.SHANHAI_SHANG = "Re"
___________NAMES.SHANHAI_JUE = "Mi"
___________NAMES.SHANHAI_ZHI = "Sol"
___________NAMES.SHANHAI_YU = "La"
___________NAMES.SHANHAI_FINISHORDER = "="
___________NAMES.SH_ROCK_1 = "Decor Rock"
___________NAMES.SH_SEANEST = "Seagull Nest"
___________NAMES.SH_SEANEST_KIT = "Mussel Rod"
___________NAMES.STATUE_ZHULONG = "Sealed Dragon"
___________NAMES.SH_BRIDGE = "Wood Bridge"
___________NAMES.SH_ZHUYAN_SPAWNER = "Zhuyan Montain"
___________NAMES.SH_TICTACTOE_BOARD = "Tic Tac Toe"
___________NAMES.DSC_CAVE_ENTRANCE = "Plugged Sinkhole"
___________NAMES.DSC_CAVE_ENTRANCE_OPEN = "Sinkhole"
___________NAMES.DSC_CAVE_EXIT = "Stairs"
___________NAMES.DSC_MUSHROOM_TO_2 = "Fake Ganoderma"
___________NAMES.XUANHE_FALL = "Water Fall"
___________NAMES.SH_ABYSSPILLAR = "Woodstep"
___________NAMES.SH_ABYSSPILLAR_ITEM = "Stonestep Kit"
___________NAMES.DSC_CAVE_MAGICSEAL = "Spirit-Binding Chains"
___________NAMES.DSC_CAVE_MAGICPLACVE = "Demon-Sealing Formation"
___________NAMES.DSC_CAVE_STAFFLIGHT = "Monfluv Star"

___________NAMES.DSC_OCEANTREE_PILLAR = "Twisted Tree"
___________NAMES.SHANHAI_HIDDENEXIT = "Hidden Exit"
___________NAMES.SHANHAI_HIDDENEXIT_2 = "Portal to Ground"
___________NAMES.SHANHAI_HIDDENCELLAR = "Mysterious Stone"
___________NAMES.SHANHAI_GOUMANG_ITEM = "Goumang Leaf"
___________NAMES.SHANHAI_GOUMANG_PLANT = "Goumang"
___________NAMES.SHANHAI_GOUMANG = "Goumang's Fruit"
___________NAMES.SHANHAI_SHANSHEN = "Wild Ginseng"
___________NAMES.SHANHAI_SHANSHEN_ACTIVE = "Wild Ginseng Man"
___________NAMES.SHANHAI_SHANSHEN_PLANTED = "Wild Ginseng"
___________NAMES.SHANHAI_COOKEDSHANSHEN = "Cooked Ginseng"
___________NAMES.SHANHAI_XIRANG = "Mysterious Soil"
___________NAMES.SHANHAI_XIRANG_ITEM = "Xirang"
___________NAMES.SHANHAI_GANODERMA = "Ganoderma"
___________NAMES.GANODERMA_CAP = "Ganoderma Cap"
___________NAMES.GANODERMA_CAP_COOKED = "Cooked Ganoderma"
___________NAMES.SHANHAI_MUSHROOMGUARD1 = "Deer Antler"
___________NAMES.SHANHAI_MUSHROOMGUARD2 = "Deer Antler"
___________NAMES.SHANHAI_MUSHROOMGUARD3 = "Deer Antler"
___________NAMES.SHANHAI_PINECONE_SAPLING = "Lumpy Sapling"
___________NAMES.SHANHAI_GINKGO = "Ginkgo"
___________NAMES.SHANHAI_GINKGOLEAVE = "Ginkgo Leave"
___________NAMES.SHANHAI_GINKGOLEAVE_GROUND = "Ginkgo Leave Deco"
___________NAMES.SHANHAI_GINKGO_SAPLING = "Ginkgo Sapling"
___________NAMES.SHANHAI_GINKGO_TREE = "Ginkgo Tree"
___________NAMES.SHANHAI_SEED_GEM = "Ancientfruit Gem VineSeed"
___________NAMES.SHANHAI_SEED_NIGHT = "Ancientfruit Nightvision VineSeed"
___________NAMES.SHANHAI_SEED_TALLBIRDEGG = "Tallbird VineSeed"
___________NAMES.SHANHAI_SEED_SHANSHEN = "Ginseng Seed"
___________NAMES.SHANHAIVINE_GEM = "Ancientfruit Gem Vine"
___________NAMES.SHANHAIVINE_NIGHT = "Ancientfruit Nightvision Vine"
___________NAMES.DSC_EGGVINE = "Tallbird Vine"
___________NAMES.SHANHAI_PINECONE = "Lumpy Pinecone"
___________NAMES.SHANHAIVINE_MOON = "Flower Vine"
___________NAMES.DSC_FLOWERVINE = "Flower Vine"
___________NAMES.SHANHAI_EXITVINE = "Flower Vine"
___________NAMES.SHANHAI_FLOWERVINE = "Flower Vine"
___________NAMES.DUG_SHANHAI_GOUMANG_PLANT = "Goumang Planted"
___________NAMES.SH_FLOWER = "Montfluv Flower"
___________NAMES.SH_MIGUTREE = "Migu Tree"
___________NAMES.SH_MIGUTWIG = "Migu Twig"
___________NAMES.SH_PLANTDECO = "Small Potted Plant"
___________NAMES.SH_ANIMAL_TRACK = "Wired Track"
___________NAMES.SADDLE_KUN_GROUND = "Cloud"
___________NAMES.DSC_OCEANTREE_PILLAR_2 = "Twisted Tree"
___________NAMES.SH_THULECITE = "Thulecite Fruit"
___________NAMES.SH_THULECITE_SEEDS = "Thulecite Fruit Seeds"
___________NAMES.FARM_PLANT_SH_THULECITE = "Thulecite Fruit Plant"
___________NAMES.SH_THULECITE_OVERSIZED = "Ovesized Thulecite Fruit"
___________NAMES.SH_THULECITE_OVERSIZED_WAXED = "Waxed Ovesized Thulecite Fruit"

___________NAMES.SHANHAI_STARFLY = "Star Fly"
___________NAMES.SHANHAI_MOONFALL = "Moon Fall"
___________NAMES.SADDLE_KUN = "Cloud Saddle"
___________NAMES.SHANHAI_REDROPE = "Red Rope"
___________NAMES.SH_SPARKLER_SMALL = "Sparkler"
___________NAMES.SH_SPARKLER_1 = "Samll Sparkler"
___________NAMES.SH_SPARKLER_2 = "Medium Sparkler"
___________NAMES.SH_SPARKLER_3 = "Large Sparkler"
___________NAMES.SH_KILLALL_WEAPON = "Zhuyan's Horn"
___________NAMES.SH_IRONOPENWORK_BASE = "Firework Base"
___________NAMES.SH_IRONOPENWORK_BASE_KIT = "Firework Base Kit"
___________NAMES.SH_FIREWORKS = "Crowkid Firework"
___________NAMES.SHANHAI_WINTER_TREE = "Winter Sparse Tree"
___________NAMES.DSC_LIGHT = "Wired Fire"
___________NAMES.DSC_COPYTOOL = "Cloud Move"
___________NAMES.XUANHE_PASSPORT = "Montfluv Jade"
___________NAMES.SH_REDPAPER = "Red Paper"
___________NAMES.SH_HEALTH = "Health"
___________NAMES.SH_DESC = "Montfluv Desc"
___________NAMES.TURF_SH_ICELAND = "Ice Turf"
___________NAMES.TURF_SH_SMALLSTONE = "Garden Turf"
___________NAMES.TURF_SH_XMM = "XMM Turf"
___________NAMES.TURF_SH_COLORXMM = "ColorXMM Turf"
___________NAMES.TURF_SH_LITTLESTONE = "Gravel Turf"
___________NAMES.TURF_SH_MANYSTONE = "Little Gravel Turf"
___________NAMES.SH_QYSTICK = "Qinyuan's Stinger"
___________NAMES.SH_FEATHER_PHOENIX = "Colorful Feather"
___________NAMES.SHPIGHAT = "Normal Disguise"
___________NAMES.SH_MAGICSHANSHEN = "Ginseng Broom"
___________NAMES.SH_BACKPACK_LEAF = "Yinglong Leafpack"
___________NAMES.SH_LEAFBOAT = "Leaf Boat"
___________NAMES.SH_BOAT_TORCH = "Leaf Candle"
___________NAMES.SH_SAIL = "Leaf Sail"
___________NAMES.SH_FEATHERSAIL = "Feather Sail"
___________NAMES.SH_BASEFAN = "Little Fan"
___________NAMES.SH_ZYBELL = "Zhuyan Bell"
___________NAMES.SH_PANFLUTE = "Ancient Panflute"
___________NAMES.SH_TICTACTOE_PIECE_X = "Piece"
___________NAMES.SH_TICTACTOE_PIECE_O = "Piece"
___________NAMES.SH_MAGICVEST = "Cosmic Robe"

___________NAMES.DSC_MUSHROOM_TO_2_BLUEPRINT = "Fakeganoderma Blueprint"
___________NAMES.SHANHAI_GOUMANG_BLUEPRINT = "Goumang Fruit Blueprint"
___________NAMES.STATUE_CHAOFENG_BLUEPRINT = "Phoenix Statue Blueprint"
___________NAMES.STATUE_ZHULONG_USE_BLUEPRINT = "Dragon Statue Blueprint"
___________NAMES.STATUE_EATMOON_BLUEPRINT = "Eatmoon Statue Blueprint"
___________NAMES.SH_CHERRYSTATUE_BLUEPRINT = "Splicing Blueprint"
___________NAMES.XUANHE_FALL_BLUEPRINT = "Waterfall Blueprint"
___________NAMES.SH_MIGUTREE_BLUEPRINT = "Migutree Blueprint"

___________NAMES.DEEPSEACAVE_PIGMAN = "Zhuyuan"
___________NAMES.DEEPSEACAVE_CROW = "Yurun"
___________NAMES.KUNPENG = "Kun"
___________NAMES.SHANHAI_PHOENIX = "Phoenix Shadow"
___________NAMES.KUNPENG_ATTACK_HORN = "Kun"
___________NAMES.KUNPENG_HORN = "Kun's Horn"
___________NAMES.SHANHAI_ZHUYAN = "Zhuyan"
___________NAMES.SHANHAI_BLUEFLY = "Butterfly"
___________NAMES.SHANHAI_GREENFLY = "Leave Butterfly"
___________NAMES.SHANHAI_ORANGEFLY = "Ginkgo Butterfly"
___________NAMES.SHANHAI_WHITEFLY = "Butterfly"
___________NAMES.KUN_RIDER = "Kun"
___________NAMES.DSC_TREECRAB = "Light Crab"
___________NAMES.SH_PAPERBIRD = "Paper Swallow"
___________NAMES.SH_QINYUAN = "Qinyuan"
___________NAMES.SH_FISHSPAWNER = "Fish School"
___________NAMES.DEEPSEACAVE_FISH = "Koi"
___________NAMES.SH_CRITTER_FOX = "Little Fox"
___________NAMES.SH_CRITTER_FOX_BUILDER = "Little Fox"
___________NAMES.SH_FSM_MONKEY_ZHUYAN = "Little Zhuyan"
___________NAMES.DSC_ELDERSWAMPIG = "Old Pigman"
___________NAMES.DSC_PIG_SHOP = "Zhuyuan's Shop"
___________NAMES.DSC_PIG_SHOP_ABANDONED = "Shop Closed"
___________NAMES.SH_BACKPACK_LEAF_FX = "Leaf Follower"
___________NAMES.SH_MONKEY = "Monkey"


------------------------配方说明--------------------------------
_____RECIPE_DESC.SHANHAI_REDROPE = "Couldn't we just dye it with berries?"
_____RECIPE_DESC.DUG_SHANHAI_GOUMANG_PLANT = "Pay a small price to revive it"
_____RECIPE_DESC.STATUE_ZHULONG_USE = "Borrow Zhulong's power to control time"
_____RECIPE_DESC.STATUE_ZHUYAN = "Zhuyan excels at sowing discord"
_____RECIPE_DESC.STATUE_CHAOFENG = "Summons the huge figure in the sky"
_____RECIPE_DESC.STATUE_NIEPAN = "Help us revive some friends, or enemies."
_____RECIPE_DESC.STATUE_EATMOON = "Never bites people, but will bite other things"
_____RECIPE_DESC.SH_SPARKLER_SMALL = "Cast the magic of happiness"
_____RECIPE_DESC.SH_SPARKLER_1 = "Get a little festive"
_____RECIPE_DESC.SH_SPARKLER_2 = "Share the holiday joy"
_____RECIPE_DESC.SH_SPARKLER_3 = "Be careful not to set fire to the mountain"
_____RECIPE_DESC.SHANHAI_STARFLY = "The power of stars and gravity"
_____RECIPE_DESC.SHANHAI_MOONFALL = "No need to wait for the next meteor shower"
_____RECIPE_DESC.SADDLE_KUN = "Perfect solution to the saddle problem of sea mounts"
_____RECIPE_DESC.SHANHAI_SHELLCHEST = "So many shell fragments are finally useful"
_____RECIPE_DESC.SHANHAI_HIDDENCELLAR_USE = "Larger stone cellar"
_____RECIPE_DESC.BOAT_ANCIENT_CONTAINER = "Use your brain, this is not just for sailors"
_____RECIPE_DESC.SHANHAI_SMALLSTATUE = "Who knows why the activity won’t return?"
_____RECIPE_DESC.SHANHAI_FLOWERVINE = "Flowers bloom, the moon is full, and people live long"
_____RECIPE_DESC.SHANHAI_PINECONE = "Now we don't have to worry about it becoming extinct."
_____RECIPE_DESC.DEEPSEACAVE_UPGRADER = "Upgrade your tower space"
_____RECIPE_DESC.SH_SEASONAQUARIUM = "Let the growth of crops no longer be affected by the season"
_____RECIPE_DESC.SH_CHERRYSTATUE = "In memory of the friendship of the little monsters"
_____RECIPE_DESC.SHANHAI_SEED_GEM = "A more stable source of ancient fruit gem!"
_____RECIPE_DESC.SHANHAI_SEED_NIGHT = "A more stable source of ancient fruit nightvision!"
_____RECIPE_DESC.SHANHAI_SEED_TALLBIRDEGG = "Is this even considered an animal?"
_____RECIPE_DESC.SHANHAI_SEED_SHANSHEN = "Ginseng's Seed"
_____RECIPE_DESC.SHANHAIVINE_MOON = "Moon tree flower vine decoration"
_____RECIPE_DESC.SH_IRONOPENWORK_BASE_KIT = "Be careful not to set fire to the mountain"
_____RECIPE_DESC.SH_FIREWORKS = "Crow shaped fireworks"
_____RECIPE_DESC.SH_ROCK_1 = "A decorative stone landscaping piece"
_____RECIPE_DESC.SH_SEANEST_KIT = "Wooden pole? Mussels!"
_____RECIPE_DESC.SH_PLANTDECO = "They can be used to decorate bases"
_____RECIPE_DESC.SH_DESC = "MOD auxiliary documentation"
_____RECIPE_DESC.TURF_SH_ICELAND = "A thousand miles of frozen ice!"
_____RECIPE_DESC.TURF_SH_SMALLSTONE = "Small gravel scattered in gardens"
_____RECIPE_DESC.TURF_SH_XMM = "Thanks to XMM"
_____RECIPE_DESC.TURF_SH_COLORXMM = "Thanks to XMM again"
_____RECIPE_DESC.TURF_SH_LITTLESTONE = "Ground with large gravel pieces"
_____RECIPE_DESC.TURF_SH_MANYSTONE = "Ground with small gravel pieces"
_____RECIPE_DESC.DEEPSEACAVE_SEAL = "Write magical incantations on paper"
_____RECIPE_DESC.SH_QYSTICK = "Infuse bee stings with celestial energy"
_____RECIPE_DESC.SH_CRITTER_FOX_BUILDER = "Adopt a nine-tailed fox"
_____RECIPE_DESC.SHPIGHAT = "Let’s pretend to be a pigman"
_____RECIPE_DESC.SHANHAI_GINKGOLEAVE_GROUND = "Use ginkgoleaf to deco ground"
_____RECIPE_DESC.SHANHAI_GOUMANG = "Manually condense the spiritual energy"
_____RECIPE_DESC.SH_MIGUTREE = "Resurrect the glowing tree with the power of Goumang"
_____RECIPE_DESC.SH_MAGICSHANSHEN = "Craft Western artifacts with Eastern materials – soar into the skies!"
_____RECIPE_DESC.SH_ABYSSPILLAR = "It allows us to cross the ocean."
_____RECIPE_DESC.SH_ABYSSPILLAR_ITEM = "It allows us to cross the ocean."
-- _____RECIPE_DESC.SH_ABYSSPILLAR_BOMB = "Bomb stonesteps"
_____RECIPE_DESC.SADDLE_KUN_GROUND = "It doesn't matter where it comes from"
_____RECIPE_DESC.SH_BACKPACK_LEAF = "Rainproof & Insulated Backpack!"
_____RECIPE_DESC.SH_BASEFAN = "It makes my pot smells better."
_____RECIPE_DESC.SH_LEAFBOAT_ITEM = "Big around age of voyage！"
_____RECIPE_DESC.SH_PANFLUTE = "The recall from the Ancient"
_____RECIPE_DESC.SEASTACK = "We have wanted this for a long time!"
_____RECIPE_DESC.MARSH_PLANT = "We have wanted this for a long time!"
_____RECIPE_DESC.POND_ALGAE = "We have wanted this for a long time!"
_____RECIPE_DESC.DSC_MUSHROOM_TO_2 = "Now we can go to the first ground"
_____RECIPE_DESC.DSC_PIG_SHOP = "Shop owned by a pog"
_____RECIPE_DESC.DSC_COPYTOOL = "This will take us home"
_____RECIPE_DESC.XUANHE_FALL = "Make our own waterfall"
_____RECIPE_DESC.DSC_MUSHROOM_TO_2_BLUEPRINT = "Learn to make a mushroom?"
_____RECIPE_DESC.SHANHAI_GOUMANG_BLUEPRINT = "Collect this in our own way"
_____RECIPE_DESC.STATUE_CHAOFENG_BLUEPRINT = "All birds should follow this phoenix"
_____RECIPE_DESC.STATUE_ZHULONG_USE_BLUEPRINT = "His eyes controll day and night"
_____RECIPE_DESC.STATUE_EATMOON_BLUEPRINT = "Doggy wants to eat moon"
_____RECIPE_DESC.SH_CHERRYSTATUE_BLUEPRINT = "Blueprint of Splicing Blueprint"
_____RECIPE_DESC.XUANHE_FALL_BLUEPRINT = "Learn to make a waterfall"
_____RECIPE_DESC.SH_MIGUTREE_BLUEPRINT = "Learn to transplant a Migutree"
_____RECIPE_DESC.DSC_POOL = "Dig a hole. Fill it with water."

------------------------科技、绘卷--------------------------------
CRAFTING_FILTERS.SHANHAIJING = "Montfluv"
___________NAMES.SHANHAIJING_BOOK = "Montfluv Desc"

---------------------------------------------------------------
------------------------额外文本--------------------------------
---------------------------------------------------------------
-- 刷新皮肤
STRINGS.SH_SKINS_UPDATE = "Update Skins"
-- 种藤的等级
STRINGS.SH_LEVEL = "Level"
-- 时空卷饼
STRINGS.SH_TIMETACO_PRE = "Rolled "
-- 原山海经的文本
STRINGS.SHANHAIJING_UI = {
    BOOK_DESCRIBE = "Mist shrouds the mountain top, the stars silent",
    BOOK_BUTTON = "Legends",
    FENGHUANG = "Phoenix",
    KUNPENG = "Kunpeng",
    YAZI = "Yazi",
    ZHUYAN = "Zhuyan",
    ZHULONG = "Zhulong",
}
-- 皮肤名称
_______SKINNAMES.SH_CROW_MOON = "Moonflower"
_______SKINNAMES.SH_CROW_GOUMANG = "Goumang"
_______SKINNAMES.SH_FLOWER_WHITE = "White"
_______SKINNAMES.SH_FLOWER_ORANGE = "Orange"
_______SKINNAMES.SH_FLOWER_YELLOW = "Yellow"
_______SKINNAMES.sh_rock_1 = "Classic"
_______SKINNAMES.shanhai_decovine = "Classic"
_______SKINNAMES.shanhai_flowervine = "Classic"

-- 皮肤提示文本
STRINGS.SH_SKINS = {
    KEY_IS_NULL = "加密数据或密钥不能为空",
    DATA_IS_INVAILD = "无效的加密数据",
    DATAFORMAT_ERROR = "解密失败：数据格式错误",
    CDK_IS_NULL = "CDK不能为空",
    CDK_NOT_FULL = "请检查CDK是否标准且完整",
    CDK_DECRYPT_ERROR = "CDK解析失败",
    WITH_OTHER_CDK = "混进去了别人的CDK",
    CDK_IS_INVALID = "CDK无效",
    VALIDATE_SUCCESS = "兑换成功！",
    SYNC_SUCCESS = "同步成功，谢谢小老板的支持",
    SYNC_FAIL = "同步失败\n请检查脚本是否正在运行",
    CDK_BUTTON = "CDK兑换",
    SYNC_BUTTON = "刷新皮肤",
    CLOSE_BUTTON = "关闭",
    SKIN_INFO = "\n皮肤信息：",
    FAIL_INFO = "兑换失败：",
}

---------------------------------------------------------------
-------------------------台词文本--------------------------------
---------------------------------------------------------------
-------------------------鲲鹏的台词------------------------------
STRINGS.KUN_IDLE = {
    "The times have changed, the world has shifted.",
    "My kin once roamed the vast oceans.",
    "I have returned from the abyss…",
}
STRINGS.KUN_ATTACK_LINES = {
    "Freedom!",
    "Embrace my wrath!",
    "This world is no longer what it once was, but only revenge remains in my heart!",
    "Get away, mortal!",
}
STRINGS.KUN_ICE_LINES = {
    "My powers have drained too much...",
    "Freeze!",
    "Freeze them!",
    "Let's see if frost still obeys my command!",
}
STRINGS.KUN_SACK = {
    "My mana has drained away too much...",
    "This is a small token of appreciation...",
    "Thank you for visiting me",
}
STRINGS.KUN_EAT = {
    "Have you come to rescue me?",
    "They say there's a Grand Frost Shark in the ocean, and it has a collection of boots...",
    "I need a pair of escape leg boots, could you help me?",
    "Thank you for visiting me",
}
STRINGS.KUN_ESCAPE = {
    "Freedom!",
    "Time changes all things, times shift and the world alters",
    "Let us see whether the ocean still hearkens to my command!",
    "This world has changed beyond recognition, yet freedom forever lies in the heart!"
}

    -- 朱源的文本大部分由ChatGPT 4o生成，威吊自行调整
    -------------------------朱源的台词------------------------------
    STRINGS.ZHUYUAN_NIGHT = {
        "Leaving work on time is a pig's blessing.",
        "Even the most knowledgeable need their sleep.",
        "Brain is offline, urgently requires blanket reboot service.",
        "Piggy brain overloaded, returning to hut for recharge.",
        "A graceful pig never stays up late.",
        "You all keep hustling, this pig is going back to snuggle its pillow.",
        "The sun clocks out, so does the pig.",
        "Ha! The plump pig is at the door!",
        "My bed and I are deeply in love.",
        "Not being eager to leave work shows problematic thinking!",
        "Knowledge needs to settle, a pig needs to lie flat.",
        "The pig has an appointment with the Duke of Zhou.",
    }
    STRINGS.ZHUYUAN_STEAL_FOUND = {
        "This is a field study on food expiration dates!",
        "Piggy is researching the progress regulation of refrigeration technology...",
        "Ahem, the sealing of this fridge... leaves room for improvement.",
        "Piggy is helping you test the automatic sensor function of the fridge door.",
        "Wasting good things is a crime! Piggy is taking on the sin for you!",
        "It's hot out, piggy is just cooling down its stomach.",
        "The fridge door opened all by itself.",
        "It was gravity! It made this piece of meat land perfectly in piggy's mouth!",
        "Taste-testing for poison is a noble tradition passed down from the ancient Divine Farmer!",
        "Think bigger! Pay attention to the bigger picture! Sharing is a virtue!",
        "The heartwarming transfer in the food chain, do you even understand?",
        "The fridge started it! It tempted piggy with its cool air.",
        "Piggy didn't steal, the food offered itself willingly.",
        "The food emitted a soulful cry of 'Eat me quick!'",
    }
    STRINGS.ZHUYUAN_TOPLAYER = {
        "You folks eat to live. Piggy? Piggy lives to eat. It's my everything.",
        "Build more fridges! Piggy can be your live-in storage manager.",
        "Piggy'll hold the crow upside down, you grab the stuff that falls out. Teamwork!",
        "Do you even sleep?",
        "Zhu Yuan. Classy name, right?",
        "Can't read Pig Latin? Someone's general education is lacking.",
        "Back in Hamlet, Piggy served as a Royal Blade-Guard! Sworn to protect the crown!",
        "Here. A scrap for you.",
        "That getup of yours... more for show than for go, huh?",
        "A paper bird carries feelings; a letter bridges a thousand miles.",
        "What's that saying... 'He who holds the crab claws, commands the pigs and monkeys'?",
        "A pig's wisdom: half from books, half from the cookpot.",
        "If my teachings don't get through... Piggy's also versed in the 'fist-and-foot' doctrine.",
        "Know why pigs are so clever?",
        "Read the stars at night? Piggy's specialty is reading the fridge light at night.",
        "Theory on paper is shallow; true wisdom is held by the ladle by the wok.",
        "When Piggy hums a tune, it's in the pentatonic scale. All five notes, perfectly pitched.",
        "True wisdom? Three parts reading, seven parts a full belly.",
        "Piggy's got the entire recipe book memorized. Backwards and forwards.",
        "Good to see the Pig King is still alive and... well, being the king.",
        "Mastering this magic circle took Piggy ages. Show some respect!",
    }
    STRINGS.ZHUYUAN_OPENFRIDGE = {
        "Enter the village quietly, no shooting.",
        "Treasure hunt time!",
        "Zero-dollar shopping initiated!",
        "Just passing by. If something is conveniently acquired, that's fate.",
        "Steps must be elegant, movements must be swift.",
        "Piggy's appetite is very small.",
        "Unauthorized resource sharing.",
        "Fridge door, heed piggy's call!",
        "Let piggy see what surprises are in store today.",
        "Unboxing! Unboxing!",
        "Heart racing, that's the thrill of a mystery box.",
        "Piggy is inspecting its future assets.",
        "Piggy can open fridges. Piggy will show you!",
    }
    -- STRINGS.ZHUYUAN_FRIDGE = {
    --     "A fridge! The tower has a power system now?",
    --     "Wine and food satisfied, piggy struts out with confidence!",
    --     "A hundred steps after a meal, you'll live to ninety-nine.",
    --     "This cooling effect... is it the legendary Frost Formation?",
    --     "With a fridge, a pig's life is half complete.",
    --     "Piggy declares you the strongest!",
    -- }
    STRINGS.ZHUYUAN_COOK = {
        "Piggy calculates with its hoof, this pot likely foretells parting ways.",
        "Life makes it hard for a pig.",
        "Cooking is creation, washing dishes is destruction.",
        "Piggy can only guarantee it's cooked, not that it's tasty.",
        "These were going bad soon anyway.",
        "Ding! Random mystery meal online!",
        "Cooking is a high-stakes gamble.",
        "Gourmet feast or dark cuisine? Let heaven decide.",
        "Piggy handles the metaphysical part of cooking; the physics are left to the pot.",
        "Cooked is success; saltiness is a surprise from the heavens.",
        "According to piggy's recipe, it should be done this way.",
        "Secret recipe. Won't kill you.",
    }
    STRINGS.ZHUYUAN_COOKPOT = {
        "Are these pots just for decoration?",
        "Where there's a pot, there's hope.",
        "An empty pot disrespects the ingredients.",
        "It's time for this pot to fulfill its sacred duty.",
        "Pot, oh pot, when will you have your moment of glory?",
        "A pot without ingredients is like a pen without ink.",
    }
    STRINGS.ZHUYUAN_BACKSELF = {
        "Piggy's heard rumors of a certain chocolate tower...",
        "Post-meal digestion demands a proper, leisurely stroll. It's an art.",
        "That shady bird is definitely talking trash about me. I can feel it.",
        "A pig's journey is to the stars... and also to the kitchen attic.",
        "Check it! With this headlamp on, I'm officially a glow-in-the-dark pig!",
        "Second floor's done. But the third floor... remains a mystery.",
        "Bored because I'm full. Literally.",
        "To contemplate the pig life, one must begin with a walk.",
        "Piggy isn't getting fat. My knowledge is just gaining density.",
        "More walking equals more eating. It's basic caloric economics.",
        "A hundred paces roughly converts to... half a steamed bun. The math checks out.",
        "I climb high and gaze far... my gaze always finds its way to the kitchen chimney.",
        "Where the pig-light shines, no leftover shall remain hidden.",
        "This is the great principle: 'From stillness comes the urge to move; from fullness, the plot to eat again.'",
        "A true belly's capacity isn't just for food—it's to hold the spirit of all gastronomes under heaven.",
        "Suddenly felt a surge of energy in my trotters. Turns out it was just hunger.",
        "'Wisdom is like a fish'? Piggy humbly suggests 'Wisdom is like a pig' is superior.",
        "Quiet, you feathered nuisance.",
        "Hey, shady bird. Care for a lecture on 'Avian Cuisine 101'?",
    }
    STRINGS.ZHUYUAN_OVEREAT = {
        "Seven parts full, three parts grace, today... seems a bit lacking in grace.",
        "Reason tells piggy it's time to stop.",
        "There's nothing left to pique piggy's tasting desires.",
        "Burp~",
        "Piggy's stomach says yes, but piggy's belt says no.",
        "Piggy doesn't want to eat, it's the mouth that has a mind of its own.",
        "Food reserves... uh, seem to be reserved up to the throat.",
    }
    STRINGS.ZHUYUAN_GIVEBACK = {
        "Bare walls, chilly breeze, a bleak pig life.",
        "Is the player so poor that they need piggy's pity?",
        "Oh no, piggy might have eaten the player's economy into collapse.",
        "The famine has truly begun.",
        "It's time to launch a vigorous foraging campaign.",
        "Not even leftovers, a hopeless pig existence.",
        "Piggy must consider the feasibility of photosynthesis.",
    }
    STRINGS.ZHUYUAN_CANNOTCOOK = {
        "A gentleman stays away from the kitchen, the ancients spoke true.",
        "A pig's talents lie in broader fields.",
        "Cooking fumes are the enemy of knowledge.",
        "A pig's hooves are for holding books and chopsticks, not spatulas.",
        "Cooking interferes with a pig's pure appreciation of fine food.",
        "Different trades, different skills. Piggy specializes in the 'art of eating'.",
    }
    STRINGS.ZHUYUAN_STARVE = {
        "Ah! The hall of knowledge collapses from hunger!",
        "Feed me! Now! This is urgent academic aid!",
        "Energy low, four hooves taking root... can't move...",
        "Starving bodies everywhere! Here lies a pig on the verge of becoming one!",
        "Save the child! Save the piggy!",
        "Piggy's HP is visibly dropping to zero!",
        "Chest sticking to back, brain sending out an SOS.",
        "Limbs weak, innards empty, urgent feeding required!",
        "Piggy's stomach is singing 'The Legend of the Hungry Wolf'...",
        "Starving to the point of hallucinations...",
        "Hunger is torture for a piggy!",
    }
    STRINGS.ZHUYUAN_STARVE_SUCCESS = {
        "You are indeed a person of great sense!",
        "A whiff of cooked food is piggy's Greater Resurrection spell!",
        "Piggy feels knowledge and strength returning together.",
        "A drop of kindness should be repaid with... with another bowl!",
        "You have saved piggy's world.",
        "You are piggy's savior! Ahem, food-savior!",
        "Piggy will compose a poem for you after eating!",
        "Such kindness, such virtue, unforgettable! Not really.",
        "From today, you are piggy's chief caretaker.",
        "Feels like intelligence has retaken the high ground.",
        "This favor, piggy will remember it in the stomach for now!",
        "Thank you. You have preserved a spark of wisdom for the world!",
        "Alive again!",
    }
    STRINGS.ZHUYUAN_STARVE_FAIL = {
        "The world is cold, a pig's heart is proof...",
        "The player's conscience must have been stolen along with the food.",
        "Miscalculation, should have picked a center-stage spot to play dead.",
        "Piggy is dying, dying peacefully... yeah right!",
        "Noted in the little book, the Nth time being ignored.",
        "Is this human nature? Piggy sees through it.",
        "Piggy's tombstone will read: Died from player's indifference.",
        "Never teaming up with players who don't feed piggy again.",
        "The heart is so cold, colder than the foodless stomach...",
        "Piggy is here, the food is far away.",
        "Not even piggy's sacrifice can earn you a shred of guilt?",
        "Piggy's legacy... is... a bellyful... of air.",
    }
    STRINGS.ZHUYUAN_DANCE_PLANT = {
        "Dang Dang Kang Kang, grow up quick~",
        "Growth, life, happiness, and my buddy~",
        "Grow! Grow! Grow! Fast and well!",
        "Lord Goumang! Help out, grow a radish three feet long!",
        "In the name of Dangkang, I grant you vitality!",
        "Boogie-woogie, grow quick, hope for extra rations tonight!",
        "Grow leaves, bloom flowers, bear fruit for piggy to praise!",
        "Grow quick, grow plump, piggy's tummy is in command!",
    }
    STRINGS.ZHUYUAN_CANNOT_DANCE = {
        "The feng shui here is poor, affects piggy's spellcasting.",
        "The ritual array requires space.",
        "Forget it, today is not a good day for ground-breaking.",
        "Killing intent detected! Not suitable for rituals.",
        "The local ley lines here are clogged, let piggy clear them first.",
    }
    STRINGS.ZHUYUAN_TALK_PANICBOSS = {
        "Pig slaughter! Help!!",
        "Run for it!",
        "Tactical retreat! Quick!",
        "Pig life is at stake, idlers disperse!",
        "Run! Or wait to become braised pork?",
        "A gentleman does not stand under a perilous wall, and neither does a pig!",
    }
    STRINGS.ZHUYUAN_TALK_FIND_MEAT = {
        "A pig's willpower is no match for a delicious meal. It shatters at the sight.",
        "This... this delicious, damnable temptation.",
        "Food! It smells like... freedom.",
        "One bite. How many pounds will that cost Piggy?",
        "This isn't gluttony. This is... a pious pursuit of gastronomy.",
        "This is an open conspiracy! The meat made the first move!",
        "Ancient tales praise Liu Xiahui for his restraint. Modern tales... shall we not speak of Piggy before meat?",
        "The meat glistens, the plate is just right.",
        "If that shady bird saw this, the heckling would be relentless.",
        "All of Piggy's spiritual cultivation crumbles at the sight of meat.",
        "Piggy reflects thrice: Can I eat it? Should I eat it? And most importantly... *How* do I eat it?",
        "To inhale this savory aroma is to hear the primordial music of creation itself.",
        "This meat is an auspicious cloud. A sign of good fortune.",
        "That meat hasn't even been on the ground for three seconds yet. The rules are clear!",
    }
    STRINGS.ZHUYUAN_TALK_ATTEMPT_TRADE = {
        "The way you're looking at piggy isn't very pure?",
        "Goods for goods, or food for service?",
        "Equivalent exchange, fair to all.",
        "Want to trade something with piggy? Show your sincerity.",
        "Goods for cash, on the spot.",
        "Piggy's got all the good stuff.",
    }
    STRINGS.ZHUYUAN_TALK_GIVE_GIFT = {
        "Pig-nose minted coins, honest and fair!",
        "Take it, take it, don't bother piggy while eating.",
        "Here, a reward for you, don't spread it around.",
        "This item is fated for you.",
        "Keep it safe, at a critical moment it might... might trade for a steamed bun.",
        "A pig's gift contains... hmm... a pig's heartfelt wishes.",
    }
    STRINGS.ZHUYUAN_FIGHTCROW = {
        "Enough talk! Let's dance!",
        "What'll it be? A duel of magic... or a contest of appetite?",
        "Piggy's battle strategy: Overwhelming Mass Persuasion!",
        "The skills of a Royal Blade-Guard are not forgotten!",
        "You raucous fowl! Behold the 'Meat Tank Assault'!",
        "Still wet behind the feathers? Fine. Piggy will give you three free shots.",
        "Today, you learn the true meaning of 'Knowledge is Weight'!",
        "Once Piggy gets a full charge going... not even Piggy can stop it!",
        "Unstoppable Pig Rush!",
        "Courtesies observed. Now, have at you!",
        "Allow Piggy to demonstrate a few moves from 'Butchering the Ox'... on you!",
        "Eat this! The World-Shaking Burp!",
        "Lord Dangkang forbids violence... but for a bird as foul as you? He'd make an exception.",
        "Time to shut that beak of yours. Permanently.",
        "You! Shady-feathers! You stole Piggy's snacks!",
    }
    STRINGS.ZHUYUAN_GOSHOP = {
        "Pig's shop, meat galore, enough to make a crow sneer.",
        "Coming, coming!",
        "Right this way, honored guest!",
        "Just a moment, if you please~",
        "The pig is at the door!",
        "Make way! Pig coming through!",
        "No touchy if you're not buying!",
    }
    STRINGS.ZHUYUAN_HITSHOP = {
        "Are you here to wreck the place?!",
        "My shop... my everything... it's the end of the world!",
        "You'd better build me a new one, got it?",
    }
    STRINGS.ZHUYUAN_TALKSHOP = {
        "Hands to yourself, please.",
        "What can Piggy get for you?",
        "Service with a smile~",
        "Your highness~",
    }
    STRINGS.ZHUYUAN_BREWSHOP = {
        "Ready in a jiffy!",
        "Just restocking the goods!",
        "Fine work can't be rushed!",
    }

    -- 羽润的文本大部分由ChatGPT 4o生成，威吊自行调整
    -------------------------羽润的台词------------------------------
    STRINGS.YURUN_SHOCK = {
        "Uh-oh, someone cast a spell on Crow!",
        "Achoo!",
        "Crow's head!",
        "An air raid!?",
    }
    STRINGS.YURUN_ANGRY = {
        "You're beyond redemption. Don't let me catch you next time!",
        "Back in my day, I had way more manners than you!",
        "Yā and you aren't best friends anymore!",
        "Did you deceive crow's feelings?",
        "Yā doesn't want to talk to you today",
        "Contact crow less from now on",
        "Arrogant little monster, you'll become roast crow courtesy of the fierce beasts!",
        "Crow's gonna kick some ass",
        "You won't leave hostile status this week!",
        "Your karma -1! -1! -1!",
        "You're on crow's Untrustworthy List!",
        "Your weekly karma has been reset to zero！",
        "Crow will remove you from the shared playlist",
        "Crow think your conscience has left you",
        "Crow will add you to 《The Villain's Guide to Self-Destruction》",
        "You'll be struck by lightning and lose all feathers when leaving the tower!",
        "You're truly not a good bird!",
    }
    STRINGS.YURUN_CAMPFIRE = {
        "The campfire's light comforts the crow",
        "The fire looks like the wings of the Phoenix!",
        "Humans are so skilled at making fire",
        "The crow wants a fire bowl with wings",
        "Shall we add some more branches to the fire?",
        "Phoenix once loved using fire to comb its feathers",
        "Don’t get too close to the fire, my feathers are not fireproof",
        "Be careful, don't burn the crow",
        "The crow feels like the fire god Zhu Rong",
        "The crow also wants to help you add fuel",
        "I feel warm all over",
        "The crow loves the campfire",
        "The crackling sound of the fire",
        "Fire can scare away monsters",
        "The crow feels full of vitality",
        "If the fire is too strong, the crow might become a roasted crow",
        "If the fire is too weak, the crow will shiver",
    }
    STRINGS.YURUN_TOCHERRYPLAYER = {
        "Can you tell me about the cherry forest?",
        "I also want to see the cherry forest",
        "He told me many stories about the cherry forest!",
        "There's a piece of land from the cherry forest in the tower!",
        "The crow wants to try cherries",
        "Are there magical flowers in the cherry forest?",
        "Is it true that it rains cherry blossoms in the forest?",
        "He said the wind in the cherry forest smells sweet!",
        "Is that ancient cherry blossom tree real?",
        "Is the legend of the cherry forest true?",
        "The cherry forest is as beautiful as a dream",
        "Are there blue cherries?",
        "Cherry Coke? Emmm, forget it.",
    }
    STRINGS.YURUN_TOPLAYER = {
        "I met a girl named Charlie, she’s not easy to mess with",
        "Have you seen the Phoenix?",
        "Do you need something from the crow?",
        "Hello, little featherless monster",
        "The crow is very curious about you",
        "Will you be the crow’s good friend?",
        "Looking for help? Just so you know, the crow is not good at fighting!",
        "The crow thinks humans overthink things",
        "Hey! Hey! I’m hungry",
        "Can I borrow your weapon to play for a bit?",
        "I like staying with you",
        "Can the crow help?",
        "You seem very busy",
        "The crow thinks you’re amazing!",
        "Can you teach the crow something you know?",
        "You look very busy, it's so attractive to the crow",
        "Are you distracted?",
        "Tell me a little secret, I will keep it",
        "Am I special?",
        "The crow is the smartest bird in the tower!",
        "The crow thinks you are like him",
        "You look like a hero",
        "Crow hopes you receive crimson gifts every day",
        "Crow got a new hairstyle today, what do you think?",
        "Are you here to pluck crow's feathers?",
        "Did you miss crow?",
        "Crow think it's time you changed your outfit",
        "You scared crow!",
        "No feathers, no tail! Poor you!",
        "Magic is taught to crows, not humans. Go ask the pigs!",
        "Did you find the phoenix's feather?",
        "You're so talented - learn from Crow and be a crow!",
        "The pig claims to be a royal guard? Actually, it was only in charge of tasting the dishes!",
    }
    STRINGS.YURUN_BACKSELF = {
        "The crow likes its name, but that silly pig always gets it wrong!",
        "The crow has learned a few words in other languages...",
        "Meow, meow meow... meow meow",
        "Western magic, Eastern magic, Crow all knows a little bit",
        "The crow wants to try a cup of Shan Hai Bubble Tea",
        "The crow wants phoenix's feather...",
        "Sometimes crow also wanna taste the koi, for a little bite……",
        "The crow has a renovation plan, needs help moving big stones",
        "I miss him",
        "That moonglass broke the tower",
        "Yes, I used magic to fix this tower",
        "The crow wants to eat shiny stones",
        "The air here is so dry",
        "Why is the world so big, and the crow so small?",
        "The crow can’t leave this tower",
        "I miss the comfort of my nest",
        "The dark places scare the crow",
        "That tree is strange, I suspect it’s transformed from a monster",
        "I still prefer my little nest",
        "The crow wants more flashy feathers",
        "In the past, the crow and the silly pig could freely enter and leave the tower",
        "A-choo! The stupid pig is scolding the crow!",
    }
    STRINGS.YURUN_NIGHT = {
        "Good night",
        "The crow is going back to the nest",
        "I’m so sleepy",
        "My little bed, here I come",
        "I want to rest",
        "The wind feels nice",
        "The wind is gentle tonight",
    }
    STRINGS.YURUN_SCARED = {
        "Enemy attack, hide!",
        "Don’t move!",
        "The crow's feathers are standing up",
        "Don’t disturb it!",
        "Chirp!",
        "Hurry and hide",
        "The enemy is here!",
        "Is it a monster?",
        "Hurry, retreat!",
        "Hurry, run!",
        "The crow's legs are weak!",
        "That's not good!",
    }
    STRINGS.YURUN_HASGIFT = {
        "Thank you, but let the crow finish its snacks first",
        "Wait a moment, crow",
        "The crow can’t reach it",
        "Do you want to make the crow fat?",
        "Thanks, but the crow needs to lose weight",
    }
    -- STRINGS.YURUN_KEEPGIFT = {
    --     "The crow got another gift!",
    --     "The crow is so touched",
    --     "You're so nice",
    --     "I like this",
    --     "Such a thoughtful gesture",
    --     "Is this really for the crow?",
    --     "The crow will treasure it",
    -- }
    STRINGS.YURUN_REFUSEGIFT = {
        "If you insist, the crow might throw it away",
        "Leave this for the silly pig",
        "The crow thought you understood it",
        "The crow doesn’t like it",
        "The crow doesn’t need this",
        "Give it to the bird in the cage!",
        "This... the crow doesn’t like it",
        "This isn’t right for the crow",
        "You can keep this one",
        "This thing is too heavy",
        "Is this really all you have for the crow?",
    }
    STRINGS.YURUN_COOKPOT = {
        "Is this food for the crow?",
        "What’s cooking in the pot?",
        "The crow smells something delicious",
        "The crow wants to taste a little bit",
        "The crow’s mouth is watering",
        "I hope it’s not crow blood noodle soup",
        "It smells like the crow's favorite!",
        "Can the crow eat this?",
        "The crow is so hungry right now",
        "Did you put the fruits the crow likes in here?",
        "This taste seems familiar to the crow",
        "The crow is eyeing the food",
        "Is this specially made for the crow?",
        "Can I have a taste?",
        "The crow is ready to enjoy the deliciousness",
    }
    STRINGS.YURUN_KNOCKPIG = {
        "Silly pig, come out!",
        "Lazybones, get up!",
        "Silly pig, the crow prepared fresh pork belly",
        "Come out, or the crow will set the tower on fire!",
        "Come out, the tower is on fire!",
        "Those hairless little monsters want to see the pig",
        "Silly pig, are you still alive?",
        "Come out or the crow will pluck the pig's hair!",
        "Someone outside says you're lazier than a pig!",
        "Open the door, the crow found a dancing duck!",
        "Silly pig, there are stones growing on the tree, come see!",
    }
    STRINGS.YURUN_HAPPYDANCE = {
        "I need to practice magic diligently",
        "Hope you enjoy~",
        "Hope this meets your satisfaction~",
        "This is crow's best effort",
        "A newly learned spell by crow",
        "Gather spirits, flames!",
        "Crow must gather spiritual energy!",
        "To show respect!",
        "Burn!",
    }
    STRINGS.YURUN_ADDFUEL = {
        "The campfire isn’t bright enough",
        "The crow found a good piece of wood",
        "The fire can’t go out",
        "The crow is a firepit genius",
        "The campfire needs more wood",
        "The flame isn’t bright enough",
        "The campfire looks much better now",
        "The crow is a fuel expert",
        "Add some firewood",
        "The crow is here to save the fire",
        "Isn’t the crow amazing?",
        "Don’t worry",
        "The campfire is the most important companion at night",
        "The crow feels like it helped a lot",
    }
    STRINGS.YURUN_CHERRYGIFT = {  
        "Cherries! Big fat cherries!",  -- Preserves childish excitement with "big fat"  
        "Crow never tasted these! Crow thanks you!",  -- Retains "Crow" self-referential speech pattern  
        "You saw Cherry Forest? Impressive Crow!",  -- Keeps "sakura" for Japanese cherry blossom lore consistency  
    }  
    STRINGS.YURUN_MAGICGIFT = {  
        "Western magic, Eastern magic, Crow all knows a little bit！",  -- "dabbles" conveys casual mastery  
        "For you wingless ones, use this magic instead!",  -- Emphasizes crow's avian perspective  
        "Crow stole this spell from a wizard!",  -- Adds mischievous tone with "Stolen" and "Shhh"  
    }  
    STRINGS.YURUN_GIVEGIFT = {
        "This is the crow's treasure",
        "Treasure it well",
        "This is a carefully selected return gift from the crow",
        "This is a gift from the crow to you",
        "The crow immediately knew this was for you",
        "This is something the crow ‘borrowed’ from somewhere else",
        "Isn’t the crow generous?",
        "Be good to the crow from now on",
        "The crow thinks this thing is magical, it’s for you",
        "Don't hesitate to use it!",
        "You’ll need this",
        "This is no ordinary item",
        "A little token of the crow's kindness",
        "The crow got this with its cleverness",
        "Don’t ask how the crow got it",
        "This is specially prepared for you by the crow",
        "This item is quite valuable, isn’t it?",
        "Crow received a gift!",
        "Crow is so moved!",
        "You're so kind!",
        "I love this!",
        "That's incredibly thoughtful!",
        "Is this really for me?",
        "I will cherish it dearly!",
    }
    STRINGS.YURUN_GETFEATHER = {
        "You found the Phoenix Lord!",
        "Phoenix's feathers!",
        "You're now crow's best friend!",
        "Crow's been searching for this!",
    }
    STRINGS.YURUN_FIGHTPIG = {
        "Crow's gonna spank that piggy butt!",
        "Crow... DIVE-BOMBER!",
        "That perfectly round pig rump is just right for claw sharpening!",
        "'Unstoppable Pig Rush'? Looks more like a sticky rice roll tumbling down a hill!",
        "I'll plant a feather on you and use you for a kick-shuttlecock!",
        "Don't you dare start squealing when you lose!",
        "Grounded, flightless, pig!",
        "In all martial arts, only speed is unbreakable! And I've got it!",
        "I'm out of patience! Just like you're out of belt notches!",
    }

-- 强制离开二岛的台词
STRINGS.DSC_FORCEMOVE = {
    "I shouldn't have trespassed here!",
    "What is this?!",
    "I'm not worthy to tread here",
    "The island is repelling me!",
}

-- 芝上谈冰缺少材料
STRINGS.SH_NO_INGREDIENT = {
    "I can't do it",
    "Ingredients are not enough",
    "I learn it, but can't do it",
    "Try to build this without ingredients?",
    "We have to collect these ingredients!",
}

-- 野生猪人的线索文本
STRINGS.REFUSE_READ = {
    "No meat, why should I help?",
    "Ask for help empty-handed?",
    "Not friends, won't help read",
    "Unless you pay consultation fee",
    "You promised me dinner last time",
    "Want free service? Borrow rice without firewood?",
    "Pigman isn't free labor!",
    "Meat! Meat! Payment first!",
}
STRINGS.REDPAPER_CLUE_PRE = {
    "It reads:",
    "Let me see:",
    "Faintly visible:",
}
STRINGS.THE_ONLY_PASSWD = "Montfluv Tower solution: "
STRINGS.THE_FAIL_PASSWD = "Password Lost"
STRINGS.REDPAPER_CLUE_CORRECT = {
    -- "Xuanhe Island lies beyond this world...",
    -- "Xuanhe Jade is the key to access the Xuanhe Island.",
    "Fireflies and Fragrant Blossoms All Welcomed : Petals, lightbulb...",  
    "Ancient Celestial Aura : Goumang's Fruit",  
    "Golden Leaves Flutter Like Butterflies : Ginkgo Leaf",  
    "No Trace of Frost's Bite : Gems", 
    "Empty Elixir? You should have collected it anyway!",
    "Give Yurun a Pumpkin during Full Moon to learn magic~", 
}
STRINGS.REDPAPER_CLUE = {
    "你要帮帮威吊！",
    "情谷底，我在绝",
    "有内鬼，终止交易",
    "我想偷走你的心，白玉汤顿首",
    "...熹贵妃安?",
    "all work and no play make jack a dull boy",
    "We really miss Gravity Fall!",
    "tell Monica I'm sorry",
}

-- 烛龙的文本
STRINGS.ZHULONG = {
    GIFT = {
        "As you wish...",
        "Congratulations..",
        "Worthy celebration...",
    },
    FIGHT = {
        "You dare challenge me?",
        "The time isn't ripe, child...",
        "Return when mastering spacetime...",
    },
    SUPERIOUS = {
        "Montain!",
        "River!",
    },
    WRONG = {
        "Use your little brain, child",
        "Try luck with boar tribe",
        "Check those paper swallows...",
        "Clues hide on paper swallows",
        "Guessing randomly? Really?",
        "I can't read pigman's script either",
    },
    EATTACO = {
        "Delicious!",
        "Oh? An offering for me?",
        "Your tribute is acknowledged, young one.",
    },
    TIMETACO = {
        "Thief of time!",
        "Chrono-thief!",
        "My space-time power... pilfered!",
    },
}

-- 长老的文本
STRINGS.DC_ELDER = {
    START = {
        "You've come.",
        "Care for a game?",
        "Play to win, but friendship is a close second.",
    },
    ANOTHER = {
        "Oh? You wish to try as well?",
        "No issue. This is a game for two, after all.",
        "Go on then, challenger.",
    },
    INGAME = {
        "Very well. I shall handle this personally.",
        "Allow me to demonstrate.",
        "I shall give you a lesson.",
    },
    NEXTMOVE = {
        "Hmm...",
        "Yes, yes... wait, no. Or is it?",
        "You can't possibly win with just five pieces, can you?",
        "No tricks now.",
        "This spot seems... appropriate.",
        "...",
        "It's easier to see the whole board from the sidelines."
    },
    REWARD = {
        "Here's your reward!",
        "Gotta have a little prize, right?",
    },
    EQUALWIN = "It's a draw!",
}

STRINGS.TICTACTOE = {
    ALREADYIN = {
        "I'm already in the game.",
        "Can't join twice, you know.",
    },
    GAMEIN = {
        "I'll have to spectate for now...",
        "Match in progress.",
    },
    STARTGAME = {
        "I'm gonna win this!",
        "I'm a Tic-Tac-Toe master, you know.",
    },
    ANNOUNCE_PRE = "Game on! Player (",
    ANNOUNCE_PST = ") goes first.",
    NOTGAMETINE = {
        "The game hasn't started yet.",
        "Not the right time!",
    },
    OUTGAME = {
        "I'm not part of this match.",
        "No backseat gaming!",
    },
    WRONGPIECE = "I used the wrong piece.",
    WRONGTURN = "It's not my turn.",
    WRONGPLACE = "Invalid spot.",
    ALREADPLACED = "There's already a piece there.",
    GAMEGOON_PRE = "Player (",
    GAMEGOON_PST = ")'s turn.",
    WIN_PRE = "Player (",
    WIN_PST= ") wins!",
    ANOTHERROUND= "Alright, one more round!",
    TIMEOUT = "Took too long. Time to call it...",
}

---------------------------------------------------------------
-------------------------加载界面的文本台词----------------------
---------------------------------------------------------------
STRINGS.UI.LOADING_SCREEN_MONTFLUV_TIPS = {}
---------------------------------------------------------------
-------------------------天狗食月的事件台词----------------------
---------------------------------------------------------------
STRINGS.START_EAT_MOON = "A dog’s bark echoes in the sky.."
STRINGS.SUCCESS_EAT_MOON = "The moonlight fades away..."
STRINGS.BREAK_EAT_MOON = "Careful, it’s falling down…"


---------------------------------------------------------------
------------------------    宣告文本    ------------------------
---------------------------------------------------------------
-- Mountain Sea Herbal Jelly
________COOKBOOK.FOOD_EFFECTS_SHANHAI_BUBBLETEA = "Yurun has great taste!"
________ANNOUNCE.FOOD_EFFECTS_SHANHAI_BUBBLETEA = {
    "Refreshing and cooling",
    "I feel significantly calmer",
    "Yurun has great taste!",
    "No wonder Yurun loves this!",
}
-- Zhishang Shaved Ice
________COOKBOOK.FOOD_EFFECTS_SH_GANOERMAICE = "Knowledge from books is shallow, true understanding requires action"
________ANNOUNCE.FOOD_EFFECTS_SH_GANOERMAICE = {
    "Knowledge from books is shallow, true understanding requires action",
    "Helpful, but I should learn by doing",
    "This can tide me over temporarily",
    "Creative juices are flowing now!",
}
-- Elixir of Immortality
________COOKBOOK.FOOD_EFFECTS_SH_NEVEROLD = "My organs didn't get the immortality memo..."
________ANNOUNCE.FOOD_EFFECTS_SH_NEVEROLD = {
    "Maybe I won't age, but baldness isn't covered",
    "My organs didn't get the immortality memo...",
    "Since I'm immortal, guess I'll work till the Big Crunch",
    "Tastes like expired milk!",
}
-- 山河卷饼
________COOKBOOK.FOOD_EFFECTS_SH_TACO = "Keep the shell thin, the filling thick!"
________ANNOUNCE.FOOD_EFFECTS_SH_TACO = {
    "Delicious, but it doesn't quite hit the spot.",
    "Zhulong is rather fond of this..",
    "A staple of Mexican cuisine",
    "I could go for another",
}
-- 不允许卷饼的食物
________ANNOUNCE.ACTIONFAIL.SHROLLFOOD = {
    BANFOOD = "The author says this is way too OP. Nope.",
}
-- 沾光失败
________ANNOUNCE.ACTIONFAIL.MIGU_ZHANGUANG = {
    TOOLOW = "Mine is better",
}
-- 沾光成功
________ANNOUNCE.ANNOUNCE_ZHANGUANGE = {
    "Helpful, for me!",
    "We need to help each other",
    "Player helps player",
}
-- 召回钦原
________ANNOUNCE.ACTIONFAIL.BEEBACK = {
    BACKFAIL = "Someone calls it back first!",
}
-- 给予鲲鹏物品
________ANNOUNCE.ANNOUNCE_KUNPENG_TRIBUTE ={
    "I brought you something!",
    "This is for you!",
    "Woah... you're, emmm, big!",
}
-- 逼供纸燕
________ANNOUNCE.ACTIONFAIL.FORCEWRITE = {
    CANNOTWRITE = "Well, you know nothing",
}
-- 给句芒普通肥料
________ANNOUNCE.ACTIONFAIL.FERTILIZE = {
    NOTXIRANG = "I don't think this is the nutrients it wants",
}
-- 寄生种藤失败
________ANNOUNCE.ACTIONFAIL.LODGEOCEANTREE = {
    WRONGSEED = "I can't put it in",
    NOOCEANTREE = "There is no planted tree inside",
}
-- 放生发光蟹失败
________ANNOUNCE.ACTIONFAIL.RELEASECRAB = {
    NOOCEANTREE = "There's nothing to cling to in the water, they'll drown",
    ISINFECTED = "This area is already colonized by glowcrabs",
}
-- 恶搞羽润时间不合适
________ANNOUNCE.ACTIONFAIL.MIGU_DEST = {
    NOTGOODTIME = "Hey, he's busy",
}
-- 恶搞羽润
________ANNOUNCE.I_AM_BAD = {
    "Huh, we're being mischievous",
    "Oops, that was 'accidentally' intentional",
}
-- 寄生种藤
________ANNOUNCE.ANNOUNCE_LODGE_OCEANTREE = {
    "The vinelet needs a host tree",
    "Grow quickly~",
}
-- 放生发光蟹
________ANNOUNCE.ANNOUNCE_RELEASE_CRAB = {
    "Here shall be your new home",
    "Yurun has made new little friends",
}
-- 施肥子圭科技
________ANNOUNCE.FERTSIVING = {
    "The Zigui sapling depletes soil nutrients rapidly",
    "It needs time to recover now",
}
-- 采集迷榖树
________ANNOUNCE.PICK_UP_MIGU = {
    "Now I won't get lost",
    "It'll light my path",
    "I sense this will be useful",
}
-- 给百鸟朝凤多余羽毛
________ANNOUNCE.ALREAY_GOT = {
    "Adding more won't help",
    "This isn't a feather duster",
}
-- 捕捉钦原
________ANNOUNCE.ANNOUNCE_NET_QINYUAN = {
    "Don't let it escape!",
    "Its stinger is too sharp",
}
-- 给鸟笼中的纸燕奇怪的东西
________ANNOUNCE.ANNOUNCE_GIVE_PAPERBIRD = {
    "Do paper birds eat this?",
    "Maybe give it a quill instead",
    "It's not a real bird after all",
    "Just tell me what you want in plain words!",
}
-- 钦原死亡
________ANNOUNCE.ANNOUNCE_QINYUAN_DEATH = {
    "My fault!",
    "No！",
    "It's dead！",
}
-- 钦原召回
________ANNOUNCE.ANNOUNCE_QINYUAN_RETRIEVE = {
    "Come back~",
    "You should have a rest now",
    "Hey！Don't point at me！",
}
-- 激怒钦原
________ANNOUNCE.ANNOUNCE_QINYUAN_AGGRESSIVE = {
    "Go crazy!",
    "Fight！",
    "Stick harder!！",
}
-- 平息钦原
________ANNOUNCE.ANNOUNCE_QINYUAN_DEFENSIVE = {
    "Calm down~",
    "Oh, come back",
    "You should really control yourself",
}
-- 拯救鲲鹏
________ANNOUNCE.ANNOUNCE_KUNRIDER_GOODBYE = {
    "Goodbye, big guy!",
    "Be careful next time~",
}
-- 锁妖失败
________ANNOUNCE.ACTIONFAIL.DSCCAVESEAL = {
    NOSPAWNER = "It's too far from his home",
    SOMETHINGWRONG = "Something wrong about this!",
    CANTSEAL = "Not a good time!",
}

-------------------------封印洞天的事件台词-----------------------
STRINGS.SHANHAI_SEAL = {
    SUCCESS = "Sealed successful",
    FAIL = "It doesn't match, the seal failed",
    WIRED = "Its origin is problematic and lacks sealing power",
}
-------------------------采集樗里的事件台词-----------------------
STRINGS.GOUMANG_LINES = {
    "Did something fall down?",
    "The essence of heaven and earth!",
    "The mysteries of the universe must not be underestimated",
}
-------------------------星引吸引物品的检查----------------------
STRINGS.WXTY_LINES = {
    "This is impossible!",
    "Where are you going?",
    "Hurry and grab it!",
    "I see my things flying in the sky!",
    "Level 1 alert, suspected Leopard Tornado sighting!",
}
-------------------------悬河秘境开启文本------------------------
STRINGS.XUANHE_GEN = {
    "The ways of heaven are hidden, the mortal world remains ignorant",
    "The wilderness returns, all things fall silent",
    "The sky remains silent, Xuanhe whispers softly",
    "The divine bird soars high, and the four seas tremble",
}
-------------------------朱厌击杀天道文本------------------------
STRINGS.ZHUYAN_DEAD = {
    "Damn！",
    "Don't gloat",
    "You think you can really kill me?",
    "No one can kill me",
    "Just the fall of an incarnation",
    "We will meet again!",
    "I will be back!",
}
STRINGS.ZHUYAN_MUSIC = {
    "Demonic Melody!",
    "Bewitchment!",
    "Insanity!",
    "Lost!",
}
STRINGS.ZHUYAN_SUMMON = {
    "War Cry!",
    "Chaos Reigns!",
    "Soldier Mutiny!",
    "Infighting!",
}
-------------------------烛龙宣告文本------------------------
STRINGS.ZHULONG_TEXT = {
    "Day, Dusk and Night！",
    "Only Day！",
    "Only Dusk！",
    "Only Night!",
    "Long Day！",
    "Long Dusk！",
    "Long Night!",
    "No Day！",
    "No Dusk！",
    "No Night!",
}

---------------------------------------------------------------
------------------------不同物品的检查文本------------------------
---------------------------------------------------------------
-- 特殊物品【弃用】
________DESCRIBE.KUNPENG = "The super super super underwater overlord from the North Sea"
________DESCRIBE.KUNPENG_ATTACK_HORN = "Are you kidding?"
________DESCRIBE.KUNPENG_HORN = "Like a hill"

-- Altar
________DESCRIBE.DEEPSEACAVE_UPGRADER = {
    IS_COOLDOWN = "Not ready yet?",
    IS_HOLDING = "Is this the right choice?",
    GENERIC = "Items placed on it often disappear",
}
-- Exit
________DESCRIBE.DEEPSEACAVE_EXIT = {
    NO_ACCESS = "Who locked the door?",
    GENERIC = "We need to build an elevator",
}
-- Twisted Tree
________DESCRIBE.DSC_OCEANTREE_PILLAR = {
    SINGLE_PAINTED = "Who painted that?",
    DOUBLE_PAINTED = "I want to paint myself too",
    LIGHT_SHOW = "Unbelievable",
    GENERIC = "Its resilience has found a way out",
}
-- Ganoderma
________DESCRIBE.SHANHAI_GANODERMA = {
    PICKED = "Let’s see how the little mushroom gets arrogant now",
    GENERIC = "A tiny devil growing on the ground",
    INGROUND = "What is that? A lollipop?",
}
-- Ginkgo Tree
________DESCRIBE.SHANHAI_GINKGO_TREE = {
    BURNT = "Sorry",
    SHORT_STUMP = "We should feel ashamed",
    SHORT = "It doesn't have many leaves",
    NORMAL_STUMP = "I’m truly sorry",
    NORMAL = "Do plants have awkward phases too?",
    TALL_STUMP = "We shouldn’t have done this",
    TALL_YELLOW = "It’s like golden butterflies are hanging from it",
    GENERIC = "I prefer its golden look",
}
-- Deepsea Tower
________DESCRIBE.DEEPSEACAVE = {
    IDLE = "Inside lies a mysterious little world",
    IDLE_DEPLOY = "It looks small from the outside, but it’s surprisingly spacious inside!",
    ACTIVATE = "Wow… amazing!",
    GENERIC = "Pack it up and take it!",
}
-- Pig House
________DESCRIBE.DEEPSEACAVE_PIGHOUSE = {
    CAN_KNOCK = "Open up!",
    PIG_OUT = "Pig's out, can I move in?",
    GENERIC = "I rrrrreally wanna move in!",
}
-- Yurun (Crow)
________DESCRIBE.DEEPSEACAVE_CROW = {
    SIT_LOOP = "It’s so well-behaved",
    HOLD = "Whoa, it’s heavy",
    SHOW = "I want to give it a hug",
    TOP = "Today, we’re all Super Mario",
    GENERIC = "It’s not like other little crows",
}
-- Shadow Pool
________DESCRIBE.DEEPSEACAVE_POOL = {
    GENERIC = "Such clear and cool water",
}
-- Deepsea Tower Seal
________DESCRIBE.DEEPSEACAVE_SEAL = {
    GENERIC = "Can a few symbols drawn on paper really work?",
}
-- Tower Walls
________DESCRIBE.DEEPSEACAVE_WALL = {
    GENERIC = "It keeps me from falling into the void",
}
-- Cloud Saddle
________DESCRIBE.SADDLE_KUN = {
    GENERIC = "Is this real cloud?",
}
-- Phoenix's Bubble Tea
________DESCRIBE.SHANHAI_BUBBLETEA = {
    GENERIC = "Was the cup made in the pot too?",
}
-- Shell Chest
________DESCRIBE.SHANHAI_SHELLCHEST = {
    GENERIC = "So it can actually open…",
}
-- Hidden Stone Chest
________DESCRIBE.SHANHAI_HIDDENCELLAR = {
    GENERIC = "Stone material, sealed with chains",
}
-- Usable Stone Chest
________DESCRIBE.SHANHAI_HIDDENCELLAR_USE = {
    GENERIC = "Stone material, sealed with chains",
}
-- Flower Vine
________DESCRIBE.SHANHAI_FLOWERVINE = {
    GENERIC = "Blossoms, moons, and everlasting people",
}
-- Blue Butterfly
________DESCRIBE.SHANHAI_BLUEFLY = {
    GENERIC = "It can heal my wounds",
}
-- Green Butterfly
________DESCRIBE.SHANHAI_GREENFLY = {
    GENERIC = "Leaves are dancing in the air",
}
-- Orange Butterfly
________DESCRIBE.SHANHAI_ORANGEFLY = {
    GENERIC = "A little butterfly disguised as a leaf",
}
-- White Butterfly
________DESCRIBE.SHANHAI_WHITEFLY = {
    GENERIC = "Is that a moon moth?",
}
-- Goumang Leaf
________DESCRIBE.SHANHAI_GOUMANG_ITEM = {
    GENERIC = "It emits a refreshing fragrance",
}
-- Goumang Plant
________DESCRIBE.SHANHAI_GOUMANG_PLANT = {
    IDLE = "An ancient and mysterious plant",
    NORMAL = "It’s okay, I can wait",
    DEAD = "The soil of the this land is unsuitable for it to grow",
    GENERIC = "What’s happening?",
}
-- Goumang Mark
________DESCRIBE.SHANHAI_GOUMANG = {
    GENERIC = "An ancient aura faintly lingers",
}
-- Hidden Exit
________DESCRIBE.SHANHAI_HIDDENEXIT = {
    GENERIC = "Shall we kick it a couple of times and see?",
}
-- Starflies
________DESCRIBE.SHANHAI_STARFLY = {
    GENERIC = "If only it could be used to catch fish",
}
-- Moonfall
________DESCRIBE.SHANHAI_MOONFALL = {
    GENERIC = "Gold is falling from the sky!",
}
-- Antler
________DESCRIBE.SHANHAI_MUSHROOMGUARD = {
    GENERIC = "Will it grow eyeless deer in spring?",
}
-- Picked Ganoderma
________DESCRIBE.GANODERMA_CAP = {
    GENERIC = "It still looks better on the ground",
}
-- Cooked Ganoderma
________DESCRIBE.GANODERMA_CAP_COOKED = {
    GENERIC = "Smells so good, I want to devour it in one bite",
}
-- Gem Parasite Seed
________DESCRIBE.SHANHAI_PARASITICSEED_GEM = {
    GENERIC = "It needs a suitable host",
}
-- Night Parasite Seed
________DESCRIBE.SHANHAI_PARASITICSEED_NIGHT = {
    GENERIC = "It needs a suitable host",
}
-- Bulky Pinecone
________DESCRIBE.SHANHAI_PINECONE = {
    GENERIC = "It can’t wait to grow",
}
-- Bulky Evergreen Sapling
________DESCRIBE.SHANHAI_PINECONE_SAPLING = {
    GENERIC = "Hang in there, little one",
}
-- Ginkgo Fruit
________DESCRIBE.SHANHAI_GINKGO = {
    GENERIC = "It has a strange smell",
}
-- Ginkgo Sapling
________DESCRIBE.SHANHAI_GINKGO_SAPLING = {
    GENERIC = "So small, will I accidentally step on you?",
}
-- Red Rope
________DESCRIBE.SHANHAI_REDROPE = {
    GENERIC = "I can still feel the pain in my fingers",
}
-- Gong
________DESCRIBE.SHANHAI_GONG = {
    GENERIC = "Do",
}
-- Shang
________DESCRIBE.SHANHAI_SHANG = {
    GENERIC = "Re",
}
-- Jue
________DESCRIBE.SHANHAI_JUE = {
    GENERIC = "Mi",
}
-- Zhi
________DESCRIBE.SHANHAI_ZHI = {
    GENERIC = "Sol",
}
-- Yu
________DESCRIBE.SHANHAI_YU = {
    GENERIC = "La",
}
-- Submit Notes
________DESCRIBE.SHANHAI_FINISHORDER = {
    GENERIC = "Wrap it up",
}
-- Zhulong’s Array
________DESCRIBE.SHANHAI_SECRETPLACE = {
    GENERIC = "So hard, it’s even more exaggerated than despair stones",
}
-- Shanshen Spirit
________DESCRIBE.SHANHAI_SHANSHEN_ACTIVE = {
    GENERIC = "I never thought it could be so tough",
}
-- Shanshen
________DESCRIBE.SHANHAI_SHANSHEN_PLANTED = {
    GENERIC = "Delicious fruit",
}
-- Shanshen
________DESCRIBE.SHANHAI_SHANSHEN = {
    GENERIC = "It’s grown into human form",
}
-- Cooked Shanshen Essence
________DESCRIBE.SHANHAI_COOKEDSHANSHEN = {
    GENERIC = "After roasting, only this much is left",
}
-- Small Statue
________DESCRIBE.SHANHAI_SMALLSTATUE = {
    GENERIC = "We should redesign its appearance",
}
-- Gem Crystal Vine
________DESCRIBE.SHANHAIVINE_GEM = {
    GENERIC = "Be careful, it might make our heads explode",
}
-- Nightberry Vine
________DESCRIBE.SHANHAIVINE_NIGHT = {
    GENERIC = "Honestly, I don’t have much appetite",
}
-- Moonflower Vine
________DESCRIBE.SHANHAIVINE_MOON = {
    GENERIC = "It’d be better if there were more colors",
}
-- Festive Evergreen Tree
________DESCRIBE.SHANHAI_WINTER_TREE = {
    BURNT = "Uh-oh",
    BURNING = "Big trouble",
    CANDECORATE = "We need bulbs and ribbons",
    YOUNG = "The festival is coming",
}
-- Xirang Item
________DESCRIBE.SHANHAI_XIRANG_ITEM = {
    GENERIC = "A small pile of soil growing on its own",
    ONCOOLDOWN = "it needs some time to cool down",
}
-- Mysterious Soil
________DESCRIBE.SHANHAI_XIRANG = {
    GENERIC = "What treasure is hidden inside?",
}
-- 息壤
________DESCRIBE.SH_XIRANG = {
    GENERIC = "A small, spiritually charged mound of earth.",
}
-- 神秘土壤
________DESCRIBE.SH_XIRANG_PLANT = {
    XIRANG_FULL = "What treasure lies within?",
    GENERIC = "It needs time to grow back.",
}
-- Zhuyan
________DESCRIBE.SHANHAI_ZHUYAN = {
    GUARD = "Its fist is bigger than a sandbag",
    NORMAL = "Caught off guard, what an opportunity!",
}
-- Hundred Birds Facing Phoenix
________DESCRIBE.STATUE_CHAOFENG = {
    GENERIC = "The little crow will like this",
    ALL_FOUND = "Holy and majestic",
}
-- Heavenly Dog Devouring the Moon
________DESCRIBE.STATUE_EATMOON = {
    EYESCLOSE = "A majestic big dog",
    EYESOPEN = "I’m worried it might bite at any moment",
    MOONEATEN = "It took a small bite of the moon in the sky",
    NODOG = "In the blink of an eye, it disappeared. Where did it go?",
}
-- Resurrection Statue
________DESCRIBE.STATUE_NIEPAN = {
    IS_COOLDOWN = "It’s not as hot anymore, needs some time",
    IS_HOLDING = "I feel like setting it on fire",
    IS_NOT_HOLDING = "Is today barbecue day?",
}
-- Turtle Custard
________DESCRIBE.TORTOISE_CUSTARD = {
    GENERIC = "Is this bowl made from a turtle shell?",
}
-- Xuanhe Pond
________DESCRIBE.XUANHE_POND = {
    STAGE_1 = "Requires: Fireflies and Fragrant Blossoms All Welcomed",  
    STAGE_2 = "Requires: Ancient Celestial Aura",  
    STAGE_3 = "Requires: Golden Leaves Flutter Like Butterflies?",  
    STAGE_4 = "Requires: No Trace of Frost's Bite?",  
    STAGE_5 = "I’m glad I could help",
}
-- Cherry Blueprint Sculpture
________DESCRIBE.SH_CHERRYSTATUE = {
    GENERIC = "Are they looking at blueprints or code?",
}
-- Four Seasons Aquarium
________DESCRIBE.SH_SEASONAQUARIUM = {
    SPRING = "Spring mountain, empty cries of birds",
    SUMMER = "Summer window, dragon scales reflected",
    AUTUMN = "Autumn light, silver candles cool against painted screens",
    WINTER = "Winter feast, flowers withered beneath soaring towers",
    ALLSEA = "Year after year, it’s the same day",
    GENERIC = "Testing the effects of these little fish",
}
-- Larger Dirt Pile
________DESCRIBE.SHANHAI_NORMALPILE = {
    GENERIC = "Greater rewards come with greater risks",
}
-- Small Sparkler
________DESCRIBE.SH_SPARKLER_SMALL = {
    GENERIC = "This aligns with science",
}
-- Small Fireworks
________DESCRIBE.SH_SPARKLER_1 = {
    GENERIC = "It could be a little bigger",
}
-- Fireworks
________DESCRIBE.SH_SPARKLER_2 = {
    GENERIC = "Happy festival!",
}
-- Big Fireworks
________DESCRIBE.SH_SPARKLER_3 = {
    GENERIC = "Now I’m the brightest in the crowd",
}
-- Chaos Weapon
________DESCRIBE.SH_KILLALL_WEAPON = {
    GENERIC = "Chaos reigns!",
}
-- Iron Openwork Base
________DESCRIBE.SH_IRONOPENWORK_BASE = {
    GENERIC = "Happy Chinese New Year!",
}
-- Iron Openwork Base Kit
________DESCRIBE.SH_IRONOPENWORK_BASE_KIT = {
    GENERIC = "Quick, set it up",
}
-- Fireworks
________DESCRIBE.SH_FIREWORKS = {
    GENERIC = "Don’t worry, it’s not a real crow",
}
-- Ginkgo Leaf
________DESCRIBE.SHANHAI_GINKGOLEAVE = {
    GENERIC = "These aren’t butterfly wings",
}
-- Kun Rider
________DESCRIBE.KUN_RIDER = {
    GENERIC = "It’s trapped here",
}
-- Flower
________DESCRIBE.SH_FLOWER = {
    GENERIC = "To pick or not to pick?",
}
-- 造景石
________DESCRIBE.SH_ROCK_1 = {
    GENERIC = "Jagged bizarre rocks",
}
-- 挖掘出来的句芒植株
________DESCRIBE.DUG_SHANHAI_GOUMANG_PLANT = {
    GENERIC = "Little plant needs relocation",
}
-- 高鸟蛋藤
________DESCRIBE.DSC_EGGVINE = {
    GENERIC = "Did evolution stop working?",
}
-- 高鸟蛋种藤
________DESCRIBE.SHANHAI_SEED_TALLBIRDEGG = {
    GENERIC = "What have we done to it?",
}
-- 发光蟹
________DESCRIBE.DSC_TREECRAB = {
    GENERIC = "It might crawl into my dreams",
}
-- 花藤，弯曲的
________DESCRIBE.DSC_FLOWERVINE = {
    GENERIC = "Twisting floral charm",
}
-- 花藤，出口处的
________DESCRIBE.SHANHAI_EXITVINE = {
    GENERIC = "It sprouted suddenly!",
}
-- 迷榖树
________DESCRIBE.SH_MIGUTREE = {
    GENERIC = "Looks surreal",
    MIGUTREE_FULL = "This might guide my way",
}
-- 迷榖枝
________DESCRIBE.SH_MIGUTWIG = {
    GENERIC = "Glowing navigational twig",
}
-- 异火
________DESCRIBE.DSC_LIGHT = {
    GENERIC = "Could regular crows make this?",
}
-- 海鸟巢
________DESCRIBE.SH_SEANEST = {
    GENERIC = "No mussels, just barnacles and seabirds!",
}
-- 海鸟杆
________DESCRIBE.SH_SEANEST_KIT = {
    GENERIC = "We should farm some mussels",
}
-- 小盆栽
________DESCRIBE.SH_PLANTDECO = {
    GENERIC = "Now this is proper horticulture",
}
-- 云开
________DESCRIBE.DSC_COPYTOOL = {
    GENERIC = "Perseverance brings clarity",
    YUNKAI_DEP = "What's that, a teleport scroll?",
}
-- 悬河灵玉
________DESCRIBE.XUANHE_PASSPORT = {
    GENERIC = "Exquisite craftsmanship indicates value",
}
-- 烛龙法阵
________DESCRIBE.STATUE_ZHULONG = {
    GENERIC = "It's watching me!",
}
-- 烛龙晦朔雕塑
________DESCRIBE.STATUE_ZHULONG_USE = {
    GENERIC = "I control the wheel of time now!",
}
-- 古怪痕迹
________DESCRIBE.SH_ANIMAL_TRACK = {
    GENERIC = "Are these... footprints?",
}
-- 纸燕
________DESCRIBE.SH_PAPERBIRD = {
    GENERIC = "There's writing on its back",
}
-- 线索纸
________DESCRIBE.SH_REDPAPER = {
    GENERIC = "I've seen such script in Pig Town",
}
-- 吊木小桥
________DESCRIBE.SH_BRIDGE = {
    GENERIC = "I've seen similar designs elsewhere",
}
-- 钦原
________DESCRIBE.SH_QINYUAN = {
    GENERIC = "Better not provoke its stinger",
}
-- 笔绘山河
________DESCRIBE.SH_DESC = {
    GENERIC = "I should settle down with a book",
}
-- 冰面地皮
________DESCRIBE.TURF_SH_ICELAND = {
    GENERIC = "A chunk of... ice?",
}
-- 花园地皮
________DESCRIBE.TURF_SH_SMALLSTONE = {
    GENERIC = "A patch of miniature garden",
}
-- XMM地皮
________DESCRIBE.TURF_SH_XMM = {
    GENERIC = "A XMM turf",
}
-- X茗茗地皮
________DESCRIBE.TURF_SH_COLORXMM = {
    GENERIC = "A ColorXMM turf",
}
-- 碎石地皮
________DESCRIBE.TURF_SH_LITTLESTONE = {
    GENERIC = "Gravel terrain",
}
-- 小碎石地皮
________DESCRIBE.TURF_SH_MANYSTONE = {
    GENERIC = "Crumbled stone patch",
}
-- 玻璃尾刺
________DESCRIBE.SH_QYSTICK = {
    GENERIC = "Glass stinger",
}
-- 彩色羽毛
________DESCRIBE.SH_FEATHER_PHOENIX = {
    GENERIC = "Traces of phoenix visitation",
}
-- 兵灾朱厌雕塑
________DESCRIBE.STATUE_ZHUYAN = {
    GENERIC = "Harbinger of war and chaos!",
}
-- 九尾狐
________DESCRIBE.SH_CRITTER_FOX = {
    GENERIC = "7, 8, 9... so many tails!"
}
-- 淳朴的伪装
________DESCRIBE.SHPIGHAT = {
    GENERIC = "Normal? I think it's clever!"
}
-- 山参种子
________DESCRIBE.SHANHAI_SEED_SHANSHEN = {
    GENERIC = "Deploy Ginseng Plant"
}
-- 银杏叶装饰
________DESCRIBE.SHANHAI_GINKGOLEAVE_GROUND = {
    GENERIC = "Golden Leaves!"
}
-- 山参扫把
________DESCRIBE.SH_MAGICSHANSHEN = {
    GENERIC = "Western magic, Eastern magic, Crow all knows a little bit！"
}
-- 芝上谈冰
________DESCRIBE.SH_GANODERMAICE = {
    GENERIC = "纸上得来终觉浅，绝知此事要躬行"
}
-- 长生不老药
________DESCRIBE.SH_NEVEROLD = {
    GENERIC = "This will be a divine gambit."
}
-- 返老还童丹
________DESCRIBE.SH_BACKYOUNG = {
    GENERIC = "Who can resist the allure of ageless vitality?"
}
-- 石阶道具
________DESCRIBE.SH_ABYSSPILLAR_ITEM = {
    GENERIC = "This should be placed on ocean"
}
-- -- 石阶炸弹
-- ________DESCRIBE.SH_ABYSSPILLAR_BOMB = {
--     GENERIC = "This could remove stonesteps placed on ocean"
-- }
-- 石阶
________DESCRIBE.SH_STONESTEP = {
    GENERIC = "Taking too many steps will tear the trousers..."
}
-- 装饰云朵
________DESCRIBE.SADDLE_KUN_GROUND = {
    GENERIC = "Cloud on the ground..."
}
-- 小次山
________DESCRIBE.SH_ZHUYAN_SPAWNER = {
    GENERIC = "The upper regions abound with white jade, while the lower strata are rich in ruddy copper ore"
}
-- 应龙叶篓
________DESCRIBE.SH_BACKPACK_LEAF = {
    GENERIC = "It combines all the advantages of the Eyebrella and Backpack!"
}
-- 小叶槎
________DESCRIBE.SH_LEAFBOAT_ITEM = {
    GENERIC = "Place it in the ocean, we are going to sail!"
}
-- 一叶浮舟
________DESCRIBE.SH_LEAFBOAT = {
    GENERIC = "It had better be able to hold up under a lot of weight."
}
-- 一叶烛
________DESCRIBE.SH_BOAT_TORCH = {
    GENERIC = "Even the tiniest flame longs to light up some corner of the world."
}
-- 羽毛风帆
________DESCRIBE.SH_FEATHERSAIL = {
    GENERIC = "It reminds me of those shipwrecked days of hardship out on the sea."
}
-- 朱厌铃铛
________DESCRIBE.SH_ZYBELL = {
    GENERIC = "Small, but beautiful."
}
-- 朱源
________DESCRIBE.DEEPSEACAVE_PIGMAN = {
    FAKEDEATH = "What's wrong with him?",
    STEALFOOD = "Hey! Thief!",
    GENERIC = "He is too smart to be a pigman",
}
-- 小叶风扇
________DESCRIBE.SH_BASEFAN = {
    GENERIC = "Thanks to Hamlet's pollen",
}
-- 远古排箫
________DESCRIBE.SH_PANFLUTE = {
    GENERIC = "It sounds... so bad",
}
-- 井字棋盘
________DESCRIBE.SH_TICTACTOE_BOARD = {
    GENERIC = "We're Tic-Tac-Toe masters.",
    PLAYING = "Game in progress. No spoilers!",
    FINISHED = "Game over",
}
-- 井字棋子
________DESCRIBE.SH_TICTACTOE_PIECE_X = {
    GENERIC = "The 'X' piece. It goes first.",
}
-- 井字棋子
________DESCRIBE.SH_TICTACTOE_PIECE_O = {
    GENERIC = "The 'O' piece. It goes second.",
}
-- 长者
________DESCRIBE.DSC_ELDERSWAMPIG = {
    GENERIC = "The author never give you a new look, right?",
}
-- 朱源的小铺
________DESCRIBE.DSC_PIG_SHOP = {
    GENERIC = "Open up! We're open for business!", 
    ACTIVE = "Where did it learn all this?", 
    BREWING = "Currently brewing!", 
    BURNT = "We really should have been more careful with fire...", 
}
-- 叶篓特效
________DESCRIBE.SH_BACKPACK_LEAF_FX = {
    GENERIC = "That's a shadow servant from the leaf basket.", 
}
-- 被堵住的洞天穴
________DESCRIBE.DSC_CAVE_ENTRANCE = {
    GENERIC = "Let's start digging!", 
}
-- 洞天穴
________DESCRIBE.DSC_CAVE_ENTRANCE_OPEN = {
    GENERIC = "Won't hurt to take a look down there.",
    OPEN = "The bats haven't found this exit!",
    FULL = "Yikes, packed to the brim.",
}
-- 洞天楼梯
________DESCRIBE.DSC_CAVE_EXIT = {
    GENERIC = "Oh no, we're trapped.",
    OPEN = "I see the way out!",
    FULL = "Yikes, packed to the brim.",
}
-- 朱厌的小猴子
________DESCRIBE.SH_MONKEY = {
    GENERIC = "They've become exceptionally vicious.",
}
-- 伪装灵芝
________DESCRIBE.DSC_MUSHROOM_TO_2 = {
    GENERIC = "Just looking at it makes my backside ache.",
}
-- 隐藏出口2
________DESCRIBE.SHANHAI_HIDDENEXIT_2 = {
    GENERIC = "Maybe we should give it a couple of kicks?",
}
-- 扭曲的大树
________DESCRIBE.DSC_OCEANTREE_PILLAR_2 = {
    GENERIC = "It looks identical to the trees on the first floor. Am I seeing things?",
}
-- 悬河瀑布
________DESCRIBE.XUANHE_FALL = {
    GENERIC = "Its waters fly straight down three thousand feet.",
}
-- 山河卷饼
________DESCRIBE.SH_TACO = {
    GENERIC = "We should've added some spicy strips."
}
-- 烛龙卷饼
________DESCRIBE.SH_ZHULONG_TACO = {
    ROLLED = "The magic of time and space, finally used for its proper purpose!",
    GENERIC = "Roll that food up! Roll it up now!"
}
-- 锁妖链
________DESCRIBE.DSC_CAVE_MAGICSEAL = {
    GENERIC = "It's not just going to snap on its own, right?"
}
-- 锁妖阵
________DESCRIBE.DSC_CAVE_MAGICPLACVE = {
    GENERIC = "I have to learn how to do this. I just have to!"
}
-- 洞天矮星
________DESCRIBE.DSC_CAVE_STAFFLIGHT = {
    GENERIC = "It makes me feel much safer."
}
-- 铥矿果
________DESCRIBE.SH_THULECITE = {
    GENERIC = "Thulecite Fruit"
}
-- 矿脉种子
________DESCRIBE.SH_THULECITE_SEEDS = {
    GENERIC = "Is it a rock? Or a seed?"
}
-- 铥矿果植株
________DESCRIBE.FARM_PLANT_SH_THULECITE = {
    GENERIC = "Looks like some kind of vine."
}
-- 巨型铥矿果
________DESCRIBE.SH_THULECITE_OVERSIZED = {
    GENERIC = "How lazy must the creator of this plant have been?"
}
-- 打蜡的巨型铥矿果
________DESCRIBE.SH_THULECITE_OVERSIZED_WAXED = {
    GENERIC = "Bigger. Brighter. Heavier."
}
-- 乾坤袖袍
________DESCRIBE.SH_MAGICVEST = {
    GENERIC = "Can't hurt to embroider a few more magic arrays on it."
}

-- 模组适配内容
___________NAMES.SHANHAI_GOUMANG_WILTON = "Goumang's Fruit"
_____RECIPE_DESC.SHANHAI_GOUMANG_WILTON = "Manually condense the spiritual energy"