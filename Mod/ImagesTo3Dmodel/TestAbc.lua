--[[
Title: 
Author(s): zhang
Date: 2017/6/28
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/ImagesTo3Dmodel/TestAbc.lua");
local TestAbc = commonlib.gettable("Mod.ImagesTo3Dmodel.TestAbc");
TestAbc.Test("Images");
------------------------------------------------------------
]]
local TestAbc = commonlib.gettable("Mod.ImagesTo3Dmodel.TestAbc");
function TestAbc.Test(p)
    TestAbc.test_reading_image_file();
    commonlib.echo("TestAbc.Test");
    commonlib.echo(p);
    return {p};
end
function TestAbc.test_reading_image_file()
	-- reading binary image file
	-- png, jpg format are supported. 
	local filename = "Image/java.png";
	local file = ParaIO.open(filename, "image");
	if(file:IsValid()) then
		local ver = file:ReadInt();
		local width = file:ReadInt();
		local height = file:ReadInt();
		-- how many bytes per pixel, usually 1, 3 or 4
		local bytesPerPixel = file:ReadInt();
		echo({ver, width=width, height = height, bytesPerPixel = bytesPerPixel})
		local pixel = {};
		for y=1, height do
			for x=1, width do
				pixel = file:ReadBytes(bytesPerPixel, pixel);
				echo({x, y, rgb=pixel})
			end
		end
		file:close();
	end
end
