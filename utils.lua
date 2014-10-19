local storyboard = require("storyboard")
local utils = {}

utils.makeButtonToScene = function ( sceneName, imageFile, subgroup, x, y )
	        local button = display.newImage(imageFile)
                button:translate(x,y)
                subgroup:insert(button)
                button.listen = function ( event )
					                   storyboard.gotoScene(sceneName)
					                   return true
					            end 
				button.start = function ()
									button:addEventListener("touch",button.listen)
								end
				button.stop = function ()
									button:removeEventListener("touch",button)
								end
                return button
        end

return utils