--[[
Title: TestSIFT
Author(s): BerryZSZ
Date: 2017/8/4
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/ImagesTo3Dmodel/TestSIFTmatching.lua",true);
------------------------------------------------------------
]]

NPL.load("(gl)Mod/ImagesTo3Dmodel/imP.lua",true);
NPL.load("(gl)Mod/ImagesTo3Dmodel/SIFT.lua",true);

--[[local imP = commonlib.gettable("Mod.ImagesTo3Dmodel.imP");
local tensor = commonlib.inherit(nil, commonlib.gettable("Mod.ImagesTo3Dmodel.imP.tensor"));
]]
local zeros = imP.tensor.zeros;
local zeros3 = imP.tensor.zeros3;
local Round = imP.Round;
local imread = imP.imread;
local rgb2gray = imP.rgb2gray;
local CreatTXT = imP.CreatTXT;
local DotProduct = imP.tensor.DotProduct;
local ArraySum = imP.tensor.ArraySum;
local ArrayShow = imP.tensor.ArrayShow;
local ArrayShow3 = imP.tensor.ArrayShow3;
local ArrayMutl = imP.tensor.ArrayMutl;
local ArrayAdd = imP.tensor.ArrayAdd;
local ArrayAddArray = imP.tensor.ArrayAddArray;
local Array2Max = imP.tensor.Array2Max;
local Array2Min = imP.tensor.Array2Min;
local Array3Max = imP.tensor.Array3Max;
local Array3Min = imP.tensor.Array3Min;
local GetGaussian = imP.GetGaussian;
local GaussianF = imP.GaussianF;
local DoG = imP.DoG;
local meshgrid = imP.tensor.meshgrid;
local conv2 = imP.tensor.conv2;
local Det2 = imP.tensor.Det2;
local Trace2 = imP.tensor.Trace2;
local HarrisCD = imP.HarrisCD;
local GetColumn = imP.tensor.GetColumn;
local MatrixMultiple = imP.tensor.MatrixMultiple;
local det = imP.tensor.det;
local SubMartrix = imP.tensor.SubMartrix;
local inv = imP.tensor.inv;
local find = imP.tensor.find;
local subvector = imP.tensor.subvector;
local submatrix = imP.tensor.submatrix;
local connect = imP.tensor.connect;
local reshape = imP.tensor.reshape;
local transposition = imP.tensor.transposition;
local norm = imP.tensor.norm;
local dot = imP.tensor.dot;
local mod = imP.tensor.mod;

local HalfSize = SIFT.HalfSize;
local DoubleSize = SIFT.DoubleSize;
local gaussian = SIFT.gaussian;
local diffofg = SIFT.diffofg;
local localmax = SIFT.localmax;
local extrafine = SIFT.extrafine;
local orientation = SIFT.orientation;
local descriptor = SIFT.descriptor;
local DO_SIFT = SIFT.DO_SIFT;
local match = SIFT.match;

local Im1_filename = "Mod/ImagesTo3Dmodel/demo-data/1.JPG";
local Im2_filename = "Mod/ImagesTo3Dmodel/demo-data/2.JPG";

--local Im1_filename = "Mod/ImagesTo3Dmodel/demo-data/church3/1.jpg";
--local im2_filename = "mod/imagesto3dmodel/demo-data/church3/2.jpg";
--
local TXT1_filename = "D:/University/SOC2017/ParaCraftSDK-master/ParaCraftSDK-master/_mod/ImagesTo3Dmodel/Mod/ImagesTo3Dmodel/demo-data/fountain/1.txt";
local TXT2_filename = "D:/University/SOC2017/ParaCraftSDK-master/ParaCraftSDK-master/_mod/ImagesTo3Dmodel/Mod/ImagesTo3Dmodel/demo-data/fountain/1.txt";


local Im1 = imread(Im1_filename);
local Im2 = imread(Im2_filename);

local I1 = rgb2gray(Im1);
local I2 = rgb2gray(Im2);

--CreatTXT(I1, TXT1_filename);
--CreatTXT(I2, TXT2_filename);

local frames1, descr1, gss1, dogss1 = DO_SIFT(I1);
local frames2, descr2, gss2, dogss2 = DO_SIFT(I2);

LOG.std(nil, "debug", "SIFT", "Computing matches...")

descr1 = transposition(descr1);
descr2 = transposition(descr2);

frames1 = transposition(frames1);
frames2 = transposition(frames2);
--ArrayShow(descr1)
--ArrayShow(descr2)


local matches,num = match(I1, descr1, frames1, I2, descr2, frames2);
LOG.std(nil, "debug", "SIFT", "Matched points:# %f", matches);
LOG.std(nil, "debug", "SIFT", "Matched points:# %f", num);