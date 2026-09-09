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


STRINGS.SH_MODNAME = "山河表里"
___CUSTOMIZATION.DSC_WITH_VINES = "塔内自带寄生藤蔓"
___CUSTOMIZATION.DSC_YURUN_FRIEND = "羽润开局友好"
___CUSTOMIZATION.DSC_WITH_BAN = "塔内附岛禁忌"
___CUSTOMIZATION.DSC_WITH_KOI = "塔内锦鲤出没"
___CUSTOMIZATION.ZHUYAN_DIFFICULTY_LEVEL = "朱厌击杀难度"
___CUSTOMIZATION.QINYUAN_DIFFICULTY_LEVEL = "钦原暴毙难度"
___CUSTOMIZATION.GOUMANG_DROP_CHANCE = "句芒印记爆率"
___CUSTOMIZATION.TACO_DROP_CHANCE = "时空卷饼爆率"
___CUSTOMIZATION.GOUMANG_GROW_SPEED = "句芒再生速度"
___CUSTOMIZATION.GANODERMA_GROW_SPEED = "灵芝再生速度"
___CUSTOMIZATION.MIGUTREE_GROW_SPEED = "迷榖枝再生速度"
___CUSTOMIZATION.SEANEST_GROW_SPEED = "海上鸟巢再生速度"
___CUSTOMIZATION.XIRANG_CD_SPEED = "息壤冷却速度"
___CUSTOMIZATION.CLOUDMOVE_CD_SPEED = "云开冷却速度"
___CUSTOMIZATION.KUNPENG_WITH_PACK = "鲲鹏必给背包"
---------------------------------------------------------------
------------------------动作 名称-------------------------------
---------------------------------------------------------------
_________ACTIONS.ACTIVATE.KNOCKPIG = "敲门"
_________ACTIONS.ACTIVATE.PUSHSTONE = "按下"
_________ACTIONS.ACTIVATE.JUMPHOLE = "跳下"
_________ACTIONS.ACTIVATE.SH_SPIN_MIGU = "引路"
_________ACTIONS.ACTIVATE.DSC_UPGRADE = "献祭"
_________ACTIONS.DEPLOY.DSC_PLACE = "解封"
_________ACTIONS.DEPLOY.SH_BOAT_PLACE = "放置"
_________ACTIONS.DEPLOY.UNROLL_SCROLL = "展开"
_________ACTIONS.DEPLOY.SH_PIECE_PLACE = "落子"
_________ACTIONS.DEPLOY.SH_ABYSS_PLACE = "放置"
_________ACTIONS.SHBOATMOUNT = "登船"
_________ACTIONS.SHBOATDISMOUNT = "下船"
_________ACTIONS.SHACTIVATELIGHT = "点燃"
_________ACTIONS.SHDESACTIVATELIGHT = "熄灭"
_________ACTIONS.SHRETRIEVE = "收回"

---------------------------------------------------------------
------------------------制作提示------------------------------
---------------------------------------------------------------
________CRAFTING.NEEDSPDSPIG_SHOP = "我们得找朱源帮忙"

---------------------------------------------------------------
------------------------N P C昵称------------------------------
---------------------------------------------------------------
-- 固定NPC，珠圆玉润组合
-- 后期解密塔的封印，可以让朱源愿意出门，让羽润可以从塔里出来
STRINGS.DEEPSEACAVE_CROW    = { "羽润", } -- { "梧芽", "芽羽", "羽润", "润梧" }
STRINGS.DEEPSEACAVE_PIGMAN  = { "朱源", } -- { "振株", "株源", "源泽", "泽振" }

---------------------------------------------------------------
------------------------物品名称--------------------------------
---------------------------------------------------------------
___________NAMES.SHANHAI_KUNLUNISLAND = "昆仑龙脉岛屿"
___________NAMES.SHANHAI_DEEPSEACAVE = "洞天塔一层"
___________NAMES.SHANHAI_DEEPSEACAVE_TWO = "洞天塔二层"
___________NAMES.SH_FLY = "飞天扫帚"
___________NAMES.SH_COOKPOTFIRE = "灶火"
___________NAMES.SH_BOAT = "小叶槎"
___________NAMES.SH_HELPER = "古老的声音"
___________NAMES.SH_SEASTACK = "海蚀柱"
___________NAMES.SH_MARSH_PLANT = "植物"
___________NAMES.SH_POND_ALGAE = "水藻"
___________NAMES.SH_TICTACTOE_GAME = "井字棋"

___________NAMES.TORTOISE_CUSTARD = "龟蛋羹"
___________NAMES.SHANHAI_BUBBLETEA = "山海烧仙草"
___________NAMES.SH_GANODERMAICE = "芝上谈冰"
___________NAMES.SH_NEVEROLD = "长生不老药"
___________NAMES.SH_TACO = "山河卷饼"
___________NAMES.SH_ZHULONG_TACO = "时空卷饼"
___________NAMES.SH_BACKYOUNG = "返老还童丹"

___________NAMES.STATUE_CHAOFENG = "百鸟朝凤雕塑"
___________NAMES.STATUE_ZHULONG_USE = "烛龙晦朔雕塑"
___________NAMES.STATUE_NIEPAN = "浴火重生雕塑"
___________NAMES.STATUE_EATMOON = "天狗食月雕塑"
___________NAMES.STATUE_ZHUYAN = "兵灾朱厌雕塑"
___________NAMES.SH_CHERRYSTATUE = "合璧蓝图雕塑"
___________NAMES.DEEPSEACAVE_UPGRADER = "祭台"
___________NAMES.SH_SEASONAQUARIUM = "四象鱼囿"
___________NAMES.SHANHAI_SHELLCHEST = "贝壳箱子"
___________NAMES.SHANHAI_HIDDENCELLAR_USE = "石锁箱子"
___________NAMES.SHANHAI_SMALLSTATUE = "纪念小雕塑"
___________NAMES.XUANHE_POND = "悬河池塘"
___________NAMES.DEEPSEACAVE = "洞天塔"
___________NAMES.DEEPSEACAVE_SEAL = "洞天塔封印"
___________NAMES.DEEPSEACAVE_EXIT = "洞天出口"
___________NAMES.DEEPSEACAVE_WALL = "洞天墙"
___________NAMES.DEEPSEACAVE_POOL = "小石潭"
___________NAMES.DSC_POOL = "小石潭"
___________NAMES.DEEPSEACAVE_PIGHOUSE = "朱源的小屋"
___________NAMES.SHANHAI_NORMALPILE = "稍大的土堆"
___________NAMES.SHANHAI_SECRETPLACE = "烛龙法阵"
___________NAMES.SHANHAI_SECRETORDER = "音阶"
___________NAMES.SHANHAI_GONG = "宫"
___________NAMES.SHANHAI_SHANG = "商"
___________NAMES.SHANHAI_JUE = "角"
___________NAMES.SHANHAI_ZHI = "徵"
___________NAMES.SHANHAI_YU = "羽"
___________NAMES.SHANHAI_FINISHORDER = "="
___________NAMES.SH_ROCK_1 = "造景石"
___________NAMES.SH_SEANEST = "海鸟巢"
___________NAMES.SH_SEANEST_KIT = "贻贝杆"
___________NAMES.STATUE_ZHULONG = "被封印的烛龙"
___________NAMES.SH_BRIDGE = "吊木小桥"
___________NAMES.SH_ZHUYAN_SPAWNER = "小次山"
___________NAMES.SH_TICTACTOE_BOARD = "井字棋盘"
___________NAMES.DSC_CAVE_ENTRANCE = "被堵住的洞天穴"
___________NAMES.DSC_CAVE_ENTRANCE_OPEN = "洞天穴"
___________NAMES.DSC_CAVE_EXIT = "洞天楼梯"
___________NAMES.DSC_MUSHROOM_TO_2 = "伪装灵芝"
___________NAMES.XUANHE_FALL = "悬河瀑布"
___________NAMES.SH_ABYSSPILLAR = "小木桩"
___________NAMES.SH_ABYSSPILLAR_ITEM = "小木桩"
___________NAMES.DSC_CAVE_MAGICSEAL = "锁妖链"
___________NAMES.DSC_CAVE_MAGICPLACVE = "锁妖阵"
___________NAMES.DSC_CAVE_STAFFLIGHT = "洞天矮星"

___________NAMES.DSC_OCEANTREE_PILLAR = "扭曲的大树"
___________NAMES.SHANHAI_HIDDENEXIT = "突兀的石头"
___________NAMES.SHANHAI_HIDDENEXIT_2 = "二层裂口"
___________NAMES.SHANHAI_HIDDENCELLAR = "神秘石头"
___________NAMES.SHANHAI_GOUMANG_ITEM = "句芒叶"
___________NAMES.SHANHAI_GOUMANG_PLANT = "句芒"
___________NAMES.SHANHAI_GOUMANG = "句芒印记"
___________NAMES.SHANHAI_SHANSHEN = "山参"
___________NAMES.SHANHAI_SHANSHEN_ACTIVE = "山参精"
___________NAMES.SHANHAI_SHANSHEN_PLANTED = "山参"
___________NAMES.SHANHAI_COOKEDSHANSHEN = "山参精华"
___________NAMES.SHANHAI_XIRANG = "神秘土壤"
___________NAMES.SHANHAI_XIRANG_ITEM = "息壤"
___________NAMES.SHANHAI_GANODERMA = "灵芝"
___________NAMES.GANODERMA_CAP = "灵芝"
___________NAMES.GANODERMA_CAP_COOKED = "烤灵芝"
___________NAMES.SHANHAI_MUSHROOMGUARD1 = "鹿茸"
___________NAMES.SHANHAI_MUSHROOMGUARD2 = "鹿茸"
___________NAMES.SHANHAI_MUSHROOMGUARD3 = "鹿茸"
___________NAMES.SHANHAI_PINECONE_SAPLING = "臃肿常青树苗"
___________NAMES.SHANHAI_GINKGO = "银杏"
___________NAMES.SHANHAI_GINKGOLEAVE = "银杏叶"
___________NAMES.SHANHAI_GINKGOLEAVE_GROUND = "银杏叶装饰"
___________NAMES.SHANHAI_GINKGO_SAPLING = "银杏树苗"
___________NAMES.SHANHAI_GINKGO_TREE = "银杏树"
___________NAMES.SHANHAI_SEED_GEM = "晶洞种藤"
___________NAMES.SHANHAI_SEED_NIGHT = "夜莓种藤"
___________NAMES.SHANHAI_SEED_TALLBIRDEGG = "高脚鸟蛋种藤"
___________NAMES.SHANHAI_SEED_SHANSHEN = "山参种藤"
___________NAMES.SHANHAIVINE_GEM = "晶洞藤"
___________NAMES.SHANHAIVINE_NIGHT = "夜莓藤"
___________NAMES.DSC_EGGVINE = "高脚鸟蛋藤"
___________NAMES.SHANHAI_PINECONE = "臃肿树苗"
___________NAMES.SHANHAIVINE_MOON = "花藤"
___________NAMES.DSC_FLOWERVINE = "花藤"
___________NAMES.SHANHAI_EXITVINE = "花藤"
___________NAMES.SHANHAI_FLOWERVINE = "花蔓"
___________NAMES.DUG_SHANHAI_GOUMANG_PLANT = "句芒植株"
___________NAMES.SH_FLOWER = "山花"
___________NAMES.SH_MIGUTREE = "迷榖树"
___________NAMES.SH_MIGUTWIG = "迷榖枝"
___________NAMES.SH_PLANTDECO = "小盆栽"
___________NAMES.SH_ANIMAL_TRACK = "古怪痕迹"
___________NAMES.SADDLE_KUN_GROUND = "云朵"
___________NAMES.DSC_OCEANTREE_PILLAR_2 = "扭曲的大树"
___________NAMES.SH_THULECITE = "铥矿果"
___________NAMES.SH_THULECITE_SEEDS = "矿脉种子"
___________NAMES.FARM_PLANT_SH_THULECITE = "铥矿果植株"
___________NAMES.SH_THULECITE_OVERSIZED = "巨型铥矿果"
___________NAMES.SH_THULECITE_OVERSIZED_WAXED = "打蜡的巨型铥矿果"

___________NAMES.SHANHAI_STARFLY = "星引"
___________NAMES.SHANHAI_MOONFALL = "月坠"
___________NAMES.SADDLE_KUN = "云鞍"
___________NAMES.SHANHAI_REDROPE = "红绳"
___________NAMES.SH_SPARKLER_SMALL = "仙女棒"
___________NAMES.SH_SPARKLER_1 = "小烟花"
___________NAMES.SH_SPARKLER_2 = "烟花"
___________NAMES.SH_SPARKLER_3 = "大烟花"
___________NAMES.SH_KILLALL_WEAPON = "朱厌角"
___________NAMES.SH_IRONOPENWORK_BASE = "貔貅小烟花"
___________NAMES.SH_IRONOPENWORK_BASE_KIT = "貔貅小烟花组件"
___________NAMES.SH_FIREWORKS = "小乌鸦烟花"
___________NAMES.SHANHAI_WINTER_TREE = "盛宴常青树"
___________NAMES.DSC_LIGHT = "异火"
___________NAMES.DSC_COPYTOOL = "云开"
___________NAMES.XUANHE_PASSPORT = "悬河灵玉"
___________NAMES.SH_REDPAPER = "线索纸"
___________NAMES.SH_HEALTH = "血量"
___________NAMES.SH_DESC = "山河绘卷"
___________NAMES.TURF_SH_ICELAND = "冰面地皮"
___________NAMES.TURF_SH_SMALLSTONE = "花园地皮"
___________NAMES.TURF_SH_XMM = "XMM地皮"
___________NAMES.TURF_SH_COLORXMM = "茗茗地皮"
___________NAMES.TURF_SH_LITTLESTONE = "碎石地皮"
___________NAMES.TURF_SH_MANYSTONE = "小碎石地皮"
___________NAMES.SH_QYSTICK = "钦原尾刺"
___________NAMES.SH_FEATHER_PHOENIX = "彩色羽毛"
___________NAMES.SHPIGHAT = "淳朴的伪装"
___________NAMES.SH_MAGICSHANSHEN = "山参扫把"
___________NAMES.SH_BACKPACK_LEAF = "小叶篓"
___________NAMES.SH_LEAFBOAT_ITEM = "小叶槎"
___________NAMES.SH_LEAFBOAT = "小叶槎"
___________NAMES.SH_BOAT_TORCH = "小叶烛"
___________NAMES.SH_FEATHERSAIL = "小叶帆"
___________NAMES.SH_BASEFAN = "小风扇"
___________NAMES.SH_ZYBELL = "朱厌铃铛"
___________NAMES.SH_PANFLUTE = "小叶笛"
___________NAMES.SH_TICTACTOE_PIECE_X = "棋子"
___________NAMES.SH_TICTACTOE_PIECE_O = "棋子"
___________NAMES.SH_MAGICVEST = "乾坤袖袍"

___________NAMES.DSC_MUSHROOM_TO_2_BLUEPRINT = "伪装灵芝蓝图"
___________NAMES.SHANHAI_GOUMANG_BLUEPRINT = "句芒印记蓝图"
___________NAMES.STATUE_CHAOFENG_BLUEPRINT = "百鸟朝凤蓝图"
___________NAMES.STATUE_ZHULONG_USE_BLUEPRINT = "烛龙晦朔蓝图"
___________NAMES.STATUE_EATMOON_BLUEPRINT = "天狗食月蓝图"
___________NAMES.SH_CHERRYSTATUE_BLUEPRINT = "合璧蓝图"
___________NAMES.XUANHE_FALL_BLUEPRINT = "悬河瀑布蓝图"
___________NAMES.SH_MIGUTREE_BLUEPRINT = "迷榖树蓝图"

___________NAMES.DEEPSEACAVE_PIGMAN = "朱源"
___________NAMES.DEEPSEACAVE_CROW = "羽润"
___________NAMES.KUNPENG = "鲲"
___________NAMES.SHANHAI_PHOENIX = "凤凰虚影"
___________NAMES.KUNPENG_ATTACK_HORN = "鲲"
___________NAMES.KUNPENG_HORN = "鲲角"
___________NAMES.SHANHAI_ZHUYAN = "朱厌"
___________NAMES.SHANHAI_BLUEFLY = "蝴蝶"
___________NAMES.SHANHAI_GREENFLY = "叶蝶"
___________NAMES.SHANHAI_ORANGEFLY = "杏叶蝶"
___________NAMES.SHANHAI_WHITEFLY = "蝴蝶"
___________NAMES.KUN_RIDER = "鲲鹏"
___________NAMES.DSC_TREECRAB = "发光蟹"
___________NAMES.SH_PAPERBIRD = "纸燕"
___________NAMES.SH_QINYUAN = "钦原"
___________NAMES.SH_FISHSPAWNER = "小鱼群"
___________NAMES.DEEPSEACAVE_FISH = "洞天锦鲤"
___________NAMES.SH_CRITTER_FOXING = "九尾狐"
___________NAMES.SH_CRITTER_FOXING_BUILDER = "九尾狐"
___________NAMES.SH_FSM_MONKEY_ZHUYAN = "小朱厌"
___________NAMES.DSC_ELDERSWAMPIG = "异域长老"
___________NAMES.DSC_PIG_SHOP = "朱源的小铺"
___________NAMES.DSC_PIG_SHOP_ABANDONED = "关门的小铺"
___________NAMES.SH_BACKPACK_LEAF_FX = "小叶仆从"
___________NAMES.SH_MONKEY = "猴子"


------------------------配方说明--------------------------------
_____RECIPE_DESC.SHANHAI_REDROPE = "难道就不能用浆果染一下色吗？"
_____RECIPE_DESC.DUG_SHANHAI_GOUMANG_PLANT = "付出一点代价复活它"
_____RECIPE_DESC.STATUE_ZHULONG_USE = "借用烛龙的力量来掌管时间"
_____RECIPE_DESC.STATUE_ZHUYAN = "朱厌是挑拨离间的一把好手"
_____RECIPE_DESC.STATUE_CHAOFENG = "召唤天空的那个巨大身影"
_____RECIPE_DESC.STATUE_NIEPAN = "帮我们复活一些朋友，或是敌人"
_____RECIPE_DESC.STATUE_EATMOON = "从不咬人，但会咬别的东西"
_____RECIPE_DESC.SH_SPARKLER_SMALL = "施放快乐的魔法"
_____RECIPE_DESC.SH_SPARKLER_1 = "获取一点节日氛围"
_____RECIPE_DESC.SH_SPARKLER_2 = "分享一下节日欢愉"
_____RECIPE_DESC.SH_SPARKLER_3 = "注意不许放火烧山"
_____RECIPE_DESC.SHANHAI_STARFLY = "星辰和引力的力量"
_____RECIPE_DESC.SHANHAI_MOONFALL = "不用等下一场流星雨了"
_____RECIPE_DESC.SADDLE_KUN = "完美解决海上坐骑的鞍具问题"
_____RECIPE_DESC.SHANHAI_SHELLCHEST = "那么多的贝壳碎片，总算有用了"
_____RECIPE_DESC.SHANHAI_HIDDENCELLAR_USE = "更大的石窖"
_____RECIPE_DESC.BOAT_ANCIENT_CONTAINER = "发动脑筋，这东西不只是水手会做"
_____RECIPE_DESC.SHANHAI_SMALLSTATUE = "活动为什么不回归，谁知道呢？"
_____RECIPE_DESC.SHANHAI_FLOWERVINE = "花好月圆人长久"
_____RECIPE_DESC.SHANHAI_PINECONE = "现在我们不用担心它会绝种了"
_____RECIPE_DESC.DEEPSEACAVE_UPGRADER = "升级你的塔内空间"
_____RECIPE_DESC.SH_SEASONAQUARIUM = "让作物的成长不再受季节影响"
_____RECIPE_DESC.SH_CHERRYSTATUE = "以此纪念小怪物们的友谊"
_____RECIPE_DESC.SHANHAI_SEED_GEM = "更稳定的晶洞果来源！"
_____RECIPE_DESC.SHANHAI_SEED_NIGHT = "更稳定的夜莓来源！"
_____RECIPE_DESC.SHANHAI_SEED_TALLBIRDEGG = "更稳定的高脚鸟蛋来源！"
_____RECIPE_DESC.SHANHAI_SEED_SHANSHEN = "种植山参植株"
_____RECIPE_DESC.SHANHAIVINE_MOON = "月树花藤蔓装饰"
_____RECIPE_DESC.SH_IRONOPENWORK_BASE_KIT = "注意不许放火烧山"
_____RECIPE_DESC.SH_FIREWORKS = "乌鸦形状的烟花"
_____RECIPE_DESC.SH_ROCK_1 = "石头做的造景装饰"
_____RECIPE_DESC.SH_SEANEST_KIT = "木杆？贻贝！"
_____RECIPE_DESC.SH_PLANTDECO = "他们可以用来装扮基地"
_____RECIPE_DESC.SH_DESC = "MOD的辅助说明"
_____RECIPE_DESC.TURF_SH_ICELAND = "冰封千里！"
_____RECIPE_DESC.TURF_SH_SMALLSTONE = "花园中散落着小碎石"
_____RECIPE_DESC.TURF_SH_XMM = "感谢XMM"
_____RECIPE_DESC.TURF_SH_COLORXMM = "这次是感谢X茗茗"
_____RECIPE_DESC.TURF_SH_LITTLESTONE = "大块碎石的地面"
_____RECIPE_DESC.TURF_SH_MANYSTONE = "小块碎石的地面"
_____RECIPE_DESC.DEEPSEACAVE_SEAL = "在纸上写下神奇的咒语"
_____RECIPE_DESC.SH_QYSTICK = "用天体能量浸染蜂刺"
_____RECIPE_DESC.SH_CRITTER_FOXING_BUILDER = "领养一只九尾狐"
_____RECIPE_DESC.SHPIGHAT = "混进猪人部落里面去！"
_____RECIPE_DESC.SHANHAI_GINKGOLEAVE_GROUND = "用银杏叶装饰你的基地"
_____RECIPE_DESC.SHANHAI_GOUMANG = "手动凝聚天地灵气"
_____RECIPE_DESC.SH_MIGUTREE = "借助句芒的力量复活那棵发光树"
_____RECIPE_DESC.SH_MAGICSHANSHEN = "用东方材料制作西方法器，起飞咯"
_____RECIPE_DESC.SH_ABYSSPILLAR = "它能让我们能跨越海洋"
_____RECIPE_DESC.SH_ABYSSPILLAR_ITEM = "它能让我们能跨越海洋"
-- _____RECIPE_DESC.SH_ABYSSPILLAR_BOMB = "小石阶炸弹"
_____RECIPE_DESC.SADDLE_KUN_GROUND = "黏黏的云朵，别管它是什么做的"
_____RECIPE_DESC.SH_BACKPACK_LEAF = "避雨隔热的背包！"
_____RECIPE_DESC.SH_BASEFAN = "它能让锅中的香味飘得更远"
_____RECIPE_DESC.SH_LEAFBOAT_ITEM = "现在是大航海时代！"
_____RECIPE_DESC.SH_PANFLUTE = "这是一个古老声音的回响"
_____RECIPE_DESC.SEASTACK = "我们想要礁石很久了"
_____RECIPE_DESC.MARSH_PLANT = "小植物装饰"
_____RECIPE_DESC.POND_ALGAE = "小苔藓装饰"
_____RECIPE_DESC.DSC_MUSHROOM_TO_2 = "现在我们可以去二层了"
_____RECIPE_DESC.DSC_PIG_SHOP = "永恒大陆的二手贩卖商铺"
_____RECIPE_DESC.DSC_COPYTOOL = "能带你回塔的活地图"
_____RECIPE_DESC.XUANHE_FALL = "打造自己的古风水景"
_____RECIPE_DESC.DSC_MUSHROOM_TO_2_BLUEPRINT = "学习制作一个弹射器"
_____RECIPE_DESC.SHANHAI_GOUMANG_BLUEPRINT = "用自己的办法凝聚生机"
_____RECIPE_DESC.STATUE_CHAOFENG_BLUEPRINT = "百鸟朝凤，浴火重生"
_____RECIPE_DESC.STATUE_ZHULONG_USE_BLUEPRINT = "烛龙晦朔，视眠息嘘"
_____RECIPE_DESC.STATUE_EATMOON_BLUEPRINT = "天狗食月，汪汪汪汪"
_____RECIPE_DESC.SH_CHERRYSTATUE_BLUEPRINT = "合璧蓝图雕塑的蓝图"
_____RECIPE_DESC.XUANHE_FALL_BLUEPRINT = "学习制作一个瀑布造景"
_____RECIPE_DESC.SH_MIGUTREE_BLUEPRINT = "学习移植一棵迷榖树"
_____RECIPE_DESC.DSC_POOL = "挖个坑，填点水"

------------------------科技、绘卷--------------------------------
CRAFTING_FILTERS.SHANHAIJING = "山河表里"
___________NAMES.SHANHAIJING_BOOK = "山海经"

---------------------------------------------------------------
------------------------额外文本--------------------------------
---------------------------------------------------------------
-- 刷新皮肤
STRINGS.SH_SKINS_UPDATE = "刷新皮肤"
-- 种藤的等级
STRINGS.SH_LEVEL = "等级"
-- 时空卷饼
STRINGS.SH_TIMETACO_PRE = "时空卷-"
-- 原山海经的文本
STRINGS.SHANHAIJING_UI = {
    BOOK_DESCRIBE = "雾隐山巅，星河沉寂",
    BOOK_BUTTON = "传说",
    FENGHUANG = "凤凰",
    KUNPENG = "鲲鹏",
    YAZI = "睚眦",
    ZHUYAN = "朱厌",
    ZHULONG = "烛龙",
}
-- 皮肤名称
_______SKINNAMES.SH_CROW_MOON = "月树花"
_______SKINNAMES.SH_CROW_GOUMANG = "句芒叶"
_______SKINNAMES.SH_FLOWER_WHITE = "珙桐"
_______SKINNAMES.SH_FLOWER_ORANGE = "百合"
_______SKINNAMES.SH_FLOWER_YELLOW = "黄蝉"
_______SKINNAMES.sh_rock_1 = "经典"
_______SKINNAMES.shanhai_decovine = "经典"
_______SKINNAMES.shanhai_flowervine = "经典"

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
    "时过境迁，时移世异",
    "我的族群，曾经遍布这片海洋",
    "我自深渊中归来…",
}
STRINGS.KUN_ATTACK_LINES = {
    "自由！",
    "迎接我的怒火！",
    "这个世界已非昔日之景，但唯有复仇永存心间！",
    "滚开！凡人！",
}
STRINGS.KUN_ICE_LINES = {
    "我的法力已经流失太多…",
    "冰封！",
    "冻结！",
    "让我们看看，冰霜是否仍听从我的号令！",
}
STRINGS.KUN_SACK = {
    "我的法力已经流失太多…",
    "这是一点谢礼…",
    "谢谢你来看我",
}
STRINGS.KUN_EAT = {
    "你是来救我出去吗?",
    "他们说海上有条大霜鲨，他有一些靴子藏品...",
    "我需要一只出逃腿靴，你能帮帮我吗?",
    "谢谢你来看我",
}
STRINGS.KUN_ESCAPE = {
    "自由！",
    "时过境迁，时移世异",
    "让我们看看，海洋是否仍听从我的号令！",
    "这个世界已非昔日之景，但唯有自由永存心间！",
}

    -- 朱源的文本大部分由ChatGPT 4o生成，威吊自行调整
    -------------------------朱源的台词------------------------------
    STRINGS.ZHUYUAN_NIGHT = {
        "准时下班是猪的福报",
        "再晚也得睡觉",
        "大脑已休眠，急需被窝服务",
        "猪脑过载，回屋充电",
        "优雅的猪，从不熬夜",
        "诸位继续卷，猪要回屋了",
        "太阳下班，猪也下班",
        "哈，肥猪拱门！",
        "吾与床铺，两情相悦",
        "下班不积极，思想有问题！",
        "知识需要沉淀，猪需要平躺",
        "猪与周公有约",
    }
    STRINGS.ZHUYUAN_STEAL_FOUND = {
        "这是食品保质期的实地考察！",
        "猪是在研究制冷技术的进度调控...",
        "咳咳，这冰箱的密封性...有待商榷",
        "猪帮你检查冰箱门的感应功能",
        "暴殄天物是重罪！猪这是在替你承担罪过！",
        "天气炎热，猪来给胃降降温",
        "冰箱门是自己打开的",
        "是重力让这块肉掉进了猪的嘴里",
        "试毒，上古神农氏留下的高尚传统",
        "格局！分享是美德！",
        "食物链的温情传递，你懂不懂",
        "冰箱用冷气勾引的猪",
        "猪没偷吃，是食物主动奉献的",
        "食物们发出了‘快吃我’的灵魂呐喊",
    }
    STRINGS.ZHUYUAN_TOPLAYER = {
        "民以食为天，猪以食为…一切",
        "多造几个冰箱，猪可以当仓管",
        "待会猪把鸦吊起来，你去捡掉下来的东西",
        "你不用睡觉的吗",
        "朱源，这名字够文雅吧",
        "看不懂猪语？教育还要普及啊",
        "猪当年在哈姆雷特，是御前带刀侍卫！",
        "嗟，来食！",
        "你这身装备，观赏性大于实用性",
        "纸燕寄情，千里传书",
        "什么是...‘蟹钳子以令猪猴’？",
        "猪的智慧，一半在书里，一半在锅里",
        "教义不通的话，猪也会些拳脚",
        "你知道猪为什么聪明吗",
        "夜观星象？猪更擅长夜观冰箱",
        "纸上谈兵终觉浅，锅边掌勺方为真",
        "猪哼小调，分宫商角徵羽",
        "所谓智慧，三分靠读书，七分靠饭饱",
        "猪的食谱，倒背如流",
        "猪很高兴，猪王大人还活着",
        "猪用了很久才修复洞穴法阵",
    }
    STRINGS.ZHUYUAN_OPENFRIDGE = {
        "悄悄地，不要声张",
        "寻宝时间到！",
        "零元购启动！",
        "只是路过，如果顺手拿到什么，那就是缘分",
        "步伐要优雅,动作要迅捷",
        "猪胃口很小的",
        "未经授权的资源共享",
        "冰箱门，听从猪的召唤！",
        "让猪看看今天有什么惊喜",
        "开箱！开箱！",
        "心跳加速，是开盲盒的乐趣",
        "猪来视察自己的未来财产",
        "猪会开冰箱，猪开给你看哈",
    }
    -- STRINGS.ZHUYUAN_FRIDGE = {
    --     "冰箱！塔里有供电系统了？",
    --     "酒足饭饱，走出一个猪猪生风~",
    --     "饭后百步走，能活九十九",
    --     "这制冷效果，是传说中的寒冰阵法?",
    --     "有了冰箱后，猪生圆满了一半",
    --     "猪愿称你为最强！",
    -- }
    STRINGS.ZHUYUAN_COOK = {
        "猪掐蹄一算，此档恐有散伙之相",
        "生活，让猪不容易",
        "煮饭是创造，刷碗是毁灭",
        "猪只能保证把它弄熟，不保证好吃",
        "反正这些也快变质了",
        "叮！随机盲盒餐已上线",
        "烹饪是一场豪赌",
        "美味佳肴还是黑暗料理？让老天决定吧",
        "猪负责烹饪的玄学部分，物理部分交给锅",
        "熟了就算成功，咸淡那是上天给的惊喜",
        "根据猪的食谱，该这么弄",
        "独家秘方，吃不死人",
    }
    STRINGS.ZHUYUAN_COOKPOT = {
        "这些锅是要爆炸了吗？",
        "锅在，希望就在",
        "空锅是对食材的不尊重",
        "是时候让这口锅履行它的神圣使命了",
        "这是属于锅的高光时刻",
        "没有食材的锅，就像没有墨水的笔",
    }
    STRINGS.ZHUYUAN_BACKSELF = {
        "猪听说有什么巧克力塔...",
        "饭后消食，讲究一个闲庭信步",
        "坏鸟肯定在诋毁猪",
        "猪的征途是星辰…和上层阁楼",
        "戴上头灯，猪就是夜明猪了",
        "二层修缮好了，但是三层呢...",
        "吃饱了撑的,字面意思",
        "思考猪生，从散步开始",
        "猪不是胖了，是知识更厚重了",
        "多走路才能多吃点",
        "踱步百圈，可折合馒头半个",
        "登高望远，望的是灶台炊烟",
        "猪光所照，剩饭剩菜无所遁形",
        "此乃‘静极思动，饱后谋食’之大道",
        "肚量者，非独容食，亦容天下饕餮客",
        "忽觉蹄下生风，原是饿的",
        "‘大智若鱼’？猪以为不如‘大智若猪’",
        "坏鸟，别聒噪！",
        "坏鸟，要不要听猪讲《禽类烹饪学》？",
    }
    STRINGS.ZHUYUAN_OVEREAT = {
        "七分饱，三分雅",
        "理智告诉猪，该停了",
        "没有能勾起猪品鉴欲望的食材了",
        "嗝~",
        "猪的胃说可以，但猪的腰带说不行",
        "猪不想吃，是嘴巴它有自己的想法",
        "食物储备...呃，好像储备到喉咙了",
    }
    STRINGS.ZHUYUAN_GIVEBACK = {
        "家徒四壁，凉风习习，猪生惨淡",
        "玩家已经穷困到需要猪来同情了吗?",
        "坏了，猪好像把玩家的经济吃崩盘了",
        "饥荒，真的开始了",
        "是时候开展一场轰轰烈烈的觅食运动了",
        "残羹冷炙都没有，猪生无望",
        "猪得考虑光合作用的可行性了",
    }
    STRINGS.ZHUYUAN_CANNOTCOOK = {
        "君子远庖厨，古人诚不我欺",
        "猪的才华，在更广阔的领域",
        "油烟，是知识的天敌",
        "猪的手，是用来捧书和拿筷子的，不是拿锅铲的",
        "做饭会干扰猪对美食的纯粹鉴赏",
        "术业有专攻，猪攻的是‘吃’术",
    }
    STRINGS.ZHUYUAN_STARVE = {
        "啊！猪饿死了!",
        "“投喂！立刻！",
        "能量不足，四蹄生根…",
        "饿殍遍野！",
        "救救孩子！救救猪猪！",
        "猪的HP正在归零！",
        "饿到前胸贴后背",
        "四肢乏力，五内俱空！",
        "猪的肚子在吟唱《饿狼传说》...",
        "饿到昏厥...",
        "饥饿是对猪猪的酷刑！",
    }
    STRINGS.ZHUYUAN_STARVE_SUCCESS = {
        "阁下果然深明大义!",
        "一缕饭香，便是猪的大复活术！",
        "猪感觉知识与力量一起回来了",
        "滴水之恩，当…当再来一碗！",
        "你拯救了猪的世界",
        "你就是猪的再世父母！呃，饭父母！",
        "猪吃饱后愿为你赋诗一首！",
        "此恩此德，没齿难忘！",
        "从今天起，你就是猪的首席饲养员了",
        "感觉智商又重新占领高地了",
        "这份恩情，猪先记胃里了！",
        "谢谢，你为世界保存了智慧的火种！",
        "活过来了！",
    }
    STRINGS.ZHUYUAN_STARVE_FAIL = {
        "世态炎凉，猪心可鉴…",
        "玩家的良心，怕是和食物一起被偷吃了",
        "失策，躺尸也该选个C位",
        "猪要死了，死的很安详…才怪！",
        "记在小本本上，第N次被无视",
        "这就是人性吗？猪看透了",
        "猪的墓碑上会写：死于玩家的冷漠",
        "再也不跟不给饭吃的玩家混了",
        "心好冷，比没饭吃的胃还冷...",
        "猪在这里，饭在远方",
        "猪的牺牲，都不能换来你的一丝愧疚吗",
        "猪的遗产...是...一肚子...空气",
    }
    STRINGS.ZHUYUAN_DANCE_PLANT = {
        "当当康康，速速成长~",
        "成长，生命，幸福还有我的朋友~",
        "长！长！长！长得又快又好！",
        "句芒大人！帮帮忙，长出萝卜三尺长！",
        "以当康之名，赐汝生机！",
        "蹦恰恰，快快长，今晚加餐有希望！",
        "长叶子，开花花，结出果子给猪夸！",
        "快快长，长得肥，猪的肚子在指挥！",
    }
    STRINGS.ZHUYUAN_CANNOT_DANCE = {
        "此地风水不佳，影响猪施法",
        "法阵需要空间",
        "罢了，今日不宜动土",
        "此处不宜作法",
        "此处地脉堵塞，待猪疏通一番",
    }
    STRINGS.ZHUYUAN_TALK_PANICBOSS = {
        "杀猪啦！救命啊！!",
        "快跑啊",
        "战略转移！快！",
        "猪命关天，闲猪退散！",
        "逃啊！难道等着变成红烧猪吗？",
        "君子不立危墙之下，猪也是！",
    }
    STRINGS.ZHUYUAN_TALK_FIND_MEAT = {
        "猪的意志在美食面前不堪一击",
        "这该死的诱惑",
        "食物！带着自由的香气",
        "一口下去，猪得长多少斤",
        "这不是贪吃，这是对美食的虔诚追求",
        "此乃阳谋！是肉先动的手",
        "古有柳下惠坐怀不乱，今有猪见肉...",
        "肉光潋滟盘方好",
        "坏鸟撞见此景，一定会讥讽",
        "猪的修行，总在见肉时破功",
        "猪三省吾身：可吃否？该吃否？何吃否？",
        "嗅此荤香，如听太古遗音",
        "此肉便是祥云",
        "肉掉到地上还不到3秒",
    }
    STRINGS.ZHUYUAN_TALK_ATTEMPT_TRADE = {
        "你看着猪的眼神，不太纯粹?",
        "以物易物，还是以食易事?",
        "等价交换，童叟无欺",
        "想从猪这换点啥？看看你的诚意",
        "一手交钱，一手交货",
        "猪手里可都是好东西",
    }
    STRINGS.ZHUYUAN_TALK_GIVE_GIFT = {
        "猪鼻铸币，童叟无欺!",
        "拿去拿去，莫要再烦猪吃饭",
        "喏，赏你的，莫要外传",
        "此物与你有缘",
        "好好收着，关键时刻能…能换个馒头也说不定",
        "猪的馈赠，蕴含着...嗯...猪的心意",
    }
    STRINGS.ZHUYUAN_FIGHTCROW = {
        "来打一架吧！",
        "比法术还是比饭量？",
        "猪的战术：体重服人！",
        "御前侍卫的功夫，猪可没忘！",
        "聒噪之鸟，可识得此‘肉弹战车’？",
        "羽翼未丰，猪能让你三招",
        "今日让你见识下，什么叫‘知识就是重量’！",
        "猪冲起来，自己都怕！",
        "猪突猛进！",
        "礼毕，看招！",
        "猪给你练几式‘庖丁解牛’",
        "看招！饱嗝震天！",
        "当康大人不许猪动手，坏鸟是例外",
        "猪要堵住你的嘴",
        "坏鸟！偷吃猪的零食！",
    }
    STRINGS.ZHUYUAN_GOSHOP = {
        "猪门酒肉臭，乌鸦皱眉头",
        "来咯，来咯",
        "客官这边请！",
        "客官稍等哈",
        "肥猪拱门",
        "猪突猛进",
        "不买别碰！",
    }
    STRINGS.ZHUYUAN_HITSHOP = {
        "你是来砸场子的",
        "店没了，天塌了",
        "你最好给我造一家新铺子",
    }
    STRINGS.ZHUYUAN_TALKSHOP = {
        "别乱碰哦",
        "要点什么？",
        "微笑服务~",
        "顾客就是上帝~",
    }
    STRINGS.ZHUYUAN_BREWSHOP = {
        "马上就好",
        "正在备货",
        "慢工出细活",
    }

    -- 羽润的文本大部分由ChatGPT 4o生成，威吊自行调整
    -------------------------羽润的台词------------------------------
    STRINGS.YURUN_SHOCK = {
        "不好，有人对鸦施法！",
        "阿嚏！",
        "鸦的脑袋！",
        "是空袭！？",
    }
    STRINGS.YURUN_ANGRY = {
        "你恶贯满盈，下次别落在鸦手里！",
        "鸦年轻的时候，比你有规矩多了",
        "鸦跟你不是天下第一好了！",
        "你欺骗鸦的感情？",
        "鸦今天不想再跟你说话了",
        "以后跟鸦少联系吧",
        "嚣张的小怪物，你会被凶兽做成烤鸦!",
        "鸦这里有新鲜的长猪肉你要不要呢？",
        "你这一周都别想出红！",
        "你功德-1! -1! -1!",
        "你上鸦的失信名单了！",
        "你的本周功德清零！",
        "鸦要把你移出共享歌单",
        "鸦觉得你的良心出走了",
        "鸦会把你写进《反派作死指南》",
        "你出塔就被雷劈到毛都不剩！",
        "你果然不是好鸟！",
    }
    STRINGS.YURUN_CAMPFIRE = {
        "篝火的光亮让鸦安心",
        "篝火像是凤凰大人的羽翼！",
        "人类生火的本事真是高超",
        "鸦想要一个带翅膀的火盆",
        "要不要再添点树枝进去？",
        "以前凤凰大人最喜欢用火梳理羽毛了",
        "不能离火太近，鸦的羽毛不防火",
        "小心点，别让火烫到鸦",
        "鸦感觉自己像火神祝融",
        "鸦也想帮你添点燃料",
        "鸦全身都暖洋洋的",
        "鸦喜欢篝火",
        "噼里啪啦的火光",
        "火可以驱赶怪物",
        "鸦觉得活力满满",
        "火太旺的话，鸦会变烤鸦",
        "火太小的话，鸦会打哆嗦",
    }
    STRINGS.YURUN_TOCHERRYPLAYER = {
        "可以给鸦讲讲樱花林吗",
        "鸦也想去樱花林看看",
        "他给鸦讲过许多樱花林的故事！",
        "塔里曾经有一块樱花林的地皮！",
        "鸦想尝尝樱桃",
        "樱花林里有神奇的花朵吗？",
        "樱花林真的会下樱花雨吗",
        "樱花林里的风带着甜甜的香气！",
        "真的有古老的樱花树吗？",
        "樱花林的传说是真的吗？",
        "樱花林美的就像一场梦",
        "有蓝色的樱桃吗",
        "樱桃可乐？鸦觉得还是算了",
    }
    STRINGS.YURUN_TOPLAYER = {
        "鸦见过一个叫查理的女孩，不太好惹",
        "你见过凤凰大人吗？",
        "有什么事要找鸦吗？",
        "你好，没羽毛的小怪物",
        "鸦对你很好奇",
        "你会成为鸦的好朋友吗？",
        "找帮手？先声明，鸦不擅长战斗！",
        "鸦觉得人类总是想得太多",
        "喂！喂！鸦饿了",
        "能借你武器来玩一下吗？",
        "鸦喜欢和你待在一起",
        "鸦能帮忙吗？",
        "你看起来很忙",
        "你没鸦厉害，但也还行",
        "教教鸦一些你会的东西啦？",
        "你忙碌的样子很吸引鸦",
        "你刚刚在摸鱼吗？",
        "告诉鸦一个小秘密吧，鸦会保密",
        "鸦是不是很特别？",
        "鸦可是塔里最聪明的鸟！",
        "鸦觉得你很像他",
        "你看起来像个小英雄",
        "鸦希望你每天都有红红的礼物可以收",
        "鸦今天做了下头发，你觉得怎么样？",
        "你是来薅鸦毛的吗？",
        "是想鸦了吗？",
        "鸦觉得你可以换身衣服了",
        "吓鸦一跳",
        "没羽毛，还没尾巴！你好可怜哦",
        "法术传鸦不传人，你去找猪吧",
        "你找到彩色羽毛了吗？",
        "你很有天赋，跟鸦学做鸦吧！",
        "猪说自己是带刀侍卫?其实它只负责试菜!",
    }
    STRINGS.YURUN_BACKSELF = {
        "鸦喜欢自己的名字，但笨猪总是叫错！",
        "鸦学过几句外语……",
        "鸦在学外语：喵，喵喵喵……",
        "西方魔法，东方法术，鸦都会一点",
        "鸦想尝一杯山海烧仙草",
        "鸦想要一根彩色羽毛……",
        "鸦也想尝尝塔下的大锦鲤……",
        "鸦有个装修计划，需要人帮忙搬大石头",
        "鸦好想他...",
        "月亮掉下来把塔砸破了",
        "鸦用法术才堵住了塔的缺口",
        "鸦想吃亮晶晶的石头",
        "这里的空气太干燥了",
        "为什么世界这么大，鸦这么小呢？",
        "鸦还不能离开这座塔",
        "鸦想自己的小巢了",
        "黑漆漆的地方让鸦害怕",
        "这棵树很奇怪，鸦怀疑它要成精了",
        "鸦还是喜欢自己的小窝",
        "鸦想要一身更炫的羽毛",
        "之前鸦和笨猪都可以自由进出塔",
        "啊嚏！笨猪在骂鸦！",
    }
    STRINGS.YURUN_NIGHT = {
        "晚安",
        "鸦要回巢咯",
        "困死鸦了",
        "小床，鸦来啦",
        "鸦想歇歇了",
        "风真舒服",
        "今晚风好轻",
    }
    STRINGS.YURUN_SCARED = {
        "敌袭，隐蔽！",
        "别乱动！",
        "鸦毛都竖起来了",
        "别惊动它！",
        "喳！",
        "快藏起来",
        "敌人来了！",
        "别是怪物吧？",
        "快撤！",
        "快跑！",
        "鸦的腿都软了！",
        "这可不妙！",
    }
    STRINGS.YURUN_HASGIFT = {
        "谢谢，但是先让鸦把零食吃完",
        "等一下鸦",
        "鸦拿不过来了",
        "你想让鸦变成肥鸦吗",
        "谢谢你，但是鸦要减肥",
    }
    -- STRINGS.YURUN_KEEPGIFT = {
    --  "鸦又收到礼物了！",
    --     "鸦太感动了",
    --     "你真好",
    --     "鸦喜欢这个",
    --     "真是太体贴了",
    --     "真的是给鸦的吗？",
    --     "鸦会好好珍惜的",
    -- }
    STRINGS.YURUN_REFUSEGIFT = {
        "你硬给的话，鸦可能会扔掉",
        "这个留给笨猪吧",
        "鸦以为你很了解鸦的",
        "鸦不喜欢",
        "鸦不太需要这个",
        "塞给鸟笼里那只鸟吧！",
        "这个…鸦不喜欢",
        "这个不适合鸦",
        "你还是自己留着这个吧",
        "这东西太重了",
        "你就给鸦这个？",
    }
    STRINGS.YURUN_COOKPOT = {
        "这是给鸦准备的食物吗？",
        "锅里煮的是什么？",
        "鸦闻到好闻的味道",
        "鸦想尝一口，一小口",
        "鸦的口水快流出来了",
        "希望不是鸦血粉丝汤",
        "闻起来像是鸦的最爱！",
        "鸦可以吃吗？",
        "鸦刚好饿了",
        "是不是放了鸦喜欢吃的果子？",
        "这个味道鸦好像闻过",
        "鸦看得有点馋了",
        "这是专门为鸦做的吗？",
        "能不能给鸦尝尝",
        "鸦已经准备好迎接美味了",
    }
    STRINGS.YURUN_KNOCKPIG = {
        "笨猪，出来！",
        "懒虫起床！",
        "笨猪，鸦准备了新鲜的五花肉",
        "再不出来鸦要放火啦！",
        "出来，塔里着火啦！",
        "那些没毛的小怪物想要看看猪",
        "笨猪，你还活着吗？",
        "再不出来鸦要拔猪毛了！",
        "外面有人说它比猪还懒！",
        "开门，鸦找到一只会跳舞的鸭子！",
        "笨猪，树上长出了石头了，出来看！",
    }
    STRINGS.YURUN_HAPPYDANCE = {
        "鸦需要努力练习法术",
        "愿您喜欢~",
        "希望能让您满意~",
        "这是鸦的最大程度了",
        "鸦新学的法术",
        "聚灵，火焰！",
        "鸦要积聚灵力！",
        "以表敬意！",
        "燃烧！",
    }
    STRINGS.YURUN_ADDFUEL = {
        "篝火不够旺",
        "鸦找到了一根好木头",
        "篝火不能灭",
        "鸦真是火盆天才",
        "篝火需要木柴",
        "火光还不够亮",
        "篝火一下子就精神了",
        "鸦是燃料小能手",
        "加点柴火",
        "鸦来拯救它",
        "鸦是不是特别厉害？",
        "别担心",
        "篝火是晚上最重要的朋友",
        "鸦觉得自己帮了大忙",
    }
    STRINGS.YURUN_CHERRYGIFT = {
        "樱桃！大樱桃！",
        "鸦没吃过这个，鸦很感激你",
        "你见过樱花林？了不起的鸦！",
    }
    STRINGS.YURUN_MAGICGIFT = {
        "西方魔法，东方法术，鸦都会一点！",
        "你没翅膀鸦，那就用这个魔法代替吧！",
        "这是鸦从一位巫师那里偷偷学到的魔法",
    }
    STRINGS.YURUN_GIVEGIFT = {
        "这是鸦的珍藏",
        "好好珍惜哦",
        "这是鸦精挑细选的回礼",
        "这是鸦送你的",
        "鸦一眼就觉得它应该是你的",
        "这是鸦从别的地方‘借’来的",
        "鸦大方吧？",
        "以后也要对鸦好一点",
        "鸦觉得这个东西很神奇，送给你",
        "别舍不得用哦！",
        "你会需要这个的",
        "这可不是一般货色",
        "鸦的一点小心意",
        "鸦用聪明才智‘借’到的东西",
        "别问鸦怎么弄来的",
        "这是鸦特意为你准备的",
        "这个东西，值很多亮晶晶的",
        "鸦收到礼物了！",
        "鸦太感动了",
        "你真好",
        "鸦喜欢这个",
        "真是太体贴了",
        "真的是给鸦的吗？",
        "鸦会好好珍惜的",
    }
    STRINGS.YURUN_GETFEATHER = {
        "你找到凤凰大人了！",
        "彩色的羽毛！",
        "你是鸦的好朋友！",
        "鸦一直在找这个！",
    }
    STRINGS.YURUN_FIGHTPIG = {
        "鸦要打你的猪屁股！",
        "乌鸦坐飞机！",
        "猪臀圆润，正好给鸦练爪！",
        "猪突猛进？鸦看你是年糕翻滚！",
        "鸦会给你插根鸟毛，然后当毽子踢！",
        "打输了你可别哭！",
        "不会飞的笨猪！",
        "天下武功，唯快不破！",
        "鸦的耐心和你的裤带一样松！",
    }

-- 强制离开二岛的台词
STRINGS.DSC_FORCEMOVE = {
    "我不该擅闯这块区域！",
    "这是什么？！",
    "我没有资格踏足这里",
    "这块岛屿在排斥我！",
}

-- 芝上谈冰缺少材料
STRINGS.SH_NO_INGREDIENT = {
    "巧妇难为无米之炊！",
    "没有材料呀",
    "脑子里有了，但是材料不够",
    "试图空手套白狼吗？",
    "我得先收集这些材料！",
}

-- 野生猪人的线索文本
STRINGS.REFUSE_READ = {
    "平白无肉的，为什么要帮你？",
    "空着手找猪帮忙？",
    "你不是朋友，不会帮你读",
    "除非你能给点咨询费",
    "你上次说请我吃饭的",
    "想白嫖？借米下锅你都不带柴火？",
    "猪人不是免费劳动力！",
    "肉！肉！要先给肉！", 
}
STRINGS.REDPAPER_CLUE_PRE = {
    "上面写着:",
    "我看看哦:",
    "模糊看到:",
}
STRINGS.THE_ONLY_PASSWD = "洞天塔解密答案，"
STRINGS.THE_FAIL_PASSWD = "密码丢失"
STRINGS.REDPAPER_CLUE_CORRECT = {
    -- "悬河秘境会在世界之外...",
    -- "悬河灵玉是通往悬河秘境的通行证",
    "萤火芳菲皆可容：花瓣、荧光果...",
    "古老的天地灵韵：句芒印记",
    "金黄满树如蝶翻：银杏叶",
    "不见风霜刻骨痕：宝石",
    "空的长生不老药？你应该收集起来！",
    "在月圆之夜给羽润1个南瓜，它会教你魔法的~",
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
        "如你所愿...",
        "恭喜..",
        "值得庆贺...",
    },
    FIGHT = {
        "你胆敢挑战我?",
        "时机未到，孩子...",
        "等你参透时空之力再来吧...",
    },
    SUPERIOUS = {
        "雾隐山岚~",
        "四海惊澜~",
    },
    WRONG = {
        "要发动你的小脑筋，孩子",
        "到猪人部落碰碰运气吧",
        "你该留意下那些纸燕...",
        "那些纸燕身上藏有线索",
        "你真打算瞎猜吗",
        "猪人的文字我也看不懂",
    },
    EATTACO = {
        "美味！",
        "哦？给我的祭品？",
        "小辈，你的心意我收到了",
    },
    TIMETACO = {
        "时光的小偷！",
        "光阴贼！",
        "我的时空之力！",
    },
}

-- 长老的文本
STRINGS.DC_ELDER = {
    START = {
        "你来啦",
        "想玩一会了吗",
        "下棋第一，友谊第二",
    },
    ANOTHER = {
        "哦？你也要试试吗",
        "没毛病，这个游戏要两个人才好玩",
        "去吧，挑战者",
    },
    INGAME = {
        "好吧，我会亲自出手",
        "我来露两手",
        "我会给你上一课的",
    },
    NEXTMOVE = {
        "呃...",
        "对的对的，哦不对不对！对吗？",
        "5个棋子你还能秒我？",
        "你可别作弊",
        "下这里比较合适",
        "...",
        "当局者迷，旁观者清"
    },
    REWARD = {
        "这是你的奖励！",
        "总得有点小奖品",
    },
    EQUALWIN = "平局！",
}

STRINGS.TICTACTOE = {
    ALREADYIN = {
        "我已经参与游戏了",
        "没办法给两次啦",
    },
    GAMEIN = {
        "我现在得观战...",
        "游戏进行中",
    },
    STARTGAME = {
        "我会赢的！",
        "我可是井字棋高手！",
    },
    ANNOUNCE_PRE = "游戏开始！玩家(",
    ANNOUNCE_PST = ")先手",
    NOTGAMETINE = {
        "游戏未开始",
        "时机未到！",
    },
    OUTGAME = {
        "我不是这局游戏的参与者",
        "观棋不语真君子",
    },
    WRONGPIECE = "我用错棋子了",
    WRONGTURN = "现在不是我的回合",
    WRONGPLACE = "无效的位置",
    ALREADPLACED = "这个位置已经有棋子了",
    GAMEGOON_PRE = "轮到玩家(",
    GAMEGOON_PST = ")行动",
    WIN_PRE = "玩家(",
    WIN_PST= ")获胜！",
    ANOTHERROUND= "好吧，再来一次！",
    TIMEOUT = "等的太久了，该结束了...",
}

---------------------------------------------------------------
-------------------------加载界面的文本台词----------------------
---------------------------------------------------------------
STRINGS.UI.LOADING_SCREEN_MONTFLUV_TIPS = {}
---------------------------------------------------------------
-------------------------天狗食月的事件台词----------------------
---------------------------------------------------------------
STRINGS.START_EAT_MOON = "天空传来犬吠…"
STRINGS.SUCCESS_EAT_MOON = "月芒消散…"
STRINGS.BREAK_EAT_MOON = "当心，它掉下来了…"


---------------------------------------------------------------
------------------------    宣告文本    ------------------------
---------------------------------------------------------------
-- 山海烧仙草
________COOKBOOK.FOOD_EFFECTS_SHANHAI_BUBBLETEA = "小羽润的品味真不错！"
________ANNOUNCE.FOOD_EFFECTS_SHANHAI_BUBBLETEA = {
    "清凉爽口",
    "我感觉自己冷静了不少",
    "小羽润的品味真不错！",
    "小羽润喜欢它是有原因的！",
}
-- 芝上谈冰
________COOKBOOK.FOOD_EFFECTS_SH_GANOERMAICE = "纸上得来终觉浅，绝知此事要躬行"
________ANNOUNCE.FOOD_EFFECTS_SH_GANOERMAICE = {
    "纸上得来终觉浅，绝知此事要躬行",
    "有帮助，但我更应该自己动手",
    "这能解决燃眉之急",
    "我现在灵感爆发！",
}
-- 长生不老药
________COOKBOOK.FOOD_EFFECTS_SH_NEVEROLD = "我的器官好像没接收到永生的通知.."
________ANNOUNCE.FOOD_EFFECTS_SH_NEVEROLD = {
    "或许不会变老，但还是会秃头",
    "我的器官好像没接收到永生的通知..",
    "既然长生了，那就加班到宇宙爆炸吧",
    "这味道像过期的牛奶！",
}
-- 山河卷饼
________COOKBOOK.FOOD_EFFECTS_SH_TACO = "饼要薄，馅要厚！"
________ANNOUNCE.FOOD_EFFECTS_SH_TACO = {
    "开心，但是不太顶饱",
    "烛龙很喜欢这个..",
    "墨西哥饮食文化的代表",
    "我得再来一个",
}
-- 不允许卷饼的食物
________ANNOUNCE.ACTIONFAIL.SHROLLFOOD = {
    BANFOOD = "威吊说这样太超模了，不行",
}
-- 沾光失败
________ANNOUNCE.ACTIONFAIL.MIGU_ZHANGUANG = {
    TOOLOW = "还没我这个好呢",
}
-- 沾光成功
________ANNOUNCE.ANNOUNCE_ZHANGUANGE = {
    "我占了好大的便宜",
    "朋友之间要互帮互助",
    "冒险家 help 冒险家",
}
-- 召回钦原
________ANNOUNCE.ACTIONFAIL.BEEBACK = {
    BACKFAIL = "有人抢先一步了",
}
-- 给予鲲鹏物品
________ANNOUNCE.ANNOUNCE_KUNPENG_TRIBUTE ={
    "我给你带了点东西!",
    "这是给你的!",
    "哇... 你看起来很，呃，大！",
}
-- 逼供纸燕
________ANNOUNCE.ACTIONFAIL.FORCEWRITE = {
    CANNOTWRITE = "它可什么都不知道",
}
-- 给句芒普通肥料
________ANNOUNCE.ACTIONFAIL.FERTILIZE = {
    NOTXIRANG = "我想这不是它想要的养分",
}
-- 寄生种藤失败
________ANNOUNCE.ACTIONFAIL.LODGEOCEANTREE = {
    WRONGSEED = "这东西放不到那里去",
    NOOCEANTREE = "里面没有植株可以依附",
}
-- 放生发光蟹失败
________ANNOUNCE.ACTIONFAIL.RELEASECRAB = {
    NOOCEANTREE = "水里没有依附，它们会淹死的",
    ISINFECTED = "已经有发光蟹在这里安家啦",
}
-- 恶搞羽润时间不合适
________ANNOUNCE.ACTIONFAIL.MIGU_DEST = {
    NOTGOODTIME = "嘿，它忙着呢",
}
-- 恶搞羽润
________ANNOUNCE.I_AM_BAD = {
    "咦，我们好坏啊",
    "哎呀，这是故意不小心的",
}
-- 寄生种藤
________ANNOUNCE.ANNOUNCE_LODGE_OCEANTREE = {
    "小藤蔓想要借宿一下",
    "快快长大~",
}
-- 放生发光蟹
________ANNOUNCE.ANNOUNCE_RELEASE_CRAB = {
    "以后这里就是你们的家了",
    "羽润有了新的小朋友",
}
-- 施肥子圭科技
________ANNOUNCE.FERTSIVING = {
    "子圭会消耗它很多的肥力",
    "现在它要缓一缓了",
}
-- 采集迷榖树
________ANNOUNCE.PICK_UP_MIGU = {
    "现在我不会迷路了",
    "它会照亮我的道路",
    "我有预感，这一定会派上用场",
}
-- 给百鸟朝凤多余羽毛
________ANNOUNCE.ALREAY_GOT = {
    "给再多也没用啦",
    "这可不是鸡毛掸子",
}
-- 捕捉钦原
________ANNOUNCE.ANNOUNCE_NET_QINYUAN = {
    "别让它跑了！",
    "它的尾刺太锋利了",
}
-- 给鸟笼中的纸燕奇怪的东西
________ANNOUNCE.ANNOUNCE_GIVE_PAPERBIRD = {
    "纸燕会吃这个吗？",
    "不如给它一支笔",
    "它毕竟不是真鸟",
    "你到底想要什么，说中文!",
}
-- 钦原死亡
________ANNOUNCE.ANNOUNCE_QINYUAN_DEATH = {
    "是我害了你!",
    "不要！",
    "小蜜蜂暴毙了！",
}
-- 钦原召回
________ANNOUNCE.ANNOUNCE_QINYUAN_RETRIEVE = {
    "回来吧~",
    "你也该休息一下了",
    "嘿！别拿你的蜂刺对着我！",
}
-- 激怒钦原
________ANNOUNCE.ANNOUNCE_QINYUAN_AGGRESSIVE = {
    "陷入蜂狂吧~",
    "上吧！",
    "扎！狠狠地扎！",
}
-- 平息钦原
________ANNOUNCE.ANNOUNCE_QINYUAN_DEFENSIVE = {
    "别激动~",
    "对不起，快回来",
    "你该控制下自己的脾气了",
}
-- 拯救鲲鹏
________ANNOUNCE.ANNOUNCE_KUNRIDER_GOODBYE = {
    "再见，大家伙！",
    "下次要小心咯~",
}
-- 锁妖失败
________ANNOUNCE.ACTIONFAIL.DSCCAVESEAL = {
    NOSPAWNER = "这里距离它的巢穴太远了",
    SOMETHINGWRONG = "施法失败了？",
    CANTSEAL = "现在不是它最虚弱的时候！",
}

-------------------------封印洞天的事件台词-----------------------
STRINGS.SHANHAI_SEAL = {
    SUCCESS = "封印成功",
    FAIL = "对不上，封印失败了",
    WIRED = "它的来源有问题，没有封印能力",
}
-------------------------采集樗里的事件台词-----------------------
STRINGS.GOUMANG_LINES = {
    "有什么东西掉下来了？",
    "天地灵韵凝聚之物!",
    "天地奥秘，不可轻视",
}
-------------------------星引吸引物品的检查----------------------
STRINGS.WXTY_LINES = {
    "这不可能！",
    "你要去哪？",
    "快点抓住它！",
    "我看到我的东西在天上飞！",
    "一级警戒，疑似豹卷风出没！"
}
-------------------------悬河秘境开启文本------------------------
STRINGS.XUANHE_GEN = {
    "天道幽隐，尘世蒙昧",
    "洪荒再临，万物归寂",
    "苍穹无声，悬河低语",
    "神鸟高翔，四海惊澜",
}
-------------------------朱厌击杀天道文本------------------------
STRINGS.ZHUYAN_DEAD = {
    "该死!",
    "别得意！",
    "你以为你能杀死我？",
    "你杀不死我的",
    "只是陨落一个化身而已",
    "我们还会见面的！",
    "我会回来的！",
}
STRINGS.ZHUYAN_MUSIC = {
    "魔音！",
    "蛊惑！",
    "失智！",
    "迷失！",
}
STRINGS.ZHUYAN_SUMMON = {
    "战争!",
    "天下大乱！",
    "兵乱！",
    "内讧！",
}
-------------------------烛龙宣告文本------------------------
STRINGS.ZHULONG_TEXT = {
    "昼夜 分明！",
    "永恒白天，目光如炬！",
    "永恒黄昏，昏昏欲眠！",
    "永恒黑夜，闭眼长眠...",
    "延长白天？我会打起精神的",
    "延长黄昏？如你所愿",
    "延长黑夜？你喜欢就好",
    "吞噬 白天！",
    "吞噬 黄昏！",
    "吞噬 黑夜！",
}

---------------------------------------------------------------
------------------------不同物品的检查文本------------------------
---------------------------------------------------------------
-- 特殊物品【弃用】
________DESCRIBE.KUNPENG = "来自北冥的超超超级海底霸主"
________DESCRIBE.KUNPENG_ATTACK_HORN = "开玩笑的吧"
________DESCRIBE.KUNPENG_HORN = "小山一样"

-- 祭台
________DESCRIBE.DEEPSEACAVE_UPGRADER = {
    IS_COOLDOWN = "还不行吗",
    IS_HOLDING = "这会是正确的选择吗？",
    GENERIC = "放在上面的物品经常会丢",
}
-- 出口
________DESCRIBE.DEEPSEACAVE_EXIT = {
    NO_ACCESS = "谁把门关了？",
    GENERIC = "我们得造一部电梯",
}
-- 扭曲的大树
________DESCRIBE.DSC_OCEANTREE_PILLAR = {
    SINGLE_PAINTED = "那是谁画上去的？",
    DOUBLE_PAINTED = "我想把自己也画上去",
    LIGHT_SHOW = "难以置信",
    GENERIC = "生命的顽强驱使它找到了出路",
}
-- 灵芝
________DESCRIBE.SHANHAI_GANODERMA = {
    PICKED = "这下看小蘑菇怎么嚣张",
    GENERIC = "长在地上的小恶魔",
    INGROUND = "那是什么，棒棒糖？",
}
-- 银杏树
________DESCRIBE.SHANHAI_GINKGO_TREE = {
    BURNT = "抱歉",
    SHORT_STUMP = "我们应该感到愧疚",
    SHORT = "它没多少叶子",
    NORMAL_STUMP = "我很抱歉",
    NORMAL = "植物也有尴尬期吗",
    TALL_STUMP = "我们不该这样的",
    TALL_YELLOW = "像是挂满了金色的蝴蝶",
    GENERIC = "我更喜欢它金色的样子",
}
-- 洞天塔
________DESCRIBE.DEEPSEACAVE = {
    IDLE = "里面有一方神奇的小天地",
    IDLE_DEPLOY = "它的外表看起来很小，可是里面却出奇的大！",
    ACTIVATE = "哇…哇噻！",
    GENERIC = "打包！带走！",
}
-- 朱源
________DESCRIBE.DEEPSEACAVE_PIGHOUSE = {
    CAN_KNOCK = "开门！",
    PIG_OUT = "猪出来了，我能住进去吗？",
    GENERIC = "我很想住进去",
}
-- 羽润
________DESCRIBE.DEEPSEACAVE_CROW = {
    SIT_LOOP = "它好乖啊",
    HOLD = "呃，好大的力气",
    SHOW = "我想给它一个拥抱",
    TOP = "今天我们都是超级玛丽",
    GENERIC = "它跟别的小乌鸦很不一样",
}
-- 荫影潭
________DESCRIBE.DEEPSEACAVE_POOL = {
    GENERIC = "好清冽的潭水",
}
-- 洞天塔封印
________DESCRIBE.DEEPSEACAVE_SEAL = {
    GENERIC = "纸上画几个符号就行吗？",
}
-- 洞天塔围墙
________DESCRIBE.DEEPSEACAVE_WALL = {
    GENERIC = "它能保护我不掉进虚空里面去",
}
-- 云鞍
________DESCRIBE.SADDLE_KUN = {
    GENERIC = "这是真的云吗",
}
-- 山海烧仙草
________DESCRIBE.SHANHAI_BUBBLETEA = {
    GENERIC = "杯子是也锅里做出来的？",
}
-- 贝壳箱子
________DESCRIBE.SHANHAI_SHELLCHEST = {
    GENERIC = "原来这是能打开的吗…",
}
-- 石头箱子(隐藏)
________DESCRIBE.SHANHAI_HIDDENCELLAR = {
    GENERIC = "石头材质，锁链加封",
}
-- 石头箱子
________DESCRIBE.SHANHAI_HIDDENCELLAR_USE = {
    GENERIC = "石头材质，锁链加封",
}
-- 花藤
________DESCRIBE.SHANHAI_FLOWERVINE = {
    GENERIC = "花好月圆人长久",
}
-- 蝴蝶（蓝）
________DESCRIBE.SHANHAI_BLUEFLY = {
    GENERIC = "它能治好我的伤",
}
-- 蝴蝶（绿）
________DESCRIBE.SHANHAI_GREENFLY = {
    GENERIC = "树叶在飞舞",
}
-- 蝴蝶（橙）
________DESCRIBE.SHANHAI_ORANGEFLY = {
    GENERIC = "小蝴蝶伪装成了树叶",
}
-- 蝴蝶（白）
________DESCRIBE.SHANHAI_WHITEFLY = {
    GENERIC = "那是月蛾吗",
}
-- 句芒叶
________DESCRIBE.SHANHAI_GOUMANG_ITEM = {
    GENERIC = "它散发一股清香",
}
-- 句芒植株
________DESCRIBE.SHANHAI_GOUMANG_PLANT = {
    IDLE = "古老而神秘的植物",
    NORMAL = "没关系的，我可以等",
    DEAD = "永恒大陆的土壤不适合它生长",
    GENERIC = "什么情况？",
}
-- 句芒印记
________DESCRIBE.SHANHAI_GOUMANG = {
    GENERIC = "上古之气，隐约其中",
}
-- 隐藏出口
________DESCRIBE.SHANHAI_HIDDENEXIT = {
    GENERIC = "要不我们踢两脚试试看？",
}
-- 星引
________DESCRIBE.SHANHAI_STARFLY = {
    GENERIC = "如果能用来抓鱼就好了",
}
-- 月坠
________DESCRIBE.SHANHAI_MOONFALL = {
    GENERIC = "天上要掉金子啦",
}
-- 鹿茸
________DESCRIBE.SHANHAI_MUSHROOMGUARD = {
    GENERIC = "春天它会长出无眼鹿吗",
}
-- 采集的灵芝
________DESCRIBE.GANODERMA_CAP = {
    GENERIC = "它还是长在地上更好看",
}
-- 烤熟的灵芝
________DESCRIBE.GANODERMA_CAP_COOKED = {
    GENERIC = "好香啊，想一口吞掉",
}
-- 晶洞蔓种
________DESCRIBE.SHANHAI_PARASITICSEED_GEM = {
    GENERIC = "要给它找一个合适的宿主",
}
-- 夜视蔓种
________DESCRIBE.SHANHAI_PARASITICSEED_NIGHT = {
    GENERIC = "要给它找一个合适的宿主",
}
-- 臃肿树苗
________DESCRIBE.SHANHAI_PINECONE = {
    GENERIC = "它已经迫不及待要成长了",
}
-- 臃肿常青树苗
________DESCRIBE.SHANHAI_PINECONE_SAPLING = {
    GENERIC = "加油啊，小生命",
}
-- 银杏果
________DESCRIBE.SHANHAI_GINKGO = {
    GENERIC = "有股怪怪的味道",
}
-- 银杏树苗
________DESCRIBE.SHANHAI_GINKGO_SAPLING = {
    GENERIC = "这么小，我会不会踩到你？",
}
-- 红绳
________DESCRIBE.SHANHAI_REDROPE = {
    GENERIC = "我的手指还能感觉到痛",
}
-- 宫
________DESCRIBE.SHANHAI_GONG = {
    GENERIC = "宫",
}
-- 商
________DESCRIBE.SHANHAI_SHANG = {
    GENERIC = "商",
}
-- 角
________DESCRIBE.SHANHAI_JUE = {
    GENERIC = "角",
}
-- 徵
________DESCRIBE.SHANHAI_ZHI = {
    GENERIC = "徵",
}
-- 羽
________DESCRIBE.SHANHAI_YU = {
    GENERIC = "羽",
}
-- 提交音符
________DESCRIBE.SHANHAI_FINISHORDER = {
    GENERIC = "收尾",
}
-- 烛龙法阵
________DESCRIBE.SHANHAI_SECRETPLACE = {
    GENERIC = "很硬，比绝望石还要夸张",
}
-- 山参精
________DESCRIBE.SHANHAI_SHANSHEN_ACTIVE = {
    GENERIC = "我没想过它会那么抗揍",
}
-- 山参
________DESCRIBE.SHANHAI_SHANSHEN_PLANTED = {
    GENERIC = "可口的果实",
}
-- 山参
________DESCRIBE.SHANHAI_SHANSHEN = {
    GENERIC = "都成人形了",
}
-- 山参精华
________DESCRIBE.SHANHAI_COOKEDSHANSHEN = {
    GENERIC = "烤完之后就只剩这一点了",
}
-- 小雕塑
________DESCRIBE.SHANHAI_SMALLSTATUE = {
    GENERIC = "我们应该为它重新设计一个外形",
}
-- 晶洞藤
________DESCRIBE.SHANHAIVINE_GEM = {
    GENERIC = "小心点，它会让我们的脑袋开花",
}
-- 夜莓藤
________DESCRIBE.SHANHAIVINE_NIGHT = {
    GENERIC = "讲真的，我不是很有食欲",
}
-- 月花藤
________DESCRIBE.SHANHAIVINE_MOON = {
    GENERIC = "如果有更多花色就好了",
}
-- 盛宴常青树
________DESCRIBE.SHANHAI_WINTER_TREE = {
    BURNT = "啊哦",
    BURNING = "大事不妙",
    CANDECORATE = "我们需要灯泡和彩条",
    YOUNG = "节日要到了",
}
-- 息壤
________DESCRIBE.SHANHAI_XIRANG_ITEM = {
    GENERIC = "小土堆在自己生长",
    ONCOOLDOWN = "他需要时间重新聚集灵气",
}
-- 神秘土壤
________DESCRIBE.SHANHAI_XIRANG = {
    GENERIC = "里面有什么宝贝？",
}
-- 息壤
________DESCRIBE.SH_XIRANG = {
    GENERIC = "充满灵力的小土堆",
}
-- 神秘土壤
________DESCRIBE.SH_XIRANG_PLANT = {
    XIRANG_FULL = "里面有什么宝贝？",
    GENERIC = "它需要时间重新长出来",
}
-- 朱厌
________DESCRIBE.SHANHAI_ZHUYAN = {
    GUARD = "拳头比沙包大",
    NORMAL = "没有防备，好机会！",
}
-- 百鸟朝凤
________DESCRIBE.STATUE_CHAOFENG = {
    GENERIC = "小乌鸦会喜欢这个的",
    ALL_FOUND = "神圣，威严",
}
-- 天狗食月
________DESCRIBE.STATUE_EATMOON = {
    EYESCLOSE = "帅气的大狗狗",
    EYESOPEN = "我现在有点担心，它会不会一口咬上来",
    MOONEATEN = "它跑到天上咬了月亮一小口",
    NODOG = "一眨眼的功夫，它就跑不见了，它去哪了？",
}
-- 涅槃重生
________DESCRIBE.STATUE_NIEPAN = {
    IS_COOLDOWN = "它没有那么炽热了，需要等一会",
    IS_HOLDING = "我有想要一把火点燃它的冲动",
    IS_NOT_HOLDING = "今天是要吃铁板烧了吗",
}
-- 龟蛋羹
________DESCRIBE.TORTOISE_CUSTARD = {
    GENERIC = "这个碗是龟壳吗？",
}
-- 悬河池塘
________DESCRIBE.XUANHE_POND = {
    STAGE_1 = "它需要：萤火芳菲皆可容",
    STAGE_2 = "它需要：天地灵韵聚凝华",
    STAGE_3 = "它需要：金黄满树如蝶翩？",
    STAGE_4 = "它需要：不见风霜刻骨痕？",
    STAGE_5 = "很高兴我能帮上忙",
}
-- 合璧蓝图雕塑
________DESCRIBE.SH_CHERRYSTATUE = {
    GENERIC = "它们在看蓝图，还是代码？",
}   
-- 四象鱼囿
________DESCRIBE.SH_SEASONAQUARIUM = {
    SPRING = "春山迷路鹅空啼",
    SUMMER = "夏窗低映龙逆粼",
    AUTUMN = "秋光银烛熊画皮",
    WINTER = "冬宴花凋鹿走目",
    ALLSEA = "岁岁朝朝开红皮",
    GENERIC = "现在我们可以实验一下小鱼的功效了",
}
-- 稍大的土堆
________DESCRIBE.SHANHAI_NORMALPILE = {
    GENERIC = "更大的收益伴随更大的风险",
}  
-- 仙女棒
________DESCRIBE.SH_SPARKLER_SMALL = {
    GENERIC = "这符合科学",
}
-- 小烟花
________DESCRIBE.SH_SPARKLER_1 = {
    GENERIC = "大一点就好了",
}
-- 烟花
________DESCRIBE.SH_SPARKLER_2 = {
    GENERIC = "节日快乐",
}
-- 大烟花
________DESCRIBE.SH_SPARKLER_3 = {
    GENERIC = "现在我是人群中最亮眼的了",
}
-- 朱厌角
________DESCRIBE.SH_KILLALL_WEAPON = {
    GENERIC = "天下大乱！",
}
-- 烟花发射器
________DESCRIBE.SH_IRONOPENWORK_BASE = {
    GENERIC = "春节快乐！",
}
-- 烟花发射器组件
________DESCRIBE.SH_IRONOPENWORK_BASE_KIT = {
    GENERIC = "快点放置起来",
}
-- 小乌鸦烟花
________DESCRIBE.SH_FIREWORKS = {
    GENERIC = "放心，不是真的乌鸦",
}
-- 银杏叶
________DESCRIBE.SHANHAI_GINKGOLEAVE = {
    GENERIC = "这并不是蝴蝶翅膀",
}
-- ？鲲鹏
________DESCRIBE.KUN_RIDER = {
    GENERIC = "它被困在这里",
}
-- 山花
________DESCRIBE.SH_FLOWER = {
    GENERIC = "采还是不采？",
}
-- 造景石
________DESCRIBE.SH_ROCK_1 = {
    GENERIC = "怪石嶙峋",
}
-- 挖掘出来的句芒植株
________DESCRIBE.DUG_SHANHAI_GOUMANG_PLANT = {
    GENERIC = "小植物要搬家",
}
-- 高鸟蛋藤
________DESCRIBE.DSC_EGGVINE = {
    GENERIC = "进化论不生效了吗？",
}
-- 高鸟蛋种藤
________DESCRIBE.SHANHAI_SEED_TALLBIRDEGG = {
    GENERIC = "我们对它做了什么？",
}
-- 发光蟹
________DESCRIBE.DSC_TREECRAB = {
    GENERIC = "它会爬进我的梦里",
}
-- 花藤，弯曲的
________DESCRIBE.DSC_FLOWERVINE = {
    GENERIC = "弯弯绕绕的风情",
}
-- 花藤，出口处的
________DESCRIBE.SHANHAI_EXITVINE = {
    GENERIC = "它是突然冒出来的！",
}
-- 迷榖树
________DESCRIBE.SH_MIGUTREE = {
    GENERIC = "看起来好不真实",
    MIGUTREE_FULL = "这或许能为我指引方向",
}
-- 迷榖枝
________DESCRIBE.SH_MIGUTWIG = {
    GENERIC = "会发光的导航枝条",
}
-- 异火
________DESCRIBE.DSC_LIGHT = {
    GENERIC = "一般的小乌鸦能弄出这个来吗？",
}
-- 海鸟巢
________DESCRIBE.SH_SEANEST = {
    GENERIC = "没有点贻贝，只有藤壶和海鸟！",
}
-- 海鸟杆
________DESCRIBE.SH_SEANEST_KIT = {
    GENERIC = "我们该养点贻贝",
}
-- 小盆栽
________DESCRIBE.SH_PLANTDECO = {
    GENERIC = "这才是园林学",
}
-- 云开
________DESCRIBE.DSC_COPYTOOL = {
    GENERIC = "守得云开见月明",
    YUNKAI_DEP = "那是什么，传送卷轴？",
}
-- 悬河灵玉
________DESCRIBE.XUANHE_PASSPORT = {
    GENERIC = "它的做工不一般，肯定是好东西",
}
-- 烛龙法阵
________DESCRIBE.STATUE_ZHULONG = {
    GENERIC = "它在看着我！",
}
-- 烛龙晦朔雕塑
________DESCRIBE.STATUE_ZHULONG_USE = {
    GENERIC = "时间的轮回现在由我掌控！",
}
-- 古怪痕迹
________DESCRIBE.SH_ANIMAL_TRACK = {
    GENERIC = "这是...脚印？",
}
-- 纸燕
________DESCRIBE.SH_PAPERBIRD = {
    GENERIC = "它背上好像有字",
}
-- 线索纸
________DESCRIBE.SH_REDPAPER = {
    GENERIC = "我在猪镇见过这样的文字",
}
-- 吊木小桥
________DESCRIBE.SH_BRIDGE = {
    GENERIC = "我在别的地方见过这种设计",
}
-- 钦原
________DESCRIBE.SH_QINYUAN = {
    GENERIC = "好尖的尾刺，还是不要惹它比较好",
}
-- 笔绘山河
________DESCRIBE.SH_DESC = {
    GENERIC = "我该沉下心来看看书",
}
-- 冰面地皮
________DESCRIBE.TURF_SH_ICELAND = {
    GENERIC = "一块...冰块？",
}
-- 花园地皮
________DESCRIBE.TURF_SH_SMALLSTONE = {
    GENERIC = "一块小花园",
}
-- XMM地皮
________DESCRIBE.TURF_SH_XMM = {
    GENERIC = "一块XMM",
}
-- X茗茗地皮
________DESCRIBE.TURF_SH_XMM = {
    GENERIC = "一块X茗茗",
}
-- 碎石地皮
________DESCRIBE.TURF_SH_LITTLESTONE = {
    GENERIC = "一块碎石",
}
-- 小碎石地皮
________DESCRIBE.TURF_SH_MANYSTONE = {
    GENERIC = "一块小碎石",
}
-- 玻璃尾刺
________DESCRIBE.SH_QYSTICK = {
    GENERIC = "玻璃尾刺",
}
-- 彩色羽毛
________DESCRIBE.SH_FEATHER_PHOENIX = {
    GENERIC = "是凤凰来过的痕迹",
}
-- 兵灾朱厌雕塑
________DESCRIBE.STATUE_ZHUYAN = {
    GENERIC = "预兆兵灾，天下大乱！",
}
-- 九尾狐
________DESCRIBE.SH_CRITTER_FOXING = {
    GENERIC = "7、8、9...它有那么多尾巴！"
}
-- 淳朴的伪装
________DESCRIBE.SHPIGHAT = {
    GENERIC = "这种伪装能骗到谁呀？"
}
-- 山参种子
________DESCRIBE.SHANHAI_SEED_SHANSHEN = {
    GENERIC = "种植山参植株"
}
-- 银杏叶装饰
________DESCRIBE.SHANHAI_GINKGOLEAVE_GROUND = {
    GENERIC = "金灿灿的叶片！"
}
-- 山参扫把
________DESCRIBE.SH_MAGICSHANSHEN = {
    GENERIC = "西方魔法，东方法术，鸦都会一点"
}
-- 芝上谈冰
________DESCRIBE.SH_GANODERMAICE = {
    GENERIC = "纸上得来终觉浅，绝知此事要躬行"
}
-- 长生不老药
________DESCRIBE.SH_NEVEROLD = {
    GENERIC = "这将是一场豪赌"
}
-- 返老还童丹
________DESCRIBE.SH_BACKYOUNG = {
    GENERIC = "谁能拒绝青春永驻呢？"
}
-- 石阶道具
________DESCRIBE.SH_ABYSSPILLAR_ITEM = {
    GENERIC = "这个要放到海里"
}
-- -- 石阶炸弹
-- ________DESCRIBE.SH_ABYSSPILLAR_BOMB = {
--     GENERIC = "这个可以把小石阶砸掉"
-- }
-- 石阶
________DESCRIBE.SH_STONESTEP = {
    GENERIC = "步子太大会扯坏裤子..."
}
-- 装饰云朵
________DESCRIBE.SADDLE_KUN_GROUND = {
    GENERIC = "铺在地上的云彩..."
}
-- 小次山
________DESCRIBE.SH_ZHUYAN_SPAWNER = {
    GENERIC = "其上多白玉，其下多赤铜"
}
-- 应龙叶篓
________DESCRIBE.SH_BACKPACK_LEAF = {
    GENERIC = "它拥有眼球伞和背包的全部优点！"
}
-- 小叶槎
________DESCRIBE.SH_LEAFBOAT_ITEM = {
    GENERIC = "放到水里，准备远航"
}
-- 一叶浮舟
________DESCRIBE.SH_LEAFBOAT = {
    GENERIC = "它最好能承受很多的重量"
}
-- 一叶烛
________DESCRIBE.SH_BOAT_TORCH = {
    GENERIC = "再小的火焰，也期盼着照亮一方天地"
}
-- 羽毛风帆
________DESCRIBE.SH_FEATHERSAIL = {
    GENERIC = "它让我想到在海难世界受苦的那些日子"
}
-- 朱厌铃铛
________DESCRIBE.SH_ZYBELL = {
    GENERIC = "小巧而精致"
}
-- 朱源
________DESCRIBE.DEEPSEACAVE_PIGMAN = {
    FAKEDEATH = "他怎么了？",
    STEALFOOD = "嘿！小偷！",
    GENERIC = "它总是很忙的样子",
}
-- 小叶风扇
________DESCRIBE.SH_BASEFAN = {
    GENERIC = "灵感来自哈姆雷特的花粉季",
}
-- 远古排箫
________DESCRIBE.SH_PANFLUTE = {
    GENERIC = "我曾希望它发出更美好的声音",
}
-- 井字棋盘
________DESCRIBE.SH_TICTACTOE_BOARD = {
    GENERIC = "我们可是井字棋高手",
    PLAYING = "观棋不语",
    FINISHED = "游戏结束",
}
-- 井字棋子
________DESCRIBE.SH_TICTACTOE_PIECE_X = {
    GENERIC = "是X，先手",
}
-- 井字棋子
________DESCRIBE.SH_TICTACTOE_PIECE_O = {
    GENERIC = "是O，后手",
}
-- 长者
________DESCRIBE.DSC_ELDERSWAMPIG = {
    GENERIC = "是暴食的长老？威吊没有给你换皮吗？",
}
-- 朱源的小铺
________DESCRIBE.DSC_PIG_SHOP = {
    GENERIC = "开门，开门呐！", 
    ACTIVE = "它从哪里学的这些？", 
    BREWING = "正在加工!", 
    BURNT = "我们该小心火烛的", 
}
-- 叶篓特效
________DESCRIBE.SH_BACKPACK_LEAF_FX = {
    GENERIC = "那是背篓里的暗影仆从", 
}
-- 被堵住的洞天穴
________DESCRIBE.DSC_CAVE_ENTRANCE = {
    GENERIC = "现在我们开凿！", 
}
-- 洞天穴
________DESCRIBE.DSC_CAVE_ENTRANCE_OPEN = {
    GENERIC = "下去看看又不会损失什么",
    OPEN = "蝙蝠们没有发现这个出口!",
    FULL = "啊哟，人满为患",
}
-- 洞天楼梯
________DESCRIBE.DSC_CAVE_EXIT = {
    GENERIC = "完蛋，被困住了",
    OPEN = "我看到了出口!",
    FULL = "啊哟，人满为患",
}
-- 朱厌的小猴子
________DESCRIBE.SH_MONKEY = {
    GENERIC = "它们变的格外凶残",
}
-- 伪装灵芝
________DESCRIBE.DSC_MUSHROOM_TO_2 = {
    GENERIC = "一看到它，我的屁股就隐隐作痛",
}
-- 隐藏出口2
________DESCRIBE.SHANHAI_HIDDENEXIT_2 = {
    GENERIC = "要不我们踢两脚试试看？",
}
-- 扭曲的大树
________DESCRIBE.DSC_OCEANTREE_PILLAR_2 = {
    GENERIC = "它是从一层长出来的",
}
-- 悬河瀑布
________DESCRIBE.XUANHE_FALL = {
    GENERIC = "飞流直下三千尺",
}
-- 山河卷饼
________DESCRIBE.SH_TACO = {
    GENERIC = "我们应该加点辣条的"
}
-- 烛龙卷饼
________DESCRIBE.SH_ZHULONG_TACO = {
    ROLLED = "时空的魔法终于用到了它该用的地方！",
    GENERIC = "快把食物卷起来，快把食物卷起来！"
}
-- 锁妖链
________DESCRIBE.DSC_CAVE_MAGICSEAL = {
    GENERIC = "它不会自己断掉吧？"
}
-- 锁妖阵
________DESCRIBE.DSC_CAVE_MAGICPLACVE = {
    GENERIC = "我要学这个，一定要！"
}
-- 洞天矮星
________DESCRIBE.DSC_CAVE_STAFFLIGHT = {
    GENERIC = "它让我感觉安全多了"
}
-- 铥矿果
________DESCRIBE.SH_THULECITE = {
    GENERIC = "铥矿果"
}
-- 矿脉种子
________DESCRIBE.SH_THULECITE_SEEDS = {
    GENERIC = "这是石头？还是种子？"
}
-- 铥矿果植株
________DESCRIBE.FARM_PLANT_SH_THULECITE = {
    GENERIC = "像是什么藤蔓植株"
}
-- 巨型铥矿果
________DESCRIBE.SH_THULECITE_OVERSIZED = {
    GENERIC = "这个植株的创造者得是有多懒呀"
}
-- 打蜡的巨型铥矿果
________DESCRIBE.SH_THULECITE_OVERSIZED_WAXED = {
    GENERIC = "更大，更亮，更重"
}
-- 乾坤袖袍
________DESCRIBE.SH_MAGICVEST = {
    GENERIC = "多纹几个法阵上去总是没坏处的"
}

-- 模组适配内容
___________NAMES.SHANHAI_GOUMANG_WILTON = "句芒印记"
_____RECIPE_DESC.SHANHAI_GOUMANG_WILTON = "手动凝聚天地灵气"