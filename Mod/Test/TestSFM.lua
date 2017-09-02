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

local Im1_filename = "Mod/ImagesTo3Dmodel/demo-data/fountain/1.jpg";
local Im2_filename = "Mod/ImagesTo3Dmodel/demo-data/fountain/2.jpg";

local Txt_I1 = "Mod/ImagesTo3Dmodel/demo-data/fountain/I1.txt";
local Txt_I2 = "Mod/ImagesTo3Dmodel/demo-data/fountain/I2.txt";
local Txt_Points3D = "Mod/ImagesTo3Dmodel/demo-data/fountain/points3D.txt";
local Txt_mp1 = "Mod/ImagesTo3Dmodel/demo-data/fountain/mp1.txt";
local Txt_mp2 = "Mod/ImagesTo3Dmodel/demo-data/fountain/mp2.txt";


local Im1 = imread(Im1_filename);
local Im2 = imread(Im2_filename);

local TXT_Im1R = "Mod/ImagesTo3Dmodel/demo-data/fountain/R.txt";
local TXT_Im1G = "Mod/ImagesTo3Dmodel/demo-data/fountain/G.txt";
local TXT_Im1B = "Mod/ImagesTo3Dmodel/demo-data/fountain/B.txt";

imP.CreatTXT(Im1[1], TXT_Im1R);
imP.CreatTXT(Im1[2], TXT_Im1G);
imP.CreatTXT(Im1[3], TXT_Im1B);


local I1 = rgb2gray(Im1);
local I2 = rgb2gray(Im2);

imP.CreatTXT(I1, Txt_I1)
imP.CreatTXT(I2, Txt_I2)

local point3D, mp1, mp2 = SFM.DO_SFM( I1, I2 );

imP.CreatTXT(point3D, Txt_Points3D);
imP.CreatTXT(mp1, Txt_mp1);
imP.CreatTXT(mp2, Txt_mp2);

