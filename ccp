--Enabled for verbose mode
local _DEBUG = true

local function inArray(array, str)
  for _,v in pairs(array) do
    if v == str then
      return true
    end
  end
  return false
end

local function debugPrint(text) if _DEBUG then print(text) end end 
local function isTable(t) return type(t) == "table" end
local function select (n, ...) return arg[n] end
local function getFolder(table, ...) return getFolder(table[select(1, expand(arg))], expand(table.remove(table, 1))) end

--Uncomment to allow -v argument
--if inArray(arg, "-v") then _DEBUG = true end
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
  local folders = getFolder(table, expand(arg))
  folders[name] = {}
  return folders
end

function edit_file(table, name, content, ...)
  local folders = getFolder(table, expand[arg])
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

function new(name)
  newccp = {}
  newccp["name"] = name
  newccp["data"] = {}
  return newccp
end

function loadFolder(folder, recurse)
  local table = {}
  recurse = recurse or false
  table.name = fs.getName(folder)
  table.data = {}
  for v,k in pairs(fs.list(folder)) do
    debugPrint("Testing "..k)
    if fs.isDir(folder..k) then
      table["data"][k] = {}
    else
      local kFile = fs.open(folder..k, "r")
      table["data"][k] = kFile.readAll()
      kFile.close()
    end
  end
  return table
end

function rename(table, name)
  table["name"] = name
  return table
end
