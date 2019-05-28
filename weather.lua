-- Weatheer information page
-- Downloads the weather data from Aviationweather.gov (2 files METARs & TAFs)
-- Uses ICAO airport code to find the informations from local data (aviator_metar.txt & aviator_taf.txt)
-- Handles errors while searching

local composer = require( "composer" )

local scene = composer.newScene()

local bg
local title
local buttonMenu
local metarIs = ""
local tafIs = ""
local metarDown
local tafdown
local arptID --Init newTextField for entering the airport's ICAO code to search for METAR
local displayMetar
local displayTaf
local percText = ""
local percDown

local hourUTC

local metarAlertText = ""
local metarAlert
local tafAlert

local keyFocus = 0
local hideButton = 0

local dwidth = display.contentWidth
local dheigh = display.contentHeight
local dwidthC = display.contentCenterX
local dheighC = display.contentCenterY


-- Creating the download progress

-- networkListener is for handling download of METAR data (Just to display the right message, need to be improoved)

local function networkListener_m( event )
	
    if ( event.isError ) then
        print( "Network error: ", event.response )

    elseif ( event.phase == "began" ) then
        if ( event.bytesEstimated <= 0 ) then
            print( "Download starting, size unknown" )
            percText = "Starting Download..."
        else
            print( "Download starting, estimated size: " .. event.bytesEstimated )
        end

    elseif ( event.phase == "progress" ) then
        if ( event.bytesEstimated <= 0 ) then
            print( "Download metar: " .. event.bytesTransferred )
        else
            print( "Download metar: " .. event.bytesTransferred .. " of estimated: " .. event.bytesEstimated )
            print( string.format("Download METAR: %d%%" , (event.bytesTransferred /event.bytesEstimated)*100 ))
            percText = string.format("Download METAR: %d%%" , (event.bytesTransferred /event.bytesEstimated)*100 )
            percDown = event.bytesTransferred /event.bytesEstimated
            print(percDown)
        end

    elseif ( event.phase == "ended" ) then
        print( "Download complete, total bytes transferred: " .. event.bytesTransferred )
        print( string.format("Download progress: %d%%" , (event.bytesTransferred /event.bytesEstimated)*100 ))
        percText = "Weather Data has been downloaded succesfully."
    end	

end	

local function networkListener_t( event )
	
    if ( event.isError ) then
        print( "Network error: ", event.response )

    elseif ( event.phase == "began" ) then
        if ( event.bytesEstimated <= 0 ) then
            print( "Download starting, size unknown" )
            percText = "Starting Download..."
        else
            print( "Download starting, estimated size: " .. event.bytesEstimated )
        end

    elseif ( event.phase == "progress" ) then
        if ( event.bytesEstimated <= 0 ) then
            print( "Download taf: " .. event.bytesTransferred )
        else
            print( "Download taf: " .. event.bytesTransferred .. " of estimated: " .. event.bytesEstimated )
            print( string.format("Download TAF: %d%%" , (event.bytesTransferred /event.bytesEstimated)*100 ))
            percText = string.format("Download TAF: %d%%" , (event.bytesTransferred /event.bytesEstimated)*100 )
            percDown = event.bytesTransferred /event.bytesEstimated
            print(percDown)
        end

    elseif ( event.phase == "ended" ) then
        print( "Download complete, total bytes transferred: " .. event.bytesTransferred )
        print( string.format("Download progress: %d%%" , (event.bytesTransferred /event.bytesEstimated)*100 ))
        percText = "Weather Data has been downloaded succesfully."
    end	

end	


-- Use phone's back button to go back to main menu.

function scene:key(event)

	if ( event.keyName == "back" or event.keyName == "unknown") then
		composer.gotoScene( "menu", {effect = "slideRight", time = 500} )
		return true
	end

end

Runtime:addEventListener( "key", scene )
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- Create the Weather page

function scene:create( event )

	local sceneGroup = self.view

	-- Background color
	bg = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
	bg:setFillColor(0.3,0.3,0.5)
	sceneGroup:insert(bg)
	
	-- Page title
    title = display.newText( "Airport's Weather", dwidthC, dheighC * 0.09, native.newFont( "FallingSkyBd.otf" ,40 ))
    sceneGroup:insert(title)
	
	-- Page footer
	local sourceTextOpt = {text = "METAR and TAF information is courtesy of Aviation Weather Center - NOAA",
        x = dwidthC,
        y = dheigh * 0.95,
        width = dwidth * 0.9,
        font = "FallingSkyExt.otf",
        fontSize = 20,
        align = "center"
    }
	
    local sourceText = display.newText( sourceTextOpt )
    sceneGroup:insert(sourceText)

	----------------------------------------------------------------------------------------------------------------------------
    -- Display Time
    ----------------------------------------------------------------------------------------------------------------------------
    
	-- Create a new text to display the time
    
	local UTC_time = display.newText( "", dwidthC, dheighC * 0.2, native.newFont( "FallingSky.otf" , 24 ))
    sceneGroup:insert(UTC_time)
    
	-- This function updates the clock
	local function updateClock(e)       

        local hourUTC = tonumber( os.date("!%H"))
        -- If hourUTC < 0 then hourUTC = hourUTC + 24 end
        -- Put the values to the UTC_time text
        UTC_time.text = string.format( "Current Time: %02d:%s Z / %s:%s Local", hourUTC, os.date("%M"),os.date("%H"),os.date("%M"))
	end		

	updateClock() --Rub the function once every second with the delay below
    timer.performWithDelay( 1000, updateClock, 0 )
	
	----------------------------------------------------------------------------------------------------------------------------
	--PAGE SECTION
	----------------------------------------------------------------------------------------------------------------------------
	
	--A button to download the latest metar
	local function onDownloadMetar ( event )
		if (event.action == "clicked") then
			local i = event.index
			if (i == 2) then

			elseif ( i == 1 ) then

				local urlMetar = 'https://www.aviationweather.gov/adds/dataserver_current/current/metars.cache.csv'

				local params = {}

				-- Tell network.request() that we want the "began" and "progress" events:
				params.progress = "download"

				-- Tell network.request() that we want the output to go to a file:
				params.response = {
				filename = "aviator_metar.txt",
				baseDirectory = system.DocumentsDirectory
				}

				network.request( urlMetar, "GET", networkListener_m,  params )
				
				-- Set parameter to hide download button
				hideButton = 1
			end
		end

		if (event.action == "clicked") then
			local i = event.index
			if (i == 2) then

			elseif ( i == 1 ) then

				local urlTaf = 'https://www.aviationweather.gov/adds/dataserver_current/current/tafs.cache.csv'

				local params = {}

				-- Tell network.request() that we want the "began" and "progress" events:
				params.progress = "download"

				-- Tell network.request() that we want the output to go to a file:
				params.response = {
					filename = "aviator_taf.txt",
					baseDirectory = system.DocumentsDirectory
				}

				network.request( urlTaf, "GET", networkListener_t,  params )

			end
		end
	end

	-- Message box function to confirm download
	local function popRequest ()
	metarAlert = native.showAlert( "Weather Data", "It is needed to download METARs & TAFs data files (about 10 MB). Press Download to proceed." ,
	{ "Download", "Cancel"}, onDownloadMetar )
	end

	-- Button 
	local metarDown = display.newRoundedRect( dwidthC, dheighC * 0.35, dwidth * 0.7, dheigh * 0.05, 15 )
		metarDown:setFillColor(0.5,0.5,1)
		metarDown:addEventListener("tap", popRequest)
	sceneGroup:insert(metarDown)

	-- Button label
 	local metarDownLabel = display.newText( "Download Latest Weather Data", dwidthC, dheighC * 0.35, native.newFont( "FallingSkyBd" , 22 ))
	sceneGroup:insert(metarDownLabel)

	-- Display METAR 
	local displayMetarOpt = { text = metarIs,
							x = display.contentCenterX,
							y = display.contentHeight * 0.45,
							width = display.actualContentWidth * 0.9,
							font = "FallingSky",
							fontSize = 20,
							align = "center"
			}
	displayMetar = display.newText( displayMetarOpt )
	sceneGroup:insert(displayMetar)

	-- Display TAF
	local displayTafOpt = { text = tafIs,
		x = display.contentCenterX,
		y = display.contentHeight * 0.70,
		width = display.actualContentWidth * 0.9,
		font = "FallingSky",
		fontSize = 20,
		align = "center"
	}
	displayTaf = display.newText( displayTafOpt )
	sceneGroup:insert(displayTaf)

	-- Display download process	
	local downPerc = display.newText( "", dwidthC, dheigh * 0.18, native.newFont( "FallingSkyBd" ,20 ) )
    sceneGroup:insert(downPerc)
		    
	local function downloadPerc()
        downPerc.text = percText
	end
	
	local function hideButtons(staus)
		if hideButton == 1 then
			metarDown.alpha = 0
			metarDownLabel.alpha = 0
		end
	end
	
	timer.performWithDelay( 300, hideButtons, 0 )
	timer.performWithDelay( 600, downloadPerc, 0 )

    ----------------------------------------------------------------------------------------------------------------------------
    -- Get airport ID
    ----------------------------------------------------------------------------------------------------------------------------
	
    local icaoID = display.newText("Enter Airport's ICAO code", dwidthC, dheighC * 0.5, native.newFont( "FallingSkyBd" ,25 ))
    sceneGroup:insert(icaoID)

	-- Function to listen the Textfield
	
	local function arptIDListener( event )	

        if ( event.phase == "began" ) then      -- User begins editing "defaultField"

        elseif ( event.phase == "ended" or event.phase == "submitted" ) then    ---Enter (or what else) pressed
        -- event.target.text is the Output resulting text from "defaultField"
            print( event.target.text )
            keyFocus = 1
            print("focus is "..keyFocus)

            ----------------------------------------------------------------------------------------------------------------------------
            -- Read metar file.
            ----------------------------------------------------------------------------------------------------------------------------
            local metarPath = system.pathForFile("aviator_metar.txt", system.DocumentsDirectory)
			
			local fileMetar = io.open( metarPath, "r" )

            if not fileMetar then print("There ia a problem with METARs file." )
            else
				local contentMetar = fileMetar:read'*a'
                local contentMetar_a = string.match( contentMetar, string.upper(arptID.text) .. ".-\n" )
                
				if not contentMetar_a then contentMetar_a = "Airport or METAR not found."
                    print("METAR data are not available")
                end
				
                metarIs = string.sub(contentMetar_a, 1, -2)
                print(metarIs)
                fileMetar:close()
				displayMetar.text = "METAR:  " .. metarIs
            end
			
            ----------------------------------------------------------------------------------------------------------------------------
            -- Read taf file.
            ----------------------------------------------------------------------------------------------------------------------------
			local tafPath = system.pathForFile("aviator_taf.txt", system.DocumentsDirectory)
			
			local fileTaf = io.open(tafPath, "r")
			
			if not fileTaf then print("There ia a problem with TAFs file")
			else
				local contentTaf = fileTaf:read'*a'
				local contentTaf_a = string.match( contentTaf, string.upper(arptID.text) .. ".-," )
			
				if not contentTaf_a then contentTaf_a = "Airport or TAF not found."
					print("TAF data are not available")
				end
				
				tafIs = string.sub(contentTaf_a, 1, -2)
				print(tafIs)
				fileTaf:close()
				displayTaf.text = "TAF:  " .. tafIs
			end

	    elseif ( event.phase == "editing" ) then
	        print( event.newCharacters )
	        print( event.oldText )
	        print( event.startPosition )
	        print( event.text )

	    end
	end

	
	-- Create Airport Textbox
    arptID = native.newTextField( dwidthC, dheighC * 0.60, 105, 40 )
	arptID.font = native.newFont( "FallingSky.otf" , 24 ) 
	arptID:resizeHeightToFitFont()
	arptID.align = "center"
	arptID:setTextColor( 0.5, 0.5, 0.5 )
	arptID:addEventListener( "userInput", arptIDListener )
    sceneGroup:insert(arptID)

end	---scene:create

----------------------------------------------------------------------------------------------------------------------------
-- General scene functions
----------------------------------------------------------------------------------------------------------------------------

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
		composer.removeScene("weather")
		print("Scene weather removed")
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
