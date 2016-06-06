--Enabled for verbose mode
_DEBUG = true

local function inArray(array, str)
  for _,v in pairs(array) do
    if v == str then
      return true
    end
  end
  return false
end

function debugPrint(text)
  if _DEBUG then print(text) end
end 
function isTable(t) return type(t) == "table" end
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

function add_folder(table, name, folder1, folder2, folder3, folder4)
  if folder1 then
    if folder2 then
      if folder3 then
        if folder4 then
          debugPrint("Going in folders: "..folder1..folder2..folder3..folder4)
          table["data"][folder1][folder2][folder3][folder4][name] = {}
        else
          debugPrint("Going in folders: "..folder1..folder2..folder3)
          table["data"][folder1][folder2][folder3][name] = {}
        end
      else
        debugPrint("Going in folders: "..folder1..folder2)
        table["data"][folder1][folder2][name] = {}
      end
    else
      debugPrint("Going in folders: "..folder1)
      table["data"][folder1][name] = {}
    end
  else
    debugPrint("Going in no folders")
    table["data"][name] = {}
  end
  return table
end

function edit_file(table, name, content, folder1, folder2, folder3, folder4, folder5)
  --debugPrint("Folder1: "..folder1 or "none".." Folder2: "..folder2 or "none".." Folder3: "..folder3 or "none".." Folder4: "..folder4 or "none".." Folder5: "..folder5 or "none")
  debugPrint("Folder: "..folder1)
  if folder1 ~= nil then
    if folder2 ~= nil then
      if folder3 ~= nil then
        if folder4 ~= nil then
          if folder5 ~= nil then
            debugPrint("Going in folders: "..folder1..folder2..folder3..folder4..folder5)
            table["data"][folder1][folder2][folder3][folder4][folder5][name] = content
          else
            debugPrint("Going in folders: "..folder1..folder2..folder3..folder4)
            table["data"][folder1][folder2][folder3][folder4][name] = content
          end
        else
          debugPrint("Going in folders: "..folder1..folder2..folder3)
          table["data"][folder1][folder2][folder3][name] = content
        end
      else
        debugPrint("Going in folders: "..folder1..folder2)
        table["data"][folder1][folder2][name] = content
      end
    else
      debugPrint("Going in folder: "..folder1)
      table["data"][folder1][name] = content
    end
  else
    debugPrint("Going in no folders")
    table["data"][name] = content
  end
  return table
end

function extract(table, folder, createFolder)
  local path = folder
  createFolder = createFolder or true
  if createFolder then
    path = path .. table["name"] .. "/"
    fs.makeDir(path)
  end
  debugPrint("Extracting to "..path)
  for k,v in pairs(table["data"]) do
    debugPrint("Testing "..k)
    if isTable(v) then
      debugPrint(k.." is a folder.")
      local folder1 = path .. k .. "/"
      fs.makeDir(folder1)
      for l,w in pairs(v) do
        if isTable(w) then
          debugPrint(l.." is a folder.")
          local folder2 = folder1 .. l .. "/"
          fs.makeDir(folder2)
          for m,x in pairs(w) do
            if isTable(x) then
              debugPrint(m.." is a folder.")
              local folder3 = folder2 .. m .. "/"
              fs.makeDir(folder3)
              for n,y in pairs(x) do
                if isTable(y) then
                  debugPrint(n.."is a folder.")
                  local folder4 = folder3 .. n .. "/"
                  fs.makeDir(folder4)
                  for o,z in pairs(y) do
                    debugPrint("Writing "..o)
                    local file5 = fs.open(o, "w")
                    file5.write(z)
                    file5.close()
                  end
                else
                  debugPrint("Writing "..n)
                  local file4 = fs.open(folder3..n, "w")
                  file4.write(y)
                  file4.close()
                end
              end
            else
              debugPrint("Writing "..m)
              local file3 = fs.open(folder2..m, "w")
              file3.write(x)
              file3.close()
            end
          end
        else
          debugPrint("Writing "..l)
          local file2 = fs.open(folder1..l, "w")
          file2.write(w)
          file2.close()
        end
      end
    else
      debugPrint("Writing "..k)
      local file1 = fs.open(path..k, "w")
      if file1 == nil then print("Error opening "..k.." in "..path) end
      file1.write(v)
      file1.close()
    end
  end
end

function new(name)
  newccp = {}
  newccp["name"] = name
  newccp["data"] = {}
  return newccp
end

function loadFolder(folder)
  local table = {}
  table.name = fs.getName(folder)
  table.data = {}
  for v,k in pairs(fs.list(folder)) do
    debugPrint("Testing "..k)
    if fs.isDir(folder..k) then
      table["data"][k] = {}
      for w,l in pairs(fs.list(folder..k)) do
        debugPrint("Testing "..l)
        if fs.isDir(folder..k.."/"..l) then
          table["data"][k][l] = {}
          for x,m in pairs(fs.list(folder..k.."/"..l)) do
            if fs.isDir(folder..k.."/"..l.."/"..m) then
            table["data"][k][l][m] = {}
              for y,n in pairs(fs.list(folder..k.."/"..l.."/"..m)) do
                if fs.isDir(folder..k.."/"..l.."/"..m.."/"..n) then
                  table["data"][k][l][m][n] = {}
                  for z,o in pairs(fs.list(folder..k.."/"..l.."/"..m.."/"..n)) do
                    if fs.isDir(folder..k.."/"..l.."/"..m.."/"..n.."/"..o) then
                      table["data"][k][l][m][n][o] = {}
                      for a,p in pairs(fs.list(folder..k.."/"..l.."/"..m.."/"..n.."/"..o)) do
                        if fs.isDir(folder..k.."/"..l.."/"..m.."/"..n.."/"..o.."/"..p) then
                          print("Only five folders can be nested!")
                        else
                          local pFile = fs.open(folder..k.."/"..l.."/"..m.."/"..n.."/"..o.."/"..p, "r")
                          table["data"][k][l][m][n][o][p] = pFile.readAll()
                          pFile.close()
                        end
                      end
                    else
                      local oFile = fs.open(folder..k.."/"..l.."/"..m.."/"..n.."/"..o, "r")
                      table["data"][k][l][m][n][o] = oFile.readAll()
                      oFile.close()
                    end
                  end
                else
                  local nFile = fs.open(folder..k.."/"..l.."/"..m.."/"..n, "r")
                  table["data"][k][l][m][n] = nFile.readAll()
                  nFile.close()
                end
              end
            else
              local mFile = fs.open(folder..k.."/"..l.."/"..m, "r")
              table["data"][k][l][m] = mFile.readAll()
              mFile.close()
            end
          end
        else
          local lFile = fs.open(folder..k.."/"..l, "r")
          table["data"][k][l] = lFile.readAll()
          lFile.close()
        end
      end
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
