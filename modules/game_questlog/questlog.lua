
local questlogWindow = nil
local questlogButton = nil
local questlogText = nil
local questlogTextLabel = nil



function init()
  questlogWindow = g_ui.displayUI('questlogwindow')
  questlogWindow:hide()

  questlogButton = modules.client_topmenu.addLeftGameButton('questlogButton', tr('Questlog'), '/images/topbuttons/questlog', toggle)
  
  questlogText = questlogWindow:getChildById('questlogText')
  questlogTextLabel = questlogWindow:getChildById('questlogTextLabel')
  questlogWindow:breakAnchors()
  questlogWindow:setPosition({x = 100, y = 100})
  questlogWindow.onEnter = hide
  questlogWindow.onEscape = hide
  
  questlogText = questlogWindow:recursiveGetChildById('text')
  local text = ""
  local textEdit = questlogWindow:getChildById('text')
  local description = questlogWindow:getChildById('description')
  questlogText:setText(text)
end

function terminate()
  questlogWindow:destroy()
  questlogButton:destroy()
end

function toggle()
    if questlogWindow:isVisible() then
        questlogWindow:hide()
        questlogButton:setOn(false)
    else
        questlogWindow:show()
        questlogButton:setOn(true)
        questlogWindow:focus()
    end
end

function hide()
    questlogWindow:hide()
    questlogButton:setOn(false)
end
