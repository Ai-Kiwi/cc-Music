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
