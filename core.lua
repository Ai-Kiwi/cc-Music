local bigFont = require("bigfont")
local programRunning = true
local songPlaying = nil
--stuff for song backend
local speaker = peripheral.find("speaker")
if speaker == nil then error("failed to find speaker") end
local bufferSize = 1024 * 16
local dfpwm = require("cc.audio.dfpwm")
local decoder = dfpwm.make_decoder()
--items for Ui
local sizeX, sizeY = term.getSize()
local pageOpen = {}
pageOpen.scrollY = 0
pageOpen.menu = ""
pageOpen.subMenu = ""
--items for interactions
local event, output1, output2, output3, output4, output5 = nil, nil, nil, nil, nil, nil
--open up data
local songsInstalled = nil
local songsDataFile = fs.open("/CCMusic/songData","r")
local songs = textutils.unserialise(songsDataFile.readAll())
local songOrdor = {}
for k,v in pairs(songs) do
    table.insert(songOrdor, k)
end
songsDataFile.close()
local playlistDataFile = fs.open("/CCMusic/playlists","r")
local playlists = textutils.unserialise(playlistDataFile.readAll())
local playlistOrdor = {}
for k,v in pairs(playlists) do
    table.insert(playlistOrdor, k)
end
playlistDataFile.close()



local function loadSong(id)
    if songs[id] == nil then songPlaying = nil return nil end
    speaker.stop()
    songPlaying = {}
    songPlaying.name = songs[id].name
    songPlaying.id = id
    songPlaying.path = songs[id].path
    songPlaying.distanceIntoSong = 0
    songPlaying.dataForSong = nil
    songPlaying.length = fs.getSize(songPlaying.path .. id .. ".dfpwm")

    local songData = fs.open(songPlaying.path .. songPlaying.id .. ".dfpwm", "rb")
    songPlaying.dataForSong = songData.readAll()
    songData.close()

    songPlaying.length = string.len(songPlaying.dataForSong)
end

local function drawItem(LinesOfText,textColors,posY)
    term.setBackgroundColor(textColors[2])
    term.setTextColor(textColors[1])

    --draws the bottom bar
    term.setCursorPos(1,posY+1+#LinesOfText)
    term.write("\130" .. string.rep("\131",sizeX - 2) .. "\129")

    --draws right bar
    for i=1, #LinesOfText do
        term.setCursorPos(sizeX,posY+i)
        term.write("\149")
    end

    --draws top right corner
    term.setCursorPos(sizeX,posY)
    term.write("\144")
    
    --swaps colors around
    term.setBackgroundColor(textColors[1])
    term.setTextColor(textColors[2])

    --drows left bar 
    for i=1, #LinesOfText do
        term.setCursorPos(1,posY+i)
        term.write("\149")
    end


    --draw top bar
    term.setCursorPos(1,posY)
    term.write("\159" .. string.rep("\143",sizeX - 2))

    for rowOfText=1, #LinesOfText do
        term.setTextColor(textColors[2+rowOfText])
        for charOfText=1, sizeX - 2 do
            term.setCursorPos(charOfText+1,posY+rowOfText)
            local char = string.sub(LinesOfText[rowOfText], charOfText, charOfText)
            if char == "" then
                term.write(" ")
            else
                term.write(char)
            end
        end
    end
end

local function drawUi()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)

    local function drawHomepageUi()
        term.clear()
        bigFont.writeOn(term.native(),1,"CC-Music",2,2)
        --drawItem({"Playlists"},{colors.green,colors.black,colors.black},5)
        drawItem({"Songs"},{colors.green,colors.black,colors.black},5)
        drawItem({"Quit"},{colors.green,colors.black,colors.black},8)
        term.setTextColor(colors.orange)
        term.setBackgroundColor(colors.black)
        term.setCursorPos(1,sizeY)
        term.write("pre-release")
    end
    local function drawSongsUi()
        term.clear()
        bigFont.writeOn(term.native(),1,"Songs",2,2 + pageOpen.scrollY)
        for k,v in pairs(songOrdor) do
            drawItem({songs[v].name},{colors.green,colors.black,colors.black},(k * 3)+2+pageOpen.scrollY)
        end
    end
    local function drawPlaylistsUi()
        term.clear()
        bigFont.writeOn(term.native(),1,"Playlists",2,2 + pageOpen.scrollY)
        for k,v in pairs(playlistOrdor) do
            drawItem({playlists[v].name,#playlists[v].songs .. " songs"},{colors.green,colors.black,colors.black,colors.gray},(k * 4)+1+pageOpen.scrollY)
        end
    end
    local function drawPlaylistOpenUi()
        term.clear()
        bigFont.writeOn(term.native(),1,playlists[pageOpen.subMenu].name,2,2 + pageOpen.scrollY)
        for k,v in pairs(playlists[pageOpen.subMenu].songs) do
            drawItem({songs[v].name},{colors.green,colors.black,colors.black},(k * 3)+2+pageOpen.scrollY)
        end
    end


    if pageOpen.menu == "homepage" then
        drawHomepageUi()
    elseif pageOpen.menu == "songs" then
        drawSongsUi()
    elseif pageOpen.menu == "playlistOpen" then
        drawPlaylistOpenUi()
    elseif pageOpen.menu == "playlists" then
        drawPlaylistsUi()
    else
        pageOpen.menu = "homepage"
        drawHomepageUi()
    end
end

local function handleInteraction()
    local function handleHomepageUi()
        if event == "mouse_click" then
            ----playlists
            --if output3 > 4 and output3 < 8 then
            --    pageOpen.menu = "playlists"
            --end
            --Songs
            if output3 > 4 and output3 < 8 then
                term.clear()
                pageOpen.menu = "songs"
            end
            --Quit
            if output3 > 7 and output3 < 11 then
                term.clear()
                programRunning = false
            end
            
        end
    end
    local function handleSongsUi()
        if event == "mouse_click" then
            local itemClickingOn = math.floor((output3-1-pageOpen.scrollY)/3)
            if not (songOrdor[itemClickingOn] == nil) then
                loadSong(songOrdor[itemClickingOn])
            end
        end
    end
    local function handlePlaylistsUi()
        if event == "mouse_click" then
            local itemClickingOn = math.floor((output3-1-pageOpen.scrollY)/4)
            if not (playlistOrdor[itemClickingOn] == nil) then
                pageOpen.menu = "playlistOpen"
                pageOpen.subMenu = playlistOrdor[itemClickingOn]
                
            end
        end
    end
    local function handlePlaylistOpenUi()
        if event == "mouse_click" then
            local itemClickingOn = math.floor((output3-1-pageOpen.scrollY)/3)
            if not (playlists[pageOpen.subMenu].songs[itemClickingOn] == nil) then
                loadSong(playlists[pageOpen.subMenu].songs[itemClickingOn])
            end
        end
    end
    

    
    if event == "mouse_scroll" then
        pageOpen.scrollY = pageOpen.scrollY - output1
        if pageOpen.scrollY > 0 then pageOpen.scrollY = 0 end
    end
    if pageOpen.menu == "homepage" then
        pageOpen.scrollY = 0
        handleHomepageUi()
    elseif pageOpen.menu == "songs" then
        handleSongsUi()
    elseif pageOpen.menu == "playlists" then
        handlePlaylistsUi()
    elseif pageOpen.menu == "playlistOpen" then
        handlePlaylistOpenUi()
    end
end

local function backGroundPlayMusic()
    if songPlaying ~= nil then
        local chunkOfSong = string.sub(songPlaying.dataForSong,songPlaying.distanceIntoSong,songPlaying.distanceIntoSong + 1024)
        local buffer = decoder(chunkOfSong)

        if speaker.playAudio(buffer) then
            songPlaying.distanceIntoSong = songPlaying.distanceIntoSong + 1024
        end
    
        if songPlaying.distanceIntoSong > songPlaying.length then
            songPlaying = nil
        end
    end
end


while programRunning == true do
    event, output1, output2, output3, output4, output5 = os.pullEvent()
    handleInteraction()
    drawUi()
    backGroundPlayMusic()
end

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.setCursorPos(1,1)
term.clear()