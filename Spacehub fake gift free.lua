
local encoded_data = {112, 114, 105, 110, 116, 40, 34, 83, 80, 65, 73, 83, 80, 65, 67, 69, 32, 72, 85, 66, 32, 76, 111, 97, 100, 101, 100, 33, 34, 41}

local decoded_chars = {}
for index, byte_value in ipairs(encoded_data) do 
    decoded_chars[index] = string.char(byte_value) 
end

local executable_script = table.concat(decoded_chars)
local run_script, err = loadstring(executable_script)

if run_script then
    run_script()
else
    warn("Lỗi thực thi: " .. tostring(err))
end
