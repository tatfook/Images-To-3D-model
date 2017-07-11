--[[
Title: 
Author(s): BerryZSZ
Date: 2017/7/11
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/ImagesTo3Dmodel/imP.lua");

------------------------------------------------------------
]]
local filename = "Mod/ImagesTo3Dmodel/lena.jpg";
function imread2Grey(filename)
    --Read the image and creat the Grey image.
	local file = ParaIO.open(filename, "image");
	if(file:IsValid()) then
		local ver = file:ReadInt();
		local width = file:ReadInt();
		local height = file:ReadInt();
		-- how many bytes per pixel, usually 1, 3 or 4
		local bytesPerPixel = file:ReadInt();
		--echo({ver, width=width, height = height, bytesPerPixel = bytesPerPixel})
		local pixel = {};
		local array = {};
		for j=1, height do
		    array[j] = {};
			for i=1, width do
				pixel = file:ReadBytes(bytesPerPixel,pixel);
				array[j][i] = pixel[1];
				for h=2, bytesPerPixel do				    
				    array[j][i] = array[j][i] + pixel[h];
				end
				array[j][i] = array[j][i]/bytesPerPixel;
				echo({i, j, pixel,array[j][i]});
			end
		end
    return array;
	else
	    print("The file is not valid");
	end
end

function zeros(height,width)
	-- body
	array={};
	for h=1, height do
		array[h]={};
		for w=1, width do
			array[h][w]=0;
		end
	end
	return array;	
end

function CreatTXT(array)
	-- body
	local file = io.open("D:/University/SOC2017/ParaCraftSDK-master/ParaCraftSDK-master/_mod/ImagesTo3Dmodel/Mod/ImagesTo3Dmodel/lena.txt","w");
	h=table.getn(array);
	if h~=nil then
		for j=1,h do
			w=table.getn(array[j]);
			if w~=nil then
				for i=1,w do
					file: write(math.ceil(array[j][i]),"\t");
					print(array[j][i])
				end
			end
			file: write("\r");
		end
	end
	file: close();
end
array=imread2Grey(filename);
CreatTXT(array);