# Love2d-api-parser
## A Lua script to parse the [love2d-community/love-api](https://github.com/love2d-community/love-api) repo! 

This scripts convert the love-api table into a folder with all the definitions, ready to be fed to the [lua language server](https://github.com/luals/lua-language-server)!

### Requierments
- Lua 5.1 or higher
- the [LuaFileSystem](https://lunarmodules.github.io/luafilesystem/) library

### How to use it
1. Clone this repo (obviously)
2. Clone the [love2d-community/love-api](https://github.com/love2d-community/love-api) repo and put it as a folder in this cloned repo
The folder structure should look something like this:
```
Love2d-api-parser/
┣━━┳ run.lua
┃  ┣ write.lua
┃  ┗ ...
┗ love-api/
    ┣ modules/
    ┣ wiki_scraper/
    ┣ love_api.lua
    ┗ ...
```
> [!NOTE]
> Adapt the names `Love2d-api-parser` and `love-api` to how the cloned repos are named
> Also, don't rename the files and directories inside `love-api`

3. Inside *Love2d-api-parser* run this:
`lua run.lua [input-folder] [output-folder]`, Where:
- `[input-folder]` is the [love2d-community/love-api](https://github.com/love2d-community/love-api) repo
- `[output-folder]` is the folder where the definitions will go
4. DONE !!!

The definition is complete, you can now add the folder as a third-party library to [lua language server](https://github.com/luals/lua-language-server)
#### How to add the definitions ???
You can read more about it [here](https://github.com/LuaLS/lua-language-server/wiki/Libraries)

## Why create this tool, if there are already definitions available?
Because yes, and also I wanted to finally make and finish a project

If there are any issues, fell free to create a new issue!

### Farewell!
