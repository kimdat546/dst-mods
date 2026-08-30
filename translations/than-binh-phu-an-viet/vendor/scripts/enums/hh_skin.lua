local HH_UTILS = require("utils/hh_utils")

local hh_skin_stone_heart_xml = "images/hh_icon/hh_skin_stone.xml"
local hh_skin_cat_box_xml = "images/hh_icon/hh_skin_cat_box.xml"
local hh_skin_hat_star_xml = "images/hh_icon/hh_skin_hat_star.xml"
local hh_skin_suit_build_xml = "images/hh_icon/hh_skin_suit_build.xml"
local hh_items_xml = "images/hh_icon/hh_items.xml"
local base_painter = "煎蛋牌画画小助手"
local function changeSkinImageAndXml(inst, skin_id, xml)
    if HH_UTILS:HasComponents(inst, "inventoryitem")
            and HH_UTILS:IsHHType(skin_id, "string")
            and HH_UTILS:IsHHType(xml, "string")
    then
        inst["g_item_skin"] = skin_id
        inst["components"]["inventoryitem"]["atlasname"] = xml
        inst["components"]["inventoryitem"]:ChangeImageName(skin_id)
    end
end
local function hatStarEquip(_inst, owner, file_scml, file_path)
    HH_UTILS:HHRemoveFx(_inst, "hh_hat_front_fx")
    HH_UTILS:HHRemoveFx(_inst, "hh_hat_back_fx")
    _inst["hh_hat_front_fx"] = SpawnPrefab("hh_hat_star_fx")
    if _inst["hh_hat_front_fx"] and _inst["hh_hat_front_fx"]["OnActivated"] then
        _inst["hh_hat_front_fx"]:OnActivated(owner, true)
        _inst["hh_hat_front_fx"]["AnimState"]:OverrideSymbol("p4_piece", tostring(file_scml), tostring(file_path))
    end
    _inst["hh_hat_back_fx"] = SpawnPrefab("hh_hat_star_fx")
    if _inst["hh_hat_back_fx"] and _inst["hh_hat_back_fx"]["OnActivated"] then
        _inst["hh_hat_back_fx"]:OnActivated(owner, false)
        _inst["hh_hat_back_fx"]["AnimState"]:OverrideSymbol("p4_piece", tostring(file_scml), tostring(file_path))
    end
end
local function hatStarUnEquip(_inst, owner, file_scml, file_path)
    HH_UTILS:HHRemoveFx(_inst, "hh_hat_front_fx")
    HH_UTILS:HHRemoveFx(_inst, "hh_hat_back_fx")
end
local function addPainterName(inst, painter_name)
    if not HH_UTILS:IsHHType(painter_name, "string") or painter_name == "" then
        inst["hh_painter"] = nil
        return
    end
    inst["hh_painter"] = painter_name
end
local function getCommonSkinStone(hh_skin_id, hh_skin_name)
    return
    {
        ["skin_id"] = hh_skin_id,
        ["skin_name"] = tostring(hh_skin_name),
        ["xml"] = hh_skin_stone_heart_xml, ["tex"] = hh_skin_id .. ".tex",
        ["skin_client"] = function(inst, skin_id)
        end,
        ["skin_server"] = function(inst, skin_id)
            inst["AnimState"]:OverrideSymbol("hh_remove_stone", "hh_skin_stone", tostring(skin_id))
            changeSkinImageAndXml(inst, skin_id, hh_skin_stone_heart_xml)
            addPainterName(inst, base_painter)
        end,
    }
end
local function getCommonSkinCatBox(hh_skin_id, hh_skin_name)
    return
    {
        ["skin_id"] = hh_skin_id,
        ["skin_name"] = tostring(hh_skin_name),
        ["xml"] = hh_skin_cat_box_xml, ["tex"] = hh_skin_id .. ".tex",
        ["skin_client"] = function(inst, skin_id)
        end,
        ["skin_server"] = function(inst, skin_id)
            inst["AnimState"]:OverrideSymbol("hh_remove_stone", "hh_skin_cat_box", tostring(skin_id))
            changeSkinImageAndXml(inst, skin_id, hh_skin_cat_box_xml)
            addPainterName(inst, base_painter)
        end,
    }
end
local function getCommonSkinHatStar(hh_skin_id, hh_skin_name)
    return
    {
        ["skin_id"] = hh_skin_id,
        ["skin_name"] = tostring(hh_skin_name),
        ["xml"] = hh_skin_hat_star_xml, ["tex"] = hh_skin_id .. ".tex",
        ["skin_client"] = function(inst, skin_id)
        end,
        ["equip_fn"] = function(hat_inst, owner, skin_id)
            hatStarEquip(hat_inst, owner, "hh_skin_hat_star", skin_id)
        end,
        ["un_equip_fn"] = function(hat_inst, owner, skin_id)
            hatStarUnEquip(hat_inst, owner, "hh_skin_hat_star", skin_id)
        end,
        ["skin_server"] = function(inst, skin_id)
            inst["AnimState"]:OverrideSymbol("hh_hat_star", "hh_skin_hat_star", tostring(skin_id))
            changeSkinImageAndXml(inst, skin_id, hh_skin_hat_star_xml)
            addPainterName(inst, base_painter)
        end,
    }
end
local function replaceAnim(inst, skin_id)
    if inst and inst["AnimState"] then
        inst["AnimState"]:SetBank("hh_skin_suit_build")
        inst["AnimState"]:SetBuild("hh_skin_suit_build")
        inst["AnimState"]:PlayAnimation("idle", true)
        inst["AnimState"]:OverrideSymbol("hh_skin_suit_build_wsq_a", "hh_skin_suit_build", tostring(skin_id))
    end
end
local function getCommonSkinSuitBuild(hh_skin_id, hh_skin_name)
    return
    {
        ["skin_id"] = hh_skin_id,
        ["skin_name"] = tostring(hh_skin_name),
        ["xml"] = hh_skin_suit_build_xml, ["tex"] = hh_skin_id .. ".tex",
        ["skin_client"] = function(inst, skin_id)
        end,
        ["placer_fn"] = function(inst, skin_id)
            replaceAnim(inst, skin_id)
        end,
        ["skin_server"] = function(inst, skin_id)
            replaceAnim(inst, skin_id)
            addPainterName(inst, base_painter)
        end,
    }
end
local HH_SKIN = {
    ["hh_effect_stone"] = {
        {
            ["skin_id"] = "hh_effect_stone",
            ["skin_name"] = "经典",
            ["xml"] = "images/hh_icon/hh_items.xml", ["tex"] = "hh_effect_stone.tex",
            ["skin_client"] = function(inst, skin_id)
            end,
            ["skin_server"] = function(inst, skin_id)
                inst["AnimState"]:OverrideSymbol("hh_remove_stone", "hh_items", "hh_effect_stone")
                changeSkinImageAndXml(inst, skin_id, hh_items_xml)
                addPainterName(inst, nil)
            end,
        },
        getCommonSkinStone("hh_skin_stone_doll_a", "一二"),
        getCommonSkinStone("hh_skin_stone_doll_b", "布布"),
        getCommonSkinStone("hh_skin_stone_doll_c", "一二"),
        getCommonSkinStone("hh_skin_stone_doll_d", "布布"),
        getCommonSkinStone("hh_skin_stone_star", "小星星"),
        getCommonSkinStone("hh_skin_stone_gold", "元宝"),
        getCommonSkinStone("hh_skin_stone_cub_a", "茶杯"),
        getCommonSkinStone("hh_skin_stone_cub_b", "茶杯"),
        getCommonSkinStone("hh_skin_stone_cub_c", "茶杯"),
        getCommonSkinStone("hh_skin_stone_cub_d", "茶杯"),
        getCommonSkinStone("hh_skin_stone_cub_e", "茶杯"),
        getCommonSkinStone("hh_skin_stone_cub_f", "茶杯"),
        getCommonSkinStone("hh_skin_stone_cub_g", "茶杯"),
        getCommonSkinStone("hh_skin_stone_cub_h", "茶杯"),
        getCommonSkinStone("hh_skin_stone_kitty_a", "kitty"),
        getCommonSkinStone("hh_skin_stone_kitty_b", "kitty"),
    },
    ["hh_cat_box"] = {
        {
            ["skin_id"] = "hh_cat_box",
            ["skin_name"] = "经典",
            ["xml"] = hh_items_xml, ["tex"] = "hh_cat_box.tex",
            ["skin_client"] = function(inst, skin_id)
            end,
            ["skin_server"] = function(inst, skin_id)
                inst["AnimState"]:OverrideSymbol("hh_remove_stone", "hh_items", tostring(skin_id))
                changeSkinImageAndXml(inst, skin_id, hh_items_xml)
                addPainterName(inst, nil)
            end,
        },
        getCommonSkinCatBox("hh_skin_cat_box_dragon", "你好"),
        getCommonSkinCatBox("hh_skin_cat_box_mld_a", "美乐蒂"),
        getCommonSkinCatBox("hh_skin_cat_box_pd", "胖丁"),
        getCommonSkinCatBox("hh_skin_cat_box_kitty_a", "kitty"),
        getCommonSkinCatBox("hh_skin_cat_box_kitty_b", "kitty"),
        getCommonSkinCatBox("hh_skin_cat_box_kitty_c", "kitty"),
        getCommonSkinCatBox("hh_skin_cat_box_kitty_d", "kitty"),
        getCommonSkinCatBox("hh_skin_cat_box_kitty_e", "kitty"),
        getCommonSkinCatBox("hh_skin_cat_box_kitty_f", "kitty"),
        getCommonSkinCatBox("hh_skin_cat_box_rabbit", "兔子"),
        getCommonSkinCatBox("hh_skin_cat_box_doll_a", "布布"),
        getCommonSkinCatBox("hh_skin_cat_box_doll_b", "一二"),
    },
    ["hh_hat_star"] = {
        {
            ["skin_id"] = "hh_hat_star",
            ["skin_name"] = "经典",
            ["xml"] = "images/hh_icon/hh_hat_star.xml", ["tex"] = "hh_hat_star.tex",
            ["skin_client"] = function(inst, skin_id)
            end,
            ["equip_fn"] = function(hat_inst, owner, skin_id)
                hatStarEquip(hat_inst, owner, skin_id, skin_id)
            end,
            ["un_equip_fn"] = function(hat_inst, owner, skin_id)
                hatStarUnEquip(hat_inst, owner, skin_id, skin_id)
            end,
            ["skin_server"] = function(inst, skin_id)
                inst["AnimState"]:OverrideSymbol("hh_hat_star", "hh_hat_star", "hh_hat_star")
                changeSkinImageAndXml(inst, skin_id, "images/hh_icon/hh_hat_star.xml")
                addPainterName(inst, base_painter)
            end,
        },
        getCommonSkinHatStar("hh_skin_hat_star_a", "炫彩"),
        getCommonSkinHatStar("hh_skin_hat_star_b", "炫彩"),
        getCommonSkinHatStar("hh_skin_hat_star_c", "炫彩"),
        getCommonSkinHatStar("hh_skin_hat_star_d", "炫彩"),
        getCommonSkinHatStar("hh_skin_hat_star_e", "炫彩"),
        getCommonSkinHatStar("hh_skin_hat_star_f", "炫彩"),
        getCommonSkinHatStar("hh_skin_hat_star_g", "炫彩"),
        getCommonSkinHatStar("hh_skin_hat_star_h", "炫彩"),
        getCommonSkinHatStar("hh_skin_hat_star_i", "炫彩"),
        getCommonSkinHatStar("hh_skin_hat_star_j", "炫彩"),
        getCommonSkinHatStar("hh_skin_hat_star_k", "炫彩"),
        getCommonSkinHatStar("hh_skin_hat_star_l", "炫彩"),
        getCommonSkinHatStar("hh_skin_hat_star_m", "炫彩"),
        getCommonSkinHatStar("hh_skin_hat_star_n", "炫彩"),
        getCommonSkinHatStar("hh_skin_hat_star_o", "炫彩"),
        getCommonSkinHatStar("hh_skin_hat_star_p", "炫彩"),
    },
    ["hh_suit_build"] = {
        {
            ["skin_id"] = "hh_suit_build",
            ["skin_name"] = "经典",
            ["xml"] = "images/hh_icon/hh_suit_build.xml", ["tex"] = "hh_suit_build.tex",
            ["skin_client"] = function(inst, skin_id)
            end,
            ["skin_server"] = function(inst, skin_id)
                inst["AnimState"]:SetBank("hh_suit_build")
                inst["AnimState"]:SetBuild("hh_suit_build")
                inst["AnimState"]:PlayAnimation("idle", true)
                addPainterName(inst, base_painter)
            end,
        },
        {
            ["skin_id"] = "hh_skin_suit_build_dragon",
            ["skin_name"] = "招吉龙",
            ["xml"] = "images/hh_icon/hh_skin_suit_build_dragon.xml", ["tex"] = "hh_skin_suit_build_dragon.tex",
            ["skin_client"] = function(inst, skin_id)
            end,
            ["placer_fn"] = function(inst, skin_id)
                if inst and inst["AnimState"] then
                    inst["AnimState"]:SetBank("hh_skin_suit_build")
                    inst["AnimState"]:SetBuild("hh_skin_suit_build")
                    inst["AnimState"]:PlayAnimation("idle", true)
                    inst["AnimState"]:OverrideSymbol("hh_skin_suit_build_wsq_a", "hh_skin_suit_build_dragon", tostring(skin_id))
                end
            end,
            ["skin_server"] = function(inst, skin_id)
                if inst and inst["AnimState"] then
                    inst["AnimState"]:SetBank("hh_skin_suit_build")
                    inst["AnimState"]:SetBuild("hh_skin_suit_build")
                    inst["AnimState"]:PlayAnimation("idle", true)
                    inst["AnimState"]:OverrideSymbol("hh_skin_suit_build_wsq_a", "hh_skin_suit_build_dragon", tostring(skin_id))
                end
                addPainterName(inst, base_painter)
            end,
        },
        getCommonSkinSuitBuild("hh_skin_suit_build_wsq_a", "可爱1号"),
        getCommonSkinSuitBuild("hh_skin_suit_build_wsq_b", "可爱2号"),
        getCommonSkinSuitBuild("hh_skin_suit_build_wsq_c", "可爱3号"),
        getCommonSkinSuitBuild("hh_skin_suit_build_wsq_d", "可爱4号"),
    },
}

return HH_SKIN