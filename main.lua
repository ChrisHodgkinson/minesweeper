-- Minesweeper

-- main.lua

local gridGroup = display.newGroup()
local board     = display.newGroup()
local wiper     = display.newGroup()
 
local board = {}
local boardHeight = 15
local boardWidth  = 15
local totalMines  = 30
local ctrlDown     = false


local function keyListener ( event )
  local phase = event.phase
  local key = event.keyName
  ctrlDown = (key == "leftControl" or key == "rightControl") and phase == "down" or false
end

local function placeNumbers ()

end

local function placeMines ()

end

local function createBoard ()
  --for f = 
end

local function zoneClicked( event )
  local thisZone = event.target
  local phase = event.phase
end
Runtime:addEventListener ( "key", keyListener )


-- EOF