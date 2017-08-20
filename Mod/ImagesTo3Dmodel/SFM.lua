--[[
Title: SFM
Author(s): BerryZSZ
Date: 2017/8/15
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/ImagesTo3Dmodel/SFM.lua");
------------------------------------------------------------
------------------------------------------------------------
local MatchFeaturePoints = SFM.MatchFeaturePoints;
local randperm = SFM.randperm;
local NormalizePoints = SFM.NormalizePoints;

------------------------------------------------------------
]]
NPL.load("(gl)Mod/ImagesTo3Dmodel/imP.lua");
NPL.load("(gl)Mod/ImagesTo3Dmodel/SIFT.lua");
local SFM = commonlib.gettable("SFM");

------------------------------------------------------------
local zeros = imP.tensor.zeros;
local zeros3 = imP.tensor.zeros3;
local Round = imP.Round;
local imread = imP.imread;
local rgb2gray = imP.rgb2gray;
local CreatTXT = imP.CreatTXT;
local DotProduct = imP.tensor.DotProduct;
local ArraySum = imP.tensor.ArraySum;
local ArrayShowE = imP.tensor.ArrayShowE;
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
local SubMatrix = imP.tensor.SubMatrix;
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
local gradient = imP.tensor.gradient;
local Spline = imP.tensor.Spline;
local imresize = imP.tensor.imresize;
local mean = imP.tensor.mean;
local diag = imP.tensor.diag;

------------------------------------------------------------
local DO_SIFT = SIFT.DO_SIFT;
local match = SIFT.match;
------------------------------------------------------------

function SFM.MatchFeaturePoints( I1, I2 )
	local frames1, descr1, gss1, dogss1 = DO_SIFT(I1);
	local frames2, descr2, gss2, dogss2 = DO_SIFT(I2);

	descr1 = transposition(descr1);
	descr2 = transposition(descr2);

	frames1 = transposition(frames1);
	frames2 = transposition(frames2);

	local matches,num, mp1, mp2 = match(I1, descr1, frames1, I2, descr2, frames2);
	return mp1, mp2;
end
local MatchFeaturePoints = SFM.MatchFeaturePoints;

function SFM.randperm(n, k)
	local k = k or n;
	local self = zeros(1, k);
	self[1][1] = math.random(1, n);
	for i = 2, k do
		repeat
			self[1][i] = math.random(1, n);
			local determine = self[1][i] ~= self[1][1];
			local j = 1;
			while(determine == true and j<i) do
				determine = determine and self[1][i] ~= self[1][j];
				j = j + 1;
			end
		until(determine == true)
	end
	return self;
end
local randperm = SFM.randperm;

function SFM.NormalizePoints( p, numDims )
	local points = {};
	local pointsLength = #p[1];
	for i = 1, numDims do
		points[i] = {};
		for j = 1, pointsLength do
			points[i][j] = p[i][j];
		end
	end
	local cent = mean(points);
	for i = 1, numDims do
		for j = 1, pointsLength do
			points[i][j] = points[i][j] - cent[i];
		end
	end
	local points = DotProduct(points, points);
	local SumPoints = {points[1]};
	for i = 2, numDims do
		SumPoints = ArrayAddArray(SumPoints, {points[i]}, SumPoints);
	end
	for i = 1, pointsLength do
		SumPoints[1][i] = math.sqrt(SumPoints[1][i]);
	end
	local meanDistanceFromCenter = mean(SumPoints[1]);

	local scale;
	if meanDistanceFromCenter > 0 then
		scale = math.sqrt(numDims)/meanDistanceFromCenter;
	else
		scale = 1;
	end

	local Tn = {};
	for i = 1, numDims + 1 do
		Tn[i] = scale;
	end
	local T = diag(Tn);
	for i = 1, numDims do
		T[i][numDims + 1] = -scale * cent[i];
	end
	T[numDims + 1][numDims + 1] = 1;

	local normPoints;
	if #p > numDims then
		normPoints = MatrixMultiple(T, p);
	else
		normPoints = ArrayMult(points, scale);
	end
	return normPoints, T;
end
local NormalizePoints = SFM.NormalizePoints;

function SFM.EightPoint( points1homo, points2homo )
	local num = #points1homo[1];
	local points1homo, t1 = NormalizePoints(points1homo, 2);
	local points2homo, t2 = NormalizePoints(points2homo, 2);
	local m = zeros(9, num);
	m[1] = DotProduct(points1homo[1], points2homo[1]);
	m[2] = DotProduct(points2homo[2], points2homo[1]);
	m[3] = points2homo[1];
	m[4] = DotProduct(points1homo[1], points2homo[2]);
	m[5] = DotProduct(points1homo[2], points2homo[2]);
	m[6] = points2homo[2];
	m[7] = points1homo[1];
	m[8] = points1homo[2];
	for i = 1, num do
		m[9][i] = 1;
	end
	m = transposition(m);
	


end

function SFM.MSAC(points1, points2)
	local nPoints = #points1[1];
	local points1homo = zeros(3, nPonits);
	local points2home = zeros(3, nPonits);
	for i = 1, nPoints do
		points1homo[1][i] = points1[1][i];
		points1homo[2][i] = points1[2][i];
		points1homo[3][i] = 0;
		points2homo[1][i] = points2[1][i];
		points2homo[2][i] = points2[2][i];
		points2homo[3][i] = 0;
	end

	local threshold = 0.01;
	local maxtrails = 20000;
	--local bestDist = 
	math.randomseed(os.time())
	local sampleIndicies, f, pfp, d, inliers, nInliers, Dist; 
	for trails = 1, maxtrails do
		sampleIndicies = randperm(nPonits, 8);

	end



function SFM.DO_SFM( I1, I2, parameter )
	
	--Match features
	local mp1, mp2 = MatchFeaturePoints(I1, I2);

	-- Estimate F R t  

end