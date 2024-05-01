-- File config.lua
Config = {}
Config.FarmingTime = 2990000 -- 30 phút làm việc
Config.HayBaleRespawnTime = 10000 -- 1 phút để cục rơm xuất hiện lại
Config.Item = {"Banhmi", "Tosti", "Nuoc"} 

-- Thêm tọa độ mới vào danh sách cục đá
function Config.AddRock(x, y, z)
    table.insert(Config.Rocks, {x = x, y = y, z = z})
end

-- Khởi tạo danh sách cục đá với các tọa độ
Config.Rocks = {}

-- Thêm tọa độ mới bằng cách sử dụng hàm AddRock
Config.AddRock(2831.5769, 4641.7500, 46.7583)
Config.AddRock(2836.1831, 4650.4863, 47.1498)
Config.AddRock(2842.4104, 4634.7256, 48.5195)
Config.AddRock(2840.9778, 4658.5801, 47.6426)

Config.AddRock(2849.2290, 4660.6846, 48.0516)
Config.AddRock(2855.8206, 4649.1611, 48.3604)
Config.AddRock(2866.1035, 4641.5981, 48.6021)
Config.AddRock(2867.2092, 4662.2495, 48.1212)
Config.AddRock(2878.0891, 4661.7085, 48.4217)
Config.AddRock(2875.5725, 4643.5464, 48.6274)
Config.AddRock(2869.0281, 4651.8242, 48.3818)
return Config