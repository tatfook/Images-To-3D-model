--[[
Title: SFM
Author(s): BerryZSZ
Date: 2017/8/28
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/Test/TestMASC.lua", true);
------------------------------------------------------------
]]
NPL.load("(gl)Mod/ImagesTo3Dmodel/imP.lua", true);
NPL.load("(gl)Mod/ImagesTo3Dmodel/SIFT.lua", true);
NPL.load("(gl)Mod/ImagesTo3Dmodel/SVD.lua", true);
NPL.load("(gl)Mod/ImagesTo3Dmodel/SFM.lua", true);

local zeros = imP.tensor.zeros;
local ArrayShow = imP.tensor.ArrayShow;

local MSAC = SFM.MSAC;

local mp1 = zeros(2, 100);
local mp2 = zeros(2, 100);

for i = 1, #mp1[1] do
	for j = 1, 2 do
		mp1[j][i] = i*j;
		mp2[j][i] = (j+2)*i;
	end
end
ArrayShow(mp1)
ArrayShow(mp2)

local F, inliersIdx = MSAC(mp1, mp2);

ArrayShow(F)
ArrayShow(inliersIdx)
