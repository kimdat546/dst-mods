-- Linh Điền craftable. (Đan lô recipe arrives in Plan B.)
local TECH = GLOBAL.TECH

AddRecipe2("pn_linhdien",
    { Ingredient("cutgrass", 6), Ingredient("twigs", 4), Ingredient("rocks", 2) },
    TECH.SCIENCE_ONE,
    { placer = "pn_linhdien_placer", atlas = "images/inventoryimages/pn_linhdien_icon.xml", image = "pn_linhdien.tex" },
    { "STRUCTURES" })

STRINGS.NAMES.PN_LINHDIEN = "Linh Điền"
STRINGS.RECIPE_DESC.PN_LINHDIEN = "Linh khí tụ — linh thảo trồng quanh đây lớn nhanh hơn."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.PN_LINHDIEN = "Linh khí nồng đậm."

-- Herb item + seed display names
local Herbs = GLOBAL.require("pn/herbs")
for _, def in ipairs(Herbs.herbs) do
    STRINGS.NAMES[string.upper(def.id)] = def.display
    STRINGS.NAMES[string.upper(def.id) .. "_SEED"] = def.display .. " (hạt)"
    STRINGS.NAMES[string.upper(def.id) .. "_PLANT"] = def.display
    STRINGS.NAMES[string.upper(def.id) .. "_CROP"] = def.display
end
