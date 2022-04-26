verson = "1.2.2"
MoniterX, MoniterY = term.getSize()
DoUpdates = true


--all the stuff for 

ListOfSettings = {}
VALUES_LOADED_IN = {}

local file = fs.open("CC-MUSIC.config","r")
if file then
    VALUES_LOADED_IN = file.readAll()
    file.close()
    VALUES_LOADED_IN = textutils.unserialise(VALUES_LOADED_IN)

end

local function SaveSettings()
    local file = fs.open("CC-MUSIC.config","w")
    local NewListOfSettings = {}
    
    for i,v in pairs(ListOfSettings) do
        NewListOfSettings[i] = {}
        NewListOfSettings[i].Value = v.Value
    end

    if file then
        file.write(textutils.serialise(NewListOfSettings))
        file.close()
        
    end
    NewListOfSettings = nil
end

local function CreateNewSettings(ValueName,ValueType,DEFAULT_VALUE,DisplayText,InfoText)
    ListOfSettings[ValueName] = {}
    ListOfSettings[ValueName]["Type"] = ValueType
    ListOfSettings[ValueName]["Value"] = DEFAULT_VALUE
    ListOfSettings[ValueName]["DisplayText"] = DisplayText
    ListOfSettings[ValueName]["InfoText"] = InfoText


    if VALUES_LOADED_IN[ValueName] == nil then
    else
        ListOfSettings[ValueName]["Value"] = VALUES_LOADED_IN[ValueName]["Value"]
    end
end

term.clear()
term.setCursorPos(1,1)

--ListOfSettings["<NAME>"]["Value"]
CreateNewSettings("SONG_BUFFER_SIZE","int",16,"Song buffer size","Song buffer size is a value that is used for chunks of a video to play. Due to current bugs alot of things that shouldnt rely off this internally. Higher seems to play video better but smaller causes more proleams but makes things look nicer due to stupid bugs i havnt got around to patching yet.")
CreateNewSettings("SHUFFLE_VIDEO","boolean",true,"shuffle video","this apon will make it so apon video finish it will start playing another video in the playlist.")
--CreateNewSettings("AUTO_FIND_SPEAKERS","boolean",true,"automatically find speakers","Enabling this will make the program automatically find speakers instead of making you set them yourself")
--CreateNewSettings("LIST_OF_SPEAKERS","LIST_OF_STRINGS",{},"list of speakers","if you have automatically find spekaers off this will let you set a list of speakers so you can play on more then one.")
CreateNewSettings("DOUBLE_BUFFERING","boolean",true,"double buffering","double buffering is a way where only after the image has fully been drawn will you be able to see it instead of allways showing it to you")
--CreateNewSettings("DEBUG_LEVEL","range-1-5",1,"debug level","this value is what level the program will try tell you about any errors that happen. we ony suggest having this enabled if you keep having proleams")
CreateNewSettings("VOLUME","range-0-100",100,"volume","this is the volume of the music")
--CreateNewSettings("SOUND_EFFECTS","boolean",true,"sound effects","this will enable or disable sound effects")







--finally start the code

local function SecandsToTime(Secands,FormatMode)
    local OutputSecands = Secands
    local OutputMinutes = 0
    local OutputHours = 0

    while OutputSecands >= 60 do
        OutputSecands = OutputSecands - 60
        OutputMinutes = OutputMinutes + 1
    end

    while OutputMinutes >= 60 do
        OutputMinutes = OutputMinutes - 60
        OutputHours = OutputHours + 1
    end

    OutPutString = ""

    if FormatMode then
        if OutputHours > 0 then
            OutPutString = OutPutString .. OutputHours .. ":"
        end

        if OutputMinutes > 0 then
            OutPutString = OutPutString .. OutputMinutes .. ":"
        end

        if OutputSecands > 0 then
            OutPutString = OutPutString .. OutputSecands
        end
    else
        if OutputHours > 0 then
            OutPutString = OutPutString..OutputHours.."h"
        end

        if OutputMinutes > 0 then
            if OutPutString ~= "" then
                OutPutString = OutPutString.." "
            end
            OutPutString = OutPutString..OutputMinutes.."m"
        end

        if OutputSecands > 0 then
            if OutPutString ~= "" then
                OutPutString = OutPutString.." "
            end
            OutPutString = OutPutString..OutputSecands.."s"
        end
    end

    return OutPutString
end


local WindowObject = nil

local function DownloadFromWeb(URL,FilePath,DontBufferBreakURL,UseBin)
    --draw text that is start looking for updates
    local Text = "idk what im doing"
    FunnyTextSite = http.get("https://gist.githubusercontent.com/meain/6440b706a97d2dd71574769517e7ed32/raw/4d5b4156027ac1605983dacaa78cf41bbd75be71/loading_messages.js")
    for i = 1, math.random(1,245) do FunnyTextSite.readLine() end
    Text = FunnyTextSite.readLine()
    FunnyTextSite.close()

    
    local LoopNumber = 0
    local TextSize = #Text

    while TextSize > MoniterX do
        if TextSize > MoniterX then
            TextSize = TextSize - MoniterX
            LoopNumber = LoopNumber + 1
        end
    end
    LoopNumber = LoopNumber + 1
    term.clear()
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)

    for i=1, LoopNumber do
        local XPOS = 1
        if LoopNumber == i then
            XPOS = math.floor(MoniterX / 2) - math.floor(TextSize / 2)
        end

        term.setCursorPos(XPOS,(MoniterY / 2) - math.floor(LoopNumber / 2) + i)
        term.write(Text:sub((i * MoniterX) - MoniterX,i * MoniterX))
    end

    if WindowObject then
        WindowObject.setVisible(true)
        WindowObject.redraw()
        WindowObject.setVisible(false)
    end

    
    --term.setCursorPos(math.floor((MoniterX / 2)) - math.floor(TextSize / 2),math.floor(MoniterY / 2) - math.floor(LoopNumber / 2))
--
    --term.write(string.sub(Text,0,MoniterX))
    --if LoopNumber > 0 then
    --    term.setCursorPos(1,math.floor(MoniterY / 2))
    --    term.write(string.sub(Text,MoniterX + 1,TextSize))
    --end

    
    
    local update = nil
    --download update
    if DontBufferBreakURL then
        update = http.get(URL,nil,UseBin)
    else
        update = http.get(URL .. "?cb=" .. os.epoch(),nil,UseBin)
    end
    if update then
        --preform updating 
        fs.delete(FilePath..".new")
        local updateFile = nil
        if UseBin then
            updateFile = fs.open(FilePath .. ".new", "wb")
        else
            updateFile = fs.open(FilePath .. ".new", "w")
        end
        updateFile.write(update.readAll())
        updateFile.close()
        update.close()
        fs.delete(FilePath)
        shell.run("rename " .. FilePath .. ".new " .. FilePath)
        fs.delete(FilePath .. ".old")
    else
        --draws screen saying failed to contact server
        term.clear()
        term.setCursorPos(math.floor((MoniterX / 2)) - 9,math.floor(MoniterY / 2))
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
        term.write("Failed to contact servers")
        sleep(2)
    end

end



if DoUpdates == true then
    fs.makeDir("UserData/Apps/CC-Music/")
    DownloadFromWeb("https://raw.githubusercontent.com/Ai-Kiwi/cc-Music/main/startup.lua","CC-Music.lua")
end



if ListOfSettings["DOUBLE_BUFFERING"]["Value"] == true then
    WindowObject = window.create(term.current(), 1, 1, MoniterX, MoniterY)
    WindowObject.setVisible(false)
    term.redirect(WindowObject)

    PromptWindowObject = window.create(term.current(), 1, 1, MoniterX, MoniterY)
    PromptWindowObject.setVisible(false)
end
local PlayListMenuSize = 10
local SongsPlaylists = {}


--shows a ui saying disk or computer
term.clear()
term.setBackgroundColor(colors.gray)
term.setTextColor(colors.white)
term.setCursorPos((math.floor(MoniterX / 2)) - 4,math.floor((MoniterY / 2) - 1))
term.write("computer")
term.setCursorPos((math.floor(MoniterX / 2)) - 2,math.floor((MoniterY / 2) + 1))
term.write("disk")

local DriveToBootOff = ""

fs.delete("songs/debug.txt")
local function debug(text)
    DebugText = fs.open("songs/debug.txt", "a")
    DebugText.writeLine(text)
    DebugText.close()
end

--scan through drive asking if to use disk
local DiskDrive = peripheral.find("drive")
if DiskDrive then
    if DiskDrive.isDiskPresent() then
        --test for what the player clicked on
        while true do
            local event, button, x, y = os.pullEvent("mouse_click")
            --look if its the computer
            if y == (math.floor((MoniterY / 2) - 1)) then
                DriveToBootOff = ""
                break
            elseif y == (math.floor((MoniterY / 2) + 1)) then
                DriveToBootOff = "disk/"
                break
            end
        end
    end
end

--bind all perphials
local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")




--look that all the needed folders exist
if fs.isDir(DriveToBootOff .. "songs/playlists/") == false then
    fs.makeDir(DriveToBootOff .. "songs/playlists/")
end

--create all varablies
local NumberOfPlayListsOnSystem = 0
local PlayerHasScrolledOnPlaylistMenu = 0
local SongSelectionScroll = 0
local NumberOfSongsInPlaylist = 0
CorrentSongPercent = 0
CorrentSongBeingPlayed = nil
SongIsPlaying = true
PlaylistPlayerHasOpen = nil
SongByteProgress = 0
SizeOfSongByteProgress = 0
local JumpBackToLastPauseSpot = false
local PauseSpotToJumpTo = 0
local SizeOfSong = 0

--text cut off function
local function TextCutOff(Text,CutOff)
    NewText = ""
    for i=1,#Text do
        if i <= CutOff then
            NewText = NewText .. Text:sub(i,i)
        else
            break
        end
    end
    return NewText
end

--this function will shuffle to a random song 
local function PlayRandomSongInPlayList()
    local ShuffledSongs = {}
    local SongsInPlaylist = fs.list(DriveToBootOff .. "songs/playlists/" .. CorrentSongBeingPlayedPlaylist)
    

    CorrentSongBeingPlayed = SongsInPlaylist[math.random(1,#SongsInPlaylist)]
    CorrentSongPercent = 0
    SongByteProgress = 0




end

local function preformPopUp(Message)
    UserInput = ""
    
    
    while true do
        local event, character = os.pullEvent()

        if event == "paste" then
            UserInput = UserInput .. character
        elseif character == keys.enter and event == "key" then
            return UserInput
        elseif character == keys.backspace and event == "key" then
            UserInput = UserInput:sub(1,#UserInput - 1)
        elseif event == "char" then
            UserInput = UserInput .. character
        end

        SizeOfTextBox = #UserInput
        
        

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

        if SizeOfTextBox < #Message then
            SizeOfTextBox = #Message
        end

        
        --draw text box for user input
        paintutils.drawFilledBox((MoniterX / 2) - ((SizeOfTextBox / 2) + 1) + 1 ,(MoniterY / 2) + 3,(MoniterX / 2) + (((SizeOfTextBox + 1) / 2)) + 1 ,(MoniterY / 2),colors.black,colors.white)
        paintutils.drawLine((MoniterX / 2) - ((SizeOfTextBox / 2) + 0) + 1 ,(MoniterY / 2) + 2,(MoniterX / 2) + (((SizeOfTextBox + 1) / 2) - 1) + 1 ,(MoniterY / 2) + 2,colors.gray)
        term.setCursorPos((MoniterX / 2) - ((SizeOfTextBox / 2) + 0) + 1 ,(MoniterY / 2) + 2)
        term.write(UserInput)
        --draw info
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
        term.setCursorPos((MoniterX / 2) - ((SizeOfTextBox / 2) + 0) + 1 ,(MoniterY / 2) + 1)
        term.write(Message)

        if WindowObject then
            term.redirect(WindowObject)
        end

    end

end

local function ClearLine(ColorPicked,Line)
    term.setCursorPos(1,Line)
    term.setBackgroundColor(ColorPicked)
    term.clearLine()
end

local function SettingsMenu()
    



    




    while true do
        --draw settings menu
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.gray)
        term.clear()

        local BindingForSettings = {}
        local Value = 0
        for k,v in pairs(ListOfSettings) do
            Value = Value + 1
            term.setCursorPos(1,Value)
            term.write(v.DisplayText .. " : " .. tostring(v.Value))
            BindingForSettings[Value] = k
    
    
        end
        term.setCursorPos(MoniterX,1)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.red)
        term.write("X")

        if WindowObject then
            WindowObject.setVisible(true)
            WindowObject.redraw()
            WindowObject.setVisible(false)
        end
        
        local EventOutput = {os.pullEvent()}
        if EventOutput[1] == "mouse_click" then
            local X,Y = EventOutput[3],EventOutput[4]
            if X == MoniterX and Y == 1 then
                term.redirect(WindowObject)
                return

            else

                ValueBeingChanged = BindingForSettings[Y]

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

local function RenderSongPlayingGUI()

    --clears the lines so that text can be drawn in a clearn area
    ClearLine(colors.black ,MoniterY)
    ClearLine(colors.black ,MoniterY - 1)

    --caulate progress bar letters
    ProgressBarLettersCanBeFilled = MoniterX - 2
    ProgressBarLettersFilled = ProgressBarLettersCanBeFilled * CorrentSongPercent

    local TextToWrite = SecandsToTime(math.floor((SizeOfSong / 6000) * (SongByteProgress / SizeOfSongByteProgress)))
    local TimeLeft = SecandsToTime(math.floor((SizeOfSong / 6000) * ((SizeOfSongByteProgress - SongByteProgress) / SizeOfSongByteProgress)))
    local SizeOfText = #TextToWrite + #TimeLeft
    for i=1,ProgressBarLettersCanBeFilled - SizeOfText do
        TextToWrite = TextToWrite.." "
    end
    TextToWrite = TextToWrite..TimeLeft
    --loops through every letter and draws a letter
    for i=1,ProgressBarLettersCanBeFilled do
        --set cursor pos (come to think of it this whole thing should be redone with term.blit)
        term.setCursorPos(i + 1,MoniterY)
        if ProgressBarLettersFilled > i then
            if SongIsPlaying then
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
    term.setCursorPos(2,MoniterY - 1)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.write(CorrentSongBeingPlayed)
    term.setTextColor(colors.gray)
    term.write(" - " .. SecandsToTime(math.floor(SizeOfSong / 6000)))
    
    --draw stop butten
    term.setCursorPos(MoniterX - 1,MoniterY - 1)
    term.setBackgroundColor(colors.red)
    term.setTextColor(colors.white)
    term.write("x")


end

local function DrawPlaylistGui()

    --draw a sidetext of the playlists
    paintutils.drawFilledBox(1,1,PlayListMenuSize,MoniterY,colors.black)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)

    --draw list of playlists
    NumberOfPlayListsOnSystem = 0
    SongsPlaylists = fs.list(DriveToBootOff .. "songs/playlists/")
    --loop though every item in the playlist
    for i=1,#SongsPlaylists do
        --draw the delete butten
        term.setCursorPos(1,2 + i + PlayerHasScrolledOnPlaylistMenu)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.red)
        term.write("x")

        --draw outline and also draws text background
        term.setTextColor(colors.white)
        if PlaylistPlayerHasOpen == SongsPlaylists[i] then
            term.setBackgroundColor(colors.gray)
        else
            term.setBackgroundColor(colors.black)
        end
        term.setCursorPos(2,2 + i + PlayerHasScrolledOnPlaylistMenu)
        term.write(TextCutOff(SongsPlaylists[i] .. "                                                                                        ",PlayListMenuSize - 1))
        NumberOfPlayListsOnSystem = NumberOfPlayListsOnSystem + 1
    end

    



    --draw add new butten
    term.setCursorPos(math.floor(PlayListMenuSize / 2),3 + NumberOfPlayListsOnSystem + PlayerHasScrolledOnPlaylistMenu)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.green)
    term.write("+")

    --draw playlist text
    term.setCursorPos(1,1)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.write(TextCutOff("Playlists",PlayListMenuSize))

    --draw verson text
    term.setCursorPos(1,MoniterY - 1)
    term.setTextColor(colors.green)
    term.setBackgroundColor(colors.black)
    term.write(TextCutOff("v" .. verson,PlayListMenuSize))

    --draw verson text
    term.setCursorPos(1,MoniterY)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.write(TextCutOff("settings",PlayListMenuSize))

end

local function DrawSongSelectionMenu()

    --print the title
    term.setCursorPos(2 + PlayListMenuSize,2 + SongSelectionScroll)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
    local AmtOfSongs = fs.list(DriveToBootOff .. "songs/playlists/" .. PlaylistPlayerHasOpen)
    term.write(PlaylistPlayerHasOpen .. " - " .. #AmtOfSongs .. " songs")
    term.setCursorPos(2 + PlayListMenuSize,3 + SongSelectionScroll)
    term.setTextColor(colors.lightGray)
    local FreeSpaceInDrive = fs.getFreeSpace(DriveToBootOff .. "songs/playlists/" .. PlaylistPlayerHasOpen) 
    term.write((math.floor(FreeSpaceInDrive / 10000) / 100) .. "mb of free space (" .. SecandsToTime(math.floor(FreeSpaceInDrive / 6000)) .. ")")

    --draw all the songs
    NumberOfSongsInPlaylist = 0
    SongsInPlaylists = fs.list(DriveToBootOff .. "songs/playlists/" .. PlaylistPlayerHasOpen)
    for i=1,#SongsInPlaylists do
        --draws the remove butten
        term.setCursorPos(1 + PlayListMenuSize,5 + i + SongSelectionScroll)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.red)
        term.write("x")

        --draws the move butten
        term.setCursorPos(2 + PlayListMenuSize,5 + i + SongSelectionScroll)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.blue)
        term.write("+")

        --draws the song name
        term.setTextColor(colors.white)
        if CorrentSongBeingPlayed == SongsInPlaylists[i] then
            term.setBackgroundColor(colors.lightGray)
        else
            term.setBackgroundColor(colors.gray)
        end
        term.setCursorPos(3 + PlayListMenuSize,5 + i + SongSelectionScroll)
        term.write(SongsInPlaylists[i] .. "                                                                                        ")
        NumberOfSongsInPlaylist = NumberOfSongsInPlaylist + 1
    end




    --draw add new butten
    term.setCursorPos(math.floor((MoniterX - PlayListMenuSize) / 2) + PlayListMenuSize,6 + NumberOfSongsInPlaylist + SongSelectionScroll)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.green)
    term.write("+")

    --ya know im looking back through my code and i have no idea why this is here
    -- --draw playlist text
    -- term.setCursorPos(1,1)
    -- term.setTextColor(colors.white)
    -- term.setBackgroundColor(colors.black)
    -- term.write(TextCutOff("Playlists",PlayListMenuSize))




end

local decoder = dfpwm.make_decoder()

local function PreformSongRender()
    if PlaylistPlayerHasOpen then
        DrawSongSelectionMenu()
    end
    DrawPlaylistGui()
    if CorrentSongBeingPlayed then
        RenderSongPlayingGUI()
    end



end




local buffer = ""

local function PlaySong()
    --debug("playing song")
    while true do
        --debug("looking if there is song to play")
        if CorrentSongBeingPlayed then
            local dfpwm = require("cc.audio.dfpwm")
            local speaker = peripheral.find("speaker")

            local decoder = dfpwm.make_decoder()
            SongHasFinished = false

            SizeOfSongByteProgress = 0
            for chunk in io.lines("songs/playlists/" .. CorrentSongBeingPlayedPlaylist .. "/" .. CorrentSongBeingPlayed, ListOfSettings["SONG_BUFFER_SIZE"]["Value"] * 1024) do
                SizeOfSongByteProgress = SizeOfSongByteProgress + 1
                --debug(SizeOfSongByteProgress)
            end
            
            SongByteProgress = 0
            local SongStartedWith = CorrentSongBeingPlayed
            SizeOfSong = fs.getSize("songs/playlists/" .. CorrentSongBeingPlayedPlaylist .. "/" .. CorrentSongBeingPlayed)
            

            --look ive been coding for to long and honestly i dont really wanna write how this works
            --maybe one day i will along with the rest of this code
            for chunk in io.lines("songs/playlists/" .. CorrentSongBeingPlayedPlaylist .. "/" .. CorrentSongBeingPlayed, ListOfSettings["SONG_BUFFER_SIZE"]["Value"] * 1024) do
                if JumpBackToLastPauseSpot == false or PauseSpotToJumpTo == SongByteProgress then
                    JumpBackToLastPauseSpot = false
                    if CorrentSongBeingPlayed then
                        buffer = decoder(chunk)

                        
                        
                        while not speaker.playAudio(buffer,ListOfSettings["VOLUME"]["Value"] / 100 ) do
                            os.sleep(0.1)
                        end
                        if CorrentSongBeingPlayed ~= SongStartedWith then
                            speaker.stop()
                        end
                        if SongIsPlaying == false then
                            speaker.stop()
                            while SongIsPlaying == false do
                                os.sleep(0.1)
                            end
                            JumpBackToLastPauseSpot = true
                            PauseSpotToJumpTo = SongByteProgress - 2
                            break
                        end

                    else
                        --debug("song is not playing")
                        --os.reboot()
                        speaker.stop()
                        break
                    end
                end

                if CorrentSongBeingPlayed == nil then
                    break
                end
                --debug("chunk played")
                SongByteProgress = SongByteProgress + 1
                if SongByteProgress == SizeOfSongByteProgress then
                    SongHasFinished = true
                end
            end
            if JumpBackToLastPauseSpot == false then
                --clears out song because it is done
                CorrentSongBeingPlayed = nil
                CorrentSongPercent = 0
                SongByteProgress = 0
                if SongHasFinished == true then
                    if ListOfSettings["SHUFFLE_VIDEO"]["Value"] == true then
                        PlayRandomSongInPlayList()
                    end
                    SongHasFinished = false
                end
            end
        else
            os.sleep(0)

        end
    end
end

local function EventHandler()
    local EventName, EventParam1, EventParam2, EventParam3 = os.pullEvent()
    -- event, button, x, y
    --looks if it is the player clicking
    if EventName == "mouse_click" then
        local MouseClickButten = EventParam1
        local MouseClickX = EventParam2
        local MouseClickY = EventParam3

        --looks if they are clicking on the corrent song playing
        if MouseClickY > (MoniterY - 2) and CorrentSongBeingPlayed then
            --they are clicking on progress bar
            if MouseClickY == MoniterY then
                SongIsPlaying = not SongIsPlaying
                if SongIsPlaying == false then
                    speaker.stop()
                    
                end
            end
            --player is clicking on the close butten
            if MouseClickY == (MoniterY - 1) and MouseClickX == (MoniterX - 1)  then
                CorrentSongBeingPlayed = nil
                speaker.stop()
            end

        --looks if they are clicking on the the playlist menu
        elseif MouseClickX < (PlayListMenuSize + 1) then
            if MouseClickY == MoniterY then
                --player has clicked the settings menu
                SettingsMenu()

            else
                --looks if they are clicking on the new playlist butten
                if MouseClickY == (3 + NumberOfPlayListsOnSystem - PlayerHasScrolledOnPlaylistMenu) then
                    local Temp = preformPopUp("Enter the name of the playlist")
                    fs.makeDir(DriveToBootOff .. "songs/playlists/" .. Temp)
                    PlaylistPlayerHasOpen = Temp
                end
                --make sure there clicking on a playlist
                if MouseClickY > 2 and MouseClickY < (NumberOfPlayListsOnSystem +(3 - PlayerHasScrolledOnPlaylistMenu)) then
                    --look if they are clicking to delete a playlist
                    if MouseClickX == 1 then
                        if preformPopUp("type yes to confirm you would like to delete this") == "yes" then
                            fs.delete(DriveToBootOff .. "songs/playlists/" .. SongsPlaylists[MouseClickY - 2 - PlayerHasScrolledOnPlaylistMenu])
                            PlaylistPlayerHasOpen = nil
                        end
                    else
                        PlaylistPlayerHasOpen = SongsPlaylists[MouseClickY - 2 - PlayerHasScrolledOnPlaylistMenu]
                        SongSelectionScroll = 0
                    end

                end
            end


            --looks if they are clicking on the song player menu
        else
            --looks if they are clicking on a song
            if MouseClickY > 4 + SongSelectionScroll and MouseClickY < NumberOfSongsInPlaylist + 6 + SongSelectionScroll then
                --look if they are clicking on the remove butten
                if MouseClickX == (1 + PlayListMenuSize) then
                    if preformPopUp("type yes to confirm you would like to delete this") == "yes" then
                        fs.delete(DriveToBootOff .. "songs/playlists/" .. PlaylistPlayerHasOpen .. "/" .. SongsInPlaylists[MouseClickY - 5 - SongSelectionScroll])
                        SongsInPlaylists = fs.list(DriveToBootOff .. "songs/playlists/" .. PlaylistPlayerHasOpen)
                        NumberOfSongsInPlaylist = NumberOfSongsInPlaylist - 1
                    end
                else
                    CorrentSongBeingPlayed = SongsInPlaylists[MouseClickY - 5 - SongSelectionScroll]
                    CorrentSongBeingPlayedPlaylist = PlaylistPlayerHasOpen
                    SongIsPlaying = true
                    CorrentSongPercent = 0
                    SongByteProgress = 0
                end
                --look if they are clicking on the addnew butten
            elseif MouseClickY == (6 + NumberOfSongsInPlaylist + SongSelectionScroll) then
                local URL = preformPopUp("Enter the URL of the song")
                local NewSongName = preformPopUp("Enter the name of the song")

                --download song
                local SongFileName = DriveToBootOff .. "songs/playlists/" .. PlaylistPlayerHasOpen .. "/" .. NewSongName
                --if SongFile then
                --    local SongFileHandle = fs.open(SongFileName, "wb")
                --    SongFileHandle.write(SongFile.readAll())
                --    SongFileHandle.close()
                --    SongFile.close()
                --end
                DownloadFromWeb(URL,SongFileName,true,true)
            end
        end
    elseif EventName == "mouse_scroll" then
        if EventParam2 < (PlayListMenuSize + 1) then
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
    CorrentSongPercent = SongByteProgress / SizeOfSongByteProgress

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
    EventHandler()
end
end




parallel.waitForAny(MainSystem, PlaySong)
