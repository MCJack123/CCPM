--Enabled for verbose mode
local _DEBUG = true
--local function inArray(array, str) for _,v in pairs(array) do if v == str then return true end end return false end
local function debugPrint(text) if _DEBUG then print(text) end end 
local function isTable(t) return type(t) == "table" end
local function select (n, ...) return arg[n] end
local function getFolder(table, ...) return getFolder(table[select(1, expand(arg))], expand(table.remove(table, 1))) end

--Uncomment to allow -v argument
--if inArray(arg, "-v") then _DEBUG = true end



--[[---------------------CCP Format--------------------------
The CCP format is made up of these different identifiers.
(CCP file) {
* name = The name of the CCP file/package.
* type = The type of package. Can be as follows in the table:
  N|Identifier |Type
  0|application|An application run by the user.
  1|intprogram |A small console program (like the GNUtils)
  2|api        |An API for any program.
  3|apiboot    |An API that will be loaded at startup.
  4|startup    |A program that is run at startup.
  5|shell      |A shell program that will shutdown after quit
  6|opersystem |A shell that will fully control the computer.
  More may be added later on as needed.
* mainexec = The path of the main executable to be run/loaded
  Format: "/path/to/application", make sure to have first /.
* preinstall = The path of the script to run before install.
  Format: "x/path/to/preinstall", x can be 't' or 'f' denotin
  if the script will be copied to destination.
* postinstall = The path of the script to run after install.
* data = The actual data in the file.
More identifiers may be added in later versions as needed.
---------------------------------------------------------]]--



function load(file)
  local ccp = fs.open(file, "r")
  local data = ccp.readAll()
  ccp.close()
  return textutils.unserialize(data)
end

function pack(name, table)
  local file = fs.open(name, "w")
  file.write(textutils.serialize(table))
  file.close()
end

function add_folder(table, name, ...)
  local folders = getFolder(table["data"], expand(arg))
  folders[name] = {}
  return folders
end

function edit_file(table, name, content, ...)
  local folders = getFolder(table["data"], expand[arg])
  folders[name] = content
  return folders
end

function extract(table, folder, createFolder, recurse)
  local path = folder
  createFolder = createFolder or true
  recurse = recurse or false
  if not recurse then
    if createFolder then
      path = path .. table["name"] .. "/"
      fs.makeDir(path)
    end
    table = table["data"]
  end
  debugPrint("Extracting to "..path)
  for k,v in pairs(table) do
    if isTable(v) then
      debugPrint(k.." is a folder.")
      local folder1 = path .. k .. "/"
      fs.makeDir(folder1)
      extract(table[k], folder1, false, true)
    else
      debugPrint("Writing "..k)
      local file = fs.open(path..k, "w")
      if file == nil then print("Error opening "..k.." in "..path) end
      file.write(v)
      file.close()
    end
  end
end

function new(name, type, mainexec)
  if name == nil then
    error("Name not given for new CCP")
    return {}
  end
  newccp = {}
  newccp["name"] = name
  newccp["type"] = type
  newccp["mainexec"] = mainexec
  newccp["preinstall"] = ""
  newccp["postinstall"] = ""
  newccp["data"] = {}
  return newccp
end

function loadFolder(folder, recurse)
  local table = {}
  recurse = recurse or false
  if not recurse then
    table.name = fs.getName(folder)
    table.data = {}
    data = table.data
  end
  for v,k in pairs(fs.list(folder)) do
    debugPrint("Testing "..k)
    if fs.isDir(folder..k) then
      data[k] = loadFolder(folder..k, true)
    else
      local kFile = fs.open(folder..k, "r")
      data[k] = kFile.readAll()
      kFile.close()
    end
  end
  if not recurse then
    table.data = data
  else
    table = data
  end
  return table
end

function rename(table, name)
  table["name"] = name
  return table
end
