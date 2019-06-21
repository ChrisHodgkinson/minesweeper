local composer = require ( "composer" )
local M = {}
  function M.new ( params ) -- { group, x, y, width, height }
    local group = params.group
    local cell = display.newRect ( group, p.x, p.y, p.w, p.h )
    cell:setFillColor ( .4, .4, .5, 1 )
    cell.strokeWidth = 1
    cell:setStrokeColour ( 0, 0, 0 )
    cell.mine = false
    cell.value = 0
    cell.flagged = false
    cell.revealed = false
    cell.neighbours = {}
    return cell
  end
return M
-- EOF
