--[[
Title: imP test file
Author(s): BerryZSZ
Date: 2017/8/14
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/Test/TestCreatTXT.lua");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/ImagesTo3Dmodel/imP.lua");

local ImageFilename = "Mod/ImagesTo3Dmodel/demo-data/church3/2.jpg";
local TxtFilename1 = "C:/Users/Azoth/Desktop/1.txt";
local TxtFilename2 = "Mod/ImagesTo3Dmodel/demo-data/church3/2.txt";
local TxtFilename3 = "C:/Users/Azoth/Desktop/ImagesTo3Dmodel/demo-data/church3/2.txt";

local Im = imP.imread(ImageFilename);
local I = imP.rgb2gray(Im);

-- ParaIO.GetWritablePath()
local I_O = imP.tensor.imresize(I,0.5);
LOG.std(nil,"debug","TestCreatTXT","-------Start 1----------");
imP.CreatTXT(I_O, TxtFilename1);
LOG.std(nil,"debug","TestCreatTXT","-------Start 2----------");
imP.CreatTXT(I_O, TxtFilename2);
--LOG.std(nil,"debug","TestCreatTXT","-------Start 3----------");
--imP.CreatTXT(I_O, TxtFilename3);