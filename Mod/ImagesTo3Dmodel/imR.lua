--[[
Title: 
Author(s): BerryZSZ
Date: 2017/7/11
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/ImagesTo3Dmodel/imP.lua");
array=imread2Grey(filename);
CreatTXT(array);
------------------------------------------------------------
]]

-- luajit, NPL:  trace just in time compiler. 
-- random io networking seed os.time , drawing ,  GPU,  .... 
-- scripting runtime  -- >  C/C++ runtime   ---> user mode ---> kernel mode


NPL.load("(gl)Mod/ImagesTo3Dmodel/models.lua");
local filename = "Mod/ImagesTo3Dmodel/lena.png";
function imread2Grey(filename)
    --Read the image and creat the Grey image.
	local file = ParaIO.open(filename, "image");
	if(file:IsValid()) then
		local ver = file:ReadInt();
		local width = file:ReadInt();
		local height = file:ReadInt();
		-- how many bytes per pixel, usually 1, 3 or 4
		local bytesPerPixel = file:ReadInt();
		echo({ver, width=width, height = height, bytesPerPixel = bytesPerPixel})
		local pixel = {};
		local array = zeros(height,width);
		for j=1, height do
			for i=1, width do
				pixel = file:ReadBytes(bytesPerPixel,pixel);
				array[j][i] = pixel[1];
				for h=2, bytesPerPixel do				    
				    array[j][i] = array[j][i] + pixel[h];
				end
				array[j][i] = Round(array[j][i]/bytesPerPixel);
				--echo({i, j, pixel,array[j][i]});
			end
		end
    return array;
	else
	    print("The file is not valid");
	end
end
array=imread2Grey(filename);
--ArrayShow(array);


function CreatTXT(array,filename)
	-- body
	local file = io.open(filename,"w");
	h=table.getn(array);
	if h~=nil then
		for j=1,h do
			w=table.getn(array[j]);
			if w~=nil then
				for i=1,w do
					file: write(math.ceil(array[j][i]),"\t");
					--print(array[j][i])
				end
			end
			file: write("\r");
		end
	end
	file: close();
end

--echo({ArrayMax(array),ArrayMin(array)});
--g=GaussianF(array,5,5);
--CreatTXT(g,"D:/University/SOC2017/ParaCraftSDK-master/ParaCraftSDK-master/_mod/ImagesTo3Dmodel/Mod/ImagesTo3Dmodel/lenaO.txt");
--F=DoG(array,1,5);
--CreatTXT(F,"D:/University/SOC2017/ParaCraftSDK-master/ParaCraftSDK-master/_mod/ImagesTo3Dmodel/Mod/ImagesTo3Dmodel/lena.txt");
R=HarrisCD(array);
CreatTXT(R,"D:/University/SOC2017/ParaCraftSDK-master/ParaCraftSDK-master/_mod/ImagesTo3Dmodel/Mod/ImagesTo3Dmodel/harris.txt");
