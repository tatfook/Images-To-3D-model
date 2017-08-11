--[[
Title: 
Author(s): zhang
Date: 2017/6/28
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/ImagesTo3Dmodel/TestAbc.lua");
local TestAbc = commonlib.gettable("Mod.ImagesTo3Dmodel.TestAbc");

------------------------------------------------------------
]]
--[[local TestAbc = commonlib.gettable("Mod.ImagesTo3Dmodel.TestAbc");
function TestAbc.Test(p)
    TestAbc.test_reading_image_file();
    commonlib.echo("TestAbc.D:\University\SOC2017\LuaCode\LenaGrey.jpgTest");
    commonlib.echo(p);
    return {p};
end]]
function TestAbc()
	-- reading binary image file
	-- png, jpg format are supported. 
	local filename = "Mod/ImagesTo3Dmodel/a.jpg";
	local file = ParaIO.open(filename, "image");
	if(file:IsValid()) then
		local ver = file:ReadInt();
		local width = file:ReadInt();
		local height = file:ReadInt();
		-- how many bytes per pixel, usually 1, 3 or 4
		local bytesPerPixel = file:ReadInt();
		echo({ver, width = width, height = height, bytesPerPixel = bytesPerPixel})
		local pixel = {};
		for y = 1, height do
			for x = 1, width do
				pixel = file:ReadBytes(bytesPerPixel, pixel);
				echo({x, y, rgb = pixel})
			end
		end

	end
end
NPL.load("(gl)Mod/ImagesTo3Dmodel/imP.lua",true);
local filename = "Mod/ImagesTo3Dmodel/lena.png";
array=imP.imread2Grey(filename);
R=imP.HarrisCD(array)
imP.CreatTXT(R, "D:/University/SOC2017/ParaCraftSDK-master/ParaCraftSDK-master/_mod/ImagesTo3Dmodel/Mod/ImagesTo3Dmodel/harris.txt");