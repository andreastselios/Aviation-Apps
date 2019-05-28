-- To be fixed 
-- 1. Only 1st runways is being displayed.
-- 2. Check if the file is older than 1 month.
-- 3. Fonts to be fixed
-- 4. Error handling
--
-- Airport Information page
-- Downloads the world airport data from OurAirports.com (2 files Airports & Runways)
-- Uses ICAO airport code to find the informations from local data (aviator_airports.txt & aviator_runways.txt)
-- Handles errors while searching

local composer = require( "composer" )
local helpers = require( "helpers" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Decleration of locals
local bg
local title
local buttonMenu

local percDown
local percText = ""

local arptID
local arptDataIs = ""
local arptData = {}
local rwyDataIs = ""
local rwyData = {}
local NorthSouth = ""
local EastWest = ""

local dwidth = display.contentWidth
local dheigh = display.contentHeight
local dwidthC = display.contentCenterX
local dheighC = display.contentCenterY

local hideButton = 0

-- Creating the download progress

-- networkListener_a is for handling download of Airport data (Just to display the right message, need to be improoved)
local function networkListener_a( event )
	
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
            print( "Download airports: " .. event.bytesTransferred )
        else
            print( "Download airports: " .. event.bytesTransferred .. " of estimated: " .. event.bytesEstimated )
            print( string.format("Download airports: %d%%" , (event.bytesTransferred /event.bytesEstimated)*100 ))
            percText = string.format("Download airports: %d%%" , (event.bytesTransferred /event.bytesEstimated)*100 )
            percDown = event.bytesTransferred /event.bytesEstimated
            print(percDown)
        end

    elseif ( event.phase == "ended" ) then
        print( "Download complete, total bytes transferred: " .. event.bytesTransferred )
        print( string.format("Download progress: %d%%" , (event.bytesTransferred /event.bytesEstimated)*100 ))
        percText = "Airport data has been downloaded succesfully."
    end	

end	

-- networkListener_r is for handling download of Runways data (Just to display the right message, need to be improoved)
local function networkListener_r( event )
	
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
            print( "Download runways: " .. event.bytesTransferred )
        else
            print( "Download runways: " .. event.bytesTransferred .. " of estimated: " .. event.bytesEstimated )
            print( string.format("Download runways: %d%%" , (event.bytesTransferred /event.bytesEstimated)*100 ))
            percText = string.format("Download runways: %d%%" , (event.bytesTransferred /event.bytesEstimated)*100 )
            percDown = event.bytesTransferred /event.bytesEstimated
            print(percDown)
        end

    elseif ( event.phase == "ended" ) then
        print( "Download complete, total bytes transferred: " .. event.bytesTransferred )
        print( string.format("Download progress: %d%%" , (event.bytesTransferred /event.bytesEstimated)*100 ))
        percText = "Runways has been downloaded succesfully."
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

-- Create the Airports page

function scene:create( event )

	local sceneGroup = self.view
    
	-- Background color
    bg = display.newRect( dwidthC, dheighC, dwidth, dheigh )
    bg:setFillColor(0.5,0.6,0.5)
    sceneGroup:insert(bg)
    
	-- Page title
    title = display.newText( "Airports Data", dwidthC, dheighC * 0.09, native.newFont( "FallingSkyBd.otf" ,40 ))
    sceneGroup:insert(title)

    -- Page footer
	
	local sourceTextOpt = {text = "Airport Information is courtesy of OurAirports.com",
        x = dwidthC,
        y = dheigh * 0.95,
        width = dwidth * 0.65,
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
    -- Download buttons & proccess
    ----------------------------------------------------------------------------------------------------------------------------

-- Download files function

	local function onDownloadAirport ( event )
		
		if (event.action == "clicked") then
            local i = event.index
            if (i == 2) then

            elseif ( i == 1 ) then

                local urlAirports = 'http://ourairports.com/data/airports.csv'

                local params = {}

                -- Tell network.request() that we want the "began" and "progress" events:
                params.progress = "download"

                -- Tell network.request() that we want the output to go to a file:
                params.response = {
                    filename = "aviator_airports.txt",
                    baseDirectory = system.DocumentsDirectory
                }

                network.request( urlAirports, "GET", networkListener_a,  params )
				
				-- Set parameter to hide download button
				hideButton = 1
            end
			
        end
			
		-- Same process for the 2nd file.
        if (event.action == "clicked") then
	        local i = event.index
            if (i == 2) then

            elseif ( i == 1 ) then

                local urlRunways = 'http://ourairports.com/data/runways.csv'

                local params = {}

                -- Tell network.request() that we want the "began" and "progress" events:
                params.progress = "download"

                -- Tell network.request() that we want the output to go to a file:
                params.response = {
                    filename = "aviator_runways.txt",
                    baseDirectory = system.DocumentsDirectory
                }

                network.request( urlRunways, "GET", networkListener_r,  params )
								
            end
        end

    end

	-- Message box function to confirm download
	local function popRequest ()
        local downAlert = native.showAlert( "Airport Data", "It is needed to download Airports & Runways data files (about 10 MB). Press Download to proceed." , 
		{ "Download", "Cancel"}, onDownloadAirport )
    end

	-- Button 
    local dataDown = display.newRoundedRect( dwidthC, dheighC * 0.35, dwidth * 0.5, dheigh * 0.05, 15 )
        dataDown:setFillColor(0.5,0.5,1)
        dataDown:addEventListener("tap", popRequest)
	sceneGroup:insert(dataDown)

	-- Button label
    local dataDownLabel = display.newText( "Download Airport Data", dwidthC, dheighC * 0.35, native.newFont( "FallingSkyBd" , 22 ))
    sceneGroup:insert(dataDownLabel)

    -- Display airport data
	local displayArptData = display.newText( arptDataIs, dwidthC, dheighC * 1.1, display.actualContentWidth * 0.8,
        display.actualContentHeight * 0.4, native.systemFont,22)
    sceneGroup:insert(displayArptData)

	-- Display download process
	local downPerc = display.newText( "", dwidthC, dheigh * 0.18, native.newFont( "FallingSkyBd" ,20 ) )
    sceneGroup:insert(downPerc)
		    
	local function downloadPerc()
        downPerc.text = percText
	end
	
	local function hideButtons(staus)
		if hideButton == 1 then
			dataDown.alpha = 0
			dataDownLabel.alpha = 0
		end
	end
	
	timer.performWithDelay( 300, hideButtons, 0 )
	timer.performWithDelay( 600, downloadPerc, 0 )
	
    ----------------------------------------------------------------------------------------------------------------------------
    -- Get airport ID
    ----------------------------------------------------------------------------------------------------------------------------
	
    local icaoID = display.newText("Enter Airport's ICAO code", dwidthC, dheighC * 0.5, native.newFont( "FallingSkyBd" ,25 ))
    sceneGroup:insert(icaoID)

    local function arptIDListener( event )

        if ( event.phase == "began" ) then      -- User begins editing "defaultField"

        elseif ( event.phase == "ended" or event.phase == "submitted" ) then    ---Enter (or what else) pressed
        -- event.target.text is the Output resulting text from "defaultField"
            print( event.target.text )
            keyFocus = 1
            print("focus is "..keyFocus)
            ----------------------------------------------------------------------------------------------------------------------------
            -- Read airport file.
            ----------------------------------------------------------------------------------------------------------------------------
            local airportPath = system.pathForFile("aviator_airports.txt", system.DocumentsDirectory)

            local airportfile = io.open( airportPath, "r" )

            if not airportfile then print("There ia a problem with Airports file." )
            else
				local airportfilecontent = airportfile:read'*a'
                local airportfilecontent_a = string.match( airportfilecontent, string.upper(arptID.text) .. ".-\n" )
                
				if not airportfilecontent_a then airportfilecontent_a = "Airport not found"
                    print("Airport DATA Not Available")
                end
				
                arptDataIs = string.sub(airportfilecontent_a, 1, -2)
                print(arptDataIs)

                arptData = airportfilecontent_a:split(",")
                for i=1, #arptData do
                    print(arptData[i])
                end

                airportfile:close()
            end

            ----------------------------------------------------------------------------------------------------------------------------
            -- Read runway file.
            ----------------------------------------------------------------------------------------------------------------------------
            local rwyPath = system.pathForFile("aviator_runways.txt", system.DocumentsDirectory)

            local rwyfile = io.open( rwyPath, "r" )

            if not rwyfile then print("There ia a problem with Runways file." )
            else
                local rwyfilecontent = rwyfile:read'*a'
                local rwyfilecontent_a = string.match( rwyfilecontent, string.upper(arptID.text) .. ".-\n" )
				
				if not rwyfilecontent_a then rwyfilecontent_a = "Airport's runways not found"
                    print("Runways DATA Not Available")
                end 
				
				rwyData = string.sub(rwyfilecontent_a, 1, -2)
				print(rwyDataIs .. " $")
				
				rwyData = rwyfilecontent_a:split(",")
				for i=1, #rwyData do
					print(rwyData[i])
				end
								
				rwyfile:close()
					
				local i = 0
				local tf = {}
				while true do
					i = string.find(rwyfilecontent, string.upper(arptID.text), i+1)
					if i == nil then break end
					table.insert(tf, i)
					print("Found at " .. i)
				end
				print(#tf)
				
            end
	
		----------------------------------------------------------------------------------------------------------------------------
		-- Create output strings
		----------------------------------------------------------------------------------------------------------------------------
        				
		if #arptData < 2 or #arptID.text < 4 then
            displayArptData.text = "Airport Not Found.\nPlease make sure that you have enetered a valid ICAO code."
			
        else

            if tonumber(arptData[4]) >= 0 then NorthSouth = "N" else NorthSouth = "S" end
            if tonumber(arptData[5]) >= 0 then EastWest = "E" else EastWest = "W" end

            displayArptData.text =                                          --1st line: ICAO, City, Country Code
            string.sub(arptData[1],1, -2) .. "  " .. string.sub(arptData[10],2, -2) .. ", " .. string.sub(arptData[8],2, -2) .." \n" ..
            string.sub(arptData[3], 2, -2) .. "\n" ..                       --Airport Name
            "IATA code: " .. string.sub(arptData[13], 2, -2) .. "\n" ..     --IATA code
            string.format("Elevetion: %d ft\n", arptData[6]) ..             --Arpt Elevetion
            string.format("Latitude: %s%8.6f\n", NorthSouth, arptData[4]) ..              --Arpt Lat
            string.format("Longitude: %s%010.6f\n", EastWest, math.abs(arptData[5])) ..             --Arpt Long
            -- (insert link to website) string.sub(arptData[15],1, -2) ..
			"\nRUNWAYS\n" ..                                                --Runways header
			string.sub(rwyData[7], 2, -2) .. "/" .. string.sub(rwyData[13], 2, -2) ..": " ..
			"HDG: " .. rwyData[11] .. "/" .. rwyData[17] .. ", Length: " .. rwyData[2] .. ", " ..
			string.sub(rwyData[4], 2, -2) .. "\n\n" 
			
			--------displayArptData.font = native.newFont( "FallingSky.otf" , 40 ) 
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

end	--scene:create

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
        composer.removeScene("AirportsData")
        print("Scene Airport Data removed")
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
