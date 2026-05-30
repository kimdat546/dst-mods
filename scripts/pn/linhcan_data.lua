-- Linh căn (spiritual root) data. tu_vi_mult capped 1.0–1.3 for MP fairness;
-- differentiation comes from element affinity (future), not raw speed.
local data = {}

data.ELEMENTS = { "KIM", "MOC", "THUY", "HOA", "THO" }
data.ELEMENT_DISPLAY = { KIM="Kim", MOC="Mộc", THUY="Thủy", HOA="Hỏa", THO="Thổ" }

data.TYPES = {
    NGUY    = { weight=65, element_count={4,5}, tu_vi_mult=1.0, display="Ngụy Linh Căn" },
    CHAN    = { weight=30, element_count={2,3}, tu_vi_mult=1.1, display="Chân Linh Căn" },
    BIEN_DI = { weight=3,  element_count={2,3}, tu_vi_mult=1.2, display="Biến Dị Linh Căn", special=true },
    THIEN   = { weight=2,  element_count={1,1}, tu_vi_mult=1.3, display="Thiên Linh Căn" },
}
-- ascending-weight order for the weighted roll
data.ROLL_ORDER = { "THIEN", "BIEN_DI", "CHAN", "NGUY" }

data.BIEN_DI_COMBOS = {
    { elements={"KIM","THUY"}, tag="BANG",   display="Băng Linh Căn" },
    { elements={"KIM","HOA"},  tag="LOI",    display="Lôi Linh Căn" },
    { elements={"MOC","HOA"},  tag="PHUONG", display="Phượng Linh Căn" },
    { elements={"MOC","THUY"}, tag="PHONG",  display="Phong Linh Căn" },
    { elements={"THUY","HOA"}, tag="AM_DUONG", display="Âm Dương Linh Căn" },
    { elements={"THO","KIM"},  tag="THACH",  display="Thạch Linh Căn" },
}

-- which dantian medallion (level1-6 in pn_ui) for a primary element
data.ELEMENT_MEDALLION = {
    THUY="level1.tex", KIM="level3.tex", MOC="level4.tex",
    THO="level5.tex", HOA="level6.tex",
}
data.DEFAULT_MEDALLION = "level2.tex"

return data
