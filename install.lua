print("If you have a preferred location for the installation, please enter it below. Otherwise, the program will be installed in your root directory for automatic startup.")
local Path = read()
if Path == "" then Path = "startup.lua" end

shell.run("wget https://raw.githubusercontent.com/Ai-Kiwi/cc-Music/main/core.lua " .. Path)
shell.run("wget https://pastebin.com/raw/3LfWxRWh bigfont")
shell.run(Path)