--[[
how to read this:
"-" before something means it will cost points to add to your character (benefits)
]]"+" before something means it will give points to your character build (detriments)

build = {
	meleeDamage = {
		name = "Melee damage",
		description = "Points in this category affect your damage dealt from melee range.",
		children = {
			doubleDamage = {
				enabled = false,
				name = "Double damage",
				description = "This doubles your damage dealt from melee range. This affects all melee-range sources."
			},
			halfManaCost = {
				enabled = false,
				name = "Half mana cost",
				description = "This reduces mana cost of abilities that affect only melee range by 50%."
			}
		}
	},
	rangedDamage = {
		name = "Ranged damage",
		description = "Points in this category affect damage dealt by your abilities which have greater range than melee.",
		children = {
			doubleDamage = {
				enabled = false,
				name = "Double damage",
				description = "This doubles damage dealt by your abilities which have greater range than melee."
			},
			halfManaCost = {
				enabled = false,
				name = "Half mana cost",
				description = "This reduces mana cost of abilities that affect only melee range by 50%."
			}
		}
	}
}
--[[

default attributes:

1 ranged damage (includes spells)
	-double ranged damage
	-half mana cost
1 healing
	-double healing
	-half mana cost
1 damage taken
	-half damage taken
	+double damage taken
invincibility duration
	-double invincibility duration
	+half
		+quarter
knockback
	-half knockback
		-no knockback
	+double knockback
200 movement speed
	-125% movement speed
	+80% movement speed
no-mana heal and damage ability
	-double strength no-mana damage ability
	+remove no-mana damage ability
	-double strength no-mana heal ability
	+remove no-mana heal ability
100 health
	-double health
	+half health
100 mana
	-double mana
	+no mana
melee range
	-double melee range
	+no melee
ranged range
	-double ranged range
healing range

optional attributes:

-mana regen
	-double mana regen
-sneakiness
	-double sneakiness
	-visible enemy aggro range

abilities:

-jump
	-double jump
	-float jump
-climbing
-swimming
-drop bombs (1 max default)
	-2 max bombs
		-4 max bombs
	-double radius
	-throw bombs
		-double throwing range
}


things to consider later:

pet(s)
	must stay near player
	high cost

]]