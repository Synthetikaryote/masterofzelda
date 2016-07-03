--[[
how to read this:
"-" before something means it will cost points to add to your character (benefits)
"+" before something means it will give points to your character build (detriments)
]]

build = {
	["Melee"] = {
		description = "This enables abilities that affect only melee range.",
		enabled = true,
		points = -1,
		children = {
			["Double damage"] = {
				description = "This doubles damage dealt by abilities that affect only melee range.",
				enabled = false,
				points = -1
			},
			group1 = {
				children = {
					["Double range"] = {
						description = "This doubles melee range.",
						enabled = false,
						points = -1
					},
					["Triple range"] = {
						description = "This triples melee range.",
						enabled = false,
						points = -2
					}
				}
			},
			["Half mana cost"] = {
				description = "This halves mana cost of abilities that affect only melee range.",
				enabled = false,
				points = -1
			}
		}
	},
	["Non-melee"] = {
		description = "This enables abilities that can affect a greater range than melee range.",
		enabled = true,
		points = -1,
		children = {
			["Double damage"] = {
				description = "This doubles damage dealt by abilities that can affect a greater range than melee range.",
				enabled = false,
				points = -1
			},
			["Half mana cost"] = {
				description = "This halves mana cost of abilities that can affect a greater range than melee range.",
				enabled = false,
				points = -1
			}
		}
	},
	["Healing"] = {
		description = "This enables abilities that heal.",
		enabled = true,
		points = -1,
		children = {
			["Double"] = {
				description = "This doubles the healing effect of all abilities that heal.",
				enabled = false,
				points = -1
			},
			group1 = {
				children = {
					["Half mana cost"] = {
						description = "This halves mana cost of abilities that only heal.",
						enabled = false,
						points = -1
					},
					["Double mana cost"] = {
						description = "This doubles mana cost of abilities that only heal.",
						enabled = false,
						points = 2
					}
				}
			}
		}
	},
	["Damage taken"] = {
		description = "Points in this category affect damage taken.",
		children = {
			group1 = {
				children = {
					["Half"] = {
						description = "This halves damage taken.",
						enabled = false,
						points = -1
					},
					["Double"] = {
						description = "This doubles damage taken.",
						enabled = false,
						points = 1
					}
				}
			}
		}
	},
	["Invincibility duration"] = {
		description = "Points in this category affect the duration of invincibility after taking damage.",
		enabled = true,
		points = -3,
		children = {
			group1 = {
				children = {
					["Double"] = {
						description = "This doubles invincibility duration.",
						enabled = false,
						points = -2
					},
					["Half"] = {
						description = "This halves invincibility duration.",
						enabled = false,
						points = 1
					},
					["Quarter"] = {
						description = "This quarters invincibility duration.",
						enabled = false,
						points = 2
					}
				}
			}
		}
	}
}
--[[

default attributes:
invincibility duration
	-double invincibility duration
	+half
		+quarter
knockback taken
	-half knockback
	-no knockback
	+double knockback
knockback dealt
	+half knockback
	+no knockback
	-double knockback
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