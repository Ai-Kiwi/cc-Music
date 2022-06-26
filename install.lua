print("where would you like it to be installed? (nothing for auto start)")
local Path = read("")

if Path == "" then
  Path = "startup.lua"
end

shell.run("wget https://raw.githubusercontent.com/Ai-Kiwi/cc-Music/main/core.lua " .. Path)
shell.run(Path)
