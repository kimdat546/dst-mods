-- characters_textfix.lua
-- Textfix cho Myth Characters (神话人物) + Myth Words Theme (神话书说) — cả 2 đều encrypted

local _G = GLOBAL
GLOBAL.setfenv(1, GLOBAL)

local textfix = rawget(_G, "myth_viet_textfix")
local word_fix = rawget(_G, "myth_viet_word_fix")
if not textfix or not word_fix then return end

-- HUD buff indicators that appear frequently — add early
textfix["闪耀"] = "Tỏa Sáng"
textfix["滑丝"] = "Trượt Tơ"
textfix["未知Buff"] = "Buff chưa biết"

-- Common English Myth items (mod sets English names directly)
textfix["Bone Wand"] = "Gậy Xương"
textfix["Sealed Book"] = "Sách Niêm Phong"
textfix["Myth Words"] = "Thiên Thư"
textfix["Myth Book"] = "Thiên Thư"

-- White Bone / Bạch Cốt powder effects (ANNOUNCE/using text)
textfix["Darkness can't hide you from me now!"] = "Giờ bóng tối không thể giấu ngươi khỏi ta!"
textfix["You feel revitalized!"] = "Ngươi cảm thấy hồi sức!"
textfix["Your mind is at peace."] = "Tâm trí ngươi đã an."
textfix["You feel your wounds closing."] = "Ngươi cảm thấy vết thương đang khép lại."
textfix["A burst of life courses through you!"] = "Luồng sinh khí trào dâng trong ngươi!"
textfix["Your body hums with electricity!"] = "Cơ thể ngươi rung chuyển điện năng!"
textfix["You glow with a radiant light!"] = "Ngươi phát sáng rực rỡ!"
textfix["Your worries fade away..."] = "Ưu tư tan biến..."
textfix["You feel drowsy..."] = "Ngươi cảm thấy buồn ngủ..."
textfix["Your senses feel numb."] = "Giác quan ngươi tê liệt."

-- ==============================
-- ITEM NAMES / PROPS
-- ==============================
local items = {
    ["白骨妖镜"]     = "Bạch Cốt Yêu Kính",
    ["不餍衣"]       = "Bất Yếm Y",
    ["出窍符"]       = "Xuất Khiếu Phù",
    ["坚骨披"]       = "Kiên Cốt Phi",
    ["夜明药粉"]     = "Bột Dạ Minh",
    ["寒眸药粉"]     = "Bột Hàn Mâu",
    ["彼岸花"]       = "Bỉ Ngạn Hoa",
    ["惊厥药粉"]     = "Bột Kinh Quyết",
    ["排郁药粉"]     = "Bột Giải Uất",
    ["活血药粉"]     = "Bột Hoạt Huyết",
    ["犀茸药粉"]     = "Bột Tê Nhung",
    ["草参药粉"]     = "Bột Thảo Sâm",
    ["解毒散"]       = "Giải Độc Tán",
    ["盈风绸"]       = "Doanh Phong Trù",
    ["血色霓"]       = "Huyết Sắc Nghê",
    ["莹月琵琶"]     = "Oánh Nguyệt Tỳ Bà",
    ["蕴玄袍"]       = "Uẩn Huyền Bào",
    ["步丝履"]       = "Bộ Ti Lý",
    ["盘丝披肩"]     = "Khăn Choàng Bàn Ti",
    ["盘丝毒针"]     = "Kim Độc Bàn Ti",
    ["盘丝滑索"]     = "Dây Trượt Bàn Ti",
    ["盘丝蛛卵"]     = "Trứng Nhện Bàn Ti",
    ["盘丝蜂针"]     = "Kim Ong Bàn Ti",
    ["盘丝吊"]       = "Dây Treo Bàn Ti",
    ["蛛网陷阱"]     = "Bẫy Tơ Nhện",
    ["蛛丝茧袋"]     = "Túi Kén Tơ Nhện",
    ["蛛丝罗网"]     = "Lưới Tơ Nhện",
    ["海丝滑索"]     = "Dây Trượt Hải Ti",
    ["月蛾引路"]     = "Nguyệt Nga Dẫn Lộ",
    ["毒蜂茧"]       = "Kén Ong Độc",
    ["美人画皮"]     = "Mỹ Nhân Họa Bì",
    ["阎罗雕像"]     = "Tượng Diêm La",
    ["竹药篓"]       = "Giỏ Thuốc Trúc",
    ["仙丹"]         = "Tiên Đan",
    ["铜钱串"]       = "Xâu Tiền Đồng",
    ["还魂丹"]       = "Hoàn Hồn Đan",
    ["通天敕令"]     = "Thông Thiên Sắc Lệnh",
    ["金击子"]       = "Kim Kích Tử",
    ["铸铁头盔"]     = "Mũ Sắt Đúc",
    ["铸铁战甲"]     = "Giáp Sắt Đúc",
    ["酆都路引"]     = "Phong Đô Lộ Dẫn",
    ["勾魂阴差"]     = "Câu Hồn Âm Sai",
    ["年兽面具"]     = "Mặt Nạ Niên Thú",
    ["月饼盒"]       = "Hộp Bánh Trung Thu",
    ["爆竹"]         = "Pháo",
    ["人参果地毯"]   = "Thảm Nhân Sâm Quả",
    ["人参果树"]     = "Cây Nhân Sâm Quả",
    ["缠根青苔绿"]   = "Rêu Xanh Quấn Rễ",
    ["破旧的供桌"]   = "Bàn Thờ Cũ Nát",
    ["广寒宫"]       = "Quảng Hàn Cung",
}
for cn, vn in pairs(items) do
    textfix[cn] = vn
    word_fix[cn] = vn
end

-- ==============================
-- BUFFS / STATUSES (ngắn gọn)
-- ==============================
textfix["治疗"]       = "Chữa Trị"
textfix["驭电"]       = "Ngự Điện"
textfix["凝霜"]       = "Ngưng Sương"
textfix["闪耀"]       = "Lấp Lánh"
textfix["回神"]       = "Hồi Thần"
textfix["滑丝"]       = "Trượt Tơ"
textfix["未知Buff"]   = "Buff Ẩn"
textfix["火眼金睛"]   = "Hỏa Nhãn Kim Tinh"
textfix["以柔克刚"]   = "Dĩ Nhu Khắc Cương"
textfix["解除"]       = "Giải Trừ"

-- ==============================
-- DESCRIPTIONS / QUOTES
-- ==============================
textfix["我，永不餍足"]                     = "Ta, mãi không thỏa mãn"
textfix["重重白骨护我身"]                   = "Lớp lớp bạch cốt hộ thân ta"
textfix["肤如凝脂，粉光若腻。"]             = "Da mịn như ngọc, phấn sáng như gấm."
textfix["寒邪客于敌。"]                     = "Hàn tà nhập địch."
textfix["花红彼岸，捻灰作尘"]               = "Bỉ ngạn hoa đỏ, nghiền thành tro bụi"
textfix["电光石火，惊厥逼人。"]             = "Điện quang thạch hỏa, kinh hãi ép người."
textfix["除忧解虑，安然自得。"]             = "Trừ ưu giải lo, an nhiên tự tại."
textfix["指花为蝶，往月翩跹"]               = "Chỉ hoa thành bướm, bay về cung trăng"
textfix["体验蜘蛛的感觉"]                   = "Trải nghiệm cảm giác làm nhện"
textfix["编织你的蛛网吧"]                   = "Hãy dệt mạng nhện của ngươi"
textfix["一丝虚空挂"]                       = "Một sợi treo hư không"
textfix["无处可悬"]                         = "Không nơi nào để treo"
textfix["也许可以"]                         = "Có lẽ được"
textfix["毒缠针头"]                         = "Độc quấn đầu kim"
textfix["应时而动，适时而谋"]               = "Tùy thời mà động, đúng lúc mà mưu"
textfix["丝悬针尾"]                         = "Tơ treo đuôi kim"
textfix["霞光日晚，采药方还"]               = "Ráng chiều hoàng hôn, hái thuốc trở về"
textfix["大补心力，使人嗜睡。"]             = "Đại bổ tâm lực, khiến người buồn ngủ."
textfix["轻拢慢捻，泪珠盈睫"]               = "Nhẹ gảy chậm vuốt, lệ đọng hàng mi"
textfix["衣袍猎猎，袖里乾坤"]               = "Áo bào phần phật, trong tay áo có càn khôn"
textfix["无处可逃"]                         = "Không đường trốn thoát"
textfix["绵绵絮絮，长存其中"]               = "Miên man bông tơ, trường tồn bên trong"
textfix["百丝杀气生"]                       = "Trăm sợi sát khí sinh"
textfix["漫天血色，尽染霓虹"]               = "Đầy trời huyết sắc, nhuộm hết cầu vồng"
textfix["以毒攻毒"]                         = "Dĩ độc trị độc"
textfix["魂迢迢兮路遥遥"]                   = "Hồn xa xôi chừ đường xa vời"
textfix["此物可助我悬丝而行"]               = "Vật này giúp ta treo tơ mà đi"
textfix["让我看看里面的宝贝"]               = "Để ta xem bảo vật bên trong"
textfix["辅助元神出窍的符咒"]               = "Phù chú trợ nguyên thần xuất khiếu"
textfix["先去里面呆着"]                     = "Vào trong đó ở đã"
textfix["清风锁不住，盈羽月夜归"]           = "Gió nhẹ không khóa được, lông cánh đêm trăng về"
textfix["毒沁针头索命回"]                   = "Độc thấm đầu kim đoạt mệnh về"
textfix["蜂针缠丝穿心过"]                   = "Kim ong quấn tơ xuyên tim qua"
textfix["不为我所用，不可留"]               = "Không phục ta, không thể để lại"
textfix["你要来试试吗？"]                   = "Ngươi muốn thử không?"
textfix["那衣物好似一只不知餍足的怪物"]     = "Bộ y phục ấy như con quái vật không biết thỏa mãn"
textfix["这披风到底害死了多少条命"]         = "Áo choàng này rốt cuộc đã hại chết bao nhiêu mạng"
textfix["天罗何在？地网何织？"]             = "Thiên la ở đâu? Địa võng dệt sao?"
textfix["明镜妆里影自怜"]                   = "Trong gương trang điểm tự thương hình bóng"
textfix["君王难逑，长生灵药。"]             = "Quân vương khó cầu, trường sinh linh dược."
textfix["春花如面，秋雨不绝"]               = "Hoa xuân như mặt, mưa thu không dứt"
textfix["指花为蝶"]                         = "Chỉ hoa thành bướm"
textfix["羽翼盈风，我登青云"]               = "Cánh đón gió, ta lên mây xanh"
textfix["特制的节点，可以承载有韧性的蛛丝"] = "Nút đặc chế, chịu được tơ nhện dai"
textfix["四青青碧竹，盎然新发。"]           = "Bốn cây trúc xanh biếc, tươi tốt đâm chồi."
textfix["这石头供桌什么来头？"]             = "Bàn thờ đá này từ đâu ra?"
textfix["月儿弯弯，满载欣欢"]               = "Trăng cong cong, đầy niềm vui"
textfix["一方蒲团，静坐凝心，"]             = "Một tấm bồ đoàn, tĩnh tọa ngưng tâm,"
textfix["感悟天地灵气。"]                   = "Cảm ngộ linh khí trời đất."
textfix["没有足够的材料"]                   = "Không đủ nguyên liệu"
textfix["镜子等级1,升级需要:"]              = "Gương cấp 1, nâng cấp cần:"

-- ==============================
-- MENU / UI LABELS (ngắn)
-- ==============================
textfix["兑换列表"]     = "Danh Sách Đổi"
textfix["全部"]         = "Tất Cả"
textfix["可给予"]       = "Có Thể Đưa"
textfix["可获得"]       = "Có Thể Nhận"
textfix["效果"]         = "Hiệu Quả"
textfix["炼制时间"]     = "Thời Gian Luyện"
textfix["药效"]         = "Dược Hiệu"
textfix["获取方式"]     = "Cách Lấy"
textfix["配方"]         = "Công Thức"
textfix["战利品"]       = "Chiến Lợi Phẩm"
textfix["更新公告"]     = "Thông Báo Cập Nhật"
textfix["注意事项"]     = "Lưu Ý"
textfix["游戏小贴士"]   = "Mẹo Chơi"
textfix["生成方式"]     = "Cách Sinh Ra"
textfix["获取途径"]     = "Cách Thu Thập"
textfix["法宝"]         = "Pháp Bảo"
textfix["灵台方寸山"]   = "Linh Đài Phương Thốn Sơn"
textfix["道德天尊，太上道祖"] = "Đạo Đức Thiên Tôn, Thái Thượng Đạo Tổ"
textfix["世外桃源 孤僻仙山"] = "Thế Ngoại Đào Nguyên - Cô Tịch Tiên Sơn"

-- ==============================
-- ANNOUNCEMENTS
-- ==============================
textfix["免疫火焰，免疫高温过热！"]         = "Miễn nhiễm lửa, miễn nhiễm quá nóng!"
textfix["免疫潮湿，免疫低温过冷！"]         = "Miễn nhiễm ẩm ướt, miễn nhiễm quá lạnh!"
textfix["免疫沙尘风暴的影响！"]             = "Miễn nhiễm bão cát!"
textfix["使用之后改变飞行术的配方"]         = "Sau khi dùng đổi công thức phi hành thuật"
textfix["获得防御加持，受到伤害减半"]       = "Nhận buff phòng ngự, sát thương nhận giảm nửa"
textfix["获得防御加持，受到伤害减半！"]     = "Nhận buff phòng ngự, sát thương nhận giảm nửa!"
textfix["获得风驰电掣般的速度提升！"]       = "Nhận tốc độ như gió cuốn sấm sét!"
textfix["使用救赎之心和太上老君换取"]       = "Dùng Cứu Chuộc Tâm đổi với Thái Thượng Lão Quân"
textfix["可召回队友灵体！"]                 = "Có thể triệu hồi linh thể đồng đội!"
textfix["喂食灵魂出窍队友身躯，"]           = "Cho thân xác đồng đội xuất hồn ăn,"
textfix["战斗力提升，攻击力翻倍"]           = "Chiến lực tăng, công kích nhân đôi"
textfix["聚宝盆有几率获得！"]               = "Tụ Bảo Bồn có xác suất nhận!"
textfix["可免疫植物的伤害并保护你！"]       = "Miễn sát thương thực vật và bảo vệ bạn!"
textfix["获得恐怖的吸血能力，小心反噬"]    = "Nhận khả năng hút máu, cẩn thận phản phệ"
textfix["获得恐怖的吸血能力，小心反噬！"]  = "Nhận khả năng hút máu, cẩn thận phản phệ!"
textfix["获得神力身负重物依然健步如飞"]    = "Nhận thần lực, vác nặng vẫn đi như bay"
textfix["获得神力身负重物依然健步如飞！"]  = "Nhận thần lực, vác nặng vẫn đi như bay!"
textfix["太上老君为青牛铸造的铃铛！"]       = "Chuông Thái Thượng Lão Quân đúc cho Thanh Ngưu!"
textfix["太上老君为青牛铸造的牛鞍！"]       = "Yên Thái Thượng Lão Quân đúc cho Thanh Ngưu!"
textfix["将符咒放在地上点燃召唤老君"]       = "Đặt phù chú xuống đất đốt triệu Lão Quân"
textfix["将符咒放在地上点燃召唤老君！"]     = "Đặt phù chú xuống đất đốt triệu Lão Quân!"
textfix["妖精持此令可与太上老君交易"]       = "Yêu tinh có lệnh này có thể giao dịch với Thái Thượng Lão Quân"
textfix["妖精持此令可与太上老君交易！"]     = "Yêu tinh có lệnh này có thể giao dịch với Thái Thượng Lão Quân!"
textfix["有教无类，"]                       = "Hữu giáo vô loại,"
textfix["浇灌施肥，复活作物，吸收雨水"]     = "Tưới bón, hồi sinh cây, hút nước mưa"
textfix["浇灌施肥，复活作物，吸收雨水！"]   = "Tưới bón, hồi sinh cây, hút nước mưa!"
textfix["吸入选定区域内的地面物品和小生物"] = "Hút vật phẩm và sinh vật nhỏ trong vùng chọn"
textfix["吸入选定区域内的地面物品和小生物！"] = "Hút vật phẩm và sinh vật nhỏ trong vùng chọn!"
textfix["阴阳双生，一扇便荡尽火焰！"]       = "Âm dương song sinh, một quạt quét sạch lửa!"
textfix["400耐久值"]                        = "400 độ bền"
textfix["600耐久值"]                        = "600 độ bền"
textfix["也会提高大蟠桃掉率！"]             = "Còn tăng tỷ lệ rớt Đại Bàn Đào!"
textfix["可以施展技能隔空取物！"]           = "Có thể dùng kỹ năng lấy đồ từ xa!"
textfix["可施展技能寒冰横扫！"]             = "Có thể dùng kỹ năng Hàn Băng Càn Quét!"
textfix["可施展技能炙热重斩！"]             = "Có thể dùng kỹ năng Chích Nhiệt Trọng Trảm!"
textfix["可施展技能一尺寒光！"]             = "Có thể dùng kỹ năng Nhất Xích Hàn Quang!"
textfix["可施展技能蓄力重锤"]               = "Có thể dùng kỹ năng Súc Lực Trọng Chùy"
textfix["攻击具有范围伤害，"]               = "Công kích có sát thương phạm vi,"
textfix["攻击次数越多伤害越高，"]           = "Đánh càng nhiều lần sát thương càng cao,"
textfix["攻击附带冰冻，"]                   = "Công kích kèm đóng băng,"
textfix["增加移速，消除生物仇恨，"]         = "Tăng tốc độ, xóa thù hận sinh vật,"
textfix["秒杀暗影生物，但无掉落物，"]       = "Giết ngay sinh vật bóng tối, nhưng không rớt đồ,"
textfix["具有霸体效果！"]                   = "Có hiệu ứng bá thể!"
textfix["具有防水抗冻效果！"]               = "Có hiệu ứng chống nước chống lạnh!"
textfix["阳光下自我修复耐久！"]             = "Tự hồi độ bền dưới ánh nắng!"
textfix["降低技能消耗，提升技能威力"]       = "Giảm tiêu hao kỹ năng, tăng uy lực"
textfix["降低技能消耗，提升技能威力，"]     = "Giảm tiêu hao kỹ năng, tăng uy lực,"
textfix["降低技能消耗，缩短技能冷却"]       = "Giảm tiêu hao kỹ năng, rút ngắn hồi chiêu"
textfix["降低技能消耗，缩短技能冷却，"]     = "Giảm tiêu hao kỹ năng, rút ngắn hồi chiêu,"
textfix["降低装备耐久消耗！"]               = "Giảm tiêu hao độ bền trang bị!"
textfix["传信接引地府神仙的虚影！"]         = "Truyền tin dẫn bóng thần tiên địa phủ!"
textfix["减伤恢复精神，"]                   = "Giảm sát thương, hồi tinh thần,"
textfix["击杀怪物恢复理智！"]               = "Giết quái hồi lý trí!"
textfix["击，"]                             = "Đánh,"
textfix["抵挡八成半伤害，提高两成攻击，"]   = "Chặn 85% sát thương, +20% công kích,"
textfix["抵挡八成半伤害，提高移动速度，"]   = "Chặn 85% sát thương, tăng tốc độ,"
textfix["度，"]                             = "Độ,"
textfix["用于采摘人参果和蟠桃，"]           = "Dùng để hái Nhân Sâm Quả và Bàn Đào,"
textfix["七星剑、子圭装备炼制材料！"]       = "Nguyên liệu luyện trang bị Thất Tinh Kiếm, Tử Khuê!"
textfix["位面防御火元淬炼材"]               = "Nguyên liệu tôi luyện Hỏa Nguyên phòng ngự vị diện"
textfix["位面伤害火元淬炼材"]               = "Nguyên liệu tôi luyện Hỏa Nguyên sát thương vị diện"
textfix["凝结天地造化与劫运的灵韵之"]       = "Linh vận ngưng tụ tạo hóa và kiếp vận"
textfix["结千丝为瑞气，织天罗御万"]         = "Kết ngàn tơ thành thụy khí, dệt thiên la ngự vạn"

-- ==============================
-- LORE (mô tả dài)
-- ==============================
textfix["作为在世阴司，在黑白无常附近死去的生物的魂魄会被黑白无常收取，存放在无常官帽之中。"] = "Là âm ty tại thế, linh hồn sinh vật chết gần Hắc Bạch Vô Thường sẽ bị thu vào mũ quan của họ."
textfix["作为阴司正神，没有生命值，只有魂魄值。黑白无常不会死亡，当两位无常都魂飞魄散时变成一缕漂泊的魂魄，一段时间后再次临世。"] = "Là chính thần âm ty, không có máu, chỉ có hồn phách. Hắc Bạch Vô Thường không chết - khi cả hai tan rã thì thành hồn phách phiêu bạt, sau một thời gian lại trở lại trần thế."
textfix["白无常持招魂幡，摄魂铃，黑无常持勾魂锁，镇魂令。招魂幡消耗善魂召唤灵体战斗，摄魂铃消耗善魂催眠。镇魂令消耗恶魂恐吓，勾魂锁的伤害取决于恶魂的数量。"] = "Bạch Vô Thường cầm Chiêu Hồn Phan, Nhiếp Hồn Linh. Hắc Vô Thường cầm Câu Hồn Tỏa, Trấn Hồn Lệnh. Phan dùng thiện hồn triệu linh thể chiến đấu. Linh thôi miên. Lệnh dùng ác hồn dọa. Tỏa gây sát thương theo số ác hồn."
textfix["盘丝娘娘"] = "Bàn Ti Nương Nương"
textfix["盘丝娘娘可以在地下或者树荫下盘丝而上，可以跨越地形。"] = "Bàn Ti Nương Nương có thể kết tơ dưới đất hoặc dưới bóng cây, vượt địa hình."
textfix["盘丝娘娘可以直接捡起蜘蛛。可直接控制蛛丝，使蜘蛛卵降级或升级。薄如蝉翼的蛛丝害怕火焰，着火会使盘丝娘娘失去大量蛛丝值。"] = "Có thể nhặt trực tiếp nhện. Điều khiển tơ, nâng/hạ cấp trứng nhện. Tơ mỏng sợ lửa, cháy khiến mất lượng lớn giá trị tơ."
textfix["盘丝娘娘善于用毒，攻击可以在敌人身上积累毒素。"] = "Bàn Ti Nương Nương giỏi dùng độc, công kích tích lũy độc trên địch."
textfix["盘丝娘娘本是蜘蛛修炼成精，是一个妖精，拥有蛛丝值。不惧黑夜，善于用毒，蜘蛛视她为同类，其他生物视她为妖怪。"] = "Vốn là nhện tu luyện thành tinh, là yêu tinh, có giá trị tơ nhện. Không sợ đêm, giỏi dùng độc, nhện coi là đồng loại, sinh vật khác coi là yêu quái."
textfix["可变回蜘蛛原形，拥有夜视，拥有较高范围攻击，可使敌人中毒，可用蛛丝化甲，抵御伤害。"] = "Có thể hóa lại nguyên hình nhện, có dạ thị, công kích phạm vi rộng, gây độc, dùng tơ làm giáp chống sát thương."
textfix["蜘蛛形态可以布网。人类形态可使用薄丝飞吻。"] = "Dạng nhện có thể giăng lưới. Dạng người có thể dùng nụ hôn tơ mỏng."
textfix["黑白无常可以建造阎罗像，不断接引阴间幽冥的力量加诸己身。"] = "Hắc Bạch Vô Thường có thể xây tượng Diêm La, liên tục dẫn lực âm gian u minh gia lên thân."
textfix["黑白无常可以引渡魂类生物、使逝去生命的躯体得到安息来获取善魂。"] = "Hắc Bạch Vô Thường có thể dẫn dắt sinh vật linh hồn, an nghỉ thân xác đã chết để nhận thiện hồn."
textfix["黑白无常虽双生一体，属性却各不相同，可以主动切换在人世的形象。"] = "Hắc Bạch Vô Thường tuy song sinh nhất thể, thuộc tính khác nhau, có thể chủ động đổi hình tượng ở nhân thế."
textfix["*蜘蛛成精，自立为后"] = "*Nhện thành tinh, tự lập làm hậu"
textfix["*黑白双生，阴间幽冥"] = "*Hắc Bạch song sinh, âm gian u minh"
textfix["在地图上靠外围随机位置会生成一片纯洁的月亮\"碎片\"。终年飘雪寒冷无比。在这片碎片上中心有一座高雅的宫殿。在其外围的寒冷土地上,还立着一座奇怪的金元宝雕像。"] = "Ở rìa bản đồ vị trí ngẫu nhiên sẽ sinh ra một mảnh \"碎片\" mặt trăng thuần khiết. Quanh năm tuyết rơi cực lạnh. Chính giữa có một cung điện thanh nhã. Trên đất lạnh xung quanh còn dựng một tượng nguyên bảo vàng kỳ lạ."
textfix["在地图靠外围随机位置会生成一片被Thanh Trúc林覆盖的洲屿。洲屿一角的小镇里住着一群抱德炀和的居民。另一角原为居民供奉先祖的场所，据说如今已被妖怪占去并设下供台，要求居民每年春天上供求和。"] = "Ở rìa bản đồ vị trí ngẫu nhiên sẽ sinh ra một châu đảo phủ rừng Thanh Trúc. Một góc đảo có thị trấn với cư dân ôm đức hòa hợp. Góc khác vốn là nơi cư dân thờ tổ tiên, nghe nói nay đã bị yêu quái chiếm và đặt bàn thờ, yêu cầu cư dân mỗi xuân dâng cúng cầu hòa."
textfix["月宫中心的一座宫殿内"] = "Trong một cung điện ở trung tâm Nguyệt Cung"
textfix["犀牛三大王占领了Thanh Trúc洲居民祭祀先祖的场所"] = "Tê Giác Tam Đại Vương chiếm nơi cư dân châu Thanh Trúc thờ tổ tiên"
textfix["偷窃袈裟的熊罴怪,一身黑，力大无穷。"] = "Gấu yêu trộm cà sa, toàn thân đen, sức mạnh vô biên."
textfix["在混合地形会生成蜜罐,蜜罐可填充蜂蜜"] = "Ở địa hình hỗn hợp sinh ra hũ mật, có thể chứa mật ong"
textfix["如果您有bug反馈或者别的建议"] = "Nếu bạn có phản hồi bug hoặc góp ý khác"
textfix["黑风大王力大无比伤害奇高且会击飞武器!"] = "Hắc Phong Đại Vương sức mạnh vô song, sát thương cực cao và đánh văng vũ khí!"
textfix["在算命小铺中购买的藏宝线索有可能寻得一颗被推倒的枯树根，被推倒的枯树根在井中经过玉净瓶中甘露水的滋润、日月精华的熏陶、玩家的悉心照料会长成参天的人参果树，人参果树每隔七七四十九天会长出传闻食用后可长生不老的人参果。"] = "Manh mối kho báu mua ở tiệm bói có thể tìm được một gốc cây khô bị đổ. Gốc khô đặt trong giếng, được Cam Lộ Thủy trong Ngọc Tịnh Bình tưới nhuần, tinh hoa nhật nguyệt hun đúc, người chơi chăm sóc, sẽ lớn thành cây Nhân Sâm Quả cao chọc trời. Mỗi 49 ngày kết ra Nhân Sâm Quả, nghe đồn ăn vào trường sinh bất lão."
textfix["高耸入云的人参果树提供大范围的树荫，树荫之下不怕风吹雨淋，不怕烈阳暴晒，不怕电闪雷鸣。结出的果子遇金而落，遇木而枯，遇水而化，遇火而焦，遇土而入。人参果树极难被破坏，唯火焰可烧毁之。"] = "Cây Nhân Sâm Quả cao chọc trời cho bóng mát rộng, dưới bóng không sợ mưa gió, nắng gắt, sấm chớp. Quả kết ra gặp Kim thì rụng, gặp Mộc thì khô, gặp Thủy thì tan, gặp Hỏa thì cháy, gặp Thổ thì lún. Cây cực khó phá, chỉ lửa mới thiêu được."
textfix["10月29日 更新说明："] = "Thông báo cập nhật ngày 29/10:"
textfix["1.  部分角色的专属技能 需要到方寸山进行解锁"] = "1. Kỹ năng riêng của một số nhân vật cần mở khóa tại Phương Thốn Sơn"
textfix["修复紫金葫芦无法吸收日月精华的问题"] = "Sửa lỗi Tử Kim Hồ Lô không thể hấp thụ tinh hoa nhật nguyệt"
textfix["使用天书制造一个原型！"] = "Dùng Thiên Thư chế một nguyên mẫu!"
textfix["靠近人参果树制造一个原型"] = "Đến gần cây Nhân Sâm Quả chế một nguyên mẫu"
textfix["靠近人参果树制造一个原型！"] = "Đến gần cây Nhân Sâm Quả chế một nguyên mẫu!"

print("[Myth-Viet] Characters/Theme textfix loaded.")
