skillsWindow = nil
skillsButton = nil

function init()
  connect(LocalPlayer, {
    onExperienceChange = onExperienceChange,
    onLevelChange = onLevelChange,
    onHealthChange = onHealthChange,
    onManaChange = onManaChange,
    onSoulChange = onSoulChange,
    onFreeCapacityChange = onFreeCapacityChange,
    onTotalCapacityChange = onTotalCapacityChange,
    onStaminaChange = onStaminaChange,
    onOfflineTrainingChange = onOfflineTrainingChange,
    onRegenerationChange = onRegenerationChange,
    onSpeedChange = onSpeedChange,
    onBaseSpeedChange = onBaseSpeedChange,
    onMagicLevelChange = onMagicLevelChange,
    onBaseMagicLevelChange = onBaseMagicLevelChange,
    onSkillChange = onSkillChange,
    onBaseSkillChange = onBaseSkillChange
  })
  connect(g_game, {
    onGameStart = refresh,
    onGameEnd = offline
  })

  skillsButton = modules.client_topmenu.addRightGameToggleButton('skillsButton', tr('Skills') .. ' (Ctrl+S)', '/images/topbuttons/skills', toggle)
  skillsButton:setOn(true)
  skillsWindow = g_ui.loadUI('skills', modules.game_interface.getRightPanel())

  g_keyboard.bindKeyDown('Ctrl+S', toggle)

  refresh()
  skillsButton:hide()
  skillsWindow:setup()
end

function terminate()
  disconnect(LocalPlayer, {
    onExperienceChange = onExperienceChange,
    onLevelChange = onLevelChange,
    onHealthChange = onHealthChange,
    onManaChange = onManaChange,
    onSoulChange = onSoulChange,
    onFreeCapacityChange = onFreeCapacityChange,
    onTotalCapacityChange = onTotalCapacityChange,
    onStaminaChange = onStaminaChange,
    onOfflineTrainingChange = onOfflineTrainingChange,
    onRegenerationChange = onRegenerationChange,
    onSpeedChange = onSpeedChange,
    onBaseSpeedChange = onBaseSpeedChange,
    onMagicLevelChange = onMagicLevelChange,
    onBaseMagicLevelChange = onBaseMagicLevelChange,
    onSkillChange = onSkillChange,
    onBaseSkillChange = onBaseSkillChange
  })
  disconnect(g_game, {
    onGameStart = refresh,
    onGameEnd = offline
  })

  g_keyboard.unbindKeyDown('Ctrl+S')
  skillsWindow:destroy()
  skillsButton:destroy()
end

function expForLevel(level)
  return math.floor((50*level*level*level)/3 - 100*level*level + (850*level)/3 - 200)
end

function expToAdvance(currentLevel, currentExp)
  return expForLevel(currentLevel+1) - currentExp
end

function resetSkillColor(id)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('value')
  widget:setColor('#bbbbbb')
end

function setSkillBase(id, value, baseValue)
  if baseValue <= 0 or value < 0 then
    return
  end
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('value')

  if value > baseValue then
    widget:setColor('#008b00') -- green
    skill:setTooltip(baseValue .. ' +' .. (value - baseValue))
  elseif value < baseValue then
    widget:setColor('#b22222') -- red
    skill:setTooltip(baseValue .. ' ' .. (value - baseValue))
  else
    widget:setColor('#bbbbbb') -- default
    skill:removeTooltip()
  end
end

function setSkillValue(id, value)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('value')
  widget:setText(value)
end

function setSkillColor(id, value)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('value')
  widget:setColor(value)
end

function setSkillTooltip(id, value)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('value')
  widget:setTooltip(value)
end

function setSkillPercent(id, percent, tooltip)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('percent')
  widget:setPercent(math.floor(percent))

  if tooltip then
    widget:setTooltip(tooltip)
  end
end

function checkAlert(id, value, maxValue, threshold, greaterThan)
  if greaterThan == nil then greaterThan = false end
  local alert = false

  -- maxValue can be set to false to check value and threshold
  -- used for regeneration checking
  if type(maxValue) == 'boolean' then
    if maxValue then
      return
    end

    if greaterThan then
      if value > threshold then
        alert = true
      end
    else
      if value < threshold then
        alert = true
      end
    end
  elseif type(maxValue) == 'number' then
    if maxValue < 0 then
      return
    end

    local percent = math.floor((value / maxValue) * 100)
    if greaterThan then
      if percent > threshold then
        alert = true
      end
    else
      if percent < threshold then
        alert = true
      end
    end
  end

  if alert then
    setSkillColor(id, '#b22222') -- red
  else
    resetSkillColor(id)
  end
end

function update()
  local offlineTraining = skillsWindow:recursiveGetChildById('offlineTraining')
  if not g_game.getFeature(GameOfflineTrainingTime) then
    offlineTraining:hide()
  else
    offlineTraining:show()
  end

  local regenerationTime = skillsWindow:recursiveGetChildById('regenerationTime')
  if not g_game.getFeature(GamePlayerRegenerationTime) then
    regenerationTime:hide()
  else
    regenerationTime:show()
  end
end

function refresh()
  local player = g_game.getLocalPlayer()
  if not player then return end

  if expSpeedEvent then expSpeedEvent:cancel() end
  expSpeedEvent = cycleEvent(checkExpSpeed, 20*1000)

  onExperienceChange(player, player:getExperience())
  onLevelChange(player, player:getLevel(), player:getLevelPercent())
  onHealthChange(player, player:getHealth(), player:getMaxHealth())
  onManaChange(player, player:getMana(), player:getMaxMana())
  onSoulChange(player, player:getSoul())
  onFreeCapacityChange(player, player:getFreeCapacity())
  onStaminaChange(player, player:getStamina())
  onMagicLevelChange(player, player:getMagicLevel(), player:getMagicLevelPercent())
  onOfflineTrainingChange(player, player:getOfflineTrainingTime())
  onRegenerationChange(player, player:getRegenerationTime())
  onSpeedChange(player, player:getSpeed())

  for i=0,6 do
    onSkillChange(player, i, player:getSkillLevel(i), player:getSkillLevelPercent(i))
    onBaseSkillChange(player, i, player:getSkillBaseLevel(i))
  end

  update()

  local contentsPanel = skillsWindow:getChildById('contentsPanel')
  skillsWindow:setContentMinimumHeight(44)
  skillsWindow:setContentMaximumHeight(390)
end

function offline()
  if expSpeedEvent then expSpeedEvent:cancel() expSpeedEvent = nil end
end

function toggle()
  if skillsButton:isOn() then
    skillsWindow:close()
    skillsButton:setOn(false)
  else
    skillsWindow:open()
    skillsButton:setOn(true)
  end
end

function checkExpSpeed()
  local player = g_game.getLocalPlayer()
  if not player then return end

  local currentLevel = player:getLevel()
  local currentPercent = player:getLevelPercent()
  local currentExp = player:getExperience()
  local currentTime = g_clock.seconds()

  if (currentLevel >= 497) and (currentExp == 0) then
    currentExp = (currentLevel * 100) + currentPercent
  end
  if player.lastExps ~= nil then
    player.expSpeed = (currentExp - player.lastExps[1][1])/(currentTime - player.lastExps[1][2])
    -- <===============================================>
    -- jesli dopiero wbiles 497 lvl i wskakujesz na buga XP to trzeba zresetowac exp/h:
    if player.expSpeed < 0 then
      player.lastExps = {}
      player.expSpeed = 0
    end
    onLevelChange(player, player:getLevel(), player:getLevelPercent())
  else
    player.lastExps = {}
  end
  table.insert(player.lastExps, {currentExp, currentTime})
  if #player.lastExps > 30 then
    table.remove(player.lastExps, 1)
  end
end

function onMiniWindowClose()
  skillsButton:setOn(false)
end

function onSkillButtonClick(button)
  local percentBar = button:getChildById('percent')
  if percentBar then
    percentBar:setVisible(not percentBar:isVisible())
    if percentBar:isVisible() then
      button:setHeight(21)
    else
      button:setHeight(21 - 6)
    end
  end
end

function onExperienceChange(localPlayer, value)
  setSkillValue('experience', value)
end

--[[function onLevelChange(localPlayer, value, percent)
  setSkillValue('level', value)
  local text = tr('You have %s percent to go', 100 - percent)
  local myLevel = localPlayer:getLevel()
  local percentLeft = 100 - percent
  local currentExp = 0
  if localPlayer:getExperience() ~= 0 and localPlayer:getLevel() < 500 and localPlayer:getLevel() >= 1 then
    text = text .. '\n' .. tr('%s of experience left to next level', expToAdvance(localPlayer:getLevel(), localPlayer:getExperience()))
  else
    if localPlayer:getLevel() < 2590 then
      local currentLevelExp = expToAdvance(myLevel, expForLevel(myLevel))
      local expForNextLevel = currentLevelExp * (percentLeft / 100)
      local myExp = expForLevel(myLevel) + (currentLevelExp * (percent / 100))
      setSkillValue('experience', myExp)
      text = text .. '\n' .. tr('%s of experience left to next level', expForNextLevel)
    end
  end

  if localPlayer.expSpeed ~= nil then
    if localPlayer:getLevel() <= 2590 and localPlayer:getLevel() >= 497 then
      currentExp = tonumber(skillsWindow:recursiveGetChildById('experience'):getChildById('value'):getText())
    else
      currentExp = localPlayer:getExperience()
    end
     local expPerHour = math.floor(localPlayer.expSpeed * 3600)
     if expPerHour > 0 then
        local nextLevelExp = expForLevel(localPlayer:getLevel()+1)
        local hoursLeft = (nextLevelExp - currentExp) / expPerHour
        local minutesLeft = math.floor((hoursLeft - math.floor(hoursLeft))*60)
        hoursLeft = math.floor(hoursLeft)
        modules.client_topmenu.updateExpSpeed(expPerHour, hoursLeft, minutesLeft)
        text = text .. '\n' .. tr('%d of experience per hour', expPerHour)
        text = text .. '\n' .. tr('Next level in %d hours and %d minutes', hoursLeft, minutesLeft)
     end
  end

  setSkillPercent('level', percent, text)
end
]]
function onLevelChange(localPlayer, value, percent)
  setSkillValue('level', value)
  local myLevel = localPlayer:getLevel()
  local text = ''

  text = tr('Do kolejnego lvla brakuje Ci %d procent', 100 - percent)
  if myLevel >= 497 then
    modules.game_hotkeys.topExperienceBar:setText(tr('%d lvl (%d)', myLevel, percent))
    if localPlayer.expSpeed ~= nil then
      local hoursLeft = 0
      local minutesLeft = 0
      local percentPerHour = math.floor(localPlayer.expSpeed * 3600)
      local expPerHour = string.format("%.2f", (percentPerHour / 100))
      if percentPerHour > 0 then
          local hoursLeft = (100 - percent) / percentPerHour
          local minutesLeft = math.floor((hoursLeft - math.floor(hoursLeft))*60)
          hoursLeft = math.floor(hoursLeft)
          local topExpBar = "%d lvl (%d%%) | Nastepny poziom za ~ %d minut (%d%%) | %s lvl/h"
          modules.game_hotkeys.topExperienceBar:setText(tr(topExpBar, myLevel, percent, minutesLeft, 100-percent, expPerHour))
          text = text .. '\n' .. tr('%s poziomow na godzine', expPerHour)
          if hoursLeft < 1 then
            text = text .. '\n' .. tr('Nastepny wbijesz za ~ %d minut', minutesLeft)
          else
            text = text .. '\n' .. tr('Nastepny wbijesz za %d godzin i %d minut', hoursLeft, minutesLeft)
          end
      end
    end

  else
    text = text .. '\n' .. tr('%s expa do nastepnego poziomu', expToAdvance(localPlayer:getLevel(), localPlayer:getExperience()))

    if localPlayer.expSpeed ~= nil then
       local expPerHour = math.floor(localPlayer.expSpeed * 3600)
       if expPerHour > 0 then
          local nextLevelExp = expForLevel(localPlayer:getLevel()+1)
          local hoursLeft = (nextLevelExp - localPlayer:getExperience()) / expPerHour
          local minutesLeft = math.floor((hoursLeft - math.floor(hoursLeft))*60)
          hoursLeft = math.floor(hoursLeft)
          text = text .. '\n' .. tr('%d of experience per hour', expPerHour)
          text = text .. '\n' .. tr('Next level in %d hours and %d minutes', hoursLeft, minutesLeft)
       end
    end
  end 
  setSkillPercent('level', percent, text)
  if modules.client_topmenu.topMenu:getChildById('expSpeedLabel'):isVisible() == true then
    modules.client_topmenu.topMenu:getChildById('expSpeedLabel'):setVisible() = false
  end
end

function onHealthChange(localPlayer, health, maxHealth)
  setSkillValue('health', health)
  checkAlert('health', health, maxHealth, 30)
end

function onManaChange(localPlayer, mana, maxMana)
  setSkillValue('mana', mana)
  checkAlert('mana', mana, maxMana, 30)
end

function onSoulChange(localPlayer, soul)
  setSkillValue('soul', soul)
end

function onFreeCapacityChange(localPlayer, freeCapacity)
  setSkillValue('capacity', freeCapacity *100)
  checkAlert('capacity', freeCapacity, localPlayer:getTotalCapacity(), 20)
end

function onTotalCapacityChange(localPlayer, totalCapacity)
  checkAlert('capacity', localPlayer:getFreeCapacity(), totalCapacity, 20)
end

function onStaminaChange(localPlayer, stamina)
  local hours = math.floor(stamina / 60)
  local minutes = stamina % 60
  if minutes < 10 then
    minutes = '0' .. minutes
  end
  local percent = math.floor(100 * stamina / (42 * 60)) -- max is 42 hours

  setSkillValue('stamina', hours .. ":" .. minutes)
  setSkillPercent('stamina', percent, tr('You have %s percent', percent))
end

function onOfflineTrainingChange(localPlayer, offlineTrainingTime)
  if not g_game.getFeature(GameOfflineTrainingTime) then
    return
  end
  local hours = math.floor(offlineTrainingTime / 60)
  local minutes = offlineTrainingTime % 60
  if minutes < 10 then
    minutes = '0' .. minutes
  end
  local percent = 100 * offlineTrainingTime / (12 * 60) -- max is 12 hours

  setSkillValue('offlineTraining', hours .. ":" .. minutes)
  setSkillPercent('offlineTraining', percent, tr('You have %s percent', percent))
end

function onRegenerationChange(localPlayer, regenerationTime)
  if not g_game.getFeature(GamePlayerRegenerationTime) or regenerationTime < 0 then
    return
  end
  local minutes = math.floor(regenerationTime / 60)
  local seconds = regenerationTime % 60
  if seconds < 10 then
    seconds = '0' .. seconds
  end

  setSkillValue('regenerationTime', minutes .. ":" .. seconds)
  checkAlert('regenerationTime', regenerationTime, false, 300)
end

function onSpeedChange(localPlayer, speed)
  setSkillValue('speed', speed)

  onBaseSpeedChange(localPlayer, localPlayer:getBaseSpeed())
end

function onBaseSpeedChange(localPlayer, baseSpeed)
  setSkillBase('speed', localPlayer:getSpeed(), baseSpeed)
end

function onMagicLevelChange(localPlayer, magiclevel, percent)
  setSkillValue('magiclevel', magiclevel)
  setSkillPercent('magiclevel', percent, tr('You have %s percent to go', 100 - percent))

  onBaseMagicLevelChange(localPlayer, localPlayer:getBaseMagicLevel())
end

function onBaseMagicLevelChange(localPlayer, baseMagicLevel)
  setSkillBase('magiclevel', localPlayer:getMagicLevel(), baseMagicLevel)
end

function onSkillChange(localPlayer, id, level, percent)
  setSkillValue('skillId' .. id, level)
  setSkillPercent('skillId' .. id, percent, tr('You have %s percent to go', 100 - percent))

  onBaseSkillChange(localPlayer, id, localPlayer:getSkillBaseLevel(id))
end

function onBaseSkillChange(localPlayer, id, baseLevel)
  setSkillBase('skillId'..id, localPlayer:getSkillLevel(id), baseLevel)
end
