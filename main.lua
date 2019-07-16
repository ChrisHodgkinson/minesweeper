-- Minesweeper
-- main.lua
local mouseHover = require ( "plugin.mouseHover" )
local stars = require ( "stars" )
local debug = false

local _x = display.actualContentWidth * 0.5
local _y = display.actualContentHeight * 0.5

display.setDefault( "background", 0, 0, 0 )

local bgGroup       = display.newGroup()
local mainGroup = display.newGroup()
local valueGroup    = display.newGroup()
local boardGroup    = display.newGroup()
mainGroup:insert(valueGroup)
mainGroup:insert(boardGroup)
mainGroup.anchorChildren = true
mainGroup.anchorX = .5
mainGroup.anchorY = .5
mainGroup.x = _x
mainGroup.y = _y

local bw, bh
local starField = {}
local boardBG
local board = {}
local boardHeight = 16
local boardWidth  = 30
local totalMines  = 99
local ctrlDown    = false
local marked      = 0
local minesLeft = 0
local minesText
local colours = {
  {0,0,1}, {0,1,0}, {1,0,0}, {.5,.5,0}, {.5,0,.5}, {.5,.5,1}, {0,.5,0}, {0,0,0}
}
local levels = {
  easy = {h = 9, w = 9, m = 10},
  medium = {h = 16, w = 16, m = 40},
  hard = {h=16, w = 30, m = 99}
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
      thisCell.alpha = 0  --transition.to (thisCell, { time = 250, alpha=0 })
      thisCell.revealed = true
      if thisCell.value == 0 then
        wakeTheNeighbours ( fy, fx )
      end
    end
  end 
end

local function shakeObject (object)
  --
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
      minesLeft = minesLeft + 1
      minesText.text = "MINES: "..tostring(minesLeft)
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
    -- If an unclicked space is clicked and CTRL is not held down.    
    if thisZone.mine then
      -- If the space contains a mine.
      --transition.to (thisZone, { time = 250, onComplete = function() thisZone.rotation = 0; end })
      shakeObject(mainGroup)
      gameOver(thisZone)
    elseif not thisZone.mine then
      -- If the space does not contain a mine.
      --transition.to (thisZone, { time = 250, xScale=3, yScale=3, alpha=0 })
      thisZone.alpha = 0
      thisZone.revealed = true
      if thisZone.value == 0 then
        -- If the space is not adjacent to any mines.
        wakeTheNeighbours ( thisZone.yCor, thisZone.xCor )
      end
      thisZone.foo = true
    end
  elseif phase == "ended" and ctrlDown and not thisZone.revealed and not thisZone.marked and minesLeft >0 then
    -- Mark zone if CTRL is held down and the space is not revealed or marked and the player still has flags left.
    transition.to (thisZone.fill, {r=.7, g=0, b=0, a=1, time=150, transition=easing.inCubic})
    thisZone.marked = true
    minesLeft = minesLeft - 1
  elseif phase == "ended" and ctrlDown and not thisZone.revealed and thisZone.marked then
    -- Unmark a previously marked zone.
    transition.to (thisZone.fill, {r=.4, g=.4, b=.5, a=1, time=150, transition=easing.inCubic})
    thisZone.marked = false
    minesLeft = minesLeft + 1
  end
  minesText.text = "MINES: "..tostring(minesLeft)
  return true
end

local function highlight ( event )
  -- local square = event.target
  -- local phase = event.phase
  -- if phase == "began" then
  --   square:toFront() 
  --   transition.to (square, {xScale = 1.1, yScale = 1.1, time = 100})
  -- elseif phase == "ended" then
  --   transition.to (square, {xScale = 1, yScale = 1, time = 100})
  -- end
end

local function createBoard ()
  local vOff = 1
  for r = 1, boardHeight do
    local hOff = 1
    board[r]={}
    for c = 1, boardWidth do
      local x =  (24*c)+hOff--199+((24*c)+hOff) -- ((24*c)+hOff)
      local y = ((24*r)+vOff)
      board[r][c] = display.newRect( boardGroup, x, y, 23, 23 )
      board[r][c]:setFillColor(.4, .4, .5, 1)
      board[r][c].strokeWidth = 1 ; board[r][c]:setStrokeColor(0,0,0)
      board[r][c]:addEventListener ("mouseHover", highlight )
      board[r][c]:addEventListener ("touch", zoneClicked )
      board[r][c].mine = false
      board[r][c].xCor = c
      board[r][c].yCor = r
      board[r][c].value = 0
      board[r][c].showValue = display.newText ( valueGroup, " ", x, y, "conthrax-sb.ttf", 18)
      board[r][c].marked = false
      board[r][c].revealed = false
      board[r][c].neighbours = getNeighbours( r, c )
      hOff = hOff + 2
    end
    vOff = vOff + 2
  end
  bw, bh = boardGroup.width, boardGroup.height
  print ("Board Width : ",bw)
  boardBG = display.newRoundedRect ( _x, _y, bw+100, bh+150, 25 )
  boardBG:setFillColor(.3,0,.3, .3)
  boardBG.strokeWidth = 2
  boardBG:toBack()
  minesText = display.newText("MINES: "..tostring(minesLeft), _x, 100, "conthrax-sb", 36 )
end

local function updateStars()
  for i = 1, #starField do
    starField[i]:update()
  end
end

local function createStars()
  for i = 1, 200 do
    starField[i]=stars.new( bgGroup, 10 )
  end
  Runtime:addEventListener( "enterFrame", updateStars )
end

--createStars()
createBoard()
placeMines()
placeNumbers()

Runtime:addEventListener ( "key", keyListener )


-- EOF