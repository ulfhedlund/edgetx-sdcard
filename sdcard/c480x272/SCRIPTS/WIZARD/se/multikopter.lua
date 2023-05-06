---- #########################################################################
---- #                                                                       #
---- # Copyright (C) OpenTX                                                  #
-----#                                                                       #
-----# Credits: graphics by Radiomaster                                      #
-----#                                                                       #
---- # License GPLv2: http://www.gnu.org/licenses/gpl-2.0.html               #
---- #                                                                       #
---- # This program is free software; you can redistribute it and/or modify  #
---- # it under the terms of the GNU General Public License version 2 as     #
---- # published by the Free Software Foundation.                            #
---- #                                                                       #
---- # This program is distributed in the hope that it will be useful        #
---- # but WITHOUT ANY WARRANTY; without even the implied warranty of        #
---- # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
---- # GNU General Public License for more details.                          #
---- #                                                                       #
---- #########################################################################

local VALUE = 0
local COMBO = 1

local edit = false
local page = 1
local current = 1
local pages = {}
local fields = {}
local switches = {"SA", "SB", "SC", "SD", "SE", "SF", "SG"}

-- load common Bitmaps
local ImgMarkBg = Bitmap.open("../img/mark_bg.png")
local BackgroundImg = Bitmap.open("../img/background.png")
local ImgPageUp = Bitmap.open("../img/pageup.png")
local ImgPageDn = Bitmap.open("../img/pagedn.png")


-- Change display attribute to current field
local function addField(step)
  local field = fields[current]
  local min, max
  if field[3] == VALUE then
    min = field[6]
    max = field[7]
  elseif field[3] == COMBO then
    min = 0
    max = #(field[6]) - 1
  end
  if (step < 0 and field[5] > min) or (step > 0 and field[5] < max) then
    field[5] = field[5] + step
  end
end

-- Select the next or previous page
local function selectPage(step)
  page = 1 + ((page + step - 1 + #pages) % #pages)
  edit = false
  current = 1
end

-- Select the next or previous editable field
local function selectField(step)
  repeat
    current = 1 + ((current + step - 1 + #fields) % #fields)
  until fields[current][4]==1
end

-- Redraw the current page
local function redrawFieldsPage(event)

  for index = 1, 10, 1 do
    local field = fields[index]
    if field == nil then
      break
    end

    local attr = current == (index) and ((edit == true and BLINK or 0) + INVERS) or 0
    attr = attr + TEXT_COLOR

    if field[4] == 1 then
      if field[3] == VALUE then
        lcd.drawNumber(field[1], field[2], field[5], LEFT + attr)
      elseif field[3] == COMBO then
        if field[5] >= 0 and field[5] < #(field[6]) then
          lcd.drawText(field[1],field[2], field[6][1+field[5]], attr)
        end
      end
    end
  end
end

local function updateField(field)
  local value = field[5]
end

-- Main
local function runFieldsPage(event)
  if event == EVT_VIRTUAL_EXIT then -- exit script
    return 2
  elseif event == EVT_VIRTUAL_ENTER then -- toggle editing/selecting current field
    if fields[current][5] ~= nil then
      edit = not edit
      if edit == false then
        updateField(fields[current])
      end
    end
  elseif edit then
    if event == EVT_VIRTUAL_INC or event == EVT_VIRTUAL_INC_REPT then
      addField(1)
    elseif event == EVT_VIRTUAL_DEC or event == EVT_VIRTUAL_DEC_REPT then
      addField(-1)
    end
  else
    if event == EVT_VIRTUAL_NEXT then
      selectField(1)
    elseif event == EVT_VIRTUAL_PREV then
      selectField(-1)
    end
  end
  redrawFieldsPage(event)
  return 0
end

-- set visibility flags starting with SECOND field of fields
local function setFieldsVisible(...)
  local arg={...}
  local cnt = 2
  for i,v in ipairs(arg) do
    fields[cnt][4] = v
    cnt = cnt + 1
  end
end

-- draws one letter mark
local function drawMark(x, y, name)
  lcd.drawBitmap(ImgMarkBg, x, y)
  lcd.drawText(x+8, y+3, name, TEXT_COLOR)
end


local ThrottleFields = {
  {50, 50, COMBO, 1, 2, { "KA1", "KA2", "KA3", "KA4", "KA5", "KA6", "KA7", "KA8" } },
}

local ThrottleBackground

local function runThrottleConfig(event)
  lcd.clear()
  if ThrottleBackground == nil then
    ThrottleBackground = Bitmap.open("../img/multirotor/throttle.png")
  end
  lcd.drawBitmap(ThrottleBackground, 0, 0)
  lcd.drawBitmap(ImgPageDn, 455, 95)
  fields = ThrottleFields
  lcd.drawText(40, 20, "Ange gaskanal", TEXT_COLOR)
  lcd.drawFilledRectangle(40, 45, 100, 30, TEXT_BGCOLOR)
  fields[1][4]=1
  local result = runFieldsPage(event)
  return result
end

local RollFields = {
  {50, 50, COMBO, 1, 0, { "KA1", "KA2", "KA3", "KA4", "KA5", "KA6", "KA7", "KA8" } },
}

local RollBackground

local function runRollConfig(event)
  lcd.clear()
  if RollBackground == nil then
    RollBackground = Bitmap.open("../img/multirotor/roll.png")
  end
  lcd.drawBitmap(RollBackground, 0, 0)
  lcd.drawBitmap(ImgPageUp, 0, 95)
  lcd.drawBitmap(ImgPageDn, 455, 95)
  fields = RollFields
  lcd.drawText(40, 20, "Ange rollkanal", TEXT_COLOR)
  lcd.drawFilledRectangle(40, 45, 100, 30, TEXT_BGCOLOR)
  fields[1][4]=1
  local result = runFieldsPage(event)
  return result
end

local PitchFields = {
  {50, 50, COMBO, 1, 1, { "KA1", "KA2", "KA3", "KA4", "KA5", "KA6", "KA7", "KA8" } },
}

local PitchBackground

local function runPitchConfig(event)
  lcd.clear()
  if PitchBackground == nil then
    PitchBackground = Bitmap.open("../img/multirotor/pitch.png")
  end
  lcd.drawBitmap(PitchBackground, 0, 0)
  lcd.drawBitmap(ImgPageUp, 0, 95)
  lcd.drawBitmap(ImgPageDn, 455, 95)
  fields = PitchFields
  lcd.drawText(40, 20, "Ange pitchkanal", TEXT_COLOR)
  lcd.drawFilledRectangle(40, 45, 100, 30, TEXT_BGCOLOR)
  fields[1][4]=1
  local result = runFieldsPage(event)
  return result
end

local YawFields = {
  {50, 50, COMBO, 1, 3, { "KA1", "KA2", "KA3", "KA4", "KA5", "KA6", "KA7", "KA8" } },
}

local YawBackground

local function runYawConfig(event)
  lcd.clear()
  if YawBackground == nil then
    YawBackground = Bitmap.open("../img/multirotor/yaw.png")
  end
  lcd.drawBitmap(YawBackground, 0, 0)
  lcd.drawBitmap(ImgPageUp, 0, 95)
  lcd.drawBitmap(ImgPageDn, 455, 95)
  fields = YawFields
  lcd.drawText(40, 20, "Ange yawkanal", TEXT_COLOR)
  lcd.drawFilledRectangle(40, 45, 100, 30, TEXT_BGCOLOR)
  fields[1][4]=1
  local result = runFieldsPage(event)
  return result
end

local ArmFields = {
  {50, 50, COMBO, 1, 5, { "SA", "SB", "SC", "SD", "SE", "SF"} },
}

local ArmBackground

local function runArmConfig(event)
  lcd.clear()
  if ArmBackground == nil then
    ArmBackground = Bitmap.open("../img/multirotor/arm.png")
  end
  lcd.drawBitmap(ArmBackground, 0, 0)
  lcd.drawBitmap(ImgPageUp, 0, 95)
  lcd.drawBitmap(ImgPageDn, 455, 95)
  fields = ArmFields
  lcd.drawText(40, 20, "Ange brytare för motor på/av", TEXT_COLOR)
  lcd.drawFilledRectangle(40, 45, 100, 30, TEXT_BGCOLOR)
  fields[1][4]=1
  local result = runFieldsPage(event)
  return result
end

local BeeperFields = {
  {50, 50, COMBO, 1, 3, { "SA", "SB", "SC", "SD", "SE", "SF"} },
}

local BeeperBackground

local function runBeeperConfig(event)
  lcd.clear()
  if BeeperBackground == nil then
    BeeperBackground = Bitmap.open("../img/multirotor/beeper.png")
  end
  lcd.drawBitmap(BeeperBackground, 0, 0)
  lcd.drawBitmap(ImgPageUp, 0, 95)
  lcd.drawBitmap(ImgPageDn, 455, 95)
  fields = BeeperFields
  lcd.drawText(40, 20, "Ange brytare för tuta/pip", TEXT_COLOR)
  lcd.drawFilledRectangle(40, 45, 100, 30, TEXT_BGCOLOR)
  fields[1][4]=1
  local result = runFieldsPage(event)
  return result
end

local ModeFields = {
  {50, 50, COMBO, 1, 0, { "SA", "SB", "SC", "SD", "SE", "SF"} },
}

local ModeBackground

local function runModeConfig(event)
  lcd.clear()
  if ModeBackground == nil then
    ModeBackground = Bitmap.open("../img/multirotor/mode.png")
  end
  lcd.drawBitmap(ModeBackground, 0, 0)
  lcd.drawBitmap(ImgPageUp, 0, 95)
  lcd.drawBitmap(ImgPageDn, 455, 95)
  fields = ModeFields
  lcd.drawText(40, 20, "Ange brytare för flygläge", TEXT_COLOR)
  lcd.drawFilledRectangle(40, 45, 100, 30, TEXT_BGCOLOR)
  fields[1][4]=1
  local result = runFieldsPage(event)
  return result
end

local lineIndex
local function drawNextChanelLine(text, text2)
  lcd.drawText(40, lineIndex, text, TEXT_COLOR)
  lcd.drawText(242, lineIndex, ": KA" .. text2 + 1, TEXT_COLOR)
  lineIndex = lineIndex + 20
end

local function drawNextSwitchLine(text, text2)
  lcd.drawText(40, lineIndex, text, TEXT_COLOR)
  lcd.drawText(242, lineIndex, ": " ..switches[text2 + 1], TEXT_COLOR)
  lineIndex = lineIndex + 20
end


local ConfigSummaryFields = {
  {110, 250, COMBO, 1, 0, { "Nej, jag behöver ändra något", "Ja, allt stämmer - skapa modellen!"} },
}

local ImgSummary

local function runConfigSummary(event)
  lcd.clear()
  if ImgSummary == nil then
    ImgSummary = Bitmap.open("../img/summary.png")
  end
  fields = ConfigSummaryFields
  lcd.drawBitmap(BackgroundImg, 0, 0)
  lcd.drawBitmap(ImgPageUp, 0, 95)
  lcd.drawBitmap(ImgSummary, 300, 60)
  lineIndex = 40
  -- throttle
  drawNextChanelLine("Gaskanal", ThrottleFields[1][5])
  -- roll
  drawNextChanelLine("Rollkanal",RollFields[1][5])
  -- pitch
  drawNextChanelLine("Pitchkanal",PitchFields[1][5])
  -- yaw
  drawNextChanelLine("Yawkanal",YawFields[1][5])
  -- arm
  drawNextSwitchLine("Motor av/på",ArmFields[1][5])
  -- beeper
  drawNextSwitchLine("Brytare tuta",BeeperFields[1][5])
  -- mode
  drawNextSwitchLine("Brytare flygläge",ModeFields[1][5])

  local result = runFieldsPage(event)
  if(fields[1][5] == 1 and edit == false) then
    selectPage(1)
  end
  return result
end

local function addMix(channel, input, name, weight, index)
  local mix = { source=input, name=name }
  if weight ~= nil then
    mix.weight = weight
  end
  if index == nil then
    index = 0
  end
  model.insertMix(channel, index, mix)
end

local function createModel(event)
  lcd.clear()
  lcd.drawBitmap(BackgroundImg, 0, 0)
  lcd.drawBitmap(ImgSummary, 300, 60)
  model.defaultInputs()
  model.deleteMixes()
  -- throttle
  addMix(ThrottleFields[1][5], MIXSRC_FIRST_INPUT+defaultChannel(2), "Gas")
  -- roll
  addMix(RollFields[1][5], MIXSRC_FIRST_INPUT+defaultChannel(0), "Roll")
  -- pitch
  addMix(PitchFields[1][5], MIXSRC_FIRST_INPUT+defaultChannel(1), "Pitch")
  -- yaw
  addMix(YawFields[1][5], MIXSRC_FIRST_INPUT+defaultChannel(3), "Yaw")
  addMix(4, MIXSRC_SA + ArmFields[1][5], "PåAv")
  addMix(5, MIXSRC_SA + BeeperFields[1][5], "Tuta")
  addMix(6, MIXSRC_SA + ModeFields[1][5], "Läge")

  lcd.drawText(70, 90, "Modellen har skapats!", TEXT_COLOR)
  lcd.drawText(100, 130, "Tryck RTN för att avsluta", TEXT_COLOR)
  return 2
end

-- Init
local function init()
  current, edit = 1, false
  pages = {
    runThrottleConfig,
    runRollConfig,
    runPitchConfig,
    runYawConfig,
    runArmConfig,
    runBeeperConfig,
    runModeConfig,
    runConfigSummary,
    createModel,
  }
end

-- Main
local function run(event)
  if event == nil then
    error("Kan inte köras som ett modellskript!")
    return 2
  elseif event == EVT_VIRTUAL_NEXT_PAGE and page < #pages-1 then
    selectPage(1)
  elseif event == EVT_VIRTUAL_PREV_PAGE and page > 1 then
    killEvents(event);
    selectPage(-1)
  end

  local result = pages[page](event)
  return result
end

return { init=init, run=run }
