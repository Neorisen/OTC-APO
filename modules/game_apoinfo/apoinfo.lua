
local apoinfoWindow = nil
local apoinfoButton = nil
local apoinfoText = nil
local apoinfoTextLabel = nil



function init()
  apoinfoWindow = g_ui.displayUI('apoinfowindow')
  apoinfoWindow:hide()

  apoinfoButton = modules.client_topmenu.addRightGameButton('apoinfoButton', tr('ApoInfo'), '/images/topbuttons/apoinfo', toggle)
  
  apoinfoText = apoinfoWindow:getChildById('apoinfoText')
  apoinfoTextLabel = apoinfoWindow:getChildById('apoinfoTextLabel')
  apoinfoWindow:breakAnchors()
  apoinfoWindow:setPosition({x = 100, y = 100})
  apoinfoWindow.onEnter = hide
  apoinfoWindow.onEscape = hide
  
  apoinfoText = apoinfoWindow:recursiveGetChildById('text')
  local text = "Ceny NPC\nNPC Dunia - (Cena + % stalego kleinta)\n ZBROJE\n plate armor [500gp + 20% = 600gp]\n noble armor [1,5k + 20% = 1,8k]\n dark armor [1k + 20% = 1,2k] \n red robe [2cc + 20% = 2.4cc] \n crown armor [25cc + 20% = 30cc] \n golden armor [45cc +20% = 54cc] \n dragon scale mail [100cc + 20% = 120cc]\n MIECZE \n spike sword [2,5k + 20% = 3k] \n serpent sword [3k + 20% = 3.6k] \n bright sword [35cc + 20% = 42cc] \n giant sword [35cc + 20% = 42cc] \n TOPORY\n guardian helbard [1cc + 20% = 1.2cc] \n great helbard [10cc + 20% = 12cc]\n daramanian waraxe [15cc + 20% = 18cc]\n TARCZE\n vampire shield [10cc + 20% = 12cc] \n medusa shield [5cc +20% = 6cc]\n NOGAWICE\n plate legs [700gp + 20% = 840gp] \n crown legs [60cc + 20% = 72cc]\n HELMY\n steel helmet [300gp + 20% = 360gp]\n crown helmet [1cc + 20% = 1,2cc]\n mystic turban [3cc + 20% = 3,6 cc]\n AMULETY\n amulet of loss [15cc + 20% = 18cc]\n BUTY\n crocodile boots [500gp + 20% = 600gp]\n\nNPC Spider - (Cena + % stalego kleinta)\n ZBROJE\n crown armor [15cc + 10% =16,5cc]\n knight armor [1cc + 10% = 1,1cc]\n noble armor [500gp + 10% = 550gp]\n blue robe [1cc + 10% = 1,1cc]\n MIECZE\n ice rapier [5k + 10% = 5,5k]\n fire sword [30cc + 10% = 33cc]\n OBUCHY\n dragon hammer [2cc + 10% = 2,2cc]\n TOPORY\n knight axe [1cc + 10% = 1,1cc]\n great helbard [3cc + 10% = 3,3cc] \n dragon lance [2cc + 10% = 2,2cc]\n daramanian waraxe [8cc + 10% = 8,8cc]\n fire axe [25cc + 10% = 27,5cc]\n HELMY\n warrior helmet [2cc + 10% = 2,2cc]\n crown helmet [7k + 10% = 7,7k]\n crusader helmet [2,5cc + 10% = 2,75cc]\n royal helmet [20cc + 10% = 22cc]\n TARCZE\n dragon shield [1cc + 10% = 1,1cc]\n tower shield [2cc + 10% = 2,2cc]\n crown shield [2cc + 10% = 2,2cc]\n vampire shield [3cc + 10% = 3,3cc]\n AMULETY\n platinum amulet [1cc + 10% = 1,1cc]\n NOGAWICE\n knight legs [12cc + 10% = 13,2cc]\n BUTY\n crocodile boots [100gp + 10% = 110gp]\n boots of haste [1cc + 10% = 1,1cc]\n steel boots [10cc + 10% = 11cc]"

  local description = apoinfoWindow:getChildById('description')
  apoinfoText:setText(text)
end

function terminate()
  apoinfoWindow:destroy()
  apoinfoButton:destroy()
end

function toggle()
    if apoinfoWindow:isVisible() then
        apoinfoWindow:hide()
        apoinfoButton:setOn(false)
    else
        apoinfoWindow:show()
        apoinfoButton:setOn(true)
        apoinfoWindow:focus()
    end
end

function hide()
    apoinfoWindow:hide()
    apoinfoButton:setOn(false)
end
