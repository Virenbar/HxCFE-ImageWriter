--ImageWriter
--Version 2.3
Info = [[
 _____                   _ _ _     _ _           
|     |_____ ___ ___ ___| | | |___|_| |_ ___ ___ 
|-   -|     | .'| . | -_| | | |  _| |  _| -_|  _|
|_____|_|_|_|__,|_  |___|_____|_| |_|_| |___|_|  
                |___|                            
ImageWriter
Version 2.3
Github-Virenbar
]]
arg = ...
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
function Init()
    print(Info)
    dofile('config.lua')
    local dir = command('dir '..OutPath..'/b /ad')[1]
    if dir == nil then
        print('[Error]Некорректный путь')
        os.execute('pause')
        os.exit()
    else
        OutPath = OutPath..dir..'\\'--Первая папка в корне
    end
end
function Scan()
    local arr = {}
    local i = 0
    local files = command('dir '..InPath..'/b /a-d')
    for _,file in pairs(files) do
        file = file:match('^(.+)%.')
        if not arr[file] then
            arr[file] = true
            i = i+1
            print('[INFO]Найдена программа: '..file)
        end  
    end
    return arr,i
end
function Find(program)
    local name, image, predir, dir, dirpath
    if string.match(program:sub(1,1),'%a') then
        name = program
        image = name..'.hfe'
        dir = program:sub(1,4)
        predir= ''
        dirpath = dir
    else
        name = program:gsub('^(%d%d%d%d).(%d%d).+','%1-%2')
        image = name..'.hfe'
        dir = 'Folder-'..name:gsub('^(%d%d%d%d).+','%1')
        predir = 'Folder-'..name:gsub('^(%d%d).+','%1xx')
        dirpath = predir..'\\'..dir
    end
    
    print('[INFO]Поиск образа с именем '..name)
    local dirs = command('dir '..OutPath..predir..'/b /ad')
    local new = false
    if find_table(dirs,dir) then
		print('[INFO]Папка найдена: '..dir)
        local files = command('dir '..OutPath..dirpath..'/b /a-d')
        new = not find_table(files,image) 
	else
		print('[INFO]Папка не найдена, создана папка: '..dir)
		os.execute('md '..OutPath..dirpath..'\\')
    new = true
	end
    if new then 
        print('[INFO]Образ не найден, создан образ: '..image)
        --os.execute('copy '..OutPath..'\\OBRAZ.hfe '..OutPath..dirpath..'\\'..image)
        os.execute('copy OBRAZ.hfe '..OutPath..dirpath..'\\'..image)
    else
        print('[INFO]Образ найден: '..image)
    end
    return OutPath..dirpath..'\\'..image
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
Init()
programs,i = Scan()
if i==0 then
    print('[WAR]Папка '..InPath..' пуста.')
    os.execute('pause')
    os.exit()
else
    print('[INFO]Кол-во найденых программ: '..i)
end
for program,_ in pairs(programs) do
    print('\n[INFO]Программа: '..program)
    local image = Find(program)
    AddFiles(image,program)
end
--print('Найдено '..i..' папок.')
--if i==0 then exit() end
--Create()
os.execute('pause')