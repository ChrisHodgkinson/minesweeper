-- Minesweeper
display.setDefault( "background", .5, .5, .5 )
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

local function zoneClicked( event )
  local thisZone = event.target
  local phase = event.phase
end

local function createBoard ()
  local vOff = 1
  for r = 1, boardHeight do
    local hOff = 1
    board[r]={}
    for c = 1, boardWidth do 
      board[r][c] = display.newRect(((32*c)+hOff), ((32*r)+vOff), 31, 31 )
      board[r][c]:setFillColor(.4, .4, .5, 1)
      board[r][c].strokeWidth = 1 ; board[r][c]:setStrokeColor(0,0,0)
      hOff = hOff + 2
    end
    vOff = vOff + 2
  end
end
createBoard()
Runtime:addEventListener ( "key", keyListener )


-- EOF