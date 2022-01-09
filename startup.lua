MoniterX, MoniterY = term.getSize()

--todo
-- suppport for ququeing songs
-- support for suffling
-- support for volume
-- repeat songs

--start looking for updates
term.clear()
term.setCursorPos(math.floor((MoniterX / 2)) - 9,math.floor(MoniterY / 2))
term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)
term.write("looking for update")

os.sleep(1)


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

local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")




--look that all the needed folders exist
if fs.isDir(DriveToBootOff .. "songs/playlists/") == false then
    fs.makeDir(DriveToBootOff .. "songs/playlists/")
end

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

local function TextCutOff(Text,CutOff)
    NewText = ""
    for i=1,#Text do
        if i <= CutOff then
            NewText = NewText .. Text:sub(i,i)
        end
    end
    return NewText
end

local function PlayRandomSongInPlayList()
    ----find a random song in the playlist
    --local RandomSong = math.random(1,#SongsPlaylists[PlaylistPlayerHasOpen])
    --local SongToPlay = SongsPlaylists[PlaylistPlayerHasOpen][RandomSong]
--
    --CorrentSongBeingPlayed = SongToPlay
    --CorrentSongPercent = 0
    --SongByteProgress = 0
    --SizeOfSongByteProgress = 0




end


local function ClearLine(ColorPicked,Line)
    term.setCursorPos(1,Line)
    term.setBackgroundColor(ColorPicked)
    term.clearLine()
end



local function RenderSongPlayingGUI()


    ClearLine(colors.black ,MoniterY)
    ClearLine(colors.black ,MoniterY - 1)

    --draw progress bar
    ProgressBarLettersCanBeFilled = MoniterX - 2
    ProgressBarLettersFilled = ProgressBarLettersCanBeFilled * CorrentSongPercent

    for i=1,ProgressBarLettersCanBeFilled do
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
        term.write(" ")
    end

    --draw song name
    term.setCursorPos(2,MoniterY - 1)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.write(CorrentSongBeingPlayed)

    --draw stop butten
    term.setCursorPos(MoniterX - 1,MoniterY - 1)
    term.setBackgroundColor(colors.red)
    term.setTextColor(colors.white)
    term.write("x")


end

local function DrawPlaylistGui()


    paintutils.drawFilledBox(1,1,PlayListMenuSize,MoniterY,colors.black)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)

    --draw list of playlists
    NumberOfPlayListsOnSystem = 0
    SongsPlaylists = fs.list(DriveToBootOff .. "songs/playlists/")
    for i=1,#SongsPlaylists do
        term.setCursorPos(1,2 + i + PlayerHasScrolledOnPlaylistMenu)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.red)
        term.write("x")

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

    
    term.setCursorPos(1,1)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.write(TextCutOff("Playlists",PlayListMenuSize))


    --draw add new butten
    term.setCursorPos(math.floor(PlayListMenuSize / 2),3 + NumberOfPlayListsOnSystem + PlayerHasScrolledOnPlaylistMenu)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.green)
    term.write("+")

    



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
    term.write((math.floor(fs.getFreeSpace(DriveToBootOff .. "songs/playlists/" .. PlaylistPlayerHasOpen) / 10000) / 100) .. "mb of free space")

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

    --draw playlist text
    term.setCursorPos(1,1)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.write(TextCutOff("Playlists",PlayListMenuSize))


    --draw add new butten
    term.setCursorPos(math.floor((MoniterX - PlayListMenuSize) / 2) + PlayListMenuSize,6 + NumberOfSongsInPlaylist + SongSelectionScroll)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.green)
    term.write("+")

    




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
        PreformSongRender()
        if SizeOfTextBox < #Message then
            SizeOfTextBox = #Message
        end

        
        --draw text box for user input
        paintutils.drawFilledBox((MoniterX / 2) - ((SizeOfTextBox / 2) + 1),(MoniterY / 2) + 3,(MoniterX / 2) + (((SizeOfTextBox + 1) / 2)),(MoniterY / 2),colors.black,colors.white)
        paintutils.drawLine((MoniterX / 2) - ((SizeOfTextBox / 2) + 0),(MoniterY / 2) + 2,(MoniterX / 2) + (((SizeOfTextBox + 1) / 2) - 1),(MoniterY / 2) + 2,colors.gray)
        term.setCursorPos((MoniterX / 2) - ((SizeOfTextBox / 2) + 0),(MoniterY / 2) + 2)
        term.write(UserInput)
        --draw info
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
        term.setCursorPos((MoniterX / 2) - ((SizeOfTextBox / 2) + 0),(MoniterY / 2) + 1)
        term.write(Message)
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

            SizeOfSongByteProgress = 0
            for chunk in io.lines("songs/playlists/" .. PlaylistPlayerHasOpen .. "/" .. CorrentSongBeingPlayed, 16 * 1024) do
                SizeOfSongByteProgress = SizeOfSongByteProgress + 1
                --debug(SizeOfSongByteProgress)
            end

            SongByteProgress = 0
            for chunk in io.lines("songs/playlists/" .. PlaylistPlayerHasOpen .. "/" .. CorrentSongBeingPlayed, 16 * 1024) do
                --debug("playing chunk")
                if CorrentSongBeingPlayed then
                    buffer = decoder(chunk)
                    --debug("playing buffer")
                    while not speaker.playAudio(buffer) do
                        while true do
                            --debug("waiting for speaker to be ready")
                            if os.pullEvent("speaker_audio_empty") == "speaker_audio_empty" then
                                --debug("speaker is ready")
                                break
                            end
                            os.sleep(0.1)
                        end
                    end
                else
                    --debug("song is not playing")
                    speaker.stop()
                    break
                end
                --debug("chunk played")
                SongByteProgress = SongByteProgress + 1
            end
                --debug("song played")
                CorrentSongBeingPlayed = nil
                CorrentSongPercent = 0
                SongByteProgress = 0
                PlayRandomSongInPlayList()
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
            end
            --player is clicking on the close butten
            if MouseClickY == (MoniterY - 1) and MouseClickX == (MoniterX - 1)  then
                CorrentSongBeingPlayed = nil
            end

        --looks if they are clicking on the the playlist menu
        elseif MouseClickX < (PlayListMenuSize + 1) then
            
            --looks if they are clicking on the new playlist butten
            if MouseClickY == (3 + NumberOfPlayListsOnSystem + PlayerHasScrolledOnPlaylistMenu) then
                local Temp = preformPopUp("Enter the name of the playlist")
                fs.makeDir(DriveToBootOff .. "songs/playlists/" .. Temp)
                PlaylistPlayerHasOpen = Temp
            end
            --make sure there clicking on a playlist
            if MouseClickY > 2 and MouseClickY < (NumberOfPlayListsOnSystem +(3 + PlayerHasScrolledOnPlaylistMenu)) then
                --look if they are clicking to delete a playlist
                if MouseClickX == 1 then
                    fs.delete(DriveToBootOff .. "songs/playlists/" .. SongsPlaylists[MouseClickY - 2 + PlayerHasScrolledOnPlaylistMenu])
                    PlaylistPlayerHasOpen = nil
                else
                    PlaylistPlayerHasOpen = SongsPlaylists[MouseClickY - 2 + PlayerHasScrolledOnPlaylistMenu]
                end

            end


            --looks if they are clicking on the song player menu
        else
            --looks if they are clicking on a song
            if MouseClickY > 4 and MouseClickY < NumberOfSongsInPlaylist + 6 + SongSelectionScroll then
                --look if they are clicking on the remove butten
                if MouseClickX == (1 + PlayListMenuSize) then
                    fs.delete(DriveToBootOff .. "songs/playlists/" .. PlaylistPlayerHasOpen .. "/" .. SongsInPlaylists[MouseClickY - 5 + SongSelectionScroll])
                    SongsInPlaylists = fs.list(DriveToBootOff .. "songs/playlists/" .. PlaylistPlayerHasOpen)
                    NumberOfSongsInPlaylist = NumberOfSongsInPlaylist - 1
                else
                    CorrentSongBeingPlayed = SongsInPlaylists[MouseClickY - 5 + SongSelectionScroll]
                    CorrentSongPercent = 0
                    SongByteProgress = 0
                end
                --look if they are clicking on the addnew butten
            elseif MouseClickY == (6 + NumberOfSongsInPlaylist + SongSelectionScroll) then
                local URL = preformPopUp("Enter the URL of the song")
                local NewSongName = preformPopUp("Enter the name of the song")

                --download song
                local SongFile = http.get(URL,nil,true)
                local SongFileName = DriveToBootOff .. "songs/playlists/" .. PlaylistPlayerHasOpen .. "/" .. NewSongName
                if SongFile then
                    local SongFileHandle = fs.open(SongFileName, "wb")
                    SongFileHandle.write(SongFile.readAll())
                    SongFileHandle.close()
                    SongFile.close()
                end
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
    EventHandler()
end
end




parallel.waitForAll(MainSystem, PlaySong)
