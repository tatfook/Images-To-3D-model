--[[
Title: imP test file
Author(s): BerryZSZ
Date: 2017/8/12
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/Test/TestimP.lua");
------------------------------------------------------------
]]

NPL.load("(gl)Mod/ImagesTo3Dmodel/imP.lua",true);
LOG.std(nil,"debug","Test","---------- Start ----------");

local filename = "Mod/ImagesTo3Dmodel/demo-data/church3/2.jpg";
--local filename = "Mod/ImagesTo3Dmodel/demo-data/2.JPG";
local Im = imP.imread(filename);
local I = imP.rgb2gray(Im);
local TXT_filename = "D:/University/SOC2017/LuaCode/lena.txt";

local I_O= imP.tensor.imresize(I, 500/math.min(#I, #I[1]));
--local I_O1 = imP.tensor.imresize(I_O, 1.5);
LOG.std(nil,"debug","Test","---------- Point ----------");

imP.CreatTXT(I_O, TXT_filename);
LOG.std(nil,"debug","Test","---------- End ----------");

