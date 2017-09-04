--[[
Title: TestSIFT
Author(s): BerryZSZ
Date: 2017/9/3
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/Test/TestSVD.lua",true);
------------------------------------------------------------
]]

NPL.load("(gl)Mod/ImagesTo3Dmodel/imP.lua",true);
NPL.load("(gl)Mod/ImagesTo3Dmodel/SVD.lua",true);

local ArrayShow = imP.tensor.ArrayShow;

local DO_SVD = SVD.DO_SVD;

local A = {{1, 2, 3, 4},
			{5, 6, 7, 8},
			{9, 10, 11, 12},
			{13, 14, 15, 16}};

local B = {{1, 2, 3, 4},
			{5, 6, 7, 8}};

local C = {{1, 2}, {3, 4}, {5, 6}, {7, 8}};

local UA, SA, VA = DO_SVD(A);
local UB, SB, VB = DO_SVD(B);
local UC, SC, VC = DO_SVD(C);

print("--------------- A -------------------");
print("UA")
ArrayShow(UA)
print("SA")
ArrayShow(SA)
print("VA")
ArrayShow(VA)
print("--------------- B -------------------");
print("UB")
ArrayShow(UB)
print("SB")
ArrayShow(SB)
print("VB")
ArrayShow(VB)
print("--------------- C -------------------");
print("UC")
ArrayShow(UC)
print("SC")
ArrayShow(SC)
print("VC")
ArrayShow(VC)


