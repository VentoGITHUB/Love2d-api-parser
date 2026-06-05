local lfs = require("lfs")

if #arg < 2 then
    print("[ERROR] Missing arguments!: lua main.lua [input-folder] [output-folder]")
    os.exit(2)
elseif lfs.attributes(arg[1], "mode") ~= "directory" then
    print(string.format("[ERROR] %s must be a directory!", arg[1]))
    os.exit(2)
end

local wholeApi = require(string.format("%s.love_api", arg[1]))
local write = require("write")

-- Love
if lfs.attributes(arg[2], "mode") == "directory" then
    print(string.format("[ERROR] %s already exists! Remove it manually", arg[2]))
    os.exit(2)
end

lfs.mkdir(arg[2])
lfs.chdir(arg[2])

local loveHandle = write.safeCreateFile("love.lua", "w+")
write.writeModuleHeader(loveHandle, "love", nil, true)

for _, func in ipairs(wholeApi.functions) do
    write.writeFunction(loveHandle, func, "love", false, true)
end
for _, callback in ipairs(wholeApi.callbacks) do
    write.writeFunction(loveHandle, callback, "love", false, true)
end
loveHandle:close()

-- Supertypes
for _, supertype in ipairs(wholeApi.types) do
    local supertypeHandle = write.safeCreateFile(supertype.name .. ".lua", "w+")
    write.writeType(supertypeHandle, supertype)
    supertypeHandle:close()
end

-- Modules
for _, module in ipairs(wholeApi.modules) do
    write.safeCreateDirectory(module.name, true)
    local moduleHandle = write.safeCreateFile(module.name .. ".lua", "w+")
    write.writeModuleHeader(moduleHandle, "" .. module.name, module.description, false)
    for _, func in ipairs(module.functions) do
        write.writeFunction(moduleHandle, func, module.name, false, false)
    end
    moduleHandle:close()

    -- Types
    write.safeCreateDirectory("types", true)
    for _, moduleType in ipairs(module.types) do
        local typeHandle = write.safeCreateFile(moduleType.name .. ".lua", "w+")
        write.writeType(typeHandle, moduleType)
        typeHandle:close()
    end
    lfs.chdir("..")

    -- Enums
    write.safeCreateDirectory("enums", true)
    for _, moduleEnum in ipairs(module.enums) do
        local enumHandle = write.safeCreateFile(moduleEnum.name .. ".lua", "w+")
        write.writeEnum(enumHandle, moduleEnum)
        enumHandle:close()
    end
    lfs.chdir("..")
    lfs.chdir("..")

    print("[INFO] Created module " .. module.name)
end

-- Success !!!
print("[END] Everything went well!")
print("[END] The api definitions are in " .. arg[2])
