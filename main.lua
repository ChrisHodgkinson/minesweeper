-- Minesweeper
-- main.lua
local mouseHover = require ( "plugin.mouseHover" )
local debug = true

display.setDefault( "background", .5, .5, .5 )

local valueGroup    = display.newGroup()
local boardGroup     = display.newGroup()

 
local board = {}
local boardHeight = 16
local boardWidth  = 16
local totalMines  = 40
local ctrlDown    = false
local marked      = 0

local colours = {
  {0,0,1}, {0,1,0}, {1,0,0}, {0,0,.5}, {.5,0,.5}, {.5,.5,1}, {0,.5,0}, {0,0,0}
}

local function keyListener ( event )
  local phase = event.phase
  local key = event.keyName
  ctrlDown = (key == "leftControl" or key == "rightControl") and phase == "down" or false
end

local function placeNumbers ()
  local squareValue
  for r = 1, boardHeight do
    for c = 1, boardWidth do
      squareValue = 0
      local toCount = board[r][c].neighbours
      for f = 1, #toCount do
        local ffr = toCount[f].y; local ffc = toCount[f].x
        if board[ffr][ffc].mine then squareValue = squareValue + 1 end
      end
      if not board[r][c].mine then
        board[r][c].value = squareValue
        if squareValue >0 then
          board[r][c].showValue.text = tostring(squareValue)
          board[r][c].showValue:setFillColor(unpack(colours[squareValue]))
        end
      end
    end
  end
end

local function getNeighbours ( r, c )
  local neighbours = {}
  if r == 1 then -- top row
    table.insert ( neighbours, {y=r+1, x=c} )
    if c == 1 then -- left column
      table.insert( neighbours, {y=r, x=c+1} )
      table.insert ( neighbours, {y=r+1, x=c+1} )
    elseif c == boardWidth then -- right column
      table.insert ( neighbours, {y=r+1, x=c-1} )
      table.insert ( neighbours, {y=r, x=c-1} )
    else -- middle columns
      table.insert ( neighbours, {y=r, x=c+1} )
      table.insert ( neighbours, {y=r+1, x=c+1} )
      table.insert ( neighbours, {y=r+1, x=c-1} )
      table.insert ( neighbours, {y=r, x=c-1} )
    end
  elseif r == boardHeight then -- bottom row
    table.insert ( neighbours, {y=r-1, x=c} )
    if c == 1 then -- left column
      table.insert ( neighbours, {y=r-1, x=c+1} )
      table.insert ( neighbours, {y=r,  x=c+1} )
    elseif c == boardWidth then -- right column
      table.insert ( neighbours, {y=r, x=c-1} )
      table.insert ( neighbours, {y=r-1, x=c-1} )
    else -- middle columns
      table.insert ( neighbours, {y=r-1, x=c+1} )
      table.insert ( neighbours, {y=r, x=c+1} )
      table.insert ( neighbours, {y=r, x=c-1} )
      table.insert ( neighbours, {y=r-1, x=c-1} )
    end
  else -- all middle rows
    if c == 1 then -- left column
      table.insert ( neighbours, {y=r-1, x=c} )
      table.insert ( neighbours, {y=r-1, x=c+1} )
      table.insert ( neighbours, {y=r, x=c+1} )
      table.insert ( neighbours, {y=r+1, x=c+1} )
      table.insert ( neighbours, {y=r+1, x=c} )
    elseif c == boardWidth then -- right column
      table.insert ( neighbours, {y=r+1, x=c} )
      table.insert ( neighbours, {y=r+1, x=c-1} )
      table.insert ( neighbours, {y=r, x=c-1} )
      table.insert ( neighbours, {y=r-1, x=c-1} )
      table.insert ( neighbours, {y=r-1, x=c} )
    else -- middle columns
      table.insert ( neighbours, {y=r-1, x=c} )
      table.insert ( neighbours, {y=r-1, x=c+1} )
      table.insert ( neighbours, {y=r, x=c+1} )
      table.insert ( neighbours, {y=r+1, x=c+1} )
      table.insert ( neighbours, {y=r+1, x=c} )
      table.insert ( neighbours, {y=r+1, x=c-1} )
      table.insert ( neighbours, {y=r, x=c-1} )
      table.insert ( neighbours, {y=r-1, x=c-1} )
    end
  end
  return neighbours
end

local function wakeTheNeighbours ( row, col )
  local neighbour = board [row][col].neighbours
  for f = 1, #neighbour do
    local fx = neighbour[f].x
    local fy = neighbour[f].y
    local thisCell = board[fy][fx]
    if thisCell.mine == false and thisCell.revealed == false then
      transition.to (thisCell, {rotation =180, time = 250, xScale=3, yScale=3, alpha=0 })
      thisCell.revealed = true
      if thisCell.value == 0 then
        wakeTheNeighbours ( fy, fx )
      end
    end
  end 
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

local function gameOver ( row, col )
  print("G A M E   O V E R")
end

local function zoneClicked( event )
  local thisZone = event.target
  local phase = event.phase
  if phase == "ended" and not ctrlDown and not thisZone.revealed then
    if thisZone.mine then
      transition.to (thisZone, {rotation =180, time = 250, onComplete = function() thisZone.rotation = 0; end })
      gameOver(thisZone)
    elseif not thisZone.mine then
      transition.to (thisZone, {rotation =180, time = 250, xScale=3, yScale=3, alpha=0 })
      thisZone.revealed = true
      if thisZone.value == 0 then
        wakeTheNeighbours ( thisZone.yCor, thisZone.xCor )
      end
    end
  elseif phase == "ended" and ctrlDown and not thisZone.revealed and not thisZone.marked then
    transition.to (thisZone.fill, {r=0, g=.7, b=0, a=1, time=150, transition=easing.inCubic})
    thisZone.marked = true
  elseif phase == "ended" and ctrlDown and not thisZone.revealed and thisZone.marked then
    transition.to (thisZone.fill, {r=.4, g=.4, b=.5, a=1, time=150, transition=easing.inCubic})
    thisZone.marked = false
  end
  return true
end

local function highlight ( event )
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
      local x = ((32*c)+hOff)
      local y = ((32*r)+vOff)
      board[r][c] = display.newRect( boardGroup, x, y, 31, 31 )
      board[r][c]:setFillColor(.4, .4, .5, 1)
      board[r][c].strokeWidth = 1 ; board[r][c]:setStrokeColor(0,0,0)
      board[r][c]:addEventListener ("mouseHover", highlight )
      board[r][c]:addEventListener ("touch", zoneClicked )
      board[r][c].mine = false
      board[r][c].xCor = c
      board[r][c].yCor = r
      board[r][c].value = 0
      board[r][c].showValue = display.newText ( valueGroup, " ", x, y, "conthrax-sb.ttf", 24)
      board[r][c].marked = false
      board[r][c].revealed = false
      board[r][c].neighbours = getNeighbours( r, c )
      hOff = hOff + 2
    end
    vOff = vOff + 2
  end
end
createBoard()
placeMines()
placeNumbers()

Runtime:addEventListener ( "key", keyListener )


-- EOF