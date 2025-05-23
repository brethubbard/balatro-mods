function table_to_string(tbl)
    local result = "{"
    for k, v in pairs(tbl) do
        -- Check the key type (ignore any numerical keys - assume its an array)
        if type(k) == "string" then
            result = result.."[\""..k.."\"]".."="
        end

        -- Check the value type
        if type(v) == "table" then
            result = result..table_to_string(v)
        elseif type(v) == "boolean" then
            result = result..tostring(v)
        else
            result = result.."\""..v.."\""
        end
        result = result..","
    end
    -- Remove leading commas from the result
    if result ~= "" then
        result = result:sub(1, result:len()-1)
    end
    return result.."}"
end

SMODS.Atlas {
	-- Key for code to find it with
	key = "calvin",
	-- The name of the file, for the code to pull the atlas from
	path = "calvin.png",
	-- Width of each sprite in 1x size
	px = 71,
	-- Height of each sprite in 1x size
	py = 95
}

SMODS.Joker {
	-- How the code refers to the joker.
	key = 'mult',
	-- loc_text is the actual name and description that show in-game for the card.
	loc_txt = {
		name = 'Mult Joker',
        text = {
            --[[
            The #1# is a variable that's stored in config, and is put into loc_vars.
            The {C:} is a color modifier, and uses the color "mult" for the "+#1# " part, and then the empty {} is to reset all formatting, so that Mult remains uncolored.
                There's {X:}, which sets the background, usually used for XMult.
                There's {s:}, which is scale, and multiplies the text size by the value, like 0.8
                There's one more, {V:1}, but is more advanced, and is used in Castle and Ancient Jokers. It allows for a variable to dynamically change the color. You can find an example in the Castle joker if needed.
                Multiple variables can be used in one space, as long as you separate them with a comma. {C:attention, X:chips, s:1.3} would be the yellow attention color, with a blue chips-colored background,, and 1.3 times the scale of other text.
                You can find the vanilla joker descriptions and names as well as several other things in the localization files.
                ]]
			"This Joker gains {X:mult,C:white} X#2# {} Mult",
			"when hand played with",
			"more than {C:attention}5 triggered cards{}",
			"{C:inactive}(Currently {X:mult,C:white} X#1# {C:inactive} Mult)",
		}
	},
	--[[
		Config sets all the variables for your card, you want to put all numbers here.
		This is really useful for scaling numbers, but should be done with static numbers -
		If you want to change the static value, you'd only change this number, instead
		of going through all your code to change each instance individually.
		]]
	config = { extra = { xmult = 1, xmult_gain = 0.25 } },
    discovered = true,
    unlocked = true,
	-- loc_vars gives your loc_text variables to work with, in the format of #n#, n being the variable in order.
	-- #1# is the first variable in vars, #2# the second, #3# the third, and so on.
	-- It's also where you'd add to the info_queue, which is where things like the negative tooltip are.
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_gain } }
	end,
	-- Sets rarity. 1 common, 2 uncommon, 3 rare, 4 legendary.
	rarity = 2,
	-- Which atlas key to pull from.
	atlas = 'calvin',
	-- This card's position on the atlas, starting at {x=0,y=0} for the very top left.
	pos = { x = 0, y = 0 },
	-- Cost of card in shop.
	cost = 0,
    triggered = false,
    triggered_cards = 0,
	-- The functioning part of the joker, looks at context to decide what step of scoring the game is on, and then gives a 'return' value if something activates.
	calculate = function(self, card, context)

        if context.before then
            self.triggered = false
            self.triggered_cards = 0
        end

        if context.individual
        and context.cardarea == G.play
        and not card.debuff
        and not self.triggered
        and not context.blueprint then
            self.triggered_cards = self.triggered_cards + 1
            if self.triggered_cards > 5 then
                self.triggered = true
                card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
                return {
                    message = 'Upgraded!',
                    colour = G.C.MULT,
                    card = card
                }
            end
        end

		if context.joker_main then
			-- Tells the joker what to do. In this case, it pulls the value of mult from the config, and tells the joker to use that variable as the "mult_mod".
			return {
				Xmult_mod = card.ability.extra.mult,
				-- This is a localize function. Localize looks through the localization files, and translates it. It ensures your mod is able to be translated. I've left it out in most cases for clarity reasons, but this one is required, because it has a variable.
				-- This specifically looks in the localization table for the 'variable' category, specifically under 'v_dictionary' in 'localization/en-us.lua', and searches that table for 'a_mult', which is short for add mult.
				-- In the localization file, a_mult = "+#1#". Like with loc_vars, the vars in this message variable replace the #1#.
				message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } }
				-- Without this, the mult will stil be added, but it'll just show as a blank red square that doesn't have any text.
			}
		end
	end
}
