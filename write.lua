local lfs = require("lfs")

local write = {}

---@param str string The string to split
---@return string[] #the result
function write.splitLines(str)
    local result = {}
    local start = 1

    while true do
        local pos = string.find(str, "\n", start, true)
        if not pos then
            table.insert(result, string.sub(str, start))
            break
        end

        table.insert(result, string.sub(str, start, pos - 1))
        start = pos + 1
    end

    return result
end

---@param str string The string to format
---@return string #the formatted string
function write.formatMarkdown(str)
    str = string.gsub(str, "\'\'\'" , "**")
    return str
end

---@param fileHandle file*
---@param description string
---@param printFirstComment boolean
function write.multiLineDesc(fileHandle, description, printFirstComment)
    local first = true
    local multiLineDesc = write.splitLines(description)
    for _, desc in ipairs(multiLineDesc) do
        fileHandle:write(string.format("%s%s\n", (not printFirstComment and first) and " " or "---" ,write.formatMarkdown(desc)))
        first = false
    end
end

---@param fileHandle file* The file handler
---@param enum table The enum table
function write.writeEnum(fileHandle, enum)
    fileHandle:write("\n")

    fileHandle:write(string.format("---@enum %s\n", enum.name))
    write.multiLineDesc(fileHandle, enum.description, true)
    fileHandle:write(string.format("local %s = {\n", enum.name))
    for _, enumMember in ipairs(enum.constants) do
        fileHandle:write(string.format("  %s = '%s', ---%s\n", enumMember.name, enumMember.name, write.formatMarkdown(enumMember.description)))
    end
    fileHandle:write("}\n")
end

---@param fileHandle file* The file handler
---@param func table The function
---@param parent string The parent
---@param isOOP boolean Is part of an object
---@param noLove boolean Should not prepend "love."
function write.writeFunction(fileHandle, func, parent, isOOP, noLove)
    local isVariantDescBroken = false
    if func.variants[1].description then
        if #func.variants < 2 then
            isVariantDescBroken = true
        elseif not func.variants[2].description then
            isVariantDescBroken = true
        end
    end

    for _, variant in ipairs(func.variants) do
        fileHandle:write("\n")
        local args = {}
        -- Comments for lua_ls
        if variant.arguments then
            for _, arg in ipairs(variant.arguments) do
                table.insert(args, arg.name)
                fileHandle:write(string.format("---@param %s %s", arg.name, arg.type))
                write.multiLineDesc(fileHandle, arg.description, false)
            end
        end
        if variant.returns then
            for _, ret in ipairs(variant.returns) do
                fileHandle:write(string.format("---@return %s %s", ret.type, ret.name))
                write.multiLineDesc(fileHandle, ret.description, false)
            end
        end

        local descToUse = (isVariantDescBroken or not variant.description) and func.description or variant.description
        write.multiLineDesc(fileHandle, descToUse, true)

        -- The ACTUAL funcion definition
        local parentName = (isOOP or noLove) and parent or "love." .. parent
        fileHandle:write(string.format("function %s%s%s(%s)\n", parentName, isOOP and ":" or ".", func.name, table.concat(args, ", ")))
        fileHandle:write("end\n")
    end
end

---@param fileHandle file* The file handler
---@param name string Name of module
---@param description string? Description of module
---@param noLove boolean Should not prepend "love."
function write.writeModuleHeader(fileHandle, name, description, noLove)
    name = noLove and name or "love." .. name
    fileHandle:write(string.format("---@class %s\n", name))
    if description then
        write.multiLineDesc(fileHandle, description, true)
    end
    fileHandle:write(string.format("%s = {}\n", name))
end

---@param fileHandle file* File handler
---@param stype table The type table
function write.writeType(fileHandle, stype)
    fileHandle:write("\n")
    fileHandle:write(string.format("---@class %s", stype.name))
    if stype.supertypes then
        fileHandle:write(": " .. table.concat(stype.supertypes, ", "))
    end
    fileHandle:write("\n")

    write.multiLineDesc(fileHandle, stype.description, true)
    fileHandle:write(string.format("%s = {}\n", stype.name))

    if stype.functions then
        for _, func in ipairs(stype.functions) do
            write.writeFunction(fileHandle, func, stype.name, true, false)
        end
    end
end

---@param name string Name of file
---@param mode "r"|"w"|"a"|"r+"|"w+"|"a+"|"rb"|"wb"|"ab"|"r+b"|"w+b"|"a+b" Mode to open the file
---@return file*
function write.safeCreateFile(name, mode)
    local handle = io.open(name, mode)
    if not handle then
        print("[ERROR] Could not create file " .. name)
        os.exit(1)
    end
    return handle
end

---@param name string Name of directory
---@param gotoit boolean Whether to go to the created directory
function write.safeCreateDirectory(name, gotoit)
    local success, errorMsg, errorCode = lfs.mkdir(name)
    if not success then
        print(string.format("[ERROR] Could not create directory %s: %s | %s", name, errorMsg, errorCode))
        os.exit(1)
    end
    if gotoit then
        lfs.chdir(name)
    end
end

return write
