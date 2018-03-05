--ImageWriter
--Version 2.2
arg = ...
--InPath = 'Z:\\protti\\source\\'
--OutPath = 'Y:\\'
i = 0
programs = {}
--functions
function find_table(arr, item) --
  for _, v in pairs(arr) do
    --if v:find(item) then
    if v==item then
      return true
    end
  end
  return false
end
function command(str)
  local iter = io.popen(str):lines()
  local i = 0
	local arr = {}
	for n in iter do 
		i=i+1
		arr[i] = n
	end
	return arr,i
end
--Functions
function Info()
  print([[
 _____                   _ _ _     _ _           
|     |_____ ___ ___ ___| | | |___|_| |_ ___ ___ 
|-   -|     | .'| . | -_| | | |  _| |  _| -_|  _|
|_____|_|_|_|__,|_  |___|_____|_| |_|_| |___|_|  
                |___|                            ]])
  print('ImageWriter')
  print('Version 2.2')
  print('Github-Virenbar')
end
function LoadConfig()
	dofile('config.lua')
  OutPath = OutPath..command('dir '..OutPath..'/b /ad')[1]..'\\'
end
function Scan()
  local arr = {}
  local i = 0
  local files = command('dir '..InPath..'/b /a-d')
  for _,file in pairs(files) do
    file = file:match('^(.+)%.')
    if arr[file] ~= true then
      arr[file] = true
      i = i+1
      print('[INFO]Найдена программа: '..file)
    end  
  end
  return arr,i
end
function Find(name)
  --local name = name:match('^%d%d%d%d')
	print('[INFO]Поиск образа с именем '..name)
  local dir = 'Folder-'..name:gsub('^(%d%d)(.+)','%1xx')
  local image = name..'.hfe'
	local dirs = command('dir '..OutPath..'/b /ad')
  local new = false
  if find_table(dirs,dir) then
		print('[INFO]Папка найдена: '..dir)
    local files = command('dir '..OutPath..dir..'/b /a-d')
    new = not find_table(files,image) 
	else
		print('[INFO]Папка не найдена, создана папка: '..dir)
		os.execute('xcopy '..OutPath..'Folder-Obraz '..OutPath..dir..'\\')
    new = true
	end
  if new then 
    print('[INFO]Образ не найден, создан образ: '..image)
    os.execute('copy '..OutPath..dir..'\\OBRAZ.hfe '..OutPath..dir..'\\'..image)
  else
    print('[INFO]Образ найден: '..image)
  end
  return OutPath..dir..'\\'..image
end
function AddFiles(image,name)
  local files = command('dir '..InPath..name..'.* /b /a-d') 
  local HxCFE
  local output = ''
  for _,v in pairs(files) do
    print('[INFO]Запись файла '..v..' в образ.')
    HxCFE = io.popen('HxCFE\\hxcfe.exe -finput:'.. image ..' -putfile:'..InPath..v)
    local output = HxCFE:read('*a')
    --print(output)
    HxCFE:close()
  end
  os.execute('del '..InPath..name..'.*')
  print('[INFO]Программа '..name..' удалена из папки.')
end

-- MAIN ------------------------------------------------------------------
os.execute('chcp 65001')--Установка кодировки консоли в UTF-8
Info()
LoadConfig()
programs,i = Scan()
if i==0 then
  print('[WAR]Папка '..InPath..' пуста.')
  os.execute('pause')
  os.exit()
else
  print('[INFO]Кол-во найденых программ: '..i)
end
for program,_ in pairs(programs) do
  print('[INFO]Программа: '..program)
  local image = Find(program:gsub('^(%d%d%d%d)(.)','%1A'))
  AddFiles(image,program)
end
--print('Найдено '..i..' папок.')
--if i==0 then exit() end
--Create()
os.execute('pause')