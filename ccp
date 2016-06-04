--Enabled for verbose mode
local _DEBUG = false

local function inArray(array, str)
  for _,v in pairs(array) do
    if v == str then
      return true
    end
  end
  return false
end

local function debugPrint(text)
  if _DEBUG then print(text) end
end 
local function isTable(t) return type(t) == "table" end
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
          table["data"][folder1][folder2][folder3][folder4][name] = {}
        else
          table["data"][folder1][folder2][folder3][name] = {}
        end
      else
        table["data"][folder1][folder2][name] = {}
      end
    else
      table["data"][folder1][name] = {}
    end
  else
    table["data"][name] = {}
  end
  return table
end

function edit_file(table, name, content, folder1, folder2, folder3, folder4, folder5)
  if folder1 then
    if folder2 then
      if folder3 then
        if folder4 then
          if folder5 then
            table["data"][folder1][folder2][folder3][folder4][folder5][name] = content
          else
            table["data"][folder1][folder2][folder3][folder4][name] = content
          end
        else
          table["data"][folder1][folder2][folder3][name] = content
        end
      else
        table["data"][folder1][folder2][name] = content
      end
    else
      table["data"][folder1][name] = content
    end
  else
    table["data"][name] = content
  end
  return table
end

function extract(table, folder, createFolder)
  local path = folder
  createFolder = createFolder or true
  if createFolder then
    path = path .. table["name"]
    fs.makeDir(path)
  end
  for k,v in ipairs(table["data"]) do
    if isTable(v) then
      local folder1 = folder .. k
      for l,w in ipairs(v) do
        if isTable(w) then
          local folder2 = folder1 .. l
          for m,x in ipairs(w) do
            if isTable(x) then
              local folder3 = folder2 .. m
              for n,y in ipairs(x) do
                if isTable(y) then
                  local folder4 = folder3 .. n
                  for o,z in ipairs(y) do
                    local file5 = fs.open(o, "w")
                    file5.write(z)
                    file5.close()
                  end
                else
                  local file4 = fs.open(folder3..n, "w")
                  file4.write(y)
                  file4.close()
                end
              end
            else
              local file3 = fs.open(folder2..m, "w")
              file3.write(x)
              file3.close()
            end
          end
        else
          local file2 = fs.open(folder1..l, "w")
          file2.write(w)
          file2.close()
        end
      end
    else
      local file1 = fs.open(folder..k, "w")
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
