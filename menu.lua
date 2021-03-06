-- Main Menu
-- Better Graphics to be implemented

-- Load the relevant LuaSocket modules
local globals = require( "globals" )
local ltn12 = require( "ltn12" )
local helpers = require( "helpers" )
local composer = require( "composer" )
--local udp = assert(socket.udp())
local backgroundTex = graphics.newTexture({type = 'image', filename = 'assets/background.png'})
local buttImageSheetOpts = {width = 512, height = 512, numFrames = 4, sheetContentWidth = 2048, sheetContentHeight = 512}
local buttImageSheet = graphics.newImageSheet("assets/menu_icons.png", buttImageSheetOpts)


local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------


local function gotoConversions()
composer.gotoScene( "conversions", {effect = "slideLeft", time = 500} )
print("Scene --> Conversions")
end

local function gotoWeather()
composer.gotoScene( "weather", {effect = "slideLeft", time = 500} )
print("Scene --> weather")
end

local function gotoComputations()
composer.gotoScene( "computations", {effect = "slideLeft", time = 500} )
print("Scene --> Computations")
end

local function gotoAirportData()
composer.gotoScene( "airportData", {effect = "slideLeft", time = 500} )
print("Scene --> AirportData")
end

local function openWiki()
	system.openURL( "https://github.com/airfightergr/Aviation-Apps/wiki" )
end

local function openTselios()
	system.openURL( "https://tselios.com" )
end

local function exitApp()
	native.requestExit()
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- Create menu page

function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local background = display.newImageRect( backgroundTex.filename, backgroundTex.baseDir, display.contentWidth, display.contentHeight )
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	sceneGroup:insert(background)
	local itx_tselios = display.newImage( "assets/logo2.png" , display.contentCenterX, display.contentHeight * 0.85)
	sceneGroup:insert(itx_tselios)
	itx_tselios:addEventListener("tap", openTselios)
	title = display.newText("Aviators's Companion", display.contentCenterX, display.contentHeight * 0.075,native.newFont( "Lost_Rock_.otf" , 50 ))
	title:setFillColor(1,1,1)
	sceneGroup:insert(title)

	--------------------------------------------------------------------------------
	-- Button Weather
	--------------------------------------------------------------------------------
	local buttWeather = display.newImageRect( buttImageSheet, 1, display.contentWidth * 0.25, display.contentWidth * 0.25)
	buttWeather.x = display.contentWidth * 0.25
	buttWeather.y = display.contentHeight * 0.25
	sceneGroup:insert(buttWeather)
	buttWeather:addEventListener("tap", gotoWeather)

	--------------------------------------------------------------------------------
	-- Button Conversions
	--------------------------------------------------------------------------------
	local buttConv = display.newImageRect( buttImageSheet, 2 , display.contentWidth * 0.25, display.contentWidth * 0.25)
	buttConv.x = display.contentWidth * 0.75
	buttConv.y = display.contentHeight * 0.25
	sceneGroup:insert(buttConv)
	buttConv:addEventListener("tap", gotoConversions)

	--------------------------------------------------------------------------------
	--Button Computations
	--------------------------------------------------------------------------------
	local buttCompute = display.newImageRect( buttImageSheet, 3 , display.contentWidth * 0.25, display.contentWidth * 0.25)
	buttCompute.x = display.contentWidth * 0.25
	buttCompute.y = display.contentHeight * 0.50
	sceneGroup:insert(buttCompute)
	buttCompute:addEventListener("tap", gotoComputations)
	
	--------------------------------------------------------------------------------
	-- Button Airport Data
	--------------------------------------------------------------------------------
	local buttairData = display.newImageRect( buttImageSheet, 4 , display.contentWidth * 0.25, display.contentWidth * 0.25)
	buttairData.x = display.contentWidth * 0.75
	buttairData.y = display.contentHeight * 0.50
	sceneGroup:insert(buttairData)
	buttairData:addEventListener("tap", gotoAirportData)

	--------------------------------------------------------------------------------
	-- Button Manual
	--------------------------------------------------------------------------------
	buttonManual = display.newRoundedRect(display.contentCenterX, display.contentHeight * 0.95, display.contentWidth * 0.30, display.contentHeight * 0.03, 15 )
	buttonManual:setFillColor(0.3,0.8,0.9)
	sceneGroup:insert(buttonManual)

	buttonManualLabel = display.newText( "Read Manual",  display.contentCenterX, display.contentHeight * 0.95, native.newFont( "FallingSkyBd.otf" ,20 ))
	buttonManualLabel:setFillColor(0,0,0)
	sceneGroup:insert(buttonManualLabel)
	buttonManualLabel:addEventListener("tap", openWiki)


	--------------------------------------------------------------------------------
	-- Button Exit
	--------------------------------------------------------------------------------
	buttonExit = display.newRoundedRect(display.contentCenterX, display.contentHeight * 0.65, display.contentWidth * 0.30, display.contentHeight * 0.03, 15 )
	buttonExit:setFillColor(0.3,0.8,0.9)
	sceneGroup:insert(buttonExit)

	buttonExitLabel = display.newText( "Exit",  display.contentCenterX, display.contentHeight * 0.65, native.newFont( "FallingSkyBd.otf" ,20 ))
	buttonExitLabel:setFillColor(0,0,0)
	sceneGroup:insert(buttonExitLabel)
	buttonExitLabel:addEventListener("tap", exitApp)
	--------------------------------------------------------------------------------
	-- Bottom warning message
	--------------------------------------------------------------------------------
	local bottomTitle = display.newText( "Do not use in Real Aviation", display.contentCenterX, display.contentHeight * 0.98, native.newFont( "/fonts/Helvetica-Bold.ttf" , 16 ))
		bottomTitle:setFillColor(1,0.2,0.2)
	sceneGroup:insert(bottomTitle)

end --scene:create( event )

	
-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
