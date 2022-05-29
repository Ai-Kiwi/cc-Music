# cc-Music
A straightforward music player interface for cc-tweaked!
![2022-05-30_17 28 09](https://user-images.githubusercontent.com/66819523/170923007-f0e3534d-198f-4152-83d5-84f92c90d78c.gif)


# install
  
```
wget run https://raw.githubusercontent.com/Ai-Kiwi/cc-Music/main/install.lua
```  
# how to use  
  
**how to download a song.**  
1: obtain a song from YouTube or another source.  
2: Use music.madefor.cc to transfer to the correct format.  
3: Post to a website such as 10 minute hosting.  
4: In the app, add a song based on that url.  
      
# maybe coming soon
 - better gui (especially for settings)
 - support for moniters (mode for playlist and mode for just video playing)
 - queue
 - suport for alot of speakers
 - polish then upload my custem youtube video downloader to github :P
 - polish support for phones
 - update disk to have better text and also look a crap ton nicer
 - smoother video progress bar
 - add full buffer on term input
 - maybe fast forwarding?
 - skip song
 - stop everything running off the stupid system of buffers and move over to time (maybe not all of it as if pc lag it could cause proleams)
 - have volume slider on video player
 - p2p or server song sharing
 - add sound effects
 - stream videos from the cloud
 - make system check web for updates instead of always updating
 - fix exit settings crash
 - make there be a settings for playlists settings size
 - auto start playing playlist on server restart
 - drag n drop support
 - fix song player breaking apon switching song
 - search
 - auto start playing songs on program boot
 - auto updating smartly updating the right file
 - fix up support for custem install locastions
 - improve progress bar and other things by using custem chactors
 - find out why popup glitchs on craftos-pc
 - dev branch
 - make so same song in 2 playlists doesnt take up doubble space
 - support for song store
 - download bulk
 - add padding for text
 - add doubble buffering to input popup
 - fix crash when closing song
 - fix possible bug with muaplue speakers
 - fix pauseing song skips backwards
 - make it so that you can just pick another song and start playing while one is playing and it doesnt bug out
 - fix EventHandler() auto finding speaker
 - clean up crash when you have no speaker

# contributing
If you would like to make any changes, please feel free to help out! However, make sure to only upload to the development branch.
If you would like to help out, I'd suggest you make the following files locally inside of your github project. (.gitignore file will stop them from syncing) They will help you out hugely with development! (make sure you have craftos-pc installed and then just double click start.bat file you made to test)

startup.lua
```
shell.run("attach top speaker top")
shell.run("core dev")
```

start.bat (make sure to make path your own)
```
powershell -Command "craftos-pc --start-dir '<full drive path to local github download>'"
:: eg : powershell -Command "craftos-pc --start-dir 'C:\Users\Ai Kiwi\Documents\coding projects\cc tweaked programs\cc-Music'"
```
