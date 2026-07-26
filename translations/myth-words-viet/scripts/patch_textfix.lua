-- patch_textfix.lua
-- Textfix cho Myth Words Patch (腌笃鲜)
-- Dùng Hán-Việt để phù hợp bối cảnh thần thoại TQ và tránh tràn UI

local _G = GLOBAL
GLOBAL.setfenv(1, GLOBAL)

local textfix = rawget(_G, "myth_viet_textfix")
if not textfix then return end

-- =================================================================
-- Item names & descriptions (STRINGS paths)
-- =================================================================
textfix["蒲团"] = "Bồ Đoàn"
textfix["喜蛛天罗衣"] = "Thiên La Y"
textfix["寸心精魄"] = "Thốn Tâm Tinh Phách"
textfix["用于打坐推演周天。"] = "Dùng để tĩnh tọa suy diễn chu thiên."
textfix["结千丝为瑞气，织天罗御万邪。"] = "Kết ngàn tơ thành thụy khí, dệt thiên la ngự vạn tà."
textfix["凝结天地造化与劫运的灵韵之核。"] = "Hạt nhân linh vận ngưng kết từ tạo hóa và kiếp vận."

textfix["方寸山中藏妙理，此中蒲团可参禅。"] = "Phương Thốn Sơn ẩn diệu lý, bồ đoàn này có thể tham thiền."
textfix["隐隐有流光游走，这件法衣仿佛有生命般在自行织补。"] = "Ẩn hiện lưu quang, pháp y như có sinh mệnh tự vá."
textfix["好纯粹的灵蕴！不知是哪里苦修来的造化"] = "Linh uẩn thuần khiết! Không biết khổ tu nơi nào mà được."

textfix["俺老孙当年在灵台方寸山，也坐过这玩意儿！"] = "Năm xưa lão Tôn cũng ngồi cái này ở Linh Đài Phương Thốn Sơn!"
textfix["纵然肉身成圣，灵台方寸间的劫运，仍需静坐方能堪破。"] = "Dù nhục thân thành thánh, kiếp vận linh đài vẫn cần tĩnh tọa mới thấu."
textfix["小爷我灵台天生清明，在这干坐着还不如去降妖除魔。"] = "Tiểu gia linh đài thanh minh, ngồi không chẳng bằng đi trừ ma."
textfix["修什么灵台寸心，坐在这上面还不如躺着舒坦。"] = "Tu gì linh đài, ngồi đây chẳng bằng nằm cho thoải mái."
textfix["褪去一身画皮，正适合凝练本座的玄阴骨气。"] = "Cởi lớp da giả, chính hợp ngưng luyện huyền âm cốt khí."
textfix["天地劫数不过是盘丝网的猎物。且容我在此凝结几缕寸心。"] = "Kiếp số chỉ là mồi trên mạng tơ. Hãy để ta ngưng kết thốn tâm."
textfix["寸心精魄千丝结。本座的这身天罗地网，岂是凡间的刀兵能破的？"] = "Thốn tâm ngàn tơ kết. Thiên la địa võng đâu thể bị phàm binh phá?"
textfix["月华如水，照见灵台。坐在此处，倒也让人心静。"] = "Nguyệt hoa như nước, soi rõ linh đài. Ngồi đây tâm tĩnh."
textfix["阴阳交界之处，可悟生死之理。"] = "Nơi giao giới âm dương, ngộ lý sinh tử."
textfix["上仙可是要寻那海上的灵台方寸山？小老儿虽然只管这一亩三分地，但那仙山灵气冲天，我倒是知道方位的。"] = "Thượng tiên tìm Linh Đài Phương Thốn Sơn ngoài biển? Lão già biết phương hướng."

-- =================================================================
-- Upgrade system (xydztz_upgrade.lua)
-- =================================================================
textfix["淬炼"] = "Tôi Luyện"
textfix["此能力已臻化境。"] = "Năng lực đã đạt cảnh giới tối cao."
textfix["此宝物已至臻境，完美无瑕。"] = "Bảo vật đã đạt cực phẩm."
textfix["宝物灵韵已修复！"] = "Linh vận bảo vật đã tu phục!"
textfix["位面伤害"] = "Sát Thương Vị Diện"
textfix["位面防御"] = "Phòng Ngự Vị Diện"

-- =================================================================
-- Actions
-- =================================================================
textfix["打坐"] = "Tĩnh Tọa"
textfix[": 打坐"] = ": Tĩnh Tọa"
textfix["： 打坐"] = "： Tĩnh Tọa"
textfix["罗袖暗锋"] = "La Tụ Ám Phong"
textfix["叨扰土地"] = "Hỏi Thổ Địa"

-- =================================================================
-- UI & durations
-- =================================================================
textfix["永久"] = "Vĩnh viễn"
textfix["剩余0秒"] = "Còn 0 giây"
textfix["腌笃鲜神话篇"] = "Myth Patch"

-- Infantree status
textfix["昨日: 环境+照顾 ✓"] = "Hôm qua: Môi trường+Chăm sóc ✓"
textfix["昨日: 环境✓ 照顾✗"] = "Hôm qua: MT✓ CS✗"
textfix["昨日: 环境✗ 照顾✓"] = "Hôm qua: MT✗ CS✓"
textfix["昨日: 环境✗ 照顾✗"] = "Hôm qua: MT✗ CS✗"
textfix["需要: 每日土壤环境 + 被照顾"] = "Cần: Môi trường đất + Chăm sóc"
textfix["需要: 添加更多精华"] = "Cần: Thêm tinh hoa"
textfix["★ 成长条件已满足！"] = "★ Đủ điều kiện sinh trưởng!"
textfix["已收集: "] = "Đã thu: "
textfix["天"] = "ngày"

-- =================================================================
-- Combat & skills
-- =================================================================
textfix["炉火旺盛，老君来了都说好"] = "Lửa lò hừng hực, Lão Quân cũng khen!"
textfix["雷动九天！"] = "Sấm rung chín tầng trời!"
textfix["这点诅咒也想困住俺老孙？"] = "Chút nguyền rủa cũng muốn giam lão Tôn?"
textfix["区区障眼法，散！"] = "Chướng nhãn pháp, tan đi!"
textfix["俺老猪乃天蓬元帅，这点妖术算个甚！"] = "Lão Trư là Thiên Bồng Nguyên Soái, yêu thuật này là gì!"
textfix["吾乃莲花化身，邪祟不侵！"] = "Ta là hóa thân hoa sen, tà ma bất xâm!"
textfix["退退退，才不要变丑猴子！"] = "Lui! Không biến thành khỉ xấu xí!"
textfix["什么诅咒，我就是诅咒~"] = "Nguyền rủa? Ta chính là nguyền rủa~"
textfix["蚍蜉撼树，不自量力。"] = "Kiến lay cây, không tự lượng sức."
textfix["生死簿上无此劫，退下！"] = "Sổ sinh tử không có kiếp này, lui!"
textfix["Oi，你没有自己的坐骑吗？"] = "Oi, ngươi không có vật cưỡi riêng sao?"
textfix["休要贪得无厌"] = "Chớ tham lam vô độ"
textfix["谷仓空间已无限！"] = "Kho thóc vô hạn!"
textfix["功夫不负有心人！"] = "Công phu không phụ người có tâm!"
textfix["神通变化，元辰暂隐"] = "Thần thông biến hóa, Nguyên Thần tạm ẩn"
textfix["真身归复，元辰重注"] = "Chân thân phục hồi, Nguyên Thần tái chú"
textfix["火元煞气已臻化境！(杀意已满)"] = "Hỏa Nguyên sát khí cực phẩm! (Sát ý đầy)"
textfix["火元护体已臻化境！(幽冥已现)"] = "Hỏa Nguyên hộ thể cực phẩm! (U Minh hiện)"

-- =================================================================
-- Boss names
-- =================================================================
textfix["黑风大王"] = "Hắc Phong Đại Vương"
textfix["犀牛三弟"] = "Tê Giác Tam Đệ"
textfix["聚宝金蟾"] = "Tụ Bảo Kim Thiềm"

-- =================================================================
-- Zodiac skill speech
-- =================================================================
textfix["好极好极！！"] = "Hay quá hay quá!!"
textfix["妙哉妙哉！"] = "Diệu thay!"
textfix["被发现啦！偷天惩罚了！"] = "Bị phát hiện! Phạt Thâu Thiên!"
textfix["气息紊乱...无法看破！"] = "Khí tức rối loạn..."
textfix["未持兵刃，谈何绝影！"] = "Chưa cầm binh khí, nói gì Tuyệt Ảnh!"
textfix["绝影已上膛！右键发起冲锋！"] = "Tuyệt Ảnh sẵn sàng! Chuột phải xung phong!"

-- =================================================================
-- Options menu
-- =================================================================
textfix["重置设置"] = "Đặt lại"
textfix["是否恢复腌笃鲜本地按键的默认设置？"] = "Khôi phục phím mặc định Patch?"
textfix["腌笃鲜"] = "Myth Patch"
textfix["腌笃鲜本地自定义设置"] = "Cài đặt Myth Patch"

-- =================================================================
-- Keybinds
-- =================================================================
textfix["酉鸡看破"] = "Dậu Kê: Nhìn Thấu"
textfix["绑定酉鸡【看破】快捷键。仅影响本地玩家。"] = "Gán phím Dậu Kê [Nhìn Thấu]."
textfix["午马绝影"] = "Ngọ Mã: Tuyệt Ảnh"
textfix["绑定午马【绝影】快捷键。仅影响本地玩家。"] = "Gán phím Ngọ Mã [Tuyệt Ảnh]."
textfix["神话UI复位"] = "Reset UI Thần Thoại"
textfix["绑定神话相关UI界面的复位快捷键。仅影响本地玩家。"] = "Gán phím reset UI Thần Thoại."

-- =================================================================
-- Myth Book (xydztz_fix_book.lua)
-- =================================================================
textfix["位面伤害火元淬炼材料"] = "Nguyên liệu tôi luyện Sát Thương Vị Diện"
textfix["位面防御火元淬炼材料"] = "Nguyên liệu tôi luyện Phòng Ngự Vị Diện"
textfix["材料"] = "Nguyên liệu"
textfix["耐久"] = "Độ bền"
textfix["建筑"] = "Kiến trúc"
textfix["装备"] = "Trang bị"
textfix["凝结寸心有概率获得"] = "Ngưng Thốn Tâm có xác suất nhận"
textfix["获取途径"] = "Cách nhận"
textfix["凝结天地造化与劫运的灵韵之核"] = "Hạt nhân linh vận từ tạo hóa và kiếp vận"
textfix["结千丝为瑞气，织天罗御万邪"] = "Kết ngàn tơ thành thụy khí, dệt thiên la ngự vạn tà"
textfix["一方蒲团，静坐凝心，\n感悟天地灵气。"] = "Bồ đoàn nhỏ, tĩnh tọa ngưng tâm,\ncảm ngộ linh khí."

-- =================================================================
-- Compat labels
-- =================================================================
textfix["神话主题"] = "Thần Thoại Chủ Đề"
textfix["神话人物"] = "Thần Thoại Nhân Vật"

-- =================================================================
-- Cultivation Screen (màn hình tu luyện)
-- =================================================================
textfix["◈ 历尽千劫凝寸心，灵台方寸度光阴。\n◈ 双鱼拨转乾坤理，一点空明破迷津。"] = "◈ Ngàn kiếp ngưng tâm, linh đài độ thời gian.\n◈ Song ngư chuyển càn khôn, một điểm phá mê."
textfix["元辰归位"] = "Nguyên Thần Quy Vị"
textfix["重楼应月"] = "Trùng Lâu Ứng Nguyệt"
textfix["无"] = "Không"
textfix["已感知节点，请点击阳鱼倾注寸心"] = "Đã cảm nhận nút, nhấn Dương Ngư để rót Thốn Tâm"
textfix["◈ 阳鱼点落寸心倾，十二元辰列宿明。\n◈ 外镇灵枢周天度，本命星君显真形。"] = "◈ Dương ngư rơi, thốn tâm nghiêng, 12 nguyên thần sáng.\n◈ Bản mệnh tinh quân hiện."
textfix["◈ 阳鱼游衍寸心开，十二重楼应月来。\n◈ 内理阴阳推造化，天时暗转筑灵台。"] = "◈ Dương ngư du, thốn tâm khai, 12 trùng lâu ứng nguyệt.\n◈ Âm dương trúc linh đài."
textfix["内景"] = "Nội Cảnh"
textfix["神识归一，方感天道"] = "Thần thức quy nhất, cảm thiên đạo"
textfix["凝神静气，调理虚实。触碰星轨，推演天机。"] = "Ngưng thần tĩnh khí, chạm quỹ đạo, suy diễn thiên cơ."
textfix["散去修为，寸心重续"] = "Tán tu vi, tái ngưng Thốn Tâm"
textfix["核验法器中..."] = "Kiểm tra pháp khí..."
textfix["凝结寸心"] = "Ngưng Thốn Tâm"
textfix["倾注寸心"] = "Rót Thốn Tâm"
textfix["寸心：--"] = "Thốn Tâm: --"
textfix["寸心: --"] = "Thốn Tâm: --"
textfix["劫运：--"] = "Kiếp Vận: --"
textfix["劫运: --"] = "Kiếp Vận: --"
textfix["感知中..."] = "Đang cảm nhận..."
textfix["极阴"] = "Cực Âm"
textfix["极阳"] = "Cực Dương"
textfix["推演中"] = "Đang suy diễn"
textfix["天道结算中..."] = "Thiên đạo kết toán..."
textfix["请先在左侧选择一个节点"] = "Chọn nút ở bên trái trước"
textfix["正在沟通天地..."] = "Đang giao tiếp trời đất..."

-- Time display
textfix["时辰: 感知中"] = "Thời Thần: Cảm nhận"

-- =================================================================
-- Cultivation manager feedback
-- =================================================================
textfix["劫运不足，暂无顿悟"] = "Kiếp vận không đủ"
textfix["灵物未显，稍候再试"] = "Linh vật chưa hiện"
textfix["旧缘已结，未得精魄"] = "Cựu duyên đã kết"
textfix["阴鱼化生，寸心凝结"] = "Âm ngư hóa sinh, Thốn Tâm ngưng kết"
textfix["真气流失"] = "Chân khí mất"
textfix["寸心不足"] = "Thốn Tâm không đủ"
textfix["天道无此星位"] = "Thiên đạo không có tinh vị"
textfix["元辰已归位"] = "Nguyên Thần đã quy vị"
textfix["重楼已映月"] = "Trùng Lâu ứng nguyệt"
textfix["内景错乱"] = "Nội cảnh rối loạn"
textfix["急急如律令！"] = "Cấp cấp như luật lệnh!"

-- =================================================================
-- Jieyun (kiếp vận) — add with ◈ prefix variant (game uses ◈ inline)
-- =================================================================
local function add_jieyun(name_cn, name_vn, motto_cn, motto_vn)
    textfix[name_cn] = name_vn
    textfix[motto_cn] = motto_vn
    textfix["◈" .. motto_cn] = "◈" .. motto_vn
    textfix["◈ " .. motto_cn] = "◈ " .. motto_vn
end

add_jieyun("寻仙问道", "Tầm Tiên Vấn Đạo", "凡胎肉眼寻真境，紫气东来踏仙山。", "Phàm thai tìm chân cảnh, tử khí đạp tiên sơn.")
add_jieyun("炉火纯青", "Lò Lửa Thuần Thanh", "天地为鼎夺造化，三昧初燃识乾坤。", "Trời đất làm đỉnh, tam muội thức càn khôn.")
add_jieyun("腾云初辟", "Đằng Vân Sơ Tịch", "凡人仰首望星河，仙家足下踏青云。", "Phàm nhân ngắm ngân hà, tiên gia đạp thanh vân.")
add_jieyun("土地结缘", "Thổ Địa Kết Duyên", "三尺微命通神明，一炷清香保平安。", "Tam xích thông thần minh, thanh hương bảo bình an.")
add_jieyun("五行避厄", "Ngũ Hành Tị Ách", "丹石护身避百厄，严寒酷暑定不侵。", "Đan thạch tránh bách ách, hàn thử không xâm.")
add_jieyun("点石成金", "Điểm Thạch Thành Kim", "摇钱树下无贫客，满地金叶耀灵光。", "Cây tiền không khách nghèo, lá vàng chiếu linh quang.")
add_jieyun("乾坤一袖", "Càn Khôn Nhất Tụ", "紫金葫芦藏日月，袖里乾坤纳万物。", "Hồ lô tàng nhật nguyệt, tụ áo nạp vạn vật.")
add_jieyun("天机指路", "Thiên Cơ Chỉ Lộ", "残图一卷掩宝光，按图索骥寻奇珍。", "Tàn đồ che bảo quang, theo đồ tìm kỳ trân.")
add_jieyun("兜率仙缘", "Đâu Suất Tiên Duyên", "不辞金银求仙药，便作蓬莱座上宾。", "Không tiếc vàng cầu tiên dược, làm khách Bồng Lai.")
add_jieyun("息焰狂风", "Tức Diễm Cuồng Phong", "扇动阴风灭炎火，一扫阴霾定乾坤。", "Quạt âm phong diệt viêm hỏa, quét âm mai định càn khôn.")
add_jieyun("移山填海", "Di Sơn Điền Hải", "力拔山兮气盖世，背负青天挪乾坤。", "Sức nhổ núi trùm đời, lưng đội trời dời càn khôn.")
add_jieyun("荆棘反戈", "Kinh Cức Phản Qua", "尖刺披身化坚甲，以彼之道还彼身。", "Gai phủ thân hóa giáp, lấy đạo người trả người.")
add_jieyun("净瓶甘露", "Tịnh Bình Cam Lộ", "一滴甘露洗凡尘，润养万物百花开。", "Cam lộ rửa phàm trần, tưới vạn vật trăm hoa.")
add_jieyun("炉火重炼", "Lò Lửa Trùng Luyện", "千锤百炼化神铁，神兵藏锋待重铸。", "Ngàn tôi luyện hóa thần thiết, thần binh đợi tái chú.")
add_jieyun("琼浆玉液", "Quỳnh Tương Ngọc Dịch", "瑶池仙酿凡间降，一醉方休解千愁。", "Tiên tửu Dao Trì giáng phàm, say giải ngàn sầu.")
add_jieyun("金击扣灵", "Kim Kích Khấu Linh", "遇金而落遇木枯，须凭金击扣神灵。", "Gặp kim thì rụng, phải kim kích khấu thần linh.")
add_jieyun("地仙圣果", "Địa Tiên Thánh Quả", "圣果一枚吞入腹，长生不老寿齐天。", "Thánh quả nuốt bụng, trường sinh thọ bằng trời.")
add_jieyun("蟠桃仙种", "Bàn Đào Tiên Chủng", "九天瑶池借仙种，蟠桃凡尘傲雪霜。", "Dao Trì mượn tiên chủng, bàn đào ngạo tuyết sương.")
add_jieyun("竹影婆娑", "Trúc Ảnh Bà Sa", "青竹小镇拔地起，竹影婆娑觅知音。", "Thanh trúc vượt đất, trúc ảnh tìm tri âm.")
add_jieyun("泥足深陷", "Nê Túc Thâm Hãm", "采得翠叶作头冠，出水芙蓉不染尘。", "Hái lá làm mũ, phù dung không nhuốm bụi.")
add_jieyun("芭蕉生风", "Ba Tiêu Sinh Phong", "一叶青葱障日明，自生清风扫阴霾。", "Lá xanh che nhật, tự sinh thanh phong quét âm mai.")
add_jieyun("凝脂玉露", "Ngưng Chi Ngọc Lộ", "慢火细熬去浊气，入口即化生阳春。", "Lửa nhỏ trừ trọc khí, vào miệng tan sinh dương xuân.")
add_jieyun("覆海鲸吞", "Phúc Hải Kình Thôn", "龙宫奇珍聚一鼎，豪气干云吞四海。", "Long Cung tụ đỉnh, hào khí nuốt bốn bể.")
add_jieyun("灵瓠长成", "Linh Hồ Trưởng Thành", "辛勤灌溉待藤老，抱得灵瓠夺天工。", "Cần cù tưới tắm đợi dây già, ôm linh hồ đoạt thiên công.")
add_jieyun("黑风截蜜", "Hắc Phong Chặn Mật", "贪嘴黑熊夜摸营，护得蜜罐镇妖风。", "Gấu tham ăn đêm mò, giữ bình mật trấn yêu phong.")
add_jieyun("岁末除凶", "Tuế Mạt Trừ Hung", "爆竹声中一岁除，金铃摇响镇年兽。", "Tiếng pháo qua năm, chuông vàng trấn Niên Thú.")
add_jieyun("犀照深渊", "Tê Chiếu Thâm Uyên", "灵犀一点通深渊，燃角引魅斩妖群。", "Linh tê thông thâm uyên, đốt sừng chém yêu quần.")
add_jieyun("子圭苏醒", "Tử Khuê Tô Tỉnh", "远古迷踪藏深渊，子圭青金铸战神。", "Viễn cổ ẩn thâm uyên, tử khuê đúc chiến thần.")
add_jieyun("函谷青牛", "Hàm Cốc Thanh Ngưu", "青牛出关迎紫气，逍遥天地任平生。", "Thanh ngưu xuất quan, tiêu dao bình sinh.")
add_jieyun("仓廪充实", "Thương Lẫm Sung Thực", "仙家自有储粮策，五谷丰登天赐福。", "Tiên gia có kế trữ lương, ngũ cốc thiên ban phúc.")
add_jieyun("饮水思源", "Ẩm Thủy Tư Nguyên", "掘地九仞寻玉液，一口甘泉润八荒。", "Đào đất tìm ngọc dịch, cam tuyền nhuận bát hoang.")
add_jieyun("广寒华灯", "Quảng Hàn Hoa Đăng", "琉璃玉盏照广寒，华灯初上破夜阑。", "Ngọc chén chiếu Quảng Hàn, hoa đăng phá đêm tàn.")
add_jieyun("钟鸣鼎食", "Chung Minh Đỉnh Thực", "八珍玉食陈高案，仙乐风飘落九天。", "Bát trân ngọc thực, tiên nhạc rơi chín tầng.")
add_jieyun("偷得浮生", "Thâu Đắc Phù Sinh", "偷得浮生半日闲，且坐清风明月间。", "Trộm phù sinh nửa ngày, ngồi giữa gió trăng.")
add_jieyun("金蝉聚宝", "Kim Thiền Tụ Bảo", "天降金雨伴雷鸣，聚宝盆中藏玄机。", "Trời mưa vàng, tụ bảo tàng huyền cơ.")

-- =================================================================
-- 12 Zodiac
-- =================================================================
textfix["子鼠"] = "Tý Thử"
textfix["丑牛"] = "Sửu Ngưu"
textfix["寅虎"] = "Dần Hổ"
textfix["卯兔"] = "Mão Thỏ"
textfix["辰龙"] = "Thìn Long"
textfix["巳蛇"] = "Tỵ Xà"
textfix["午马"] = "Ngọ Mã"
textfix["未羊"] = "Mùi Dương"
textfix["申猴"] = "Thân Hầu"
textfix["酉鸡"] = "Dậu Kê"
textfix["戌狗"] = "Tuất Cẩu"
textfix["亥猪"] = "Hợi Trư"

textfix["五鬼搬运"] = "Ngũ Quỷ Bàn Vận"
textfix["迟钝痛觉"] = "Trì Độn Thống Giác"
textfix["猛虎撕裂"] = "Mãnh Hổ Tư Liệt"
textfix["狡兔脱身"] = "Giảo Thỏ Thoát Thân"
textfix["鳞甲偏转"] = "Lân Giáp Thiên Chuyển"
textfix["蛇瞳双生"] = "Xà Đồng Song Sinh"
textfix["绝影突袭"] = "Tuyệt Ảnh Đột Kích"
textfix["棉晶护体"] = "Miên Tinh Hộ Thể"
textfix["借假修真"] = "Tá Giả Tu Chân"
textfix["金鸡破晓"] = "Kim Kê Phá Hiểu"
textfix["死士狂吠"] = "Tử Sĩ Cuồng Phệ"
textfix["贪婪之噬"] = "Tham Lam Chi Phệ"

textfix["多倍资源"] = "Nhân bội tài nguyên"
textfix["硬核减伤"] = "Giảm thương cứng"
textfix["极致爆发"] = "Bùng nổ cực hạn"
textfix["保命护盾"] = "Khiên bảo mệnh"
textfix["控场能力"] = "Khống chế"
textfix["交互反馈"] = "Phản hồi tương tác"

-- Earthly branches
textfix["子"] = "Tý"
textfix["丑"] = "Sửu"
textfix["寅"] = "Dần"
textfix["卯"] = "Mão"
textfix["辰"] = "Thìn"
textfix["巳"] = "Tỵ"
textfix["午"] = "Ngọ"
textfix["未"] = "Mùi"
textfix["申"] = "Thân"
textfix["酉"] = "Dậu"
textfix["戌"] = "Tuất"
textfix["亥"] = "Hợi"

textfix["冬至子夜"] = "Đông Chí Tý Dạ"
textfix["小寒黎明"] = "Tiểu Hàn Lê Minh"
textfix["立春平旦"] = "Lập Xuân Bình Đán"
textfix["惊蛰日出"] = "Kinh Trập Nhật Xuất"
textfix["清明食时"] = "Thanh Minh Thực Thời"
textfix["立夏隅中"] = "Lập Hạ Ngung Trung"
textfix["夏至日中"] = "Hạ Chí Nhật Trung"
textfix["小暑日昳"] = "Tiểu Thử Nhật Diệt"
textfix["立秋晡时"] = "Lập Thu Bô Thời"
textfix["白露日入"] = "Bạch Lộ Nhật Nhập"
textfix["寒露黄昏"] = "Hàn Lộ Hoàng Hôn"
textfix["立冬人定"] = "Lập Đông Nhân Định"

-- Earthly branch descriptions (shortened)
textfix["冬至阳生，万物生机。\n子水旺相，水行共振拔群。"] = "Đông chí dương sinh.\nTý thủy vượng, thủy hành cộng chấn."
textfix["金水寒极，土坚如铁。\n丑土旺相，承伤御守之极。"] = "Kim thủy hàn cực.\nSửu thổ vượng, ngự thủ cực."
textfix["三阳开泰，猛虎下山。\n寅木旺相，木行杀伐之始。"] = "Tam dương khai thái.\nDần mộc vượng, sát phạt khởi."
textfix["雷发东隅，万物复苏。\n卯木旺相，生机遁走之源。"] = "Vạn vật phục tô.\nMão mộc vượng, sinh cơ độn tẩu."
textfix["龙潜深渊，水土交融。\n辰土旺相，万物得土而固。"] = "Long tiềm thâm uyên.\nThìn thổ vượng, vạn vật cố."
textfix["火土始盛，六阳之极。\n巳火旺相，毒炎极盛爆发。"] = "Lục dương chi cực.\nTỵ hỏa vượng, độc viêm bộc phát."
textfix["夏至阴生，烈火烹油。\n午火旺相，逐击杀之天时。"] = "Hạ chí âm sinh.\nNgọ hỏa vượng, trục kích sát."
textfix["木气入地，燥土极盛。\n未土旺相，晶体固若金汤。"] = "Táo thổ cực thịnh.\nMùi thổ vượng, tinh thể kiên cố."
textfix["金水相生，肃杀始起。\n申金旺相，修真玄妙时刻。"] = "Kim thủy tương sinh.\nThân kim vượng, tu chân huyền diệu."
textfix["金气登峰，锋芒毕露。\n酉金旺相，兵刃交锋反制。"] = "Phong mang tất lộ.\nDậu kim vượng, binh nhận phản chế."
textfix["火气入地，秋尽冬来。\n戌土旺相，死士驻守防线。"] = "Thu tận đông lai.\nTuất thổ vượng, tử sĩ phòng tuyến."
textfix["水归大海，六阴之极。\n亥水旺相，万物归藏至极。"] = "Lục âm chi cực.\nHợi thủy vượng, vạn vật quy tàng."

-- =================================================================
-- Misc
-- =================================================================
textfix["芜湖，你的神话UI回家了"] = "Wuhu, UI Thần Thoại về nhà rồi"

print("[Myth-Viet] Patch textfix loaded.")
