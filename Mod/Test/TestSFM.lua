--[[
Title: SFM
Author(s): BerryZSZ
Date: 2017/8/28
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/Test/TestSFM.lua", true);
------------------------------------------------------------
]]
NPL.load("(gl)Mod/ImagesTo3Dmodel/imP.lua", true);
NPL.load("(gl)Mod/ImagesTo3Dmodel/SIFT.lua", true);
NPL.load("(gl)Mod/ImagesTo3Dmodel/SVD.lua", true);
NPL.load("(gl)Mod/ImagesTo3Dmodel/SFM.lua", true);

local imread = imP.imread;
local rgb2gray = imP.rgb2gray;

local Im1_filename = "Mod/ImagesTo3Dmodel/demo-data/church3/1.JPG";
local Im2_filename = "Mod/ImagesTo3Dmodel/demo-data/church3/2.JPG";

local Im1 = imread(Im1_filename);
local Im2 = imread(Im2_filename);

local I1 = rgb2gray(Im1);
local I2 = rgb2gray(Im2);

local point3D = SFM.DO_SFM( I1, I2 );