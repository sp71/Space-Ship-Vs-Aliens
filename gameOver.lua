local storyboard = require( "storyboard" )
local physics = require("physics" )
physics.start( )
--physics.setDrawMode( "hybrid" )

local scene = storyboard.newScene()
local width = display.contentWidth
local height = display.contentHeight

function scene:createScene( event )
	local group12 = self.view
	local msg = display.newText ("Final Score: " .. event.params.curScoree, width/2, height*.95, systemFont , 20)
 	msg:setFillColor( 1, 0, 1 )
	local gameDone = display.newImage("GameOver.png", width/2, height/2)
	gameDone:scale(.3,.3)
	local bird = display.newImage("birdG.png", width/5, height/-0.5)
	bird:scale( .3,.3 )
	physics.addBody(bird)
	local rect = display.newRect(4,280 ,1000 , 2 )
	rect:setFillColor(0.5)
	physics.addBody( rect, "static")
	group12:insert(gameDone)
	group12:insert(msg)
	group12:insert(bird)

	bird:rotate( 90 )
end

scene:addEventListener ( "createScene", scene)
return scene