-- phase1_strings.lua
-- STRINGS overrides cho Myth mods -- Phase 1 (482 entries)
-- Duoc goi tu AddSimPostInit trong main.lua

local STRINGS = GLOBAL.STRINGS
if not STRINGS then return end

-- Helper de set gia tri nested
local function set_str(path, value)
    local parts = {}
    for p in path:gmatch("[^%.]+") do parts[#parts+1] = p end
    local tbl = GLOBAL.STRINGS
    for i = 1, #parts - 1 do
        if type(tbl[parts[i]]) ~= "table" then return end
        tbl = tbl[parts[i]]
    end
    tbl[parts[#parts]] = value
end

-- ==============================
-- STRINGS.NAMES
-- ==============================
if STRINGS.NAMES then
    STRINGS.NAMES.MYTH_FOOD_GQMX = "Phở Qua Cầu"
    STRINGS.NAMES.MYTH_SHOP_RAREITEM = "Quầy Kỳ Trân"
    STRINGS.NAMES.MYTH_FOOD_CDF = "Đậu Hũ Thối"
    STRINGS.NAMES.MADAMEWEB_CANTSILKFLY = "Không Nơi Treo"
    STRINGS.NAMES.MYTH_IRON_BROADSWORD = "Đại Đao Gang"
    STRINGS.NAMES.WB_ARMORBONE = "Kiên Cốt Bào"
    STRINGS.NAMES.MYTH_SHOP_CONSTRUCT = "Tiệm Vật Liệu"
    STRINGS.NAMES.MADAMEWEB_SPIDERHOME = "Bàn Ti Tổ Nhện"
    STRINGS.NAMES.MADAMEWEB_SILKVALUELOW = "Khoan đã, thiếp còn cần thêm thời gian"
    STRINGS.NAMES.WALL_DWELLING_ITEM = "Ngói Đen Tường Trắng"
    STRINGS.NAMES.BUFF_M_DUST = "Tị Trần"
    STRINGS.NAMES.MADAMEWEB_BEEMINE = "Kén Ong Độc"
    STRINGS.NAMES.MYTH_ROCKTIPS = "Sỏi Cuội"
    STRINGS.NAMES.YANGJIAN_BUZZARD = "Ngạo Thiên Ưng"
    STRINGS.NAMES.HUA_FAKE_SPIDER_SHOE = "Bộ Ti Hài"
    STRINGS.NAMES.MYTH_PLANT_INFANTREE_MEDIUM = "Tiên Thụ Hồi Sinh"
    STRINGS.NAMES.POWDER_M_TAKEITEASY = "Bột Giải Ưu"
    STRINGS.NAMES.PASS_COMMISSIONER_CJ = "Phong Đô Lộ Dẫn · Thôi Giác"
    STRINGS.NAMES.GHOST_CLEMENT = "Ân Hồn"
    STRINGS.NAMES.MYTH_SHOP_FOODS = "Tiệm Trà Hào"
    STRINGS.NAMES.BUFF_M_IMMUNE_ICE = "Kháng Băng"
    STRINGS.NAMES.POWDER_M_LIFEELIXIR = "Bột Tê Giác"
    STRINGS.NAMES.BUFF_M_INFANT = "Trường Sinh Bất Lão"
    STRINGS.NAMES.MADAMEWEB_BEE = "Bàn Ti Độc Phong"
    STRINGS.NAMES.MYTH_HIGANBANA_REBORN = "Mạn Châu Sa Hoa"
    STRINGS.NAMES.WB_ARMORBLOOD = "Huyết Sắc Nghê"
    STRINGS.NAMES.POWDER_M_IMPROVEHEALTH = "Bột Hoạt Huyết"
    STRINGS.NAMES.YT_DAOYAO = "Giã Thuốc"
    STRINGS.NAMES.HUA_INTERNET_NODE_SEA_ITEM = "Dây Trượt Hải Ti"
    STRINGS.NAMES.BONE_MIRROR = "Bạch Cốt Yêu Kính"
    STRINGS.NAMES.MYTH_PIGSYSKILL_BOOKINFO = "Cương Liệp Bản Tướng"
    STRINGS.NAMES.YANGJIAN_BUZZARD_SPAWN = "Triệu Ưng"
    STRINGS.NAMES.MADAMEWEB_POISONBEEMINE = "Bàn Ti Trứng Nhện"
    STRINGS.NAMES.MADAMEWEB_DETOXIFY = "Giải Độc Tán"
    STRINGS.NAMES.BUFF_M_CHARGED = "Cảm Điện"
    STRINGS.NAMES.GHOST_IRRITATED = "Oán Hồn"
    STRINGS.NAMES.MYTH_PLANT_BAMBOO_5 = "Trúc Xanh"
    STRINGS.NAMES.MYTH_FOOD_DJYT = "Sữa Đậu Quẩy"
    STRINGS.NAMES.SONG_M_WORKUP = "《Điền Trung Lạc》"
    STRINGS.NAMES.SONG_M_ICESHIELD = "《Mộng Phi Sương》"
    STRINGS.NAMES.MYTH_IRON_HELMET = "Mũ Sắt Đúc"
    STRINGS.NAMES.SOUL_SPECTER = "Thiện Hồn"
    STRINGS.NAMES.COMMISSIONER_BOOK = "Phán Quan Bút · Sinh Tử Bạ"
    STRINGS.NAMES.CANE_PEACH = "Gậy Gỗ Đào"
    STRINGS.NAMES.MYTH_PLANT_BAMBOO_STUMP = "Gốc Trúc"
    STRINGS.NAMES.BUFF_M_PROMOTE_HEALTH = "Dinh Dưỡng"
    STRINGS.NAMES.NIAN_MOUNT = "Niên Thú"
    STRINGS.NAMES.SONG_M_NOLOVE = "《Lưu Thủy Vô Tình》"
    STRINGS.NAMES.BUFF_M_IMMUNE_FIRE = "Tị Hỏa"
    STRINGS.NAMES.BUFF_M_INSOMNIA = "Khó Ngủ"
    STRINGS.NAMES.MYTH_YAMA_STATUE2 = "Tượng Thần Diêm La"
    STRINGS.NAMES.SONG_M_FIREIMMUNE = "《Dục Hỏa Tấu》"
    STRINGS.NAMES.SONG_M_WEAKDEFENSE = "《Bá Vương Tá Giáp》"
    STRINGS.NAMES.BUFF_M_DEF_UP = "Kiên Cố"
    STRINGS.NAMES.BUFF_M_IMMUNE_WATER = "Tị Thủy"
    STRINGS.NAMES.HAT_COMMISSIONER_WHITE = "Mũ Quan Vô Thường"
    STRINGS.NAMES.MADAMEWEB_PITFALL_COCOON = "Kén Khốn Đốn"
    STRINGS.NAMES.BUFF_M_ATK_ICE = "Ngưng Sương"
    STRINGS.NAMES.BUFF_M_DEATHHEART = "Hắc Tâm"
    STRINGS.NAMES.BUFF_M_HUNGER_STRONG = "Thao Thiết"
    STRINGS.NAMES.WB_ARMORFOG = "Vụ Ẩn Thường"
    STRINGS.NAMES.WB_ARMORGREED = "Bất Yếm Y"
    STRINGS.NAMES.NIAN_BELL = "Chuông Niên Thú"
    STRINGS.NAMES.MYTH_HIGANBANA_ITEM = "Bỉ Ngạn Hoa"
    STRINGS.NAMES.MYTH_YAMA_STATUE1 = "Tượng Điêu Diêm La"
    STRINGS.NAMES.MYTH_PLANT_BAMBOO_0 = "Măng Đã Trồng"
    STRINGS.NAMES.MYTH_YAMA_STATUE4 = "Miếu Diêm Vương"
    STRINGS.NAMES.BUFF_M_HEALTH_REGEN = "Trị Liệu"
    STRINGS.NAMES.TREASURE_PAPER_MYTH = "Giấy Manh Mối"
    STRINGS.NAMES.BUFF_M_BEEFALO = "Ngưu Tức"
    STRINGS.NAMES.PENNANT_COMMISSIONER = "Chiêu Hồn Phan"
    STRINGS.NAMES.BUFF_M_SANITY_REGEN = "Hồi Thần"
    STRINGS.NAMES.FENCE_GATE_BAMBOO_ITEM = "Cổng Trúc"
    STRINGS.NAMES.MYTH_FOOD_LHYX = "Vịt Huyết Sen"
    STRINGS.NAMES.MYTH_SHOP_WEAPONS = "Tiệm Thợ Rèn"
    STRINGS.NAMES.SOUL_GHAST = "Ác Hồn"
    STRINGS.NAMES.PASS_COMMISSIONER = "Phong Đô Lộ Dẫn"
    STRINGS.NAMES.BUFF_M_SANITY_STAY = "Ngưng Thần"
    STRINGS.NAMES.WHIP_COMMISSIONER = "Câu Hồn Sách"
    STRINGS.NAMES.BUFF_M_GLOW = "Lấp Lánh"
    STRINGS.NAMES.MYTH_PLANT_INFANT_FRUIT = "Nhân Sâm Quả"
    STRINGS.NAMES.MEDICINE_PESTLE_MYTH = "Chày Giã Thuốc"
    STRINGS.NAMES.MYTH_PLANT_INFANTREE = "Cây Nhân Sâm Quả"
    STRINGS.NAMES.MADAMEWEB_FEISHENG = "Bàn Ti Điếu"
    STRINGS.NAMES.MYTH_SHOP_NUMEROLOGY = "Tiệm Bói Toán"
    STRINGS.NAMES.SONG_M_INSOMNIA = "《Xuân Quang Khúc》"
    STRINGS.NAMES.WB_ARMORLIGHT = "Doanh Phong Trù"
    STRINGS.NAMES.GUITAR_JADEHARE = "Oánh Nguyệt Tỳ Bà"
    STRINGS.NAMES.POWDER_M_COLDEYE = "Bột Hàn Mâu"
    STRINGS.NAMES.MYTH_IRON_BATTLEGEAR = "Giáp Sắt Đúc"
    STRINGS.NAMES.BUFF_M_LOCO_UP = "Tật Hành"
    STRINGS.NAMES.MYTH_TOY_BOOKINFO = "Đồ Chơi Thần Thoại"
    STRINGS.NAMES.MYTH_STOOL = "Ghế Gỗ"
    STRINGS.NAMES.PASS_COMMISSIONER_WZ = "Phong Đô Lộ Dẫn · Ngụy Trưng"
    STRINGS.NAMES.POWDER_M_CHARGED = "Bột Kinh Quyết"
    STRINGS.NAMES.BUFF_M_ATK_UP = "Cường Tráng"
    STRINGS.NAMES.PASS_COMMISSIONER_LZD = "Phong Đô Lộ Dẫn · Lục Chi Đạo"
    STRINGS.NAMES.MYTHTUMBLE = "Té Ngã"
    STRINGS.NAMES.MYTH_HOUSE_BAMBOO = "Nhà Ngói Trúc Xanh"
    STRINGS.NAMES.MYTH_COLDESSENSE = "Tinh Hoa Nguyệt"
    STRINGS.NAMES.TURF_QUAGMIRE_PARKFIELD = "Thảm Đào Viên"
    STRINGS.NAMES.PASS_COMMISSIONER_YLW = "Phong Đô Lộ Dẫn · Diêm La Vương"
    STRINGS.NAMES.TREASURE_SHOW_MYTH = "Đống Đất Bình Thường"
    STRINGS.NAMES.MINIFLARE_MYTH = "Pháo Thăng Thiên"
    STRINGS.NAMES.MYTH_SHOP_INGREDIENT = "Tiệm Rau Chợ"
    STRINGS.NAMES.MYTH_PLANT_BAMBOO_BURNT = "Trúc Cháy Khét"
    STRINGS.NAMES.BELL_COMMISSIONER = "Nhiếp Hồn Linh"
    STRINGS.NAMES.MADAMEWEB_SPIDER_WARRIOR = "Bàn Ti Độc Nhện"
    STRINGS.NAMES.SONG_M_WEAKATTACK = "《Xuân Phong Hóa Vũ》"
    STRINGS.NAMES.MYTH_PASSCARD_JIE = "Thông Thiên Sắc Lệnh"
    STRINGS.NAMES.SONG_M_NOCURE = "《Oán Triền Thân》"
    STRINGS.NAMES.MYTH_GOLD_STAFF = "Kim Kích Tử"
    STRINGS.NAMES.MADAMEWEB_PITFALL_GROUND = "Bẫy Lưới Nhện"
    STRINGS.NAMES.MYTH_FLYSKILL_YA = "U Minh Thân"
    STRINGS.NAMES.MK_DSF = "Định Thân Pháp"
    STRINGS.NAMES.MYTH_MADAMEWEB = "Giá Trị Tơ Nhện"
    STRINGS.NAMES.MYTH_NIAN_FUR = "Bờm Niên Thú"
    STRINGS.NAMES.MYTH_YAMA_STATUE3 = "Miếu Thần Diêm La"
    STRINGS.NAMES.MADAMEWEB_POISONSTINGER = "Bàn Ti Độc Châm"
    STRINGS.NAMES.SONG_M_SWEETDREAM = "《Dạ Lan Dao》"
    STRINGS.NAMES.MADAMEWEB_STINGER = "Bàn Ti Phong Châm"
    STRINGS.NAMES.TOKEN_COMMISSIONER = "Trấn Hồn Lệnh"
    STRINGS.NAMES.MYTH_FIREESSENSE = "Tinh Hoa Nhật"
    STRINGS.NAMES.MYTH_BAHY = "Bỉ Ngạn Hoàn Dương"
    STRINGS.NAMES.BUFF_M_PROMOTE_HUNGER = "Khai Vị"
    STRINGS.NAMES.MYTH_FOOD_LRHS = "Bánh Nướng Thịt Lừa"
    STRINGS.NAMES.MYTH_BAMBOO_BASKET = "Giỏ Thuốc Trúc"
    STRINGS.NAMES.HUA_INTERNET_NODE_ITEM = "Dây Trượt Bàn Ti"
    STRINGS.NAMES.MYTH_SHOP_PLANTS = "Tiệm Hạt Giống"
    STRINGS.NAMES.MYTH_HUANHUNDAN = "Hoàn Hồn Đan"
    STRINGS.NAMES.MADAMEWEB_SILKCOCOON_PACKED = "Bàn Ti Dệt Túi"
    STRINGS.NAMES.BUFF_M_STENCH = "Thơm Ngát"
    STRINGS.NAMES.BUFF_M_BLOODSUCK = "Khát Huyết"
    STRINGS.NAMES.COMMISSIONER_MPT = "Canh Mạnh Bà"
    STRINGS.NAMES.MYTH_FOOD_XCMT = "Bánh Bao Dưa Muối"
    STRINGS.NAMES.HUA_INTERNET_NODE = "Bàn Ti Tiêu Điểm"
    STRINGS.NAMES.PASS_COMMISSIONER_ZK = "Phong Đô Lộ Dẫn · Chung Quỳ"
    STRINGS.NAMES.MYTH_FOOD_THL = "Kẹo Hồ Lô"
    STRINGS.NAMES.MYTH_PLANT_INFANTREE_TRUNK = "Gốc Cây Bị Đổ"
    STRINGS.NAMES.MADAMEWEB_ARMOR = "Bàn Ti Khăn Choàng"
    STRINGS.NAMES.BUFF_M_WORKUP = "Cao Hiệu"
    STRINGS.NAMES.HUA_INTERNET_LINK = "Tơ Nhện"
    STRINGS.NAMES.BUFF_M_PROMOTE_SANITY = "Mỹ Vị"
    STRINGS.NAMES.MADAMEWEB_NET = "Lưới Tơ Nhện"
    STRINGS.NAMES.HUA_INTERNET_NODE_SEA = "Hải Ti Tiêu Điểm"
    STRINGS.NAMES.PASS_COMMISSIONER_MP = "Phong Đô Lộ Dẫn · Mạnh Bà"
    STRINGS.NAMES.BUFF_M_ATK_ELEC = "Ngự Điện"
    STRINGS.NAMES.BUFF_M_UNDEAD = "Bất Tử"
    STRINGS.NAMES.MYTH_PLAYERREDPOUCH_SUPER = "Bao Lì Xì May Mắn"
    STRINGS.NAMES.BUFF_M_HUNGER_REGEN = "No Bụng"
    STRINGS.NAMES.SONG_M_ICEIMMUNE = "《Hàn Phong Điệu》"
    STRINGS.NAMES.MYTH_SHOP_ANIMALS = "Tiệm Hoa Điểu"
    STRINGS.NAMES.MADAMEWEB_SILKCOCOON = "Túi Kén Tơ Nhện"
    STRINGS.NAMES.MYTH_CQF = "Xuất Khiếu Phù"
    STRINGS.NAMES.MADAMEWEB_SILKCOCOON_HANGED = "Bàn Ti Huyền Kén"
    STRINGS.NAMES.MYTH_COIN_BOX = "Xâu Tiền Đồng"
    STRINGS.NAMES.MYTH_PLAYERREDPOUCH_NORMAL = "Bao Lì Xì"
    STRINGS.NAMES.BUFF_M_ICESHIELD = "Sương Giáp"
    STRINGS.NAMES.POWDER_M_BECOMESTAR = "Bột Dạ Minh"
    STRINGS.NAMES.BUFF_M_THORNS = "Gai Nhọn"
    STRINGS.NAMES.FENCE_BAMBOO_ITEM = "Hàng Rào Trúc"
    STRINGS.NAMES.BUFF_M_WARM = "Tị Hàn"
    STRINGS.NAMES.COMMISSIONER_FLYBOOK = "Sinh Tử Bạ"
    STRINGS.NAMES.YT_MOONBUTTERFLY = "Nguyệt Nga Dẫn Lộ"
    STRINGS.NAMES.BUFF_M_COOL = "Tị Thử"
    STRINGS.NAMES.MYTH_FOOD_NRLM = "Mì Bò Kéo"
    STRINGS.NAMES.POWDER_M_HYPNOTICHERB = "Bột Thảo Sâm"
    STRINGS.NAMES.BUFF_M_HUNGER_STAY = "No Nê"
    STRINGS.NAMES.WB_ARMORSTORAGE = "Uẩn Huyền Bào"
    STRINGS.NAMES.BUFF_M_STRENGTH_UP = "Dời Núi"
end

-- ==============================
-- STRINGS.ACTIONS
-- ==============================
set_str("STRINGS.ACTIONS.MYTH_FUCHEN.QUWU", "Cách Không Lấy Vật")
set_str("STRINGS.ACTIONS.MYTH_LOTUS_PLANT", "Trồng")
set_str("STRINGS.ACTIONS.MYTH_USE_INVENTORY.PLAYER", "Quấn Thân")
set_str("STRINGS.ACTIONS.MYTHBIANHUAN.PIG_BIANHUAN", "Khiêu Khích")
set_str("STRINGS.ACTIONS.CASTAOE.CANE_PEACH", "Bỏ Gậy Hóa Rừng")
set_str("STRINGS.ACTIONS.HUA_INTERNET_BUILD", "Nối Dây")
set_str("STRINGS.ACTIONS.OPEN_CRAFTING.DC_CONSULT", "Thỉnh Giáo")
set_str("STRINGS.ACTIONS.MYTHBIANHUAN.OUT_GROUND", "Lên Mặt Đất")
set_str("STRINGS.ACTIONS.DEPLOY.SILKCOCOON", "Treo Lên")
set_str("STRINGS.ACTIONS.CASTSPELL.BANANAFAN", "Phong Quyển Tàn Vân")
set_str("STRINGS.ACTIONS.MYTH_USE_INVENTORY.SPIDERDEN", "Hạ Cấp")
set_str("STRINGS.ACTIONS.MYTH_SILKFLY.MYTH_SILKFLY_DOWN", "Bàn Ti Truỵ")
set_str("STRINGS.ACTIONS.MYTH_USE_INVENTORY.COIN", "Xâu Lại")
set_str("STRINGS.ACTIONS.MYTH_USE_INVENTORY.WHIP", "Quỷ Hỏa Triền Thân")
set_str("STRINGS.ACTIONS.TRADE_BBSHOP_M", "Vào Xem")
set_str("STRINGS.ACTIONS.CASTAOE.PENNANT_COMMISSIONER", "Chiêu Hồn")
set_str("STRINGS.ACTIONS.MYTH_FUCHEN.MOREN", "Thi Pháp")
set_str("STRINGS.ACTIONS.MYTH_USE_INVENTORY.ABSORB", "Hấp Thụ")

-- ==============================
-- STRINGS.TABS
-- ==============================
set_str("STRINGS.TABS.阴司栏", "Âm Ti")
set_str("STRINGS.TABS.盘丝", "Bàn Ti")
set_str("STRINGS.TABS.蟾宫技艺", "Thiềm Cung Kỹ Nghệ")

-- ==============================
-- STRINGS.UI
-- ==============================
set_str("STRINGS.UI.RARITY.MYTH_YUTU_FROG", "Thiên Hình Vạn Trạng")
set_str("STRINGS.UI.RARITY.NEZA_RAP", "Thời Gian Lệch Vị")
set_str("STRINGS.UI.RARITY.PIGSY_CONSTELLATION", "Vị Liệt Tiên Ban")
set_str("STRINGS.UI.CRAFTING.NEEDSMYTH_TECH_CHANGE_FOUR", "Cần thiện cảm tối đa với Hằng Nga để chế tạo nguyên mẫu!")

-- ==============================
-- STRINGS.RECIPE_DESC
-- ==============================
set_str("STRINGS.RECIPE_DESC.MADAMEWEB_PITFALL", "Trăm tơ sát khí sinh")
set_str("STRINGS.RECIPE_DESC.WB_ARMORLIGHT", "Lông cánh đầy gió, ta lên mây xanh")
set_str("STRINGS.RECIPE_DESC.POWDER_M_CHARGED", "Điện quang thạch hỏa, kinh quyết bức người.")
set_str("STRINGS.RECIPE_DESC.TURF_QUAGMIRE_PARKFIELD", "Đào hoa lãng mạn rơi vào bùn")
set_str("STRINGS.RECIPE_DESC.MADAMEWEB_STINGER", "Tơ treo kim đuôi")
set_str("STRINGS.RECIPE_DESC.MADAMEWEB_NET", "Không nơi trốn thoát")
set_str("STRINGS.RECIPE_DESC.MADAMEWEB_SILKCOCOON", "Mềm mại bông êm, trường tồn trong đó")
set_str("STRINGS.RECIPE_DESC.WB_ARMORFOG", "Gió ẩn chập chùng, sương phủ lặng thầm")
set_str("STRINGS.RECIPE_DESC.SILK", "Bụng ta được mấy nhiều tơ?")
set_str("STRINGS.RECIPE_DESC.SONG_M_INSOMNIA", "Tình nhân oán đêm dài, thâu đêm nhớ thương.")
set_str("STRINGS.RECIPE_DESC.MYTH_ROCKTIPS", "Có lẽ không đến nỗi cộm chân")
set_str("STRINGS.RECIPE_DESC.WB_ARMORSTORAGE", "Áo bào phơ phất, trong tay áo càn khôn")
set_str("STRINGS.RECIPE_DESC.FENCE_BAMBOO_ITEM", "Hương trúc thoang thoảng")
set_str("STRINGS.RECIPE_DESC.WB_SKELETON", "Tạo một thân xác phù hợp")
set_str("STRINGS.RECIPE_DESC.MYTH_BAMBOO_BASKET", "Nắng chiều ráng đỏ, hái thuốc mới về")
set_str("STRINGS.RECIPE_DESC.SONG_M_WEAKATTACK", "Lầu nhỏ đêm nghe mưa xuân, ngõ sâu sáng sớm bán hoa hạnh.")
set_str("STRINGS.RECIPE_DESC.MYTH_HOUSE_BAMBOO", "Trúc xanh ngói biếc về nơi đâu")
set_str("STRINGS.RECIPE_DESC.WB_ARMORBLOOD", "Khắp trời huyết sắc, nhuộm thắm cầu vồng")
set_str("STRINGS.RECIPE_DESC.SONG_M_NOCURE", "Má hồng phận bạc, chớ oán gió xuân hãy tự than.")
set_str("STRINGS.RECIPE_DESC.SONG_M_NOLOVE", "Triều dâng không thành đầu tóc bạc, ca một khúc oán ánh tà dương.")
set_str("STRINGS.RECIPE_DESC.MYTH_FLYSKILL_YT", "Sương lạnh sương mù, cùng bay như mây biếc")
set_str("STRINGS.RECIPE_DESC.SONG_M_FIREIMMUNE", "Nghìn búa vạn đục ra từ núi sâu, lửa đốt thiêu như không.")
set_str("STRINGS.RECIPE_DESC.HUA_INTERNET_NODE_ITEM", "Dệt lưới nhện của ngươi đi")
set_str("STRINGS.RECIPE_DESC.MADAMEWEB_BEEMINE", "Tạm thời ở bên trong đã")
set_str("STRINGS.RECIPE_DESC.YT_DAOYAO", "Chế thuốc.")
set_str("STRINGS.RECIPE_DESC.SONG_M_SWEETDREAM", "Núi cao đất rộng, đêm khuya canh tàn.")
set_str("STRINGS.RECIPE_DESC.WB_ARMORBONE", "Trùng trùng bạch cốt hộ thân ta")
set_str("STRINGS.RECIPE_DESC.SONG_M_WEAKDEFENSE", "Trống tàn tên hết ai thu công, tướng quân tá giáp vào cửu trùng.")
set_str("STRINGS.RECIPE_DESC.MADAMEWEB_FEISHENG", "Một tơ treo giữa hư không")
set_str("STRINGS.RECIPE_DESC.MADAMEWEB_DETOXIFY", "Lấy độc trị độc")
set_str("STRINGS.RECIPE_DESC.SONG_M_ICEIMMUNE", "Như một đêm gió xuân đến, nghìn cây vạn cây hoa lê nở.")
set_str("STRINGS.RECIPE_DESC.SONG_M_WORKUP", "Sáng dậy làm cỏ hoang, mang trăng vác cuốc về.")
set_str("STRINGS.RECIPE_DESC.YANGJIAN_BUZZARD_SPAWN", "Mắt vàng cánh bạc, bắt giữ vô song")
set_str("STRINGS.RECIPE_DESC.MADAMEWEB_POISONBEEMINE", "Động theo thời, mưu theo lúc")
set_str("STRINGS.RECIPE_DESC.MYTH_BAHY", "Hoa hồng không thấy, mau trở nhân gian")
set_str("STRINGS.RECIPE_DESC.POWDER_M_IMPROVEHEALTH", "Hoạt huyết hóa ứ, thông lạc tâm mạch.")
set_str("STRINGS.RECIPE_DESC.POWDER_M_HYPNOTICHERB", "Bổ lớn tâm lực, khiến người dễ ngủ.")
set_str("STRINGS.RECIPE_DESC.SONG_M_ICESHIELD", "Suối băng lạnh buốt dây ngưng đứt, ngưng đứt không thông tiếng tạm nghỉ.")
set_str("STRINGS.RECIPE_DESC.POWDER_M_COLDEYE", "Hàn tà khách ở địch.")
set_str("STRINGS.RECIPE_DESC.MYTH_YAMA_STATUE1", "Hồn xa xa, đường xa vời")
set_str("STRINGS.RECIPE_DESC.GUITAR_JADEHARE", "Vuốt nhẹ gảy chậm, lệ đầy mi")
set_str("STRINGS.RECIPE_DESC.MADAMEWEB_POISONSTINGER", "Độc quấn đầu kim")
set_str("STRINGS.RECIPE_DESC.WB_ARMORGREED", "Ta, vĩnh viễn không no")
set_str("STRINGS.RECIPE_DESC.POWDER_M_TAKEITEASY", "Trừ ưu giải lo, an nhiên tự đắc.")
set_str("STRINGS.RECIPE_DESC.FENCE_GATE_BAMBOO_ITEM", "Cửa khép hờ")
set_str("STRINGS.RECIPE_DESC.POWDER_M_BECOMESTAR", "Da như mỡ đông, phấn trơn mịn.")
set_str("STRINGS.RECIPE_DESC.MYTH_FLYSKILL_YA", "Hồng trần cuồn cuộn, nhập thế câu hồn")
set_str("STRINGS.RECIPE_DESC.RABBITHOLE", "Một mái ấm ngọt ngào")
set_str("STRINGS.RECIPE_DESC.HUA_FAKE_SPIDER_SHOE", "Trải nghiệm cảm giác của nhện")
set_str("STRINGS.RECIPE_DESC.MYTH_HIGANBANA_ITEM", "Hoa hồng bỉ ngạn, nghiền tro thành bụi")
set_str("STRINGS.RECIPE_DESC.MYTH_STOOL", "Ngồi xuống nghỉ ngơi đi")
set_str("STRINGS.RECIPE_DESC.BONE_MIRROR", "Gương sáng trang điểm bóng tự thương")
set_str("STRINGS.RECIPE_DESC.POWDER_M_LIFEELIXIR", "Quân vương khó cầu, trường sinh linh dược.")
set_str("STRINGS.RECIPE_DESC.MADAMEWEB_ARMOR", "Có lẽ được")
set_str("STRINGS.RECIPE_DESC.YT_MOONBUTTERFLY", "Chỉ hoa hóa bướm, bay về phía trăng")

-- ==============================
-- STRINGS.CHARACTERS.GENERIC.DESCRIBE
-- ==============================
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.BONE_MIRROR.SMALL", "Gương loan vỡ, dung nhan tàn")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MADAMEWEB_DETOXIFY", "Thuốc hay thanh nhiệt giải độc")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.RHINO3_RED", "Tịch Thử Đại Vương")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.YANGJIAN_BUZZARD", "Đây lẽ nào là cú mèo phương đông?")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.WB_ARMORBONE", "Cái áo choàng này rốt cuộc đã hại chết bao nhiêu mạng người")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_FOOD_DJYT", "Mỗi ngày đều phải ăn sáng đúng giờ nhé")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_FOOD_CDF", "Thơm quá, chỉ có chút mùi thối thôi mà")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_SHOP_RAREITEM", "Chủ tiệm này thích lắm thứ kỳ lạ cổ quái.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_PLANT_BAMBOO_STUMP", "Phấn cốt toái thân cũng không sợ.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.WB_ARMORLIGHT", "Gió trong không khóa được, lông đầy đêm trăng về")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MADAMEWEB_SILKCOCOON", "Muốn đoán thử xem là gì không?")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_PASSCARD_JIE", "'Hữu giáo vô loại', lệnh bài của Thông Thiên Giáo Chủ, một trong tam thanh.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.HUA_FAKE_SPIDER_SHOE", "Khoan, đất này hơi trơn")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.BONE_MIRROR.MIDDLE", "Phù dung không bằng mỹ nhân trang điểm")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.WB_ARMORSTORAGE", "Dưới thắt lưng, có càn khôn riêng")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MADAMEWEB_STINGER", "Kim ong quấn tơ xuyên qua tim")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.PENNANT_COMMISSIONER.SPELL", "Dẫn độ giờ lành! Hồn phách mau đến!")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_ROCKTIPS", "Con đường gập ghềnh đầy sỏi cuội")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.POWDER_M_IMPROVEHEALTH", "Ngửi rất thơm ngọt, phải không.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.BELL_COMMISSIONER.GENERIC", "Đây là bảo vật an tử vật vỗ về người sống.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.FIRECRACKERS_MYTH", "Một bay lên trời, xuân đến nhân gian")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.WALL_DWELLING_ITEM", "Ngói xanh người đã hoang, khói xám bốc tường trắng")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.GUITAR_JADEHARE.GENERIC", "Thiềm cung u hận, đều gửi vào khúc nhạc.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.PASS_COMMISSIONER_LZD.INACTIVE", "Phải nhắn tiếng đã.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.FENCE_BAMBOO_ITEM", "Sân nhỏ cỏ xanh, tựa lan can nhớ xưa")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.TOKEN_COMMISSIONER.NOSOUL", "Không ác, không tác dụng.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_COIN_BOX", "Một xâu tiền đồng lớn")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.WB_ARMORGREED", "Cái áo ấy như một con quái vật không biết no")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MADAMEWEB_SPIDERDEN", "Thiên la đâu? Địa võng đan như nào?")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MADAMEWEB_PITFALL_COCOON", "Nó giờ không nhúc nhích được")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.NIAN_MOUNT", "Ngươi giờ ngoan hơn nhiều rồi")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_FIREESSENSE", "Chí cương chí dương, ngưng thành vật này")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.TOKEN_COMMISSIONER.NOHAT", "Không đỉnh nạp ác, không tác dụng.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_COLDESSENSE", "Chí nhu chí âm, hóa thành hình này")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.BELL_COMMISSIONER.NOSOUL", "Không thiện, không dụng.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.SOUL_SPECTER", "Sinh thời tích đức hành thiện, lòng mang ý tốt, sau khi mất như thế.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.POWDER_M_BECOMESTAR", "Dù là con trai hay con gái, đều khuyên thoa trước khi ngủ nhé.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_FOOD_THL", "Ngửi một cái đã thèm chảy nước miếng")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.PASS_COMMISSIONER_LZD.ONLYYAMA", "Đây không phải thứ ta dùng được.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_MOONCAKE_BOX", "Hộp bánh trung thu tinh xảo mỹ lệ")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.WB_ARMORBLOOD", "Đỗ quyên khóc huyết, gió xuân không về")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_YAMA_STATUE4", "Đứng đầu thập điện, vua của ngục tốt")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_HOUSE_BAMBOO", "Ngói đen trúc xanh, Giang Nam lưu thủy")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.WB_ARMORFOG", "Sương mây ánh nguyệt vụ mờ ảo, mỹ nhân như ngồi trong gương")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_IRON_BATTLEGEAR", "Mặc nó vào là ta thành gà sắt rồi.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.FENCE_GATE_BAMBOO_ITEM", "Cổng trúc sao đặt để hộ thân")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.PENNANT_COMMISSIONER.GENERIC", "Chiêu hồn dẫn phách, dắt qua hoàng tuyền.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_NIANHAT", "Mặt thú che thẹn, chớ gây phiền não")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_YAMA_STATUE1", "Một bức tượng đá không tên")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.BLACKBEAR", "Một yêu tinh đen quá!")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.GUITAR_JADEHARE.NOCOST", "Ta không còn sức để gảy nữa.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_CQF", "Lá bùa hỗ trợ nguyên thần xuất khiếu")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.POWDER_M_TAKEITEASY", "Thật ra còn có thể dùng pha trà.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.TREASURE_SHOW_MYTH", "Ta nghĩ, trên biển viết đúng đấy.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_FOOD_LHYX", "Cay đến tận đáy lòng ta")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.GUITAR_JADEHARE.NOGUITAR", "Cách âm nhạc tuyệt diệu còn thiếu cây tỳ bà!")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.SOUL_GHAST", "Sinh thời làm ác, lòng mang bất chính, chết đi thành thế.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MADAMEWEB_SILKCOCOON_PACKED", "Chờ đến mai, đúng lúc mở lại")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.GUITAR_JADEHARE.UNKOWN", "Ta chưa biết khúc này.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_STOOL", "Phải nghỉ ngơi cho tử tế một chút")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_SHOP_FOODS", "Thật là một nơi tốt để ăn uống no nê!")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_IRON_BROADSWORD", "Đại đao, chém xuống đầu bọn địch đi.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_PLANT_BAMBOO_BURNT", "Phải lưu sự trong trắng lại nhân gian.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_SHOP_WEAPONS", "Sư phụ tiệm này đúc sửa, mọi thứ đều thông thạo.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MADAMEWEB_POISONSTINGER", "Độc thấm đầu kim đòi mạng về")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_FOOD_LRHS", "Một cái không đủ, hai cái quá no")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_SHOP_ANIMALS", "Là tiệm bán động vật nhỏ dễ thương thú vị.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.PASS_COMMISSIONER_CJ", "Dưới luật lệnh, công tội tự có phán")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_FOOD_GQMX", "Ngọt thơm vừa miệng, lưỡi ta sắp cắn mất rồi")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.POWDER_M_LIFEELIXIR", "Sau khi mài thành bột không chỉ đại bổ, còn có phép thuật nhân từ.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MADAMEWEB_PITFALL_TRAP", "Bên trong có gì nhỉ?")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_SHOP_PLANTS", "Thật không biết họ cũng không trồng ruộng, làm sao có nhiều hạt giống thế.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_IRON_HELMET", "Đội nó vào là ta đầu cứng như sắt.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.POWDER_M_CHARGED", "Sau khi mài thành bột, khả năng dẫn điện có tính dễ bay hơi.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_SHOP_CONSTRUCT", "Ồ, nhớ cảm giác dạo tiệm đồ gia dụng quá.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_QUAGMIRE_PARKFIELD", "Cỏ thơm xinh đẹp, cánh hoa rơi rụng")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.POWDER_M_COLDEYE", "Vốn muốn tạo ra một con nai khổng lồ, nhưng thất bại.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.PASS_COMMISSIONER_WZ", "Thiện quả, đáng thưởng")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MADAMEWEB_BEEMINE", "Để ta xem báu vật bên trong")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.NIAN_BELL", "Hình như có thứ gì đang ngáy")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_YAMA_STATUE2", "Vài thứ cúng tế, màu sắc loang lổ")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.PASS_COMMISSIONER_LZD.NOTSOUL", "Vị đại nhân này chỉ cần hồn phách thiện ác.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.PASS_COMMISSIONER_MP", "Mê mê muội muội, uống một bát canh")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.RHINO3_YELLOW", "Tịch Trần Đại Vương")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_HUANHUNDAN", "Hoàn hồn đan, khiến người chết sống lại, xương trắng mọc thịt")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_PLANT_BAMBOO_5", "Cành khô còn tựa gió xuân lực, trúc xanh xưa nay tự chịu lạnh.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_YAMA_STATUE3", "Gạch ngói mới dựng")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_RHINO", "A! Có yêu khí!")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.TOKEN_COMMISSIONER.GENERIC", "Đây là bảo vật trấn tử vật kinh người sống.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MADAMEWEB_SPIDERHOME", "Ấm ổ ấp trứng nhện độc")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_NIAN_FUR", "Đêm giao thừa, nhiễu loạn nhân gian")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_SHOP_NUMEROLOGY", "Lừa người thôi, ta không bao giờ mê tín.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_PLANT_BAMBOO_2", "Lớn đi, lớn đi.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.POWDER_M_HYPNOTICHERB", "Dù bị mài thành bột ta vẫn nhận ra ngươi, Mandrake!")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MADAMEWEB_POISONBEEMINE", "Vẫn chưa đến lúc ấp nở")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.WHIP_COMMISSIONER", "Chuyên móc ác hồn, cũng trừng tà phách.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.BONE_MIRROR.MAX", "Lông mày nhạt núi thu e bàn gương, hải đường nở hay chưa?")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.BELL_COMMISSIONER.NOHAT", "Không mũ nạp thiện, không tác dụng.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.RHINO3_BLUE", "Tịch Hàn Đại Vương")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.PASS_COMMISSIONER_ZK", "Ác quả, tự chịu")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MINIFLARE_MYTH", "Trong tiếng pháo một năm trôi qua")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.PASS_COMMISSIONER_LZD.GENERIC", "Xét công tội, thiện ác không thể dối")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MADAMEWEB_SPIDER_WARRIOR", "Những con này không phải dễ chọc")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MADAMEWEB_SILKCOCOON_HANGED", "Tơ nhện treo không kết, không biết giấu gì bên trong")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_HIGANBANA_REBORN", "Hoàng tuyền bờ bên bao chuyện? Một bát canh Mạnh Bà tiễn đầu bạc.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.HUA_INTERNET_NODE", "Nút đặc chế, có thể chịu được tơ nhện dẻo dai")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_FOOD_XCMT", "Không có gì đưa cơm hơn thế")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.PASS_COMMISSIONER_YLW", "Sa bà khổ, chết vô thường, ai dám phóng túng")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.GHOST_IRRITATED", "Ác hồn mất ràng buộc, trở nên càng hung bạo tà ác.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.HAT_COMMISSIONER_WHITE", "Sa bà khổ, sinh lão bệnh vô thường")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_NIAN", "Bờm vàng rực như mặt trời")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_FOOD_NRLM", "Vị bò đậm đà, nước thơm bốn phương")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.GUITAR_JADEHARE.NOSONG", "Gảy khúc nào bây giờ?")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_PLANT_BAMBOO_3", "Bốn gốc trúc biếc xanh tươi, nảy chồi mới.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_BAMBOO_BASKET", "Một làn hương thuốc miên man truyền đến")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_HIGANBANA_ITEM", "Hoa nở không thấy lá, gặp nhau nghìn năm")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.GHOST_CLEMENT", "Thiện thay, vong hồn báo ân xong sẽ đầu thai chuyển kiếp.")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.BELL_COMMISSIONER.SPELL", "Âm sai mượn đường! Nhiếp hồn nhập mộng!")
set_str("STRINGS.CHARACTERS.GENERIC.DESCRIBE.MYTH_SHOP_INGREDIENT", "Hoa quả thịt trứng bán ở đây, có chín không vậy?")

-- CHARACTERS.GENERIC (non-DESCRIBE)
set_str("STRINGS.CHARACTERS.GENERIC.CANE_PEACH", "Bỏ gậy, hóa thành rừng Đặng")
set_str("STRINGS.CHARACTERS.GENERIC.INFANTREE_CARPET", "Lá rụng tơi bời, hòa vào thân này")
set_str("STRINGS.CHARACTERS.GENERIC.COMMISSIONER_BOOK", "Khâm định sinh tử, đâu dám không theo?")
set_str("STRINGS.CHARACTERS.GENERIC.COMMISSIONER_MPT", "Thương Lãng chi thủy rửa thanh trọc")
set_str("STRINGS.CHARACTERS.GENERIC.MYTH_INFANT_FRUIT", "Như hài như đồng, ăn vào trường sinh")
set_str("STRINGS.CHARACTERS.GENERIC.MYTH_PLANT_INFANTREE_TRUNK", "Một đoạn rễ cây khô mục, e tiên thần khó cứu")
set_str("STRINGS.CHARACTERS.GENERIC.MYTH_PLANT_INFANTREE_MEDIUM", "Nhật nguyệt ngưng tụ, cây khô gặp xuân")
set_str("STRINGS.CHARACTERS.GENERIC.MYTH_PLAYERREDPOUCH_NORMAL", "Vui vẻ tình nghĩa thâm sâu nhất, tiền tài ít ỏi đều hoan hô!")
set_str("STRINGS.CHARACTERS.GENERIC.MYTH_PLAYERREDPOUCH_SUPER", "Dây màu xỏ qua, đan thành hình rồng")
set_str("STRINGS.CHARACTERS.GENERIC.MYTH_GOLD_STAFF", "Một sợi xích kim, hai thước ngắn dài")
set_str("STRINGS.CHARACTERS.GENERIC.MYTH_PLANT_INFANTREE", "Tiên sơn tùng hạc, trời đất mở ra một linh căn")
set_str("STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.TRADE_BBSHOP_M.CLOSED", "Ôi, lại đóng cửa rồi.")
set_str("STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.TRADE_BBSHOP_M.OCCUPIED", "Xếp hàng là thói quen tốt!")

-- ==============================
-- STRINGS.CHARACTER_TITLES/DESCRIPTIONS/SURVIVABILITY
-- ==============================
set_str("STRINGS.CHARACTER_DESCRIPTIONS.madameweb", "*Nhện tu thành tinh, tự lập làm hậu")
set_str("STRINGS.CHARACTER_DESCRIPTIONS.yama_commissioners", "*Hắc Bạch song sinh, âm gian u minh")
set_str("STRINGS.CHARACTER_TITLES.madameweb", "Bàn Ti Nương Nương")
set_str("STRINGS.CHARACTER_TITLES.yama_commissioners", "Câu Hồn Âm Sai")
set_str("STRINGS.CHARACTER_SURVIVABILITY.madameweb", "Cao Gối Vô Ưu")
set_str("STRINGS.CHARACTER_SURVIVABILITY.yama_commissioners", "Trường Sinh Bất Tử")

-- ==============================
-- STRINGS.MYTH_RENWUMIAOSHU (character descriptions)
-- ==============================
set_str("STRINGS.MYTH_RENWUMIAOSHU.ZZ.1", "Bàn Ti Nương Nương vốn là nhện tu luyện thành tinh, là một yêu tinh, sở hữu giá trị tơ nhện. Không sợ bóng đêm, giỏi dùng độc, nhện xem nàng là đồng loại, sinh vật khác xem nàng là yêu quái.")
set_str("STRINGS.MYTH_RENWUMIAOSHU.ZZ.2", "Có thể biến lại nguyên hình nhện, có thị giác ban đêm, có tấn công phạm vi lớn, có thể khiến địch trúng độc, có thể dùng tơ nhện làm giáp chống đỡ sát thương.")
set_str("STRINGS.MYTH_RENWUMIAOSHU.ZZ.3", "Hình thái nhện có thể giăng lưới. Hình thái người có thể dùng hôn gió tơ mỏng.")
set_str("STRINGS.MYTH_RENWUMIAOSHU.ZZ.4", "Bàn Ti Nương Nương có thể trực tiếp nhặt nhện. Có thể trực tiếp điều khiển tơ nhện, khiến trứng nhện xuống cấp hoặc lên cấp. Tơ nhện mỏng như cánh ve sợ lửa, cháy sẽ khiến Bàn Ti Nương Nương mất nhiều giá trị tơ nhện.")
set_str("STRINGS.MYTH_RENWUMIAOSHU.ZZ.5", "Bàn Ti Nương Nương giỏi dùng độc, tấn công có thể tích lũy độc tố trên người địch.")
set_str("STRINGS.MYTH_RENWUMIAOSHU.ZZ.6", "Bàn Ti Nương Nương có thể giăng tơ lên dưới đất hoặc bóng cây, có thể vượt địa hình.")
set_str("STRINGS.MYTH_RENWUMIAOSHU.YA.1", "Hắc Bạch Vô Thường tuy song sinh một thể, thuộc tính lại khác nhau, có thể chủ động chuyển đổi hình tượng trong nhân thế.")
set_str("STRINGS.MYTH_RENWUMIAOSHU.YA.2", "Là âm ti chính thần, không có giá trị máu, chỉ có giá trị hồn phách. Hắc Bạch Vô Thường không chết, khi cả hai Vô Thường đều hồn phi phách tán sẽ biến thành một làn hồn phách phiêu bạt, một thời gian sau lại lâm thế.")
set_str("STRINGS.MYTH_RENWUMIAOSHU.YA.3", "Là âm ti tại thế, hồn phách của sinh vật chết gần Hắc Bạch Vô Thường sẽ bị họ thu lấy, lưu trong mũ quan Vô Thường.")
set_str("STRINGS.MYTH_RENWUMIAOSHU.YA.4", "Hắc Bạch Vô Thường có thể xây tượng Diêm La, không ngừng tiếp dẫn sức mạnh âm gian u minh vào bản thân.")
set_str("STRINGS.MYTH_RENWUMIAOSHU.YA.5", "Bạch Vô Thường cầm Chiêu Hồn Phan, Nhiếp Hồn Linh; Hắc Vô Thường cầm Câu Hồn Sách, Trấn Hồn Lệnh. Chiêu Hồn Phan tiêu hao thiện hồn triệu hồi linh thể chiến đấu, Nhiếp Hồn Linh tiêu hao thiện hồn thôi miên. Trấn Hồn Lệnh tiêu hao ác hồn dọa nạt, sát thương của Câu Hồn Sách tuỳ vào số lượng ác hồn.")
set_str("STRINGS.MYTH_RENWUMIAOSHU.YA.6", "Hắc Bạch Vô Thường có thể dẫn độ hồn thể sinh vật, khiến thân xác sinh mệnh đã mất được an nghỉ để có được thiện hồn.")

-- ==============================
-- STRINGS.MYTH_INFANT_FRUIT_ONDROP
-- ==============================
set_str("STRINGS.MYTH_INFANT_FRUIT_ONDROP.GENERIC", "Quả này lại bị bùn ăn mất rồi sao?")
set_str("STRINGS.MYTH_INFANT_FRUIT_ONDROP.yama_commissioners", "Thế này thì hỏng rồi")
set_str("STRINGS.MYTH_INFANT_FRUIT_ONDROP.madameweb", "Chết rồi, thiếp quên giăng lưới")
set_str("STRINGS.MYTH_INFANT_FRUIT_ONDROP.white_bone", "Cơ duyên tột trời này ta không có phúc hưởng")
set_str("STRINGS.MYTH_INFANT_FRUIT_ONDROP.myth_tudi", "Đại Thánh, việc này không liên quan đến lão nô")
set_str("STRINGS.MYTH_INFANT_FRUIT_ONDROP.monkey_king", "Lão Tôn ta nhất thời quên mất, không nhớ tập tính của quả này")
set_str("STRINGS.MYTH_INFANT_FRUIT_ONDROP.myth_yutu", "A, ta lại làm hỏng rồi, biết làm sao bây giờ")
set_str("STRINGS.MYTH_INFANT_FRUIT_ONDROP.pigsy", "Lẽ nào lại là con khỉ đó đang chọc ghẹo ta")
set_str("STRINGS.MYTH_INFANT_FRUIT_ONDROP.yangjian", "Sư phụ từng nhắc chuyện này, thôi bỏ đi")
set_str("STRINGS.MYTH_INFANT_FRUIT_ONDROP.neza", "Ôi, nhân sâm quả Na Tra hái biến đi đâu rồi")

-- ==============================
-- STRINGS.MKCETALK_YUTU (Yutu conversations)
-- ==============================
set_str("STRINGS.MKCETALK_YUTU.SONG_M_WORKUP.LEARNED", "Đừng chơi nữa, bột thuốc hôm nay làm xong chưa?")
set_str("STRINGS.MKCETALK_YUTU.POWDER_M_COLDEYE.LEARNED", "Hèn chi ta thấy lạnh một cơn, mau cầm đi.")
set_str("STRINGS.MKCETALK_YUTU.SONG_M_ICEIMMUNE.WRONGSTATE", "Thiềm cung không thiếu loại đá thường này.")
set_str("STRINGS.MKCETALK_YUTU.POWDER_M_BECOMESTAR.LEARNED", "Ta không cần cái này, con ạ, tự dùng đi.")
set_str("STRINGS.MKCETALK_YUTU.SONG_M_WEAKATTACK.LEARNED", "Nếu có kẻ sai hết lần này đến lần khác, ngươi nhớ đừng nhân từ.")
set_str("STRINGS.MKCETALK_YUTU.POWDER_M_LIFEELIXIR.GENERIC", "Con ơi, sao con có cái này, không đắc tội ai đó chứ?")
set_str("STRINGS.MKCETALK_YUTU.SONG_M_ICESHIELD.LEARNED", "Con tự giữ đi, ta đã có một con rồi.")
set_str("STRINGS.MKCETALK_YUTU.POWDER_M_CHARGED.GENERIC", "Khi nghiền và đóng túi rất dễ bị điện giật, vạn vạn phải cẩn thận.")
set_str("STRINGS.MKCETALK_YUTU.POWDER_M_CHARGED.LEARNED", "Ngạc nhiên, ta đã dạy con rồi, con quên à.")
set_str("STRINGS.MKCETALK_YUTU.SONG_M_WEAKDEFENSE.LEARNED", "Giờ ngươi là chỗ dựa duy nhất của ta, ta không còn phải trông đợi ai nữa.")
set_str("STRINGS.MKCETALK_YUTU.SONG_M_INSOMNIA.LEARNED", "Con ơi, đừng nghĩ nhiều, chú ý nghỉ ngơi.")
set_str("STRINGS.MKCETALK_YUTU.POWDER_M_IMPROVEHEALTH.LEARNED", "Ta không thể quên mùi hương ngọt ngào này.")
set_str("STRINGS.MKCETALK_YUTU.SONG_M_SWEETDREAM.LEARNED", "Trong cung ngày thường chỉ có ta và ngươi, ta cần thêm một cái nữa để làm gì.")
set_str("STRINGS.MKCETALK_YUTU.SONG_M_ICESHIELD.GENERIC", "Cá kỳ lạ làm sao, vảy băng tâm băng, ta cũng muốn thử nuôi một con.")
set_str("STRINGS.MKCETALK_YUTU.SONG_M_ICEIMMUNE.GENERIC", "Gió lạnh vi vu, băng giá cửu trùng.")
set_str("STRINGS.MKCETALK_YUTU.SONG_M_FIREIMMUNE.LEARNED", "Ta không cần nữa, con tự giữ đi.")
set_str("STRINGS.MKCETALK_YUTU.POWDER_M_TAKEITEASY.GENERIC", "Khi trăm sự nhàm chán, mong con ra ngoài dạo chơi, giải khuây nhiều hơn.")
set_str("STRINGS.MKCETALK_YUTU.SONG_M_WORKUP.GENERIC", "Đàn ong cần cù lao động, con ơi phải học theo chúng, nhớ không được lười biếng.")
set_str("STRINGS.MKCETALK_YUTU.SONG_M_INSOMNIA.GENERIC", "Mùi vị của nhớ nhung không dễ chịu, trằn trọc không yên, đêm khó ngủ được.")
set_str("STRINGS.MKCETALK_YUTU.SONG_M_NOCURE.LEARNED", "Thiềm cung không cho quái vật ở lại, mau ném ra ngoài đi.")
set_str("STRINGS.MKCETALK_YUTU.SONG_M_NOCURE.GENERIC", "Oán người, oán mình, oán này oán kia, hối không kịp.")
set_str("STRINGS.MKCETALK_YUTU.SONG_M_SWEETDREAM.GENERIC", "Tốt lắm, ngày nào đêm khuya khó ngủ, có thể thổi một khúc giải sầu.")
set_str("STRINGS.MKCETALK_YUTU.POWDER_M_COLDEYE.GENERIC", "Lấy từ vật yêu tà, thường dùng để lấy độc trị độc.")
set_str("STRINGS.MKCETALK_YUTU.POWDER_M_LIFEELIXIR.LEARNED", "Con ơi, dừng tay đi.")
set_str("STRINGS.MKCETALK_YUTU.SONG_M_NOLOVE.LEARNED", "Ngươi đi đi, ta muốn ở một mình một lát.")
set_str("STRINGS.MKCETALK_YUTU.SONG_M_NOLOVE.GENERIC", "Lời bên tai của y nhân xưa, đã theo tiếng triều chảy về đông.")
set_str("STRINGS.MKCETALK_YUTU.POWDER_M_HYPNOTICHERB.LEARNED", "Thảo dược quý hiếm, đâu có nhiều thế này.")
set_str("STRINGS.MKCETALK_YUTU.POWDER_M_HYPNOTICHERB.GENERIC", "Đây là cực phẩm trong thảo dược, khi nghiền phải nắm cho đúng.")
set_str("STRINGS.MKCETALK_YUTU.SONG_M_FIREIMMUNE.GENERIC", "Dục hỏa trọng sinh, tựa như phượng hoàng.")
set_str("STRINGS.MKCETALK_YUTU.POWDER_M_BECOMESTAR.GENERIC", "Sau khi giã nát trộn với phấn thơm, thoa lên da là có thể rạng ngời, hiểu chứ.")
set_str("STRINGS.MKCETALK_YUTU.SONG_M_WEAKATTACK.GENERIC", "Lấy tâm từ bi đối đãi vạn sự vạn vật, mới có thể xuân phong hóa vũ, trăm dặm đồ tô.")
set_str("STRINGS.MKCETALK_YUTU.POWDER_M_TAKEITEASY.LEARNED", "Cảm ơn, có ngươi bên cạnh ta vui vẻ hơn nhiều.")
set_str("STRINGS.MKCETALK_YUTU.SONG_M_WEAKDEFENSE.GENERIC", "Xưa mong y tá giáp về điền viên, mà giờ ta lại rơi vào cảnh này.")
set_str("STRINGS.MKCETALK_YUTU.POWDER_M_IMPROVEHEALTH.GENERIC", "Vốn dĩ rất dính, cần thêm gia vị, nghe chưa.")
set_str("STRINGS.MKCETALK_YUTU.SONG_M_ICEIMMUNE.LEARNED", "Nhiệt độ ấm áp này luôn khiến ta chợt nhớ đến sự lạnh lẽo của Thiềm cung.")

-- ==============================
-- STRINGS.HUA_INTERNET_BUILDER
-- ==============================
set_str("STRINGS.HUA_INTERNET_BUILDER.FAILED_EXIST", "Đã có dây nối, không thể xây")
set_str("STRINGS.HUA_INTERNET_BUILDER.FAILED_PREFAB", "Thiếu prefab: ")
set_str("STRINGS.HUA_INTERNET_BUILDER.FAILED_DIST", "Khoảng cách quá xa, không thể xây")
set_str("STRINGS.HUA_INTERNET_BUILDER.FAILED_MATERIAL", "Vật liệu không đủ, không thể xây")

-- ==============================
-- STRINGS.WB_ARMORSTR
-- ==============================
set_str("STRINGS.WB_ARMORSTR.WB_ARMORGREED", "Ấm, tham lam sẽ khiến ngươi giành được nhiều chiến lợi phẩm hơn")
set_str("STRINGS.WB_ARMORSTR.WB_ARMORFOG", "Ấm, mở rộng phạm vi yêu vụ, trong yêu vụ tăng lớn tốc độ di chuyển")
set_str("STRINGS.WB_ARMORSTR.WB_ARMORBLOOD", "Mát, có được khả năng hút máu bạch cốt cực mạnh")
set_str("STRINGS.WB_ARMORSTR.WB_ARMORSTORAGE", "Ấm, có thể mang thêm vật phẩm, tự động hút vật phẩm cùng loại")
set_str("STRINGS.WB_ARMORSTR.WB_ARMORBONE", "Mát, có được giáp cao hơn, nhưng mất khả năng hút máu bạch cốt")
set_str("STRINGS.WB_ARMORSTR.WB_ARMORLIGHT", "Mát, gió nổi, tăng lớn tốc độ di chuyển")

-- ==============================
-- STRINGS.SKIN_NAMES
-- ==============================
set_str("STRINGS.SKIN_NAMES.yangjian_hawk", "Kim Sí Đại Bàng")
set_str("STRINGS.SKIN_NAMES.myth_stool_bigstone", "Huyền Minh")
set_str("STRINGS.SKIN_NAMES.myth_stool_tiger", "Hổ Khiếu")
set_str("STRINGS.SKIN_NAMES.myth_stool_bear", "Ngọa Hùng")
set_str("STRINGS.SKIN_NAMES.myth_stool_golden", "Phượng Đài")
set_str("STRINGS.SKIN_NAMES.white_bone_queen", "Tây Lương Nữ Vương")
set_str("STRINGS.SKIN_NAMES.myth_food_table_star", "Thất Tinh")
set_str("STRINGS.SKIN_NAMES.fence_bamboo_decolored", "Khô Trúc")
set_str("STRINGS.SKIN_NAMES.mk_battle_flag_item_golden", "Liệu Nguyên")
set_str("STRINGS.SKIN_NAMES.myth_redlantern_ground_wood", "Cành Khô")
set_str("STRINGS.SKIN_NAMES.pigsy_constellation", "Thất Hỏa Tinh Tú")
set_str("STRINGS.SKIN_NAMES.myth_interiors_ghg_groundlight_yhy", "U Hồn Dẫn")
set_str("STRINGS.SKIN_NAMES.myth_yutu_soprano", "Duyệt Nhĩ Điềm Âm")
set_str("STRINGS.SKIN_NAMES.myth_food_table_stone", "Mặc Ngọc")

-- ==============================
-- STRINGS.SKIN_QUOTES
-- ==============================
set_str("STRINGS.SKIN_QUOTES.madameweb_rat", "\"Ngươi có thấy giày của thiếp không?\"")
set_str("STRINGS.SKIN_QUOTES.madameweb_none", "\"Không bằng vào động Bàn Ti của ta ngồi chút?\"")
set_str("STRINGS.SKIN_QUOTES.yangjian_hawk", "\"Ta ở Diêm Phù Đề, một ngày ăn trăm rồng\"")
set_str("STRINGS.SKIN_QUOTES.yama_commissioners_none", "\"Lệ quỷ câu hồn, vô thường đòi mạng\"")
set_str("STRINGS.SKIN_QUOTES.white_bone_queen", "\"Ngự Đệ ca ca, lần biệt ly này e khó gặp lại.\"")
set_str("STRINGS.SKIN_QUOTES.pigsy_constellation", "\"Thần Quan, thần mùa, Doanh Thất Tinh Thần chủ quản.\"")
set_str("STRINGS.SKIN_QUOTES.myth_yutu_soprano", "\"Giai điệu xuyên thẳng nhân tâm này.\"")

-- ==============================
-- STRINGS.PRETRANSLATED
-- ==============================
set_str("STRINGS.PRETRANSLATED.LANGUAGES.22", "Giản thể Trung Văn (Simplified Chinese)")
set_str("STRINGS.PRETRANSLATED.LANGUAGES.21", "Phồn thể Trung Văn (Traditional Chinese)")
set_str("STRINGS.PRETRANSLATED.LANGUAGES_BODY.21", "Có đặt ngôn ngữ thành Phồn thể Trung Văn không?")
set_str("STRINGS.PRETRANSLATED.LANGUAGES_BODY.22", "Có đặt ngôn ngữ thành Trung Văn không?")
set_str("STRINGS.PRETRANSLATED.LANGUAGES_TITLE.21", "Cài đặt ngôn ngữ")
set_str("STRINGS.PRETRANSLATED.LANGUAGES_TITLE.22", "Cài đặt ngôn ngữ")

print("[Myth-Viet] Phase 1 STRINGS loaded.")
