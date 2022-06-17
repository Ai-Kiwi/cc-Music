local args = {...}
--cleanup screen
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.setCursorPos(1,1)
term.clear()

--defining values
verson = "1.4"
local DevMode = false
if args[1] == "dev" then
    DevMode = true
end
local WindowObject = nil
local MonitorData = {}
MonitorData.X, MonitorData.Y = term.getSize()
local SongsPlaylists = {}
local NumberOfPlayListsOnSystem = 0
local PlayerHasScrolledOnPlaylistMenu = 0
local SongSelectionScroll = 0
local NumberOfSongsInPlaylist = 0
local DoUpdates = true
--setup for dev mode
if DevMode == true then
    DoUpdates = false
    verson = verson.." (DEV)"
else
    DoUpdates = true
end



--setting values
local ListOfSettings = {}
local VALUES_LOADED_IN = {}

--load values from file
local file = fs.open("CCMusicSettings.json","r")
if file then
    VALUES_LOADED_IN = file.readAll()
    file.close()
    VALUES_LOADED_IN = textutils.unserialiseJSON(VALUES_LOADED_IN)

end

--function to save the settings values to file
local function SaveSettings()
    local file = fs.open("CCMusicSettings.json","w")
    local NewListOfSettings = {}
    
    for i,v in pairs(ListOfSettings) do
        NewListOfSettings[i] = {}
        NewListOfSettings[i].Value = v.Value
    end

    if file then
        file.write(textutils.serialiseJSON(NewListOfSettings))
        file.close()
        
    end
    NewListOfSettings = nil
end

--make sure a settings exists incase it failed to load or settings are missing
local function CreateNewSettings(ValueName,ValueType,DEFAULT_VALUE,DisplayText,InfoText)
    --creates template of what the value should be
    ListOfSettings[ValueName] = {}
    ListOfSettings[ValueName]["Type"] = ValueType
    ListOfSettings[ValueName]["Value"] = DEFAULT_VALUE
    ListOfSettings[ValueName]["DisplayText"] = DisplayText
    ListOfSettings[ValueName]["InfoText"] = InfoText

    --if value doesnt exist then use template
    if VALUES_LOADED_IN[ValueName] == nil then
    else
        ListOfSettings[ValueName]["Value"] = VALUES_LOADED_IN[ValueName]["Value"]
    end
end



--looks that all the settings have been loaded and if they don't creates them

--ListOfSettings["<NAME>"]["Value"]
CreateNewSettings("SONG_BUFFER_SIZE","int",16,"Song buffer size","Song buffer size is a value that is used for chunks of a video to play. Due to current bugs alot of things that shouldnt rely off this internally. Higher seems to play video better but smaller causes more proleams but makes things look nicer due to stupid bugs i havnt got around to patching yet.")
CreateNewSettings("SHUFFLE_VIDEO","boolean",true,"shuffle video","this apon will make it so apon video finish it will start playing another video in the playlist.")
--CreateNewSettings("AUTO_FIND_SPEAKERS","boolean",true,"automatically find speakers","Enabling this will make the program automatically find speakers instead of making you set them yourself")
--CreateNewSettings("LIST_OF_SPEAKERS","LIST_OF_STRINGS",{},"list of speakers","if you have automatically find spekaers off this will let you set a list of speakers so you can play on more then one.")
CreateNewSettings("DOUBLE_BUFFERING","boolean",true,"double buffering","double buffering is a way where only after the image has fully been drawn will you be able to see it instead of allways showing it to you")
CreateNewSettings("VOLUME","range-0-100",100,"volume","this is the volume of the music")
CreateNewSettings("PLAYLIST_MENU_SIZE","int",10,"playlist menu size","this is the size of the playlist menu")

--CreateNewSettings("SOUND_EFFECTS","boolean",true,"sound effects","this will enable or disable sound effects")

SaveSettings()

--converts seconds to hours, minutes, seconds
local function SecandsToTime(Secands,FormatMode)
    --define values
    local OutputSecands = Secands
    local OutputMinutes = 0
    local OutputHours = 0
    local OutPutString = ""

    --calculates the time values
    local function CalculateTimeValue(InputTime)
        --define values
        local OutputValue = 0
        local NewInputTime = InputTime

        --calculates the values
        while NewInputTime >= 60 do
            NewInputTime = NewInputTime - 60
            OutputValue = OutputValue + 1
        end
        return OutputValue, NewInputTime
    end

    OutputMinutes, OutputSecands = CalculateTimeValue(OutputSecands)
    OutputHours, OutputMinutes = CalculateTimeValue(OutputMinutes)


    --format the output to a string
    if FormatMode then
        --converts it to a mode like this : 5:26:15

        --function to add number to string
        local function AddValue(Value)
            if Value > 0 then
                if OutPutString == "" then
                else
                    OutPutString = OutPutString..":"
                end
                OutPutString = OutPutString .. Value
            end
        end
        
        AddValue(OutputHours)
        AddValue(OutputMinutes)
        AddValue(OutputSecands)

    else
        --converts it to a mode like this : 5h 26m 15s

        --function to add number to string
        local function AddValue(Value,Text)
            if Value > 0 then
                if OutPutString ~= "" then
                    OutPutString = OutPutString.." "
                end
                OutPutString = OutPutString..Value..Text
            end
        end

        AddValue(OutputHours,"h")
        AddValue(OutputMinutes,"m")
        AddValue(OutputSecands,"s")

    end

    return OutPutString
end

local function CreateCrash(ErrorMessage)
    --remove doubble buffer because yes
    term.redirect(term.native())
    --crash go brr
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.red)
    term.setCursorPos(1,1)
    term.clear()
    print("CCMusic - " .. verson)
    print("")
    print("CCMusic has crashed")
    error(ErrorMessage, 2)

end

local function DownloadFromWeb(URL,FilePath,DontUseBufferBreaker,UseBin)
    --get funny message for user
    local FunnyText = "error 404 message not found"
    FunnyTextSite = http.get("https://gist.githubusercontent.com/meain/6440b706a97d2dd71574769517e7ed32/raw/4d5b4156027ac1605983dacaa78cf41bbd75be71/loading_messages.js")
    for i = 1, math.random(1,245) do FunnyTextSite.readLine() end
    FunnyText = FunnyTextSite.readLine()
    FunnyTextSite.close()


    --define values for printing text
    local LoopNumber = 1
    local TextSize = #FunnyText

    --gets how many lines the text will be on
    while TextSize > MonitorData.X do
        if TextSize > MonitorData.X then
            TextSize = TextSize - MonitorData.X
            LoopNumber = LoopNumber + 1
        end
    end

    --prints the funny text
    term.clear()
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)

    --runs through all the rows and prints the text
    for i=1, LoopNumber do
        local XPOS = 1
        if LoopNumber == i then
            XPOS = math.floor(MonitorData.X / 2) - math.floor(TextSize / 2)
        end

        term.setCursorPos(XPOS,(MonitorData.Y / 2) - math.floor(LoopNumber / 2) + i)
        term.write(FunnyText:sub((i * MonitorData.X) - MonitorData.X,i * MonitorData.X))
    end

    --updates the doubble buffering frame
    if WindowObject then
        WindowObject.setVisible(true)
        WindowObject.redraw()
        WindowObject.setVisible(false)
    end

    
    --define values needed for downloading
    local update = nil

    --download update
    if DontUseBufferBreaker then
        update = http.get(URL,nil,UseBin)
    else
        update = http.get(URL .. "?cb=" .. os.epoch(),nil,UseBin)
    end

    --check if the download was successful
    if update then
        --preform updating 
        local updateFile = nil
        if UseBin then
            updateFile = fs.open(FilePath, "wb")
        else
            updateFile = fs.open(FilePath, "w")
        end
        updateFile.write(update.readAll())
        updateFile.close()
        update.close()
    else
        --draws screen saying failed to contact server
        term.clear()
        term.setCursorPos(math.floor((MonitorData.X / 2)) - 9,math.floor(MonitorData.Y / 2))
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
        term.write("Failed to contact servers")
        sleep(2)
    end

end

--if the program isn't set to not update then update the program
if DoUpdates == true then
    DownloadFromWeb("https://raw.githubusercontent.com/Ai-Kiwi/cc-Music/main/core.lua",shell.getRunningProgram())
end

--sets up doubble buffering if it is enabled
if ListOfSettings["DOUBLE_BUFFERING"]["Value"] == true then
    WindowObject = window.create(term.current(), 1, 1, MonitorData.X, MonitorData.Y)
    WindowObject.setVisible(false)
    term.redirect(WindowObject)

    PromptWindowObject = window.create(term.current(), 1, 1, MonitorData.X, MonitorData.Y)
    PromptWindowObject.setVisible(false)
end




--shows a ui saying disk or computer
term.clear()
term.setBackgroundColor(colors.gray)
term.setTextColor(colors.white)
term.setCursorPos((math.floor(MonitorData.X / 2)) - 4,math.floor((MonitorData.Y / 2) - 1))
term.write("computer")
term.setCursorPos((math.floor(MonitorData.X / 2)) - 2,math.floor((MonitorData.Y / 2) + 1))
term.write("disk")





--defult location for the music
local DriveToBootOff = fs.getDir(shell.getRunningProgram())
--scan through drive asking if to use disk     TODO:     THIS NEEDS TO BE UPDATED!!! LOOKS LIKE CRAP!
local DiskDrive = peripheral.find("drive")
if DiskDrive then
    if DiskDrive.isDiskPresent() then
        --test for what the player clicked on
        while true do
            local event, button, x, y = os.pullEvent("mouse_click")
            --look if its the computer
            if y == (math.floor((MonitorData.Y / 2) - 1)) then
                break
            elseif y == (math.floor((MonitorData.Y / 2) + 1)) then
                DriveToBootOff = "disk/"
                break
            end
        end
    end
end







--look that all the needed folders exist
if fs.isDir(DriveToBootOff .. "songs/playlists/") == false then
    fs.makeDir(DriveToBootOff .. "songs/playlists/")
end

--create all varablies --TODO: Clean up how many values there are
SongPlaying = {}
SongPlaying.CorrentSongPercent = 0
SongPlaying.CorrentSongBeingPlayed = nil
SongPlaying.SongIsPlaying = true
SongPlaying.PlaylistPlayerHasOpen = nil
SongPlaying.SongByteProgress = 0
SongPlaying.SizeOfSongByteProgress = 0
SongPlaying.JumpBackToLastPauseSpot = false
SongPlaying.PauseSpotToJumpTo = 0
SongPlaying.SizeOfSong = 0
SongPlaying.SongStopped = false





--this function will shuffle to a random song 
local function PlayRandomSongInPlayList()
    --gets songs in playlist
    local ShuffledSongs = {}
    local SongsInPlaylist = fs.list(DriveToBootOff .. "songs/playlists/" .. SongPlaying.CorrentSongBeingPlayedPlaylist)

    --selects song to play at random
    SongPlaying.CorrentSongBeingPlayed = SongsInPlaylist[math.random(1,#SongsInPlaylist)]
    SongPlaying.CorrentSongPercent = 0
    SongPlaying.SongByteProgress = 0

end

local function tableContains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
end

local LastScanFilesOnSystem = fs.list("")
--look for new songs
local function LookForNewSongDragAndDropped()
    local NewFiles = fs.list("")
    for i=1,#NewFiles do
        if tableContains(LastScanFilesOnSystem, NewFiles[i]) == false then
            --look for songs that have been added
    
            local NewName = NewFiles[i]
    
            if string.sub(NewName, #NewName -5, #NewName) == ".dfpwm" then
                NewName = string.sub(NewName, 1, #NewName -6)
            end
            fs.move(NewFiles[i], DriveToBootOff .. "songs/playlists/" .. SongPlaying.PlaylistPlayerHasOpen .. "/" .. NewName)
            break
        end
    end
end


local function preformPopUp(Message)
    --defines values needed for the pop up
    UserInput = ""
    local startingFiles = fs.list("")

    --keeps looping until the user presses enter
    while true do
        --gets the user input
        local event, character = os.pullEvent()

        --handles the user input
        if event == "paste" then
            UserInput = UserInput .. character
        elseif character == keys.enter and event == "key" then
            return UserInput
        elseif character == keys.backspace and event == "key" then
            UserInput = UserInput:sub(1,#UserInput - 1)
        elseif event == "char" then
            UserInput = UserInput .. character
        end

        --gets size of text user inputed
        SizeOfTextBox = #UserInput
        
        
        --looks if doubble buffering is enabled
        if WindowObject == nil then
            term.setBackgroundColor(colors.gray)
            term.clear()
            
        else
            
            term.redirect(WindowObject)
            WindowObject.setVisible(true)
            WindowObject.redraw()
            WindowObject.setVisible(false)
            term.redirect(term.native())
        end

        --if the user text typed in is less the the size of the message then draw the message
        if SizeOfTextBox < #Message then
            SizeOfTextBox = #Message
        end

        
        --draw text box for user input
        paintutils.drawFilledBox((MonitorData.X / 2) - ((SizeOfTextBox / 2) + 1) + 1 ,(MonitorData.Y / 2) + 3,(MonitorData.X / 2) + (((SizeOfTextBox + 1) / 2)) + 1 ,(MonitorData.Y / 2),colors.black,colors.white)
        paintutils.drawLine((MonitorData.X / 2) - ((SizeOfTextBox / 2) + 0) + 1 ,(MonitorData.Y / 2) + 2,(MonitorData.X / 2) + (((SizeOfTextBox + 1) / 2) - 1) + 1 ,(MonitorData.Y / 2) + 2,colors.gray)
        term.setCursorPos((MonitorData.X / 2) - ((SizeOfTextBox / 2) + 0) + 1 ,(MonitorData.Y / 2) + 2)
        term.write(UserInput)
        --draw info
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
        term.setCursorPos((MonitorData.X / 2) - ((SizeOfTextBox / 2) + 0) + 1 ,(MonitorData.Y / 2) + 1)
        term.write(Message)

        --reddicrect to the normal window
        if WindowObject then
            term.redirect(WindowObject)
        end
        LookForNewSongDragAndDropped()
    end
    
end

--clears the line you pick
local function ClearLine(ColorPicked,Line)
    term.setCursorPos(1,Line)
    term.setBackgroundColor(ColorPicked)
    term.clearLine()
end

--draws the settings menu
local function SettingsMenu()


    while true do
        --draw settings menu
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.gray)
        term.clear()

        --draws each setting
        local BindingForSettings = {}
        local Value = 0
        for k,v in pairs(ListOfSettings) do
            Value = Value + 1
            term.setCursorPos(1,Value)
            term.write(v.DisplayText .. " : " .. tostring(v.Value))
            BindingForSettings[Value] = k
    
    
        end
        --draws close button
        term.setCursorPos(MonitorData.X,1)
        term.setTextColor(colors.red)
        term.setBackgroundColor(colors.gray)
        term.write("x")

        --double buffering
        if WindowObject then
            WindowObject.setVisible(true)
            WindowObject.redraw()
            WindowObject.setVisible(false)
        end
        
        --handle user input
        local EventOutput = {os.pullEvent()}
        if EventOutput[1] == "mouse_click" then
            local X,Y = EventOutput[3],EventOutput[4]
            if X == MonitorData.X and Y == 1 then
                term.redirect(WindowObject)
                return

            else

                ValueBeingChanged = BindingForSettings[Y]
                --TODO: clean up this code
                --if they click on a value then change it
                if ListOfSettings[ValueBeingChanged] then            
                    if ListOfSettings[ValueBeingChanged].Type == "boolean" then
                        ListOfSettings[ValueBeingChanged].Value = not ListOfSettings[ValueBeingChanged].Value
                    elseif ListOfSettings[ValueBeingChanged].Type == "range-1-5" then
                        if ListOfSettings[ValueBeingChanged].Value == 5 then
                            ListOfSettings[ValueBeingChanged].Value = 1
                        else
                            ListOfSettings[ValueBeingChanged].Value = ListOfSettings[ValueBeingChanged].Value + 1
                        end
                    elseif ListOfSettings[ValueBeingChanged].Type == "LIST_OF_STRINGS" then
                        ListOfSettings[ValueBeingChanged].Value = preformPopUp("New value for " .. ListOfSettings[ValueBeingChanged].DisplayText .. "?")
                    elseif ListOfSettings[ValueBeingChanged].Type == "int" then
                        ListOfSettings[ValueBeingChanged].Value = math.floor(tonumber(preformPopUp("New value for " .. ListOfSettings[ValueBeingChanged].DisplayText .. "?")))

                        --TODO: fix range system
                    elseif ListOfSettings[ValueBeingChanged].Type == "range-0-100" then

                        if ListOfSettings[ValueBeingChanged].Value >= 100 then
                            ListOfSettings[ValueBeingChanged].Value = 0
                        else
                            ListOfSettings[ValueBeingChanged].Value = ListOfSettings[ValueBeingChanged].Value + 10
                        end

                    end
                    SaveSettings()
                end

            end
        end
        



    end



end

--TODO: clean up this whole function
--draws the corrent song playing
local function RenderSongPlayingGUI()

    --clears the lines so that text can be drawn in a certain area
    ClearLine(colors.black ,MonitorData.Y)
    ClearLine(colors.black ,MonitorData.Y - 1)

    --caulate progress bar data
    ProgressBarLettersCanBeFilled = MonitorData.X - 2
    ProgressBarLettersFilled = ProgressBarLettersCanBeFilled * SongPlaying.CorrentSongPercent
    local TextToWrite = SecandsToTime(math.floor((SongPlaying.SizeOfSong / 6000) * (SongPlaying.SongByteProgress / SongPlaying.SizeOfSongByteProgress)))
    local TimeLeft = SecandsToTime(math.floor((SongPlaying.SizeOfSong / 6000) * ((SongPlaying.SizeOfSongByteProgress - SongPlaying.SongByteProgress) / SongPlaying.SizeOfSongByteProgress)))
    local SizeOfText = #TextToWrite + #TimeLeft
    for i=1,ProgressBarLettersCanBeFilled - SizeOfText do
        TextToWrite = TextToWrite.." "
    end
    TextToWrite = TextToWrite..TimeLeft

    --loops through every letter and draws a letter in the progress bar
    for i=1,ProgressBarLettersCanBeFilled do
        term.setCursorPos(i + 1,MonitorData.Y)
        if ProgressBarLettersFilled > i then
            if SongPlaying.SongIsPlaying then
                term.setBackgroundColor(colors.orange)
            else
                term.setBackgroundColor(colors.red)
            end
        else
            term.setBackgroundColor(colors.gray)
        end
        if string.sub(TextToWrite,i,i) == "" then
            term.write(" ")
        else
            term.write(string.sub(TextToWrite,i,i))
            
        end
            
    end

    --draw song name
    term.setCursorPos(2,MonitorData.Y - 1)
    term.setBackgroundColor(colors.black)

    local SongNameWritting = SongPlaying.CorrentSongBeingPlayed
    local SongLengthWritting = SecandsToTime(math.floor(SongPlaying.SizeOfSong / 6000))
    local SpaceCanWrite = MonitorData.X - 6
    
    local SizeCanWrite = (SpaceCanWrite - #SongLengthWritting)
    local finalTextWriteing = nil
    local offset = 0
    --look if text is too long then if it is start wrapping it
    if ((#SongNameWritting + 2) - SizeCanWrite) < 1 then
        offset = 0
        finalTextWriteing = SongNameWritting
        
    else
        offset = os.clock() - (math.floor(os.clock() / (((#SongNameWritting + 2) - SizeCanWrite )*2)) * (((#SongNameWritting + 2) - SizeCanWrite)*2))
        finalTextWriteing = (SongNameWritting .. "   " .. SongNameWritting):sub(1 + offset,SizeCanWrite + offset)
    end

    

    term.setTextColor(colors.white)
    term.write(finalTextWriteing)

    term.setCursorPos(MonitorData.X - (#SongLengthWritting + 3),MonitorData.Y - 1)
    term.setTextColor(colors.gray)
    term.write(SongLengthWritting)
    
    
    term.setCursorPos(MonitorData.X - 1,MonitorData.Y - 1)
    term.setBackgroundColor(colors.red)
    term.setTextColor(colors.white)
    term.write("x")

    --draws skip button
    term.setCursorPos(MonitorData.X - 2,MonitorData.Y - 1)
    term.setBackgroundColor(colors.orange)
    term.setTextColor(colors.white)
    term.write(">")


end


local function DrawPlaylistGui()

    --draw a sidetext of the playlists
    paintutils.drawFilledBox(1,1,ListOfSettings["PLAYLIST_MENU_SIZE"]["Value"],MonitorData.Y,colors.black)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)

    --draw list of playlists
    NumberOfPlayListsOnSystem = 0
    SongsPlaylists = fs.list(DriveToBootOff .. "songs/playlists/")

    --loop though every item in the playlist
    for i=1,#SongsPlaylists do
        --draw the delete button
        term.setCursorPos(1,2 + i + PlayerHasScrolledOnPlaylistMenu)
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.red)
        term.write("x")

        --gets the background color of the playlist (different if selected)
        if SongPlaying.PlaylistPlayerHasOpen == SongsPlaylists[i] then
            term.setBackgroundColor(colors.gray)
        else
            term.setBackgroundColor(colors.black)
        end

        --draw outline
        term.setTextColor(colors.white)
        term.setCursorPos(2,2 + i + PlayerHasScrolledOnPlaylistMenu)
        term.write((SongsPlaylists[i] .. "                                                                                        "):sub(1,ListOfSettings["PLAYLIST_MENU_SIZE"]["Value"] - 1))
        NumberOfPlayListsOnSystem = NumberOfPlayListsOnSystem + 1
    end

    --draw add new button
    term.setCursorPos(math.floor(ListOfSettings["PLAYLIST_MENU_SIZE"]["Value"] / 2),3 + NumberOfPlayListsOnSystem + PlayerHasScrolledOnPlaylistMenu)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.green)
    term.write("+")

    --draw playlist text
    term.setCursorPos(1,1)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.write(("Playlists"):sub(1,ListOfSettings["PLAYLIST_MENU_SIZE"]["Value"]))

    --draw verson text
    term.setCursorPos(1,MonitorData.Y - 1)
    if DevMode == true then
        term.setTextColor(colors.green)
    else
        term.setTextColor(colors.blue)
    end
    term.setBackgroundColor(colors.black)
    term.write(("v" .. verson):sub(1,ListOfSettings["PLAYLIST_MENU_SIZE"]["Value"]))

    --draw settings text
    term.setCursorPos(1,MonitorData.Y)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.write(("settings"):sub(1,ListOfSettings["PLAYLIST_MENU_SIZE"]["Value"]))

end

--draws menu for what song to play
local function DrawSongSelectionMenu()

    --print the title
    term.setCursorPos(2 + ListOfSettings["PLAYLIST_MENU_SIZE"]["Value"],2 + SongSelectionScroll)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
    local AmtOfSongs = fs.list(DriveToBootOff .. "songs/playlists/" .. SongPlaying.PlaylistPlayerHasOpen)
    term.write(SongPlaying.PlaylistPlayerHasOpen .. " - " .. #AmtOfSongs .. " songs")
    term.setCursorPos(2 + ListOfSettings["PLAYLIST_MENU_SIZE"]["Value"],3 + SongSelectionScroll)
    term.setTextColor(colors.lightGray)
    local FreeSpaceInDrive = fs.getFreeSpace(DriveToBootOff .. "songs/playlists/" .. SongPlaying.PlaylistPlayerHasOpen) 
    term.write((math.floor(FreeSpaceInDrive / 10000) / 100) .. "mb of free space (" .. SecandsToTime(math.floor(FreeSpaceInDrive / 6000)) .. ")")

    --draw all the songs
    NumberOfSongsInPlaylist = 0
    SongsInPlaylists = fs.list(DriveToBootOff .. "songs/playlists/" .. SongPlaying.PlaylistPlayerHasOpen)
    for i=1,#SongsInPlaylists do
        --draws the remove button
        term.setCursorPos(2 + ListOfSettings["PLAYLIST_MENU_SIZE"]["Value"],5 + i + SongSelectionScroll)
        term.setBackgroundColor(colors.gray)
        term.setTextColor(colors.red)
        term.write("x ")
        
        
        --set the background color (differnt if item is selected)
        if SongPlaying.CorrentSongBeingPlayed == SongsInPlaylists[i] then
            term.setBackgroundColor(colors.lightGray)
        else
            term.setBackgroundColor(colors.gray)
        end

        --draws the song name
        term.setTextColor(colors.white)
        term.setCursorPos(4 + ListOfSettings["PLAYLIST_MENU_SIZE"]["Value"],5 + i + SongSelectionScroll)
        term.write(SongsInPlaylists[i] .. "                                                                                        ")
        NumberOfSongsInPlaylist = NumberOfSongsInPlaylist + 1
    end

    --draw add new button
    term.setCursorPos(math.floor((MonitorData.X - ListOfSettings["PLAYLIST_MENU_SIZE"]["Value"]) / 2) + ListOfSettings["PLAYLIST_MENU_SIZE"]["Value"],6 + NumberOfSongsInPlaylist + SongSelectionScroll)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.green)
    term.write("+")

end

--function that draws song render
local function PreformSongRender()
    if SongPlaying.PlaylistPlayerHasOpen then
        DrawSongSelectionMenu()
    end
    DrawPlaylistGui()
    if SongPlaying.CorrentSongBeingPlayed then
        RenderSongPlayingGUI()
    end



end





--TODO: make code less janky
local function PlaySong()
    --define values needed
    local buffer = ""
    local dfpwm = require("cc.audio.dfpwm")
    local speaker = peripheral.find("speaker")
    if speaker == nil then
        CreateCrash("No speaker found")
    end

    local decoder = dfpwm.make_decoder()
    

    while true do
        --if a song if being played
        if SongPlaying.CorrentSongBeingPlayed then
            --setup for song playing
            SongHasFinished = false
            SongPlaying.SongStopped = false
            SongPlaying.SizeOfSongByteProgress = 0
            for chunk in io.lines("songs/playlists/" .. SongPlaying.CorrentSongBeingPlayedPlaylist .. "/" .. SongPlaying.CorrentSongBeingPlayed, ListOfSettings["SONG_BUFFER_SIZE"]["Value"] * 1024) do
                SongPlaying.SizeOfSongByteProgress = SongPlaying.SizeOfSongByteProgress + 1
            end
            SongPlaying.SongByteProgress = 0
            local SongStartedWith = SongPlaying.CorrentSongBeingPlayed
            SongPlaying.SizeOfSong = fs.getSize("songs/playlists/" .. SongPlaying.CorrentSongBeingPlayedPlaylist .. "/" .. SongPlaying.CorrentSongBeingPlayed)
            

            --look ive been coding for to long and honestly i dont really wanna write how this works
            --maybe one day i will along with the rest of this code
            for chunk in io.lines("songs/playlists/" .. SongPlaying.CorrentSongBeingPlayedPlaylist .. "/" .. SongPlaying.CorrentSongBeingPlayed, ListOfSettings["SONG_BUFFER_SIZE"]["Value"] * 1024) do
                --looks if its skipping this part of the song becuase its resumming from pause
                if SongPlaying.JumpBackToLastPauseSpot == false or SongPlaying.PauseSpotToJumpTo == SongPlaying.SongByteProgress then
                    --says it has finish unpasuing
                    SongPlaying.JumpBackToLastPauseSpot = false
                    if SongPlaying.CorrentSongBeingPlayed then
                        buffer = decoder(chunk)
                        
                        --wait until next part of song can be played
                        while not speaker.playAudio(buffer,ListOfSettings["VOLUME"]["Value"] / 100 ) do
                            os.sleep(0.1)
                        end
                        --stops song is pause is pressed
                        if SongPlaying.CorrentSongBeingPlayed ~= SongStartedWith then
                            speaker.stop()
                        end
                        --if song is paused then wait until it is unpaused
                        if SongPlaying.SongIsPlaying == false then
                            speaker.stop()
                            while SongPlaying.SongIsPlaying == false do
                                os.sleep(0.1)
                            end
                            SongPlaying.JumpBackToLastPauseSpot = true
                            SongPlaying.PauseSpotToJumpTo = SongPlaying.SongByteProgress - 2
                            break
                        end

                    else
                        --handles unpausing
                        speaker.stop()
                        break
                    end
                end
                --skips if its paused
                if SongPlaying.CorrentSongBeingPlayed == nil then

                    break
                end
                --stop song
                if SongPlaying.SongStopped then
                    speaker.stop()
                    break
                end
                SongPlaying.SongByteProgress = SongPlaying.SongByteProgress + 1
                if SongPlaying.SongByteProgress == SongPlaying.SongByteProgress then
                    SongHasFinished = true
                end
            end
            if SongPlaying.JumpBackToLastPauseSpot == false then
                --clears out song because it is done
                SongPlaying.CorrentSongBeingPlayed = nil
                SongPlaying.CorrentSongPercent = 0
                SongPlaying.SongByteProgress = 0
                if SongHasFinished == true then
                    if SongPlaying.SongStopped == false then
                        if ListOfSettings["SHUFFLE_VIDEO"]["Value"] == true then
                            PlayRandomSongInPlayList()
                        end
                    end
                    SongHasFinished = false
                end
            end
            SongPlaying.SongStopped = false
        else
            os.sleep(0)

        end
    end
end

--handles the event handler
local function EventHandler()
    local speaker = peripheral.find("speaker")
    if speaker == nil then
        CreateCrash("No speaker found")
    end
    local EventName, EventParam1, EventParam2, EventParam3 = os.pullEvent()
    -- event, button, x, y
    --looks if it is the player clicking
    if EventName == "mouse_click" then
        local MouseClickButten = EventParam1
        local MouseClickX = EventParam2
        local MouseClickY = EventParam3

        --looks if they are clicking on the corrent song playing
        if MouseClickY > (MonitorData.Y - 2) and SongPlaying.CorrentSongBeingPlayed then
            --they are clicking on progress bar
            if MouseClickY == MonitorData.Y then
                SongPlaying.SongIsPlaying = not SongPlaying.SongIsPlaying
                if SongPlaying.SongIsPlaying == false then
                    speaker.stop()
                    
                end
            end
            --player is clicking on the close button
            if MouseClickY == (MonitorData.Y - 1) and MouseClickX == (MonitorData.X - 1)  then
                SongPlaying.SongStopped = true

            end
            --player is clicking on the skip button
            if MouseClickY == (MonitorData.Y - 1) and MouseClickX == (MonitorData.X - 2)  then
                SongPlaying.CorrentSongBeingPlayed = nil
            end

        --looks if they are clicking on the the playlist menu
        elseif MouseClickX < (ListOfSettings["PLAYLIST_MENU_SIZE"]["Value"] + 1) then
            if MouseClickY == MonitorData.Y then
                --player has clicked the settings menu
                SettingsMenu()

            else
                --looks if they are clicking on the new playlist button
                if MouseClickY == (3 + NumberOfPlayListsOnSystem - PlayerHasScrolledOnPlaylistMenu) then
                    local Temp = preformPopUp("Enter the name of the playlist")
                    fs.makeDir(DriveToBootOff .. "songs/playlists/" .. Temp)
                    SongPlaying.PlaylistPlayerHasOpen = Temp
                end
                --make sure there clicking on a playlist
                if MouseClickY > 2 and MouseClickY < (NumberOfPlayListsOnSystem +(3 - PlayerHasScrolledOnPlaylistMenu)) then
                    --look if they are clicking to delete a playlist
                    if MouseClickX == 1 then
                        if preformPopUp("type yes to confirm you would like to delete this") == "yes" then
                            fs.delete(DriveToBootOff .. "songs/playlists/" .. SongsPlaylists[MouseClickY - 2 - PlayerHasScrolledOnPlaylistMenu])
                            SongPlaying.PlaylistPlayerHasOpen = nil
                        end
                    else
                        SongPlaying.PlaylistPlayerHasOpen = SongsPlaylists[MouseClickY - 2 - PlayerHasScrolledOnPlaylistMenu]
                        SongSelectionScroll = 0
                    end

                end
            end


            --looks if they are clicking on the song player menu
        else
            --looks if they are clicking on a song
            if MouseClickY > 4 + SongSelectionScroll and MouseClickY < NumberOfSongsInPlaylist + 6 + SongSelectionScroll then
                --look if they are clicking on the remove button
                if MouseClickX == (2 + ListOfSettings["PLAYLIST_MENU_SIZE"]["Value"]) then
                    if preformPopUp("type yes to confirm you would like to delete this") == "yes" then
                        fs.delete(DriveToBootOff .. "songs/playlists/" .. SongPlaying.PlaylistPlayerHasOpen .. "/" .. SongsInPlaylists[MouseClickY - 5 - SongSelectionScroll])
                        SongsInPlaylists = fs.list(DriveToBootOff .. "songs/playlists/" .. SongPlaying.PlaylistPlayerHasOpen)
                        NumberOfSongsInPlaylist = NumberOfSongsInPlaylist - 1
                    end
                else
                    SongPlaying.CorrentSongBeingPlayed = SongsInPlaylists[MouseClickY - 5 - SongSelectionScroll]
                    SongPlaying.CorrentSongBeingPlayedPlaylist = SongPlaying.PlaylistPlayerHasOpen
                    SongPlaying.SongIsPlaying = true
                    SongPlaying.CorrentSongPercent = 0
                    SongPlaying.SongByteProgress = 0
                end
                --look if they are clicking on the addnew button
            elseif MouseClickY == (6 + NumberOfSongsInPlaylist + SongSelectionScroll) then
                local URL = preformPopUp("Enter the URL or drag and drop")
                if not (URL == nil) then
                    local NewSongName = preformPopUp("Enter the name of the song")
                    --download song
                    local SongFileName = DriveToBootOff .. "songs/playlists/" .. SongPlaying.PlaylistPlayerHasOpen .. "/" .. NewSongName
                    DownloadFromWeb(URL,SongFileName,true,true)
                end
                
            end
        end
    elseif EventName == "mouse_scroll" then
        if EventParam2 < (ListOfSettings["PLAYLIST_MENU_SIZE"]["Value"] + 1) then
            PlayerHasScrolledOnPlaylistMenu = PlayerHasScrolledOnPlaylistMenu + (EventParam1 * -1)
            if PlayerHasScrolledOnPlaylistMenu > 0 then
                PlayerHasScrolledOnPlaylistMenu = 0
            end


        else
            SongSelectionScroll = SongSelectionScroll + (EventParam1 * -1)
            if SongSelectionScroll > 0 then
                
                SongSelectionScroll = 0
            end
        end 
    end

end



local function MainSystem()
while true do
    SongPlaying.CorrentSongPercent = SongPlaying.SongByteProgress / SongPlaying.SizeOfSongByteProgress

    term.setBackgroundColor(colors.gray)
    term.clear()
    
    PreformSongRender()

    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)

    if WindowObject then
        WindowObject.setVisible(true)
        WindowObject.redraw()
        WindowObject.setVisible(false)
    end
    LookForNewSongDragAndDropped()
    EventHandler()
    
end
end


parallel.waitForAny(MainSystem, PlaySong)
--program has finished probs crashed but idk


--remove doubble buffer because yes
term.redirect(term.native())
