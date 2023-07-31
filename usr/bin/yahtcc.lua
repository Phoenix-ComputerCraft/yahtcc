-- YahtCC by JackMacWindows
-- GPL license

local util = require "system.util"
local keys = require "system.keys"
local terminal = require "system.terminal"
local hardware = require "system.hardware"
local term, termerr = terminal.openterm()
if not term then error("Could not open terminal: " .. termerr) end

local diceMaps = {
    [0] = {0xA0, 0xA0, 0xA0, 0xA0, 0xA0, 0xA0},
    {0x20, 0x10, 0x95, 0x8f, 0x8f, 0x85},
    {0x08, 0x20, 0x95, 0x8f, 0x8d, 0x85},
    {0x08, 0x10, 0x95, 0x8f, 0x8d, 0x85},
    {0x08, 0x08, 0x95, 0x8d, 0x8d, 0x85},
    {0x08, 0x18, 0x95, 0x8d, 0x8d, 0x85},
    {0x97, 0x97, 0x95, 0x8d, 0x8d, 0x85}
}

local logo = {
    {0x2F, 0x34, 0x00, 0x38, 0x1F, 0x00, 0x00, 0x28, 0x14, 0x00, 0x00, 0x3C, 0x00, 0x00, 0x38, 0x3C, 0x14, 0x20, 0x3C, 0x3C},
    {0x00, 0x0B, 0x3F, 0x07, 0x00, 0x00, 0x00, 0x2A, 0x15, 0x00, 0x0F, 0x3F, 0x0F, 0x2A, 0x17, 0x00, 0x00, 0x3F, 0x01, 0x00},
    {0x00, 0x00, 0x3F, 0x00, 0x38, 0x0F, 0x3E, 0x2A, 0x1F, 0x2F, 0x14, 0x3F, 0x00, 0x2A, 0x15, 0x00, 0x00, 0x3F, 0x00, 0x00},
    {0x00, 0x00, 0x3F, 0x00, 0x0B, 0x3C, 0x2F, 0x2A, 0x15, 0x2A, 0x15, 0x3F, 0x00, 0x02, 0x2F, 0x3C, 0x14, 0x0B, 0x3D, 0x3C}
}

local rollcup = {
    {0x00, 0x3C, 0x30, 0x30, 0x38, 0x14, 0x00},
    {0x00, 0x15, 0x17, 0x17, 0x15, 0x15, 0x00},
    {0x00, 0x15, 0x15, 0x15, 0x15, 0x15, 0x00},
    {0x00, 0x35, 0x15, 0x15, 0x35, 0x15, 0x00},
    {0x00, 0x03, 0x0F, 0x0F, 0x07, 0x01, 0x00}
}

local scorecardNames = {
    {
        {name = ""},
        {name = "Ones", score = function(dice)
            local score = 0
            for _,i in ipairs(dice) do if i.value == 1 then score = score + i.value end end
            return score
        end},
        {name = "Twos", score = function(dice)
            local score = 0
            for _,i in ipairs(dice) do if i.value == 2 then score = score + i.value end end
            return score
        end},
        {name = "Threes", score = function(dice)
            local score = 0
            for _,i in ipairs(dice) do if i.value == 3 then score = score + i.value end end
            return score
        end},
        {name = "Fours", score = function(dice)
            local score = 0
            for _,i in ipairs(dice) do if i.value == 4 then score = score + i.value end end
            return score
        end},
        {name = "Fives", score = function(dice)
            local score = 0
            for _,i in ipairs(dice) do if i.value == 5 then score = score + i.value end end
            return score
        end},
        {name = "Sixes", score = function(dice)
            local score = 0
            for _,i in ipairs(dice) do if i.value == 6 then score = score + i.value end end
            return score
        end},
        {name = "Bonus"}
    },
    {
        {name = "Three of a Kind", score = function(dice)
            local counts = {0, 0, 0, 0, 0, 0}
            local ok = false
            local sum = 0
            for _,i in ipairs(dice) do
                counts[i.value] = counts[i.value] + 1
                sum = sum + i.value
                if counts[i.value] >= 3 then ok = true end
            end
            return ok and sum or 0
        end},
        {name = "Four of a Kind", score = function(dice)
            local counts = {0, 0, 0, 0, 0, 0}
            local ok = false
            local sum = 0
            for _,i in ipairs(dice) do
                counts[i.value] = counts[i.value] + 1
                sum = sum + i.value
                if counts[i.value] >= 4 then ok = true end
            end
            return ok and sum or 0
        end},
        {name = "Full House", score = function(dice, scores)
            local counts = {0, 0, 0, 0, 0, 0}
            for _,i in ipairs(dice) do counts[i.value] = counts[i.value] + 1 end
            local three, two, yahtzee = false, false, nil
            for i = 1, 6 do
                if counts[i] == 3 then three = true
                elseif counts[i] == 2 then two = true
                elseif counts[i] == 5 then yahtzee = i end
            end
            if yahtzee and scores[2][6].locked and not scores[1][yahtzee+1].locked then return 25 end
            return (three and two) and 25 or 0
        end},
        {name = "Small Straight", score = function(dice, scores)
            local counts = {0, 0, 0, 0, 0, 0}
            local yahtzee = nil
            for _,i in ipairs(dice) do counts[i.value] = counts[i.value] + 1 if counts[i.value] == 5 then yahtzee = i.value end end
            if yahtzee and scores[2][6].locked and not scores[1][yahtzee+1].locked then return 30 end
            if counts[3] == 0 or counts[4] == 0 then return 0
            elseif (counts[1] ~= 0 and counts[2] ~= 0) or
                   (counts[2] ~= 0 and counts[5] ~= 0) or
                   (counts[5] ~= 0 and counts[6] ~= 0) then return 30 end
            return 0
        end},
        {name = "Large Straight", score = function(dice, scores)
            local counts = {0, 0, 0, 0, 0, 0}
            local yahtzee = nil
            for _,i in ipairs(dice) do counts[i.value] = counts[i.value] + 1 if counts[i.value] == 5 then yahtzee = i.value end end
            if yahtzee and scores[2][6].locked and not scores[1][yahtzee+1].locked then return 40 end
            if counts[2] == 0 or counts[3] == 0 or counts[4] == 0 or counts[5] == 0 then return 0 end
            return (counts[1] ~= 0 or counts[6] ~= 0) and 40 or 0
        end},
        {name = "Yahtzee", score = function(dice)
            local c = dice[1].value
            for _,i in ipairs(dice) do if c ~= i.value then return 0 end end
            return 50
        end},
        {name = "Chance", score = function(dice)
            local sum = 0
            for _,i in ipairs(dice) do sum = sum + i.value end
            return sum
        end},
        {name = "Yahtzee Bonus"}
    }
}

local function drawDie(x, y, n, b)
    b = b or '0'
    local f = 'f'
    local d = diceMaps[n]
    term.setCursorPos(x, y)
    for i = 1, 3 do
        local c = d[i]
        if c == 0x20 then term.blit(' ', f, b)
        elseif c < 0x80 then term.blit(string.char(c + 0x80), f, b)
        else term.blit(string.char(c), b, f) end
    end
    term.setCursorPos(x, y+1)
    for i = 4, 6 do
        local c = d[i]
        if c == 0x20 then term.blit(' ', f, b)
        elseif c < 0x80 then term.blit(string.char(c + 0x80), f, b)
        else term.blit(string.char(c), b, f) end
    end
    term.setBackgroundColor(terminal.colors.black)
    term.setTextColor(terminal.colors.white)
end

local function drawDice(x, y, dice)
    for n,i in ipairs(dice) do drawDie(x + (n-1)*3, y, i.value, i.locked and '4' or '0') end
end

local function drawLogo(xx, yy, ff)
    ff = ff or '0'
    for y = 1, 4 do
        term.setCursorPos(xx, yy + y - 1)
        for _,c in ipairs(logo[y]) do
            local f, b = ff, 'f'
            if bit32.btest(c, 0x20) then
                f, b = b, f
                c = bit32.band(bit32.bnot(c), 0x1F)
            end
            c = bit32.bor(c, 0x80)
            if c == 0x80 then c = 0x20 end
            term.blit(string.char(c), f, b)
        end
    end
    term.setBackgroundColor(terminal.colors.black)
    term.setTextColor(terminal.colors.white)
end

local function drawRollCup(xx, yy, color, rolling)
    color = color or 'b'
    for y = 1, 5 do
        term.setCursorPos(xx - 1, yy + y - 1)
        for x,c in ipairs(rollcup[y]) do
            local f, b
            if y > 1 and y < 5 and x > 1 and x < 6 then f, b = color, '8'
            else f, b = color, 'f' end
            if bit32.btest(c, 0x20) then
                f, b = b, f
                c = bit32.band(bit32.bnot(c), 0x1F)
            end
            c = bit32.bor(c, 0x80)
            if c == 0x80 then c = 0x20 end
            term.blit(string.char(c), f, b)
        end
    end
    term.setCursorPos(xx - 6, yy + 2)
    term.setBackgroundColor(terminal.colors.black)
    term.setTextColor(terminal.colors.white)
    term.write(rolling and "      " or " Roll ")
end

local function drawScores(x, y, scores, selectcol, selectrow)
    term.setBackgroundColor(terminal.colors.black)
    term.setCursorBlink(false)
    for e = 1, 2 do
        for i,v in ipairs(scorecardNames[e]) do
            local selected = e == selectcol and i == selectrow
            term.setBackgroundColor(selected and terminal.colors.white or (i % 2 == 1 and terminal.colors.black or terminal.colors.gray))
            term.setTextColor(selected and terminal.colors.black or terminal.colors.white)
            term.setCursorPos(x + (e - 1)*20, y + i - 1)
            term.write(v.name .. (' '):rep(16 - #v.name))
            if not scores[e][i].locked and not v.bonus then
                if scores[e][i].value == 0 then term.setTextColor(terminal.colors.lightGray)
                else term.setTextColor(terminal.colors.lightBlue) end
            else term.setTextColor(selected and terminal.colors.black or terminal.colors.white) end
            if scores[e][i].value == nil then term.write("   ")
            elseif scores[e][i].value < 10 then term.write("  " .. scores[e][i].value)
            else term.write(" " .. scores[e][i].value) end
        end
    end
    term.setBackgroundColor(terminal.colors.black)
    term.setTextColor(terminal.colors.white)
end

local function drawStatus(x, y, scores, rolls)
    term.setCursorPos(x, y)
    term.write("Score: ")
    local sum = 0
    for e = 1, 2 do
        for i,v in ipairs(scores[e]) do
            if v.value and v.locked then sum = sum + v.value end
        end
    end
    term.write(sum)
    term.setCursorPos(x, y + 1)
    term.write("Rolls remaining: " .. rolls)
    term.setBackgroundColor(terminal.colors.black)
    term.setTextColor(terminal.colors.white)
end

local function calculateScores(scores, dice)
    for e = 1, 2 do
        for i,v in ipairs(scorecardNames[e]) do
            if not scores[e][i].locked and v.score then
                scores[e][i].value = v.score(dice, scores)
            end
        end
    end
    if scores[2][6].locked and scores[2][6].value == 50 then
        local c = dice[1].value
        for _,i in ipairs(dice) do if c ~= i.value then return scores end end
        scores[2][8].value = 100
        scores[2][8].locked = true
    end
    return scores
end

local function confirmScore(scores, col, row)
    if col then scores[col][row].locked = true end
    for e = 1, 2 do for i,v in ipairs(scores[e]) do if not v.locked then v.value = nil end end end
    if ((scores[1][2].locked and scores[1][2].value or 0) +
        (scores[1][3].locked and scores[1][3].value or 0) +
        (scores[1][4].locked and scores[1][4].value or 0) +
        (scores[1][5].locked and scores[1][5].value or 0) +
        (scores[1][6].locked and scores[1][6].value or 0) +
        (scores[1][7].locked and scores[1][7].value or 0)) >= 63 then
        scores[1][8].value = 35
        scores[1][8].locked = true
    end
    return scores
end

local speaker = hardware.find("speaker")

local function rollDice(dice, dx, dy, cx, cy, color, last)
    for _,v in ipairs(dice) do if not v.locked then v.value = 0 end end
    drawDice(dx, dy, dice)
    for i = 1, 4 do
        drawRollCup(cx, cy, color, true)
        if speaker then speaker:playNote("hat", 2, 12) speaker:playNote("hat", 2, 7) end
        util.sleep(0.1)
        drawRollCup(cx + 1, cy, color, true)
        if speaker then speaker:playNote("hat", 2, 11) speaker:playNote("hat", 2, 6) end
        util.sleep(0.1)
        drawRollCup(cx, cy, color, true)
        if speaker then speaker:playNote("hat", 2, 12) speaker:playNote("hat", 2, 7) end
        util.sleep(0.1)
        drawRollCup(cx - 1, cy, color, true)
        if speaker then speaker:playNote("hat", 2, 11) speaker:playNote("hat", 2, 6) end
        util.sleep(0.1)
    end
    if speaker then speaker:playNote("hat", 2, 3) speaker:playNote("hat", 2, 6) end
    for _,v in ipairs(dice) do if not v.locked then v.value = math.random(1, 6) end end
    drawRollCup(cx, cy, color, last)
    drawDice(dx, dy, dice)
    return dice
end

local positions = {
    dice = {x = 2, y = 17},
    rollCup = {x = 36, y = 15},
    logo = {x = 2, y = 2},
    status = {x = 23, y = 3},
    scores = {x = 2, y = 7}
}

local dice = {{value = 0}, {value = 0}, {value = 0}, {value = 0}, {value = 0}}
local scores = {{{}, {}, {}, {}, {}, {}, {}, {}}, {{}, {}, {}, {}, {}, {}, {}, {}}}
local rollsRemaining = 3
local selectedcol, selectedrow = false, 0
local filledScores = 0
local cupColor = 0xb
math.randomseed(os.time())
term.clear()
drawLogo(positions.logo.x, positions.logo.y)
drawStatus(positions.status.x, positions.status.y, scores, rollsRemaining)
drawScores(positions.scores.x, positions.scores.y, scores)
drawDice(positions.dice.x, positions.dice.y, dice)
drawRollCup(positions.rollCup.x, positions.rollCup.y, ('%x'):format(cupColor))

while filledScores < 13 do
    local ev, params = coroutine.yield()
    if ev == "key" then
        if params.keycode == keys.r and rollsRemaining > 0 and not (dice[1].locked and dice[2].locked and dice[3].locked and dice[4].locked and dice[5].locked) then
            rollsRemaining = rollsRemaining - 1
            confirmScore(scores)
            drawScores(positions.scores.x, positions.scores.y, scores)
            drawStatus(positions.status.x, positions.status.y, scores, rollsRemaining)
            rollDice(dice, positions.dice.x, positions.dice.y, positions.rollCup.x, positions.rollCup.y, ('%x'):format(cupColor), rollsRemaining < 1)
            calculateScores(scores, dice)
            if rollsRemaining == 0 then
                selectedcol = false
                selectedrow = 2
                while selectedrow <= 7 and scores[1][selectedrow].locked do selectedrow = selectedrow + 1 end
                if selectedrow > 7 then
                    selectedcol = true
                    selectedrow = 1
                    while selectedrow <= 7 and scores[2][selectedrow].locked do selectedrow = selectedrow + 1 end
                    if selectedrow > 7 then selectedrow = 0 end
                end
                drawScores(positions.scores.x, positions.scores.y, scores, selectedcol and 2 or 1, selectedrow)
            else
                selectedcol, selectedrow = false, 0
                drawScores(positions.scores.x, positions.scores.y, scores)
            end
        elseif params.keycode == keys.one and rollsRemaining < 3 and rollsRemaining > 0 then
            dice[1].locked = not dice[1].locked
            drawDice(positions.dice.x, positions.dice.y, dice)
        elseif params.keycode == keys.two and rollsRemaining < 3 and rollsRemaining > 0 then
            dice[2].locked = not dice[2].locked
            drawDice(positions.dice.x, positions.dice.y, dice)
        elseif params.keycode == keys.three and rollsRemaining < 3 and rollsRemaining > 0 then
            dice[3].locked = not dice[3].locked
            drawDice(positions.dice.x, positions.dice.y, dice)
        elseif params.keycode == keys.four and rollsRemaining < 3 and rollsRemaining > 0 then
            dice[4].locked = not dice[4].locked
            drawDice(positions.dice.x, positions.dice.y, dice)
        elseif params.keycode == keys.five and rollsRemaining < 3 and rollsRemaining > 0 then
            dice[5].locked = not dice[5].locked
            drawDice(positions.dice.x, positions.dice.y, dice)
        elseif params.keycode == keys.q then break
        elseif params.keycode == keys.up and rollsRemaining < 3 then
            if selectedrow == 0 then
                selectedcol = false
                selectedrow = 2
                while selectedrow <= 7 and scores[1][selectedrow].locked do selectedrow = selectedrow + 1 end
                if selectedrow > 7 then
                    selectedcol = true
                    selectedrow = 1
                    while selectedrow <= 7 and scores[2][selectedrow].locked do selectedrow = selectedrow + 1 end
                    if selectedrow > 7 then selectedrow = 0 end
                end
            end
            if selectedrow > (selectedcol and 1 or 2) then
                local oldrow = selectedrow
                repeat selectedrow = selectedrow - 1 until selectedrow < (selectedcol and 1 or 2) or not scores[selectedcol and 2 or 1][selectedrow].locked
                if selectedrow < (selectedcol and 1 or 2) then selectedrow = oldrow end
            end
            drawScores(positions.scores.x, positions.scores.y, scores, selectedcol and 2 or 1, selectedrow)
        elseif params.keycode == keys.down and rollsRemaining < 3 then
            if selectedrow == 0 then
                selectedcol = false
                selectedrow = 7
                while selectedrow >= 2 and scores[1][selectedrow].locked do selectedrow = selectedrow - 1 end
                if selectedrow < 2 then
                    selectedcol = true
                    selectedrow = 7
                    while selectedrow >= 1 and scores[2][selectedrow].locked do selectedrow = selectedrow - 1 end
                    if selectedrow < 1 then selectedrow = 0 end
                end
            end
            if selectedrow > 0 and selectedrow < 7 then
                local oldrow = selectedrow
                repeat selectedrow = selectedrow + 1 until selectedrow > 7 or not scores[selectedcol and 2 or 1][selectedrow].locked
                if selectedrow > 7 then selectedrow = oldrow end
            end
            drawScores(positions.scores.x, positions.scores.y, scores, selectedcol and 2 or 1, selectedrow)
        elseif (params.keycode == keys.left or params.keycode == keys.right) and rollsRemaining < 3 and selectedrow ~= 1 and (selectedrow == 0 or not scores[selectedcol and 1 or 2][selectedrow].locked) then
            if selectedrow == 0 then
                selectedcol = params.keycode == keys.right
                selectedrow = (selectedcol and 1 or 2)
                while selectedrow <= 7 and scores[selectedcol and 2 or 1][selectedrow].locked do selectedrow = selectedrow + 1 end
                if selectedrow > 7 then
                    selectedcol = not selectedcol
                    selectedrow = (selectedcol and 1 or 2)
                    while selectedrow <= 7 and scores[selectedcol and 2 or 1][selectedrow].locked do selectedrow = selectedrow + 1 end
                    if selectedrow > 7 then selectedrow = 0 end
                end
            else selectedcol = not selectedcol end
            drawScores(positions.scores.x, positions.scores.y, scores, selectedcol and 2 or 1, selectedrow)
        elseif params.keycode == keys.enter and selectedrow ~= 0 and rollsRemaining < 3 and not scores[selectedcol and 2 or 1][selectedrow].locked then
            confirmScore(scores, selectedcol and 2 or 1, selectedrow)
            dice = {{value = 0}, {value = 0}, {value = 0}, {value = 0}, {value = 0}}
            rollsRemaining = 3
            drawStatus(positions.status.x, positions.status.y, scores, rollsRemaining)
            drawScores(positions.scores.x, positions.scores.y, scores)
            drawDice(positions.dice.x, positions.dice.y, dice)
            drawRollCup(positions.rollCup.x, positions.rollCup.y, ('%x'):format(cupColor))
            filledScores = filledScores + 1
        elseif params.keycode == keys.c then
            cupColor = cupColor + 1
            if cupColor > 0xf then cupColor = 0x0 end
            drawRollCup(positions.rollCup.x, positions.rollCup.y, ('%x'):format(cupColor))
        end
    elseif ev == "mouse_click" and params.button == 1 then
        if ((params.x >= positions.rollCup.x and params.x < positions.rollCup.x + 5 and params.y >= positions.rollCup.y and params.y < positions.rollCup.y + 5) or (params.x >= positions.rollCup.x - 5 and params.x < positions.rollCup.x - 1 and params.y == positions.rollCup.y + 2)) and rollsRemaining > 0 and not (dice[1].locked and dice[2].locked and dice[3].locked and dice[4].locked and dice[5].locked) then
            rollsRemaining = rollsRemaining - 1
            confirmScore(scores)
            drawScores(positions.scores.x, positions.scores.y, scores)
            drawStatus(positions.status.x, positions.status.y, scores, rollsRemaining)
            rollDice(dice, positions.dice.x, positions.dice.y, positions.rollCup.x, positions.rollCup.y, ('%x'):format(cupColor), rollsRemaining < 1)
            calculateScores(scores, dice)
            if rollsRemaining == 0 then
                selectedcol = false
                selectedrow = 2
                while selectedrow <= 7 and scores[1][selectedrow].locked do selectedrow = selectedrow + 1 end
                if selectedrow > 7 then
                    selectedcol = true
                    selectedrow = 1
                    while selectedrow <= 7 and scores[2][selectedrow].locked do selectedrow = selectedrow + 1 end
                    if selectedrow > 7 then selectedrow = 0 end
                end
                drawScores(positions.scores.x, positions.scores.y, scores, selectedcol and 2 or 1, selectedrow)
            else
                selectedcol, selectedrow = false, 0
                drawScores(positions.scores.x, positions.scores.y, scores)
            end
        elseif params.x >= positions.dice.x and params.x < positions.dice.x + 15 and params.y >= positions.dice.y and params.y < positions.dice.y + 2 and rollsRemaining < 3 and rollsRemaining > 0 then
            dice[math.floor((params.x - positions.dice.x) / 3) + 1].locked = not dice[math.floor((params.x - positions.dice.x) / 3) + 1].locked
            drawDice(positions.dice.x, positions.dice.y, dice)
        elseif params.x >= positions.scores.x and params.x < positions.scores.x + 40 and params.y >= positions.scores.y and params.y < positions.scores.y + 7 and rollsRemaining < 3 then
            local col, row = params.x - positions.scores.x >= 20, params.y - positions.scores.y + 1
            if selectedcol == col and selectedrow == row and not scores[col and 2 or 1][row].locked then
                confirmScore(scores, selectedcol and 2 or 1, selectedrow)
                dice = {{value = 0}, {value = 0}, {value = 0}, {value = 0}, {value = 0}}
                rollsRemaining = 3
                drawStatus(positions.status.x, positions.status.y, scores, rollsRemaining)
                drawScores(positions.scores.x, positions.scores.y, scores)
                drawDice(positions.dice.x, positions.dice.y, dice)
                drawRollCup(positions.rollCup.x, positions.rollCup.y, ('%x'):format(cupColor))
                filledScores = filledScores + 1
            elseif (col or row > 1) and not scores[col and 2 or 1][row].locked then
                selectedcol = col
                selectedrow = row
                drawScores(positions.scores.x, positions.scores.y, scores, selectedcol and 2 or 1, selectedrow)
            end
        end
    end
end

if filledScores == 13 then
    for i = 1, 3 do
        drawLogo(positions.logo.x, positions.logo.y, '5')
        util.sleep(0.5)
        drawLogo(positions.logo.x, positions.logo.y, '0')
        util.sleep(0.5)
    end
    drawLogo(positions.logo.x, positions.logo.y, '5')
    util.sleep(1)
end

term.close()
local sum = 0
for e = 1, 2 do for i,v in ipairs(scores[e]) do if v.value and v.locked then sum = sum + v.value end end end
print("Final score: " .. sum)
print("Thanks for playing YahtCC!")
