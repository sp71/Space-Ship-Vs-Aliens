--Satinder
--Bader
local storyboard = require( "storyboard" )
local physics = require("physics")
local utils = require("utils")
local scene = storyboard.newScene()
local vector = require("vector")
local fsm = require("fsm")
local width = display.contentWidth
local height = display.contentHeight
local fireOn = true
storyboard.purgeOnSceneChange = true --erases previous scene 
local gameisDone = false

local fireButton, moveButton

local alienSheets = {
    {sheet = graphics.newImageSheet( "alien1.png", { width=25, height=48, numFrames=1})},
    {sheet = graphics.newImageSheet( "alien3.png", { width=25, height=48, numFrames=1})}
}

local alienSequenceData = {
      { name="seq1", sheet=alienSheets[1].sheet, start=1, count=1, time=1, loopCount=0 },
      { name="seq2", sheet=alienSheets[2].sheet, start=1, count=1, time=1, loopCount=0 }
}

function fireListener (event)
   if (event.phase == "began") then
        SoundMaster.playButtonSound("wow")
        fireOn = true
    end
    return true
end
function moveListener (event)
   if (event.phase == "began") then
    --    SoundMaster.playButtonSound("mov")
        fireOn = false
    end
    return true
end
-- Called when the scene's view does not exist:
function scene:createScene( event )
    local options = {
        effect = "zoomOutInRotate",
        time = 400
    }
-----    local aaa = alienMaker(math.random(600), -20, height*.20)
    -- OBJECTS
  --  local bg  Satinder commented this code
    local scoreText 
    local aliens = {}
    local turret
    local alienlives = 4

    -- object attributes
    local stoneDensity = 5.0
    local health

    -- VARIABLES
    local numAliens = 0
    local gameLives = 4
    local gameScore = 0

    local group = self.view


    -- functions for forward referencing
    local destroyObject

    -- image sheet from sky bkgrnd
   local options = { width=64, height=64, 
                        numFrames=768, sheetContentWidth=2048, 
                        sheetContentHeight=1536}

    -- hud
    scene.hud = display.newGroup()
    group:insert(scene.hud)


    local centerX = display.contentCenterX
    local centerY = display.contentCenterY
    scene.width = display.contentWidth
    scene.height = display.contentHeight

    -- declare states here for forward referencing
    healthyState = {}
    unhealthyState = {}
    alienEntries = {}

    fightState = {}
    moveState = {}

    -- physics
    physics.start()
 --   physics.setDrawMode("hybrid")
    --physics.setGravity(0, 11)

    function fightState:enter ( owner )
        -- register event (table) listeners, initialize state

    end

    function fightState:exit ( owner )
        -- unsubscribe event listeners, cleanup
    end

    function fightState:execute ( owner )
        if (fireOn == true and gameisDone == true) then
            owner:setFillColor(1, 0, 0)
        else
            owner.fsm:changeState(moveState)
        end
    end


    function moveState:enter ( owner )
        -- register event (table) listeners, initialize state

    end

    function moveState:exit ( owner )
        -- unsubscribe event listeners, cleanup
    end

    function moveState:execute ( owner )
        if (fireOn == false) then
            owner:setFillColor(1, 1, 0)
        else
            owner.fsm:changeState(fightState)
        end
    end


    -------------------
    -- healthyState
    -------------------

    function healthyState:enter ( owner )
        -- register event (table) listeners, initialize state

    end

    function healthyState:exit ( owner )
        -- unsubscribe event listeners, cleanup
    end

    function healthyState:execute ( owner )
        -- called every frame
        -- first, execute in current state
  --      lowHealth = function()
            
  --      end
        if owner.health < 40 then owner.fsm:changeState(unhealthyState) end
    end

    -----------------------------
    -- unhealthyState
    -----------------------------

    function unhealthyState:enter ( owner )
        print("entering unhealthyState")
        owner:setSequence("seq2")
    end
    function unhealthyState:exit ( owner )
        --print ('sadState:exit()' .. owner.name )
        
        --return true
    end
    function unhealthyState:execute ( owner )
        --print ('sadState:execute()')
        print ("Unhealthy now")
        owner.name = "sadAlien"
        if owner.health <= 0 then
            destroyObject(owner)
            alienlives = alienlives - 1
        end
    end
    
    function loadExplosionData()
        local data = {}
        data.options = { width=64, height=64, numFrames=16, 
                        sheetContentWidth=256, sheetContentHeight=256}
        data.sheet = graphics.newImageSheet("explosion.png", data.options )
        data.sequenceData = {
                name="exploding",
                start=1,
                count=16,
                time=500,
                loopCount = 1,   -- Optional ; default is 0 (loop indefinitely)
                loopDirection = "forward"    -- Optional ; values include "forward" or "bounce"
            }
        return data
    end

    scene.explosionData = loadExplosionData()
    scene.explosions = {}

    -------------------------------------------------
    -- GAME OVER
    -------------------------------------------------

    local gameOver = function(outcome)
        local outcome = outcome

        gameIsActive = false
        physics.pause()

        -- game over window


        if outcome == "yes" then
                gameisDone = "true"
                storyboard.gotoScene("gameOver", { effect = "zoomOutInRotate", time = 400, params = {curScoree = gameScore}})
        else
            self.buttons = display.newGroup()
            group:insert(self.buttons)
            self.menuButton = utils.makeButtonToScene("startmenu",
            "youlose.png", self.buttons, 
            display.contentCenterX,
            display.contentCenterY)
        end

    end

-------------------------------------------------
-- PLAYER
-------------------------------------------------

    local loadTurret = function()
        turret = display.newImageRect("turret.png", 49, 67)
        turret.x = width * 0.5
        turret.y = height * 0.5 + 120
        physics.addBody(turret)
       turret.gravityScale = 0
       turret.name = "turret"
       turret.fsm = fsm.new(turret)
        turret.fsm:changeState(fightState)
        -- add physics body?

        --insert the player into the scene group
        scene.player = turret
        scene.world:insert(scene.player)
    end

    -------------------------------------------------
    -- FORIEGN OBJECTS 
    -------------------------------------------------

    function loadAsteroidData()
        local data = {}
        data.options = { width=72, height=72, numFrames=16, 
                        sheetContentWidth=360, sheetContentHeight=288}

        data.sheet = graphics.newImageSheet("asteroid.png", data.options )
        data.sequenceData = {
                name="rotating",
                start=1,
                count=16,
                time=500,
                loopCount = 0,   -- Optional ; default is 0 (loop indefinitely)
                loopDirection = "forward"    -- Optional ; values include "forward" or "bounce"
            }
        return data
    end

    scene.asteroidData = loadAsteroidData()
    scene.explosions = {}

    local loadAsteroid = function(x, y)
        local asteroid = display.newSprite(scene.asteroidData.sheet, scene.asteroidData.sequenceData)
        asteroid:setFillColor(math.random(), math.random(), math.random())
        asteroidAttributes = {
            density = 40.0,
            bounce = 0.4,
            friction = 0.15,
            radius = 2
        }
        physics.addBody(asteroid, "static", asteroidAttributes)
        asteroid.x = x
        asteroid.y = y
        asteroid.xScale = 0.5
        asteroid.yScale = 0.5
        asteroid:play()
        scene.world:insert(asteroid)

        return asteroid
    end

    -------------------------------------------------
    -- AUDIO 
    -------------------------------------------------
    audio.setVolume(0.05)


    -------------------------------------------------
    -- EXPLOSION
    -------------------------------------------------
    --[[local explode = function(obj)
        -- start up a an explosion at the obj's position
        
        local ex = display.newSprite( scene.explosionData.sheet, scene.explosionData.sequenceData )
        ex.x = obj.x
        ex.y = obj.y
        ex:rotate(math.random(360))
        ex:pause()
        ex:setFrame(1)
        scene.world:insert(ex)

        ex:play()
        audio.play(explosionSound)
    end--]]

    -- collision event handler
    scene.onCollision = function(event)
    
      if (event.object1.name == "laser" and event.object2.name == "turret") then
        return 
      end 
    if (event.object2.name == "laser" and event.object1.name == "turret") then
        return 
      end 
      
      if (event.object1.isBullet or event.object2.isBullet) then
        if (event.phase == "ended") then
            if event.object1.name == "alien" then
             event.object1.health = 30
            else
                event.object1:removeSelf()
                 if event.object1.name == "sadAlien" then
                    alienlives = alienlives - 1
                end 
            end
    
          event.object2:removeSelf()
          -- display explosion animation
          local explosionSequenceData = 
          {
            name = "explosionSprite",
            start = 1,
            count = 10,
            time = 500,
            loopCount = 1,
            loopDirection = "forward"
          }
      
          local explosion = display.newSprite(scene.explosionData.sheet, scene.explosionData.sequenceData)
          local explosionX = event.object1.x
          local explosionY = event.object1.y
        explosion.x = explosionX; explosion.y = explosionY
          --explosion:addEventListener("sprite", endOfExplosion)
          explosion:play()
          SoundMaster.playButtonSound("exp")
          if explosion.phase == "ended" then
            display.remove(explosion)
            explosion = nil
          end
          gameScore = gameScore + 5
          scoreText.text = "Score: " .. gameScore
          scoreText:setFillColor(math.random(), math.random(), math.random())
        end
      end
    end

    -------------------------------------------------
    -- COLLISIONS
    -------------------------------------------------

    destroyObject = function ( obj )
        explode(obj)
        timer.performWithDelay(100, display.remove(obj))
        -- remove the object from the list if it belongs in one
        if obj == alien then
            for i=1,#alienEntries do
                if alienEntries[i] == obj then
                    --table.remove(obj, i)
                    alienEntries[i] = nil
                end
            end

            -- check if the pig list is empty, if it is the level is complete
            if next(alienEntries) == nil then
                gameOver("yes")
            end
        end
    end

    local removeBullet = function (bullet)
        timer.performWithDelay(100, display.remove(bullet) )
    end

    -------------------------------------------------
    -- BACKGROUND
    -------------------------------------------------

    local drawBackground = function()
        scene.background = display.newGroup()
        local bg = display.newImage("space.jpg",width*.50,height*.40)
        scoreText =  display.newText ("Score: 0", width*.14, height*.90, font, 20)
        scoreText:setFillColor(1,0,0)
        scoreText.alpha = .7
        scene.background:insert(bg)
        scene.background:insert(scoreText)
        group:insert(scene.background)
        group:insert(scene.background)
        scene.world = display.newGroup()
        group:insert(scene.world)

    end

    local drawButtons = function()
        fireButton = display.newImage("fireButton.png", 10, 10)
        fireButton.x = width*.90
        fireButton.y = height*.90
        moveButton = display.newImage("move arrow.png", 10, 10)
        moveButton.x = width*.90
        moveButton.y = height*.70
        scene.fButton = fireButton
        scene.mbutton = moveButton
        scene.world:insert(scene.fButton)
        scene.world:insert(scene.mbutton)
        fireButton:addEventListener ("touch", fireListener)
        moveButton:addEventListener ("touch", moveListener)
    end

    -- function for finding the proper angle that the bullets and turret must rotate
    local function angleOfRotation(turretX, turretY, eventX, eventY)
        local angle = (math.deg(math.atan2(eventY - turretY, eventX - turretX)) + 90)
        if (angle < 0) then
          angle = angle + 360
        end
        
        return angle % 360
    end
      
    -- event handler for when the user taps the screen
    scene.aimAndShoot = function(event)
      -- rotate the turret to desired direction
        local rotationAngle = angleOfRotation(turret.x, turret.y, event.x, event.y)
        turret.rotation = rotationAngle
        if fireOn then 
          -- now fire the bullet
        turret.fsm:changeState(fightState)
          bulletX = turret.x
          bulletY = turret.y
          local bullet = display.newImage("laser_shot.png", bulletX, bulletY)
          physics.addBody(bullet, "kinematics", {bounce = 0.0,radius = 12})
          bullet.name = "laser"
          bullet.isBullet = true
          
          velocityX = 100*(event.x - bullet.x)
          velocityY = 100*(event.y - bullet.y)
          bullet.rotation = rotationAngle
          bullet:setLinearVelocity(velocityX, velocityY)
          SoundMaster.playButtonSound("laser")
        else
            transition.to( turret, { time=1000, x=event.x, y= event.y} )
            SoundMaster.playButtonSound("fly")
        end 
      return true
    end

    local onScreenTouch = function (event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus(event.target)
        end
        if event.phase == "ended" then
            -- calculate the distance and force that is placed on the penguin

            local xForce = (-1 * (event.x - event.xStart)) * 2.15
            local yForce = (-1 * (event.y - event.yStart)) * 2.15

            event.target.bodyType = "dynamic"
            event.target:applyLinearImpulse(xForce, yForce, event.target.x, event.target.y)
            event.target.isReady = false
            event.target.inAir = true
        end
        return true
    end

    -------------------------------------------------
    -- LEVEL
    -------------------------------------------------

    local createLevel = function()

        -- bad guys
        for i=1,10 do 
        loadAsteroid(width*.20, height*.20)
        loadAsteroid(width*.20, height*.60)

        loadAsteroid(width*.50, height*.20)
        loadAsteroid(width*.50, height*.60)

        loadAsteroid(width*.60, height*.20)
        loadAsteroid(width*.60, height*.60)

        loadAsteroid(width*.90, height*.20)
        loadAsteroid(width*.90, height*.60)

        end

        -- objects


        --scene.world:insert(horizontalPlank)
    end


    local setupLevel = function()
        print("setupLevel() being called")
        -- game objects
        drawBackground()
        drawButtons()
        loadTurret()
        loadAliens(width*.10,height*.05)
        loadAliens(width*.50,height*.05)
        loadAliens(width*.90,height*.05)
        -- create the level
        loadAliens(width*.5,height*.5)
        createLevel()

        -- add event listeners
        --Runtime:addEventListener("enterFrame", gameLoop)

    end
    
    setupLevel()

    startAgain = function()
        print(gameLives)
        gameLives = gameLives - 1
        if gameLives <= 0 then
            gameOver("no")

        else
            setupLevel()
        end

        return true
    end


    -- Calls Execute Method in states!
    function update ( event )
        print ("ALIEN LIVES LEFT: " .. alienlives)
        if( alienlives == 0) then 
            gameOver("yes")
        end

        for i=1,#alienEntries do
            if alienEntries[i].name == "alien" then 
                alienEntries[i].fsm:update(event)
                local xDiff = turret.x - alienEntries[i].x 
                local yDiff = turret.y - alienEntries[i].y
                local forceNeed = math.sqrt( xDiff* xDiff + yDiff*yDiff)
                alienEntries[i]:setLinearVelocity(xDiff/ forceNeed*50, yDiff/ forceNeed*50,alienEntries[i].x,alienEntries[i].y) 
                alienEntries[i].rotation= 0
            end
        end

        -- update alien fsm
        turret.fsm:update(event)
    end
  end

    loadAliens = function( Xposition, Yposition)
        local alien = display.newSprite(alienSheets[1].sheet, alienSequenceData)
        alien.x = Xposition
        alien.y= Yposition
        alien.fsm = fsm.new(alien)
        alien.name = "alien"
        alien.fsm:changeState(healthyState)
        alien.health = 100
        alien.numHits = 0 -- Number of hits the alien has taken  
        scene.enemy = alien
        scene.world:insert(scene.enemy)
        physics.addBody( alien, {bounce = 0} )
        alien.gravityScale = 0
        alien.isFixedRotation = true
        table.insert(alienEntries, alien)
        return alien
end
-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
        local group = self.view
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
        local group = self.view
        Runtime:addEventListener("tap", scene.aimAndShoot)
        Runtime:addEventListener("enterFrame", scene)
        Runtime:addEventListener("collision", scene.onCollision)
        Runtime:addEventListener("enterFrame", update) 

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
        local group = self.view

        -----------------------------------------------------------------------------

        --      INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)

        -----------------------------------------------------------------------------
        Runtime:removeEventListener("enterFrame", scene)
        Runtime:removeEventListener("collision", scene.onCollision)
        for i = 1, #group do
            group[i] = nil
        end

        physics.stop()
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "willEnterScene" event is dispatched before scene transition begins
scene:addEventListener( "willEnterScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "didExitScene" event is dispatched after scene has finished transitioning out
scene:addEventListener( "didExitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-- "overlayBegan" event is dispatched when an overlay scene is shown
scene:addEventListener( "overlayBegan", scene )

-- "overlayEnded" event is dispatched when an overlay scene is hidden/removed
scene:addEventListener( "overlayEnded", scene )

---------------------------------------------------------------------------------

return scene