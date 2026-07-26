-- Canonical overrides using Vietnamese Fandom wiki names
-- Source: https://dont-starve-game.fandom.com/vi/wiki/ (Na_Tra, T%C3%B4n_Ng%E1%BB%99_Kh%C3%B4ng,
--   D%C6%B0%C6%A1ng_Ti%E1%BB%85n, B%E1%BA%A1ch_C%E1%BB%91t_Phu_Nh%C3%A2n, Tr%C6%B0_B%C3%A1t_Gi%E1%BB%9Bi, Ng%E1%BB%8Dc_Th%E1%BB%91)
--
-- These override any earlier translations. Load this AFTER phase_en2_strings.lua.

local STRINGS = GLOBAL.STRINGS
if not STRINGS then return end

local function set_str(path, value)
    local parts = {}
    for p in path:gmatch("[^%.]+") do parts[#parts+1] = p end
    if parts[1] == "STRINGS" then table.remove(parts, 1) end
    local tbl = GLOBAL.STRINGS
    for i = 1, #parts - 1 do
        if type(tbl[parts[i]]) ~= "table" then return end
        tbl = tbl[parts[i]]
    end
    tbl[parts[#parts]] = value
end

-- =============================================================================
-- NA TRA (Nezha) — Tam Thái Tử
-- Weapons: Hỏa Tiêm Thương (Fire-pointed Spear), Càn Khôn Quyện, Hỗn Thiên Lăng
-- =============================================================================

-- NZ.1: tagline/one-liner (wiki: "kỳ tài trời sinh, hàng yêu phục ma, không sợ cái gì")
set_str("STRINGS.MYTH_RENWUMIAOSHU.NZ.1",
    "Na Tra là Linh Châu Tử chuyển thế, kỳ tài trời sinh, hàng yêu phục ma, không sợ cái gì. Hào quang giảm tinh thần của quái vật lên Na Tra chỉ còn một nửa.")

-- NZ.2: body is lotus root
set_str("STRINGS.MYTH_RENWUMIAOSHU.NZ.2",
    "Thân Na Tra là ngó sen, không bị ẩm ướt ảnh hưởng tiêu cực. Khi độ ướt đủ cao sẽ từ từ hồi máu. Có thể chế tạo Hoa Sen và trồng sen trên hồ.")

-- NZ.3: impishness and divinity → Thần chức ngoan đồng
set_str("STRINGS.MYTH_RENWUMIAOSHU.NZ.3",
    "Tính cách nghịch ngợm mà lại mang thần vị. Na Tra giết quái vật sẽ tăng tinh thần, nhưng sát hại sinh linh vô tội sẽ giảm tinh thần.")

-- NZ.4: Hỏa Tiêm Thương (wiki: "Ba Đầu Sáu Tay" = Triple Attack)
set_str("STRINGS.MYTH_RENWUMIAOSHU.NZ.4",
    "Hỏa Tiêm Thương — vũ khí chỉ nhận Na Tra làm chủ. Gây sát thương gấp bội lên mục tiêu hệ hỏa. Chuột phải kích hoạt \"Ba Đầu Sáu Tay\": Na Tra giáng xuống từ trời gây sát thương diện rộng liên tiếp ba lần.")

-- NZ.5: Càn Khôn Quyện (ranged boomerang ring)
set_str("STRINGS.MYTH_RENWUMIAOSHU.NZ.5",
    "Càn Khôn Quyện — vũ khí riêng. Tấn công mục tiêu từ xa, dội liên hoàn giữa các mục tiêu (mỗi mục tiêu chỉ nhận sát thương một lần). Khi quay về cần dùng tay chụp lấy.")

-- NZ.6: Hỗn Thiên Lăng (red damask sash)
set_str("STRINGS.MYTH_RENWUMIAOSHU.NZ.6",
    "Hỗn Thiên Lăng — linh phù bảo vệ của Na Tra. Đỡ hoàn toàn 10 lần sát thương. Có thể dùng Hoa Sen để phục hồi độ bền. Ngoài ra còn tăng tốc độ di chuyển.")


-- =============================================================================
-- TÔN NGỘ KHÔNG (Monkey King) — Mỹ Hầu Vương
-- Weapon: Kim Cô Bổng
-- Skills: Lông Mao Cứu Mạng, Hoả Nhãn Kim Tinh, Nhất Trụ Kình Thiên, Chướng Nhãn Pháp
-- =============================================================================

-- MK.1: tagline
set_str("STRINGS.MYTH_RENWUMIAOSHU.MK.1",
    "Mỹ Hầu Vương. Tốc độ chạy nhanh hơn 10%. Thích trái cây, ghét đồ mặn.")

-- MK.2: Lông Mao Cứu Mạng (after 6 hits spawn 4 monkeys)
set_str("STRINGS.MYTH_RENWUMIAOSHU.MK.2",
    "Lông Mao Cứu Mạng: sau khi Ngộ Không đánh MỘT mục tiêu 6 lần, 4 con khỉ lông sẽ hiện ra, mỗi con gây 50 sát thương lên mục tiêu đó.")

-- MK.3: Trọng tội khó yên (burning trees → sanity drain)
set_str("STRINGS.MYTH_RENWUMIAOSHU.MK.3",
    "Hoa Quả Sơn quê hương bị thiêu rụi do lỗi của Ngộ Không. Cây cháy và cây cháy đen gợi nhớ thảm họa đó, làm giảm tinh thần.")

-- MK.4: Hoả Nhãn Kim Tinh (night vision, hungry)
set_str("STRINGS.MYTH_RENWUMIAOSHU.MK.4",
    "Hoả Nhãn Kim Tinh: nhấn phím H để mở thiên nhãn, nhìn được ban đêm, tiêu hao nhanh độ đói và tinh thần. Không dùng được trong bão cát hay phấn hoa.")

-- MK.5: Kim Cô Bổng as weapon + Phân thân
set_str("STRINGS.MYTH_RENWUMIAOSHU.MK.5",
    "Kim Cô Bổng — vũ khí riêng. Không bị boss đánh rơi khỏi tay. Các vũ khí khác có 50% tuột khỏi tay khi đánh. Chuột phải khi đang cầm để kích hoạt \"Chướng Nhãn Pháp\": Ngộ Không chớp đi, để lại một phân thân gây Sát Thương Chí Mạng.")

-- MK.6: Nhất Trụ Kình Thiên (summon cudgel from sky)
set_str("STRINGS.MYTH_RENWUMIAOSHU.MK.6",
    "Kỹ năng đặc biệt trong cột Thần Thoại: \"Nhất Trụ Kình Thiên\". Triệu Kim Cô Bổng từ trên trời giáng xuống hình thái gốc, gây 400 sát thương AOE lên sinh vật và công trình quanh đó, đốn hạ cây cối. Tốn 50 tinh thần.")

-- MK.7: Chướng Nhãn Pháp / disguise
set_str("STRINGS.MYTH_RENWUMIAOSHU.MK.7",
    "Chướng Nhãn Pháp — tinh thông biến hóa. Chuột phải vào bản thân khi tay trống để cải trang thành một ngôi đền, đánh lừa kẻ địch xung quanh.")


-- =============================================================================
-- DƯƠNG TIỄN (Yangjian) — Nhị Lang Thần
-- Weapon: Tam Tiêm Lưỡng Nhẫn Đao (NOT "Tam Tiêm Thương" — that was wrong!)
-- Companion: Hao Thiên Khuyển (Wheeze)
-- Skills: Khu Lôi Xiết Điện, Tam Nhãn Thần Mục (= Động thám hắc ám), Thần Ưng Tương Tùy
-- =============================================================================

-- YJ.1: Skyeye → Tam Nhãn Thần Mục / Động thám hắc ám
set_str("STRINGS.MYTH_RENWUMIAOSHU.YJ.1",
    "Thiên nhãn của Dương Tiễn động thám hắc ám, nhìn thấu bản chất của bóng tối, sức mạnh bóng tối không thể ảnh hưởng đến tâm trí. Ngài xem thường cột Ma Pháp.")

-- YJ.2: Hao Thiên Khuyển (Wheeze)
set_str("STRINGS.MYTH_RENWUMIAOSHU.YJ.2",
    "Hao Thiên Khuyển — chú chó trung thành. Tay không chuột phải vào bản thân để huýt sáo gọi, chuột phải vào Hao Thiên Khuyển để nó đứng chờ. Nó tự đi bắt thỏ và tìm vật mà Dương Tiễn cho ngửi. Cần cho ăn. Dương Tiễn giảm 50 tinh thần tối đa khi Hao Thiên Khuyển chết; có thể hồi sinh bằng Vòng Cổ Răng cùng vật phẩm hồi sinh.")

-- YJ.3: Khu Lôi Xiết Điện (right-click skill of Tam Tiêm Đao)
set_str("STRINGS.MYTH_RENWUMIAOSHU.YJ.3",
    "Khi Tam Tiêm Đao đã nạp sét, chuột phải để kích hoạt \"Khu Lôi Xiết Điện\": Dương Tiễn lao đến khu vực đã chọn, phóng sét vào mục tiêu xung quanh, gây ba đòn AOE diện rộng, khiến mọi mục tiêu nhiễm điện và nhận thêm 10% sát thương từ mọi nguồn.")

-- YJ.4: Tam Nhãn Thần Mục (night vision)
set_str("STRINGS.MYTH_RENWUMIAOSHU.YJ.4",
    "Tam Nhãn Thần Mục: nhấn phím H để mở thiên nhãn, nhìn được ban đêm, tiêu hao nhanh độ đói và tinh thần. Không dùng được trong bão cát hay phấn hoa.")

-- YJ.5: Thần Ưng Tương Tùy / Ưng Kích Trường Không (eagle transform)
set_str("STRINGS.MYTH_RENWUMIAOSHU.YJ.5",
    "Kỹ năng đặc biệt trong cột Thần Thoại: \"Thần Ưng Tương Tùy\". Biến thành chim ưng tung cánh dò thám khu vực quanh bản đồ, rồi chọn một điểm trong khu vực đó, hoặc một người chơi khác trong thế giới, để đáp xuống.")

-- YJ.6: Tam Tiêm Lưỡng Nhẫn Đao (electric weapon)
set_str("STRINGS.MYTH_RENWUMIAOSHU.YJ.6",
    "Tam Tiêm Lưỡng Nhẫn Đao — vũ khí điện riêng. Gây thêm sát thương lên mục tiêu ẩm ướt. Chuột phải để đao hấp thụ một tia sét. Sau khi đánh MỘT mục tiêu 6 lần, gọi sét từ trời đánh xuống mục tiêu, gây thêm sát thương.")


-- =============================================================================
-- BẠCH CỐT PHU NHÂN (White Bone) — Bạch Cốt Tinh
-- Items: Bạch Cốt Yêu Kính, Cốt Tiên, Cốt Nhận, Cốt Trượng, Âm Sâm Chi Tâm
-- =============================================================================

-- WB.1: shadow creatures drain hunger; revive via skeleton
set_str("STRINGS.MYTH_RENWUMIAOSHU.WB.1",
    "Là yêu quái, đòn của sinh vật bóng tối làm mất độ đói của Bạch Cốt thay vì máu. Vì không có da thịt thật, thuốc cao và tuyến không thể chữa, trừ túi máu. Sau khi chết, hồn ma yêu quái có tỷ lệ ám cao, chỉ có thể hồi sinh qua bộ xương.")

-- WB.2: witchcrafting tab — canonical item names
set_str("STRINGS.MYTH_RENWUMIAOSHU.WB.2",
    "Bạch Cốt có cột Bạch Cốt Yêu Thuật riêng. Có thể chế tạo Cốt Nhận, Cốt Tiên, Cốt Trượng, Bộ Xương, và Âm Sâm Chi Tâm. Ba thứ đầu có thể vá bằng Mảnh Xương.")

-- WB.3: Thích uống máu tươi
set_str("STRINGS.MYTH_RENWUMIAOSHU.WB.3",
    "Bạch Cốt có thể ăn nhiên liệu ác mộng và tim. Thích thịt sống nhất, các loại thịt khác ít hơn, rau củ ít nhất. Ăn Tim Bóng Tối làm cô hưng phấn, tăng sát thương và hồi tinh thần.")

-- WB.4: Thao túng xương cốt (Dissect / Corpsify)
set_str("STRINGS.MYTH_RENWUMIAOSHU.WB.4",
    "Thao túng xương cốt: Bạch Cốt dùng nhiên liệu ác mộng và độ đói để điều khiển xương cốt. Chuột trái để Mổ Xẻ xác chết, lấy thêm mảnh xương; chuột phải để Hóa Xác, biến chiến lợi phẩm thành nhiên liệu ác mộng tương đương.")

-- WB.5: Xuất quỷ nhập thần (fog)
set_str("STRINGS.MYTH_RENWUMIAOSHU.WB.5",
    "Xuất quỷ nhập thần: chuột phải vào bản thân khi tay không để triệu Sương Mù. Trong sương, tốc độ tăng, ẩn mình trước các sinh vật khác; chỉ kẻ bị cô tấn công mới phát hiện được.")

-- WB.6: Kẻ hai mặt (Bone / Maiden face)
set_str("STRINGS.MYTH_RENWUMIAOSHU.WB.6",
    "Kẻ hai mặt: Bạch Cốt có Mặt Xương và Mặt Thiếu Nữ. Mặt Xương kháng sát thương và đi nhanh hơn, nhưng chiếm ô thân và đầu. Mặt Thiếu Nữ khi bị tấn công sẽ được sinh vật hiền lành thương hại; tự vỡ khi đói hoặc chủ động tấn công.")


-- =============================================================================
-- TRƯ BÁT GIỚI (Pigsy) — Thiên Bồng Nguyên Soái
-- Weapon: Cửu Xỉ Đinh Ba
-- =============================================================================

-- PG.1: Đầu thai làm heo
set_str("STRINGS.MYTH_RENWUMIAOSHU.PG.1",
    "Bát Giới từng là Thiên Bồng Nguyên Soái, vì trêu ghẹo Hằng Nga mà bị giáng xuống phàm trần đầu thai làm heo. Chỉ có thể hồi sinh bằng cách ám vào nhà heo hoặc bùa hộ mệnh.")

-- PG.2: Chơi thân với heo
set_str("STRINGS.MYTH_RENWUMIAOSHU.PG.2",
    "Bát Giới là một pigman, họ hàng với các pigman khác. Họ không bao giờ từ chối đồ ăn của Bát Giới, còn ra tay giúp khi ngài gặp nguy. Vua Heo đôi khi cho Bát Giới thêm cục vàng.")

-- PG.3: Giỏi nông dốt công
set_str("STRINGS.MYTH_RENWUMIAOSHU.PG.3",
    "Bát Giới giỏi làm nông, tay không thu hái cây cỏ nông sản nhanh hơn, bón phân giúp tăng tinh thần. Nhưng chế đồ khá chậm.")

-- PG.4: Ham ăn mê ngủ
set_str("STRINGS.MYTH_RENWUMIAOSHU.PG.4",
    "Bát Giới không kén ăn, chỉ chê thịt. Khi đói thì yếu và chậm. Có thể dùng 3 cỏ cắt trong cột Sinh Tồn để làm ổ rơm dùng một lần.")

-- PG.5: Da thô thịt dày
set_str("STRINGS.MYTH_RENWUMIAOSHU.PG.5",
    "Ăn càng no da càng dày — kháng sát thương và kích thước đều tăng theo độ đói.")

-- PG.6: Nhìn mặt thấy ghét
set_str("STRINGS.MYTH_RENWUMIAOSHU.PG.6",
    "Bát Giới là đứa đáng ghét và lẻo mép nhất nhóm. Quái sẽ ưu tiên đánh Bát Giới trước, và không dễ dàng tha cho ngài.")

-- PG.7: Cửu Xỉ Đinh Ba
set_str("STRINGS.MYTH_RENWUMIAOSHU.PG.7",
    "Cửu Xỉ Đinh Ba — vũ khí riêng. Bát Giới dùng để làm nông: chuột phải vào mặt đất để xới đất gieo hạt. Tay cầm đinh ba chuột phải có thể đỡ toàn bộ sát thương trong một lúc, tiêu hao đói.")


-- =============================================================================
-- NGỌC THỐ (Yutu) — Ngọc Thố Tiên Tử
-- Items: Chày Nghiền Thuốc, Oánh Nguyệt Tỳ Bà
-- Skills: Giảo Thố Tam Quật, Đảo Dược Vi Chức, Linh Lung Tiên Thố, Nguyệt Nga Dẫn Lối, Trường Cư Nguyệt Cung
-- =============================================================================

-- YU.1: Giảo thố tam quật (underground walk)
set_str("STRINGS.MYTH_RENWUMIAOSHU.YU.1",
    "Giảo thố tam quật: có thể tạo hang thỏ, cũng có thể nhặt đồ trong hang. Chuột phải vào bản thân để độn thổ (có tầm nhìn ban đêm), tiêu hao nhiều đói và tinh thần, không thể bị tấn công hay bị target. Động đất, tử kim hồ lô, và đói sẽ buộc chui lên.")

-- YU.2: Đảo dược vi chức (Pounding, Chày Nghiền Thuốc)
set_str("STRINGS.MYTH_RENWUMIAOSHU.YU.2",
    "Đảo dược vi chức: Ngọc Thố có Chày Nghiền Thuốc riêng. Dùng \"Nghiền Thuốc\" ở cột Thần Thoại để nghiền tối đa 2 nguyên liệu. Sau 30s, bột thuốc rơi ra, gây hiệu quả lên người chơi xung quanh. Chỉ dùng được với món chay tươi hoặc nguyên liệu quý: trái cây tăng máu, rau tăng tinh thần.")

-- YU.3: Linh lung tiên thố (fairy hare / loves rabbits)
set_str("STRINGS.MYTH_RENWUMIAOSHU.YU.3",
    "Linh lung tiên thố: Ngọc Thố là thỏ tiên, ăn chay, không sợ hoàng hôn và ban đêm. Thỏ không chạy khỏi nàng, có thể trực tiếp bắt thỏ. Có thỏ trong hành trang giúp hồi tinh thần; thỏ chết gần đó làm nàng đau lòng. Rất thích món cà rốt.")

-- YU.4: Nguyệt Nga dẫn lối (moon moth)
set_str("STRINGS.MYTH_RENWUMIAOSHU.YU.4",
    "Nguyệt Nga dẫn lối: tốn một cánh hoa triệu hồi bướm Nguyệt Nga trong cột Thần Thoại. Nguyệt Nga sẽ bay về hướng Quảng Hàn Cung, không thể bắt được.")

-- YU.5: Trường cư Nguyệt Cung
set_str("STRINGS.MYTH_RENWUMIAOSHU.YU.5",
    "Trường cư Nguyệt Cung: không bị hiệu ứng nghịch đảo tinh thần trên mặt trăng. Tăng tốc độ khi đứng trên moon turf. Không bị giới hạn thời gian trong Quảng Hàn Cung, không bị Hằng Nga đuổi ban đêm. Tặng quà cho Hằng Nga sẽ được nhiều thiện cảm hơn, và có thêm bánh trung thu.")

-- =============================================================================
-- TÔN NGỘ KHÔNG — WIKI-FAITHFUL CORRECTIONS (second pass)
-- Source: https://dont-starve-game.fandom.com/vi/wiki/Tôn_Ngộ_Không
-- Biệt danh: Mỹ Hầu Vương / Tề Thiên Đại Thánh
-- Châm ngôn: "Ngạo nghễ cười nhìn trời, thần tiên đều vô dụng"
-- Chỉ số: Máu 175 / No 150 / Tinh thần 125
-- Vũ khí: Kim Cô Bổng (Như Ý Kim Cô Bổng, vốn là Định Hải Thần Châm, nặng 3 vạn 6 nghìn cân)
-- Vật phẩm khởi đầu: Kim Cô Bổng + 5 quả Bàn Đào
-- Món yêu thích: Bàn Đào Đại Hội
-- Skill của Kim Cô Bổng (chuột phải) = Thân Ngoại Thân Pháp (KHÔNG phải Chướng Nhãn Pháp)
-- Chướng Nhãn Pháp = biến thành Miếu Thổ Địa (MK.7)
-- =============================================================================

-- MK.1: Hầu vương tại thế — tagline từ wiki
set_str("STRINGS.MYTH_RENWUMIAOSHU.MK.1",
    "Tề Thiên Đại Thánh Mỹ Hầu Vương, thân thủ nhanh nhẹn — chạy nhanh hơn 10% so với các nhân vật khác. Ghét ẩm ướt (bị ướt giảm tinh thần). Rất thích ăn hoa quả và các món chay; người xuất gia không tham đồ mặn (ăn thịt nhận lợi ích ít hơn).")

-- MK.2: Lông Mao Cứu Mạng — wiki mô tả: 4 phân thân, mỗi phân thân gây sát thương một lần
set_str("STRINGS.MYTH_RENWUMIAOSHU.MK.2",
    "Lông Mao Cứu Mạng: khi Ngộ Không tấn công cùng một mục tiêu 6 lần, sẽ rút lông biến ra 4 phân thân. Mỗi phân thân gây sát thương một lần cho mục tiêu đó.")

-- MK.3: Trọng Tội Khó Yên
set_str("STRINGS.MYTH_RENWUMIAOSHU.MK.3",
    "Trọng tội khó yên: năm xưa Ngộ Không đại náo thiên cung, thiên đình phóng hỏa đốt núi khiến Hoa Quả Sơn sinh linh đồ thán. Từ đó mỗi khi đứng gần cây cháy hay cây cháy đen, ngài cảm thấy bất nhẫn và tinh thần giảm mạnh.")

-- MK.4: Hoả Nhãn Kim Tinh
set_str("STRINGS.MYTH_RENWUMIAOSHU.MK.4",
    "Hoả Nhãn Kim Tinh: nhấn phím H (hoặc biểu tượng mặt Ngộ Không ở góc trên phải) để bật, nhìn được ban đêm và xua tan sương mù. Duy trì trạng thái tiêu hao nhanh độ đói và tinh thần. Không thể dùng trong bão cát hay phấn hoa.")

-- MK.5: Kim Cô Bổng + Thân Ngoại Thân Pháp (FIX: wiki gọi skill này là Thân Ngoại Thân Pháp, KHÔNG phải Chướng Nhãn Pháp)
set_str("STRINGS.MYTH_RENWUMIAOSHU.MK.5",
    "Như Ý Kim Cô Bổng — nặng 3 vạn 6 nghìn cân, vũ khí duy nhất thuận tay với Tôn Ngộ Không; không bị boss đánh rơi khỏi tay. Mọi vũ khí khác có 50% tỷ lệ tuột khỏi tay khi tấn công. Chuột phải khi đang cầm để thi triển Thân Ngoại Thân Pháp: tiêu hao độ đói, dịch chuyển tức thời đến vị trí chỉ định và để lại một phân thân thu hút kẻ địch. Phân thân có thể tấn công và tồn tại trong một thời gian ngắn.")

-- MK.6: Nhất Trụ Kình Thiên — wiki mô tả Kim Cô Bổng vốn là Định Hải Thần Châm
set_str("STRINGS.MYTH_RENWUMIAOSHU.MK.6",
    "Nhất Trụ Kình Thiên — kỹ năng đặc biệt trong cột Thần Thoại. Như Ý Kim Cô Bổng vốn là Định Hải Thần Châm; khi không cầm trên tay, Ngộ Không thi triển kỹ năng này khiến Kim Cô Bổng phóng to ra và giáng xuống từ trời, gây 400 sát thương AOE lên sinh vật và công trình xung quanh, đốn hạ cây cối. Tốn 50 tinh thần.")

-- MK.7: Chướng Nhãn Pháp — biến thành Miếu Thổ Địa
set_str("STRINGS.MYTH_RENWUMIAOSHU.MK.7",
    "Chướng Nhãn Pháp: tay không bấm chuột phải vào bản thân để Ngộ Không thi triển chướng nhãn pháp, biến thành Miếu Thổ Địa nhằm tránh kẻ địch ở gần. Phải im lặng, chớ gây tiếng động.")


print("[Myth-Viet] wiki_canonical overrides loaded.")
