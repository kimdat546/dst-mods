AddModCharacter("phamnhan", "MALE")

-- Only "Phàm Nhân" is selectable.
local VANILLA = {
    "wilson","willow","wendy","wolfgang","wx78","wickerbottom","woodie","wes",
    "waxwell","wathgrithr","webber","winona","warly","wormwood","wortox","wurt",
    "walter","wanda",
}
for _, c in ipairs(VANILLA) do RemoveDefaultCharacter(c) end
