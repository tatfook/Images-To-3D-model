--[[
Title: TestSIFT
Author(s): BerryZSZ
Date: 2017/8/4
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/Test/TestSIFT.lua",true);
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
local ArrayMult = imP.tensor.ArrayMult;
local ArrayAdd = imP.tensor.ArrayAdd;
local ArrayAddArray = imP.tensor.ArrayAddArray;
local FindMax2 = imP.tensor.FindMax2;
local FindMin2 = imP.tensor.FindMin2;
local FindMax3 = imP.tensor.FindMax3;
local FindMin3 = imP.tensor.FindMin3;
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
local Spline = imP.tensor.Spline;
local imresize = imP.tensor.imresize;

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

local Im_filename = "Mod/ImagesTo3Dmodel/demo-data/church3/2.jpg";
--local Im_filename = "Mod/ImagesTo3Dmodel/demo-data/2.JPG";


--local TXT_filename = "D:/University/SOC2017/_mod/ImagesTo3Dmodel/Mod/ImagesTo3Dmodel/demo-data/fountain/1.txt";


local Im = imread(Im_filename);

local I = rgb2gray(Im);
--CreatTXT(I1, TXT1_filename);

local I_O = imresize(I, 500/math.min(#I, #I[1]));


local frames1, descriptors1, scalespace1, difofg1 = DO_SIFT(I_O);

--ArrayShow(descriptors1)

