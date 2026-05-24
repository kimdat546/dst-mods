-- scripts/pn/linhcan_data.lua
-- Linh căn (spiritual root) definitions per PNTT novel canon.
-- 4 types rolled at spawn with weighted probability.

local data = {}

-- 5 base elements (Kim/Mộc/Thủy/Hỏa/Thổ)
data.ELEMENTS = { "KIM", "MOC", "THUY", "HOA", "THO" }

data.ELEMENT_DISPLAY = {
    KIM  = "Kim",
    MOC  = "Mộc",
    THUY = "Thủy",
    HOA  = "Hỏa",
    THO  = "Thổ",
}

-- 4 types with roll weights (total = 100)
data.TYPES = {
    NGUY = {
        weight        = 65,
        element_count = { 4, 5 },  -- roll 4 or 5 elements
        tu_vi_mult    = 1.0,
        display       = "Ngụy Linh Căn",
        description   = "Linh căn tạp loạn, tốc độ tu luyện chậm — đa số phàm nhân.",
    },
    CHAN = {
        weight        = 30,
        element_count = { 2, 3 },
        tu_vi_mult    = 1.5,
        display       = "Chân Linh Căn",
        description   = "Linh căn thuần khiết, tu chân thuận lợi.",
    },
    BIEN_DI = {
        weight        = 3,
        element_count = { 2, 3 },
        tu_vi_mult    = 2.5,
        display       = "Biến Dị Linh Căn",
        description   = "Linh căn dị biến, tốc độ ngang Thiên Linh, có thiên phú riêng.",
        special       = true,
    },
    THIEN = {
        weight        = 2,
        element_count = { 1, 1 },  -- exactly 1 element
        tu_vi_mult    = 3.0,
        display       = "Thiên Linh Căn",
        description   = "Linh căn đơn nhất, thiên tài bẩm sinh, hiếm có khó tìm.",
    },
}

-- Biến Dị element combos — when a BIEN_DI rolls these specific elements, it gets a special tag.
data.BIEN_DI_COMBOS = {
    { elements = { "KIM", "THUY" }, tag = "BANG",    display = "Băng Linh Căn"    },
    { elements = { "KIM", "HOA"  }, tag = "LOI",     display = "Lôi Linh Căn"     },
    { elements = { "MOC", "HOA"  }, tag = "PHUONG",  display = "Phượng Linh Căn"  },
    { elements = { "MOC", "THUY" }, tag = "PHONG",   display = "Phong Linh Căn"   },
    { elements = { "THUY", "HOA" }, tag = "AM_DUONG", display = "Âm Dương Linh Căn" },
    { elements = { "THO", "KIM"  }, tag = "THACH",   display = "Thạch Linh Căn"   },
}

-- Type list ordered by weight ASC for roll algorithm (rare first → easy threshold check)
data.TYPE_ORDER = { "THIEN", "BIEN_DI", "CHAN", "NGUY" }

return data
