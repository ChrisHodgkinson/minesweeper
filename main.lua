-- Minesweeper
-- main.lua
local mouseHover = require ( "plugin.mouseHover" )
local debug = true

display.setDefault( "background", .5, .5, .5 )


local gridGroup = display.newGroup()
local boardGroup     = display.newGroup()
local wiperGroup     = display.newGroup()
 
local board = {}
local boardHeight = 15
local boardWidth  = 15
local totalMines  = 72
local ctrlDown     = false


local function keyListener ( event )
  local phase = event.phase
  local key = event.keyName
  ctrlDown = (key == "leftControl" or key == "rightControl") and phase == "down" or false
end

local function placeNumbers ()

end

local function getNeighbours ( r, c )
  local neighbours = {}
  if r == 1 then -- top row
    table.insert ( neighbours, {r+1, c} )
    if c == 1 then -- left column
      table.insert( neighbours, {r, c+1} )
      table.insert ( neighbours, {r+1, c+1} )
    elseif c == boardWidth then -- right column
      table.insert ( neighbours, {r+1, c-1} )
      table.insert ( neighbours, {r, c-1} )
    else -- middle columns
      table.insert ( neighbours, {r, c+1} )
      table.insert ( neighbours, {r+1, c+1} )
      table.insert ( neighbours, {r+1, c-1} )
      table.insert ( neighbours, {r, c-1} )
    end
  elseif r == boardHeight then -- bottom row
    table.insert ( neighbours, {r-1, c} )
    if c == 1 then -- left column
      table.insert ( neighbours, {r-1, c+1} )
      table.insert ( neighbours, {r,  c+1} )
    elseif c == boardWidth then -- right column
      table.insert ( neighbours, {r, c-1} )
      table.insert ( neighbours, {r-1, c-1} )
    else -- middle columns
      table.insert ( neighbours, {r-1, c+1} )
      table.insert ( neighbours, {r, c+1} )
      table.insert ( neighbours, {r, c-1} )
      table.insert ( neighbours, {r-1, c-1} )
    end
  else -- all middle rows
    if c == 1 then -- left column
      table.insert ( neighbours, {r-1, c} )
      table.insert ( neighbours, {r-1, c+1} )
      table.insert ( neighbours, {r, c+1} )
      table.insert ( neighbours, {r+1, c+1} )
      table.insert ( neighbours, {r+1, c} )
    elseif c == boardWidth then -- right column
      table.insert ( neighbours, {r=1, c} )
      table.insert ( neighbours, {r+1, c-1} )
      table.insert ( neighbours, {r, c-1} )
      table.insert ( neighbours, {r-1, c-1} )
      table.insert ( neighbours, {r-1, c} )
    else -- middle columns
      table.insert ( neighbours, {r-1, c} )
      table.insert ( neighbours, {r-1, c+1} )
      table.insert ( neighbours, {r, c+1} )
      table.insert ( neighbours, {r+1, c+1} )
      table.insert ( neighbours, {r+1, c} )
      table.insert ( neighbours, {r+1, c-1} )
      table.insert ( neighbours, {r, c-1} )
      table.insert ( neighbours, {r-1, c-1} )
    end
  end
  return neighbours
end

local function placeMines ()
  local bombCounter = totalMines
  while bombCounter > 0 do
    --local rnum = math.random (  * boardWidth )
    local row = math.random( 1, boardHeight )
    local col = math.random( 1, boardWidth )
    if not board[row][col].mine then
      board[row][col].mine = true
      bombCounter = bombCounter -1
      if debug then board[row][col]:setFillColor( .5, .4, .4 ); end
    end
  end
end

local function zoneClicked( event )
  local thisZone = event.target
  local phase = event.phase
end

local function shake ( event )
  local square = event.target
  local phase = event.phase
  if phase == "began" then
    square:toFront() 
    transition.to (square, {xScale = 1.3, yScale = 1.3, time = 100})
  elseif phase == "ended" then
    transition.to (square, {xScale = 1, yScale = 1, time = 100})
  end
end

local function createBoard ()
  local vOff = 1
  for r = 1, boardHeight do
    local hOff = 1
    board[r]={}
    for c = 1, boardWidth do 
      board[r][c] = display.newRect( boardGroup, ((32*c)+hOff), ((32*r)+vOff), 31, 31 )
      board[r][c]:setFillColor(.4, .4, .5, 1)
      board[r][c].strokeWidth = 1 ; board[r][c]:setStrokeColor(0,0,0)
      board[r][c]:addEventListener ("mouseHover", shake )
      board[r][c].mine = false
      board[r][c].xCor = c
      board[r][c].yCor = r
      board[r][c].neighbours = getNeighbours( r, c )
      hOff = hOff + 2
    end
    vOff = vOff + 2
  end
end
createBoard()
placeMines()

Runtime:addEventListener ( "key", keyListener )


-- EOF