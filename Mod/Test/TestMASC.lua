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
LOG.std(nil,"debug","Test","TestMASC: -----------------------Strat--------------------------");
NPL.load("(gl)Mod/ImagesTo3Dmodel/imP.lua", true);
NPL.load("(gl)Mod/ImagesTo3Dmodel/SIFT.lua", true);
NPL.load("(gl)Mod/ImagesTo3Dmodel/SVD.lua", true);
NPL.load("(gl)Mod/ImagesTo3Dmodel/SFM.lua", true);

local zeros = imP.tensor.zeros;
local ArrayShow = imP.tensor.ArrayShow;
local EightPoint = SFM.EightPoint;
local ArraySum = imP.tensor.ArraySum;
local transposition = imP.tensor.transposition;
local ArrayMult = imP.tensor.ArrayMult;
local eye = imP.tensor.eye;
local mytriangualation = SFM.mytriangualation;
local connect = imP.tensor.connect;
local MatrixMultiple = imP.tensor.MatrixMultiple;

local MSAC = SFM.MSAC;
local MotionFromF = SFM.MotionFromF;
local mytriangualation = SFM.mytriangualation;

local mp1 = zeros(2, 100);
local mp2 = zeros(2, 100);

for i = 1, #mp1[1] do
	for j = 1, 2 do
		mp1[j][i] = i*j;
		mp2[j][i] = (j+2)*i;
	end
end
--ArrayShow(mp1)
--ArrayShow(mp2)
--local f = EightPoint(mp1, mp2);
--ArrayShow(f)

local col = {{1663.782234, 0.000000, 785.889057}, 
			{0.000000, 1663.367425, 638.790025},
			{0.000000, 0.000000, 1.000000}};
local col = ArrayMult(col, 0.5);

local intrinsic = transposition(col);

local F, inliersIdx = MSAC(mp1, mp2);
--ArrayShow(F)
--ArrayShow({inliersIdx})
local num = ArraySum(inliersIdx);
local inlierPoints1 = zeros(num, 2);
local inlierPoints2 = zeros(num, 2);
local num_count = 0;
for i = 1, #mp1[1] do 
	if inliersIdx[i] == 1 then 
		num_count = num_count + 1;
		for j = 1, #mp1 do
			inlierPoints1[num_count][j] = mp1[j][i];
			inlierPoints2[num_count][j] = mp2[j][i];
		end
	end
end
LOG.std(nil, "debug", "SFM", "SFM: Start Motion From F...");	
local R, t = MotionFromF(F, intrinsic, inlierPoints1, inlierPoints2);
ArrayShow(R)
print("----------------------------------")
ArrayShow(t)
local camMat0 = MatrixMultiple(connect(eye(3), {{0, 0, 0}}, 1), intrinsic);
local camMatl = MatrixMultiple(connect(R, MatrixMultiple(ArrayMult(t, -1), R), 1), intrinsic);
print("camMat0----------------------")
ArrayShow(camMat0)
print("camMatl----------------------")
ArrayShow(camMatl)

--local camMatl = {{-207.4634, -880.4934, -0.2486},
--				{85.4147, 114.6958, -0.3854},
--				{892.2508, -75.0488, 0.1993},
--				{-831.8911, 0, 0}};

local points3D = mytriangualation(mp1, mp2, camMat0, camMatl);

print("points3D----------------------")
ArrayShow(points3D)

LOG.std(nil,"debug","Test","TestMASC: ----------------------- End --------------------------");
