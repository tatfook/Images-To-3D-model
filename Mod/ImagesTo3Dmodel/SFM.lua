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
NPL.load("(gl)Mod/ImagesTo3Dmodel/SVD.lua");

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
local QRDecompositionHouse = SVD.QRDecompositionHouse;
local DO_SVD = SVD.DO_SVD;
------------------------------------------------------------

function SFM.MatchFeaturePoints( I1, I2 )
	local frames1, descr1, gss1, dogss1 = DO_SIFT(I1);
	local frames2, descr2, gss2, dogss2 = DO_SIFT(I2);

	descr1 = transposition(descr1);
	descr2 = transposition(descr2);

	frames1 = transposition(frames1);
	frames2 = transposition(frames2);

	local matches, num, mp1, mp2 = match(I1, descr1, frames1, I2, descr2, frames2);
	return mp1, mp2;
end
local MatchFeaturePoints = SFM.MatchFeaturePoints;

function SFM.randperm(n, k)
	local k = k or n;
	local self = zeros(1, k);
	self[1][1] = math.random(1, n);
	for i = 2, k do
		local determine = false
		while(determine == false) do
			self[1][i] = math.random(1, n);
			determine = self[1][i] ~= self[1][1];
			local j = 1;
			while(determine == true and j<i) do
				determine = determine and self[1][i] ~= self[1][j];
				j = j + 1;
			end
		end
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
	local SumPoints = points[1];
	for i = 2, numDims do
		SumPoints = ArrayAddArray(SumPoints, points[i], SumPoints);
	end
	for i = 1, pointsLength do
		SumPoints[i] = math.sqrt(SumPoints[i]);
	end
	local meanDistanceFromCenter = mean(SumPoints);

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
	local um, sm, vm = DO_SVD(m);
	local f = zeros(3, 3);
	for i = 1, 3 do
		for j = 1, 3 do
			f[i][j] = vm[3*(i-1)+j][#vm];
		end
	end
	local u, s, v = DO_SVD(f);
	s[#s][#s[1]] = 0;
	f = MatrixMultiple(MatrixMultiple(u, s), transposition(v));
	f = MatrixMultiple(MatrixMultiple(transposition(t2), s), t1);
	local uf, sf, vf = DO_SVD(f);
	f = ArrayMult(f, 1/FindMax2(sf));
	if f[#f][#f[1]] < 0 then
		f = ArrayMult(f, -1);
	end
	return f;
end
local EightPoint = SFM.EightPoint;


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
	local sampleIndicies, f, pfp, inliers, nInliers, bestDist;
	local bestInliers;
	local EightPoint1 = zeros(3, 8);
	local EightPoint2 = zeros(3, 8); 
	local d = {}; 
	local Dist = 0;
	for trails = 1, maxtrails do
		--estimate f using random 8 points
		sampleIndicies = randperm(nPonits, 8);
		for i = 1, 8 do
			EightPoint1[1][i] = points1homo[1][sampleIndicies[1][i]];
			EightPoint1[2][i] = points1homo[2][sampleIndicies[1][i]];
			EightPoint1[3][i] = points1homo[3][sampleIndicies[1][i]];
			EightPoint2[1][i] = points2homo[1][sampleIndicies[1][i]];
			EightPoint2[2][i] = points2homo[2][sampleIndicies[1][i]];
			EightPoint2[3][i] = points2homo[3][sampleIndicies[1][i]];
		end 
		f = EightPoint(EightPoint1, EightPoint2);

		--reprojection error
		pfp = MatrixMultiple(transposition(f), points2homo);
		pfp = DotProduct(pfp, points1homo);
		d[1] = pfp[1];
		for j = 2, 3 do
			d = ArrayAddArray(d, pfp[j]);
		end
		d = DotProduct(d, d);

		--find inliers
		inliers = zeros(1, nPonits);
		for k = 1, nPonits do 
			if (d[1][k] <= threshold) then
				inliers[1][k] = 1;
			end
		end
		nInliers = ArraySum(inliers[1]);

		--MSAC metric
		for l = 1, nPonits do
			if inliers[1][l] == 1 then
				Dist = Dist + d[l];
			end
		end
		Dist = Dist + threshold*(nPonits-nInliers);
		if trails == 1 then
			bestDist = Dist;
		end
		if bestDist > Dist then
			bestDist = Dist;
			bestInliers = inliers;
		end
	end
	for i = 1, #bestInliers[1] do
			EightPoint1[1][i] = points1homo[1][bestInliers[1][i]];
			EightPoint1[2][i] = points1homo[2][bestInliers[1][i]];
			EightPoint1[3][i] = points1homo[3][bestInliers[1][i]];
			EightPoint2[1][i] = points2homo[1][bestInliers[1][i]];
			EightPoint2[2][i] = points2homo[2][bestInliers[1][i]];
			EightPoint2[3][i] = points2homo[3][bestInliers[1][i]];
	end 
	f = EightPoint(EightPoint1, EightPoint2);
	return f, bestInliers[1];
end
local MSAC = SFM.MSAC;

function SFM.MotionFromF( F, intrinsic, inliers1, inlires2 )
	local E = MatrixMultiple(MatrixMultiple(intrinsic, F), transposition(intrinsic));
	--decompose E
	local U, D, V = DO_SVD(E);
	local e = (D[1][1] + D[2][2])/2;
	D[1][1] = e;
	D[2][2] = e;
	D[3][3] = 0;
	E = MatrixMultiple(MatrixMultiple(U, D), transposition(V));
	local U, D1, V = DO_SVD(E);
	local W = {{0, -1, 0}, {1, 0, 0}, {0, 0, 1}};
	local Z = {{0, 1, 0}, {-1, 0, 0}, {0, 0 ,0}};
	local R1 = MatrixMultiple(MatrixMultiple(U, W), transposition(V));
	local R2 = MatrixMultiple(MatrixMultiple(U, transposition(W)), transposition(V));
	if det(R1) < 0 then
		R1 = ArrayMult(R1, -1);
	end
	if det(R2) < 0 then
		R2 = ArrayMult(R2, -1);
	end
	local Tx = MatrixMultiple(MatrixMultiple(U, Z), transposition(U));
	local t = {{-Tx[3][2], - Tx[1][3], -Tx[2][1]}};
	local R = transposition(R1);

	--choose solution
	local negs = zeros(1, 4);
	local nInliers = #inliers1;
	local camMat0 = transposition(MatrixMultiple({{1, 0, 0},{0, 1, 0},{0, 0, 1},{0, 0, 0}}, intrinsic);
	local M1 = submatrix(camMat0, 1, 3, 1, 3);
	local c1 = ArrayMult(MatrixMultiple(inv(M1), submatrix(camMat0, 1, #camMat0, 4,4)), -1);
	local camMatl, M2, c2, a1, a2, A, alpha, p, m1, m2;
	local Matrix_one = {{1}};
	for i = 1, 4 do
		if i > 2 then
			R = transposition(R2);
		end
		t = ArrayMult(t, -1);
		camMatl = transposition(MatrixMultiple(connect(R, t), intrinsic));
		M2 = submatrix(camMatl, 1, 3, 1, 3);
		c2 = ArrayMult(MatrixMultiple(inv(M2), submatrix(camMatl, 1, #camMatl, 4,4)), -1);
		for j = nInliers do
			a1 = MatrixMultiple(inv(M1), transposition(connect(inliers1[j], Matrix_one)));
			a2 = MatrixMultiple(inv(M2), transposition(connect(inliers2[j], Matrix_one)));
			A = connect(a1, ArrayMult(a2));
			alpha = MatrixMultiple(MatrixMultiple(inv(MatrixMultiple(transposition(A), A)), transposition(A)), ArrayAddArray(c2, ArrayMult(c1, -1)));
			p = ArrayMult(ArrayAddArray(ArrayAddArray(c1, ArrayMult(a1, alpha[1][1])), ArrayAddArray(c2, ArrayMult(a2, alpha[2][1]))), 0.5);
			m1[j] = transposition(p);
		end
		m2 = ArrayAddArray(MatrixMultiple(m1, R), t);
		for k = 1, #m1 do
			if (m1[k][3] < 0) or (m2[k][3] < 0) then
				negs[1][i] = negs[1][i] + 1;
			end
		end
	end
	local idx = 1;
	while(negs[1][count] ~= FindMin2(negs)) do
		idx = idx + 1;
	end
	if idx < 3 then
		R = transposition(R1);
	end
	if (idx == 1 or idx == 3) then
		t = ArrayMult(t, -1);
	end
	t = ArrayMult(t, 1/norm(t));

	local location = MatrixMultiple(ArrayMult(t, -1), transposition(R));
	return R, location;
end
local MotionFromF = SFm.MotionFromF;

function SFM.DO_SFM( I1, I2, parameter )
	
	--Match features
	local mp1, mp2 = MatchFeaturePoints(I1, I2);

	-- Estimate F R t  
	local F, inliersIdx = MSAC(mp1, mp2);
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

	local R, t = MotionFromF(F, intrinsic, inlierPoints1, inlierPoints2);
	local camMat0 = MatrixMultiple(connect(eye(3), {{0, 0, 0}}), intrinsic);
	local camMatl = MatrixMultiple(connect(R, MatrixMultiple(ArrayMult(t, -1), R)), intrinsic);

	--dense match
	mp1, mp2 = MatchFeaturePoints(img0, img1);
	




end