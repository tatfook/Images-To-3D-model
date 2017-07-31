--[[
Title: SIFT
Author(s): BerryZSZ
Date: 2017/7/21
Desc: 
use the lib:
------------------------------------------------------------

------------------------------------------------------------
------------------------------------------------------------
local HalfSize = SIFT.HalfSize;
local DoubleSize = SIFT.DoubleSize;
local gaussian = SIFT.gaussian;
local diffofg = SIFT.diffofg;
local localmax = SIFT.localmax;
local extrafine = SIFT.extrafine;
local orientation = SIFT.orientation;
local descriptor = SIFT.descriptor;
local DO_SIFT = SIFT.DO_SIFT;

------------------------------------------------------------
]]

NPL.load("(gl)Mod/ImagesTo3Dmodel/imP.lua");
local SIFT = commonlib.gettable("SIFT");


local zeros = imP.tensor.zeros;
local zeros3 = imP.tensor.zeros3;
local Round = imP.Round;
local imread2Grey = imP.imread2Grey;
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

----------------------------------------------------
local ceil = math.ceil;
local fmod = math.fmod;
local abs = math.abs;
local sqrt = math.sqrt;
local mod = math.mod;
local atan = math.atan;
local pi = math.pi;
local floor = math.floor;
local max = math.max;
local min = math.min;
local exp = math.exp;
local sin = math.sin;
local cos = math.cos;
local acos = math.acos;
-----------------------------------------------------
-- Resize the image to its half
function SIFT.HalfSize(array)
	local h = #array;
	local w = #array[1];
	local self = zeros(ceil(h / 2), ceil(w / 2));
	for i = 1, h, 2 do
		for j = 1, w, 2 do
			self[(i + 1) / 2][(j + 1) / 2] = array[i][j];
		end
	end
	return self;
end
local HalfSize = SIFT.HalfSize;
-- a = {{1,2,3,4,5},{1,2,3,4,5},{1,2,3,4,5},{1,2,3,4,5}};
-- b = HalfSize(a);
-- ArrayShow(b)

-- Resize the image to its double 
function SIFT.DoubleSize(array)
	local h = #array;
	local w = #array[1];
	local self = zeros(2 * h, 2 * w);
	for i = 1, h do
		for j = 1, w do
			self[2 * i-1][2 * j-1] = array[i][j]
		end
	end
	for i = 1, h-1 do
		for j = 1, w-1 do
			self[2 * i][2 * j] = 0.25 * (array[i][j] + 
			array[i][j + 1] + array[i + 1][j] + array[i + 1][j + 1]);
			self[2 * i-1][2 * j] = 0.5 * (array[i][j] + array[i][j + 1]);
			self[2 * i][2 * j-1] = 0.5 * (array[i][j] + array[i + 1][j]);
		end
	end
	for i = 1, 2 * h-1 do
		if fmod(i, 2)==0 then
			self[i][2 * w-1] = 0.5 * (self[i-1][2 * w-1] + self[i + 1][2 * w-1]);
		end
		self[i][2 * w] = self[i][2 * w-1];
	end
	for i = 1, 2 * w-1 do
		if fmod(i, 2)==0 then
			self[2 * h-1][i] = 0.5 * (self[2 * h-1][i-1] + self[2 * h-1][i + 1]);
		end
		self[2 * h][i] = self[2 * h-1][i];
	end
	self[2 * h][2 * w] = self[2 * h-1][2 * w-1];
	return self
end
local DoubleSize = SIFT.DoubleSize;
-- a = {{1,2,3,4,5},{5,4,6,2,1},{1,2,3,4,5},{5,4,3,2,1}};
-- b=DoubleSize(a);
-- ArrayShow(a)
-- ArrayShow(b)

function SIFT.gaussian(I, O, S, omin, smin, smax)
	if omin<0 then
		for o = 1, -omin do
			I = DoubleSize(I);
		end
	elseif omin>0 then
		for o = 1, -omin do
			I = HalfSize(I);
		end
	end
	local M = #I;
	local N = #I;
	local k = 2^(1 / S);
	local sigma0 = 1.6 * k;
	local dsigma0 = sigma0 * (1 - 1 / k^2)^0.5;
	local sigmaN = 0.5;
	local so = -smin + 1;

	--Scale space structure 
	local L = {};
	L.O = O;
	L.S = S;
	L.sigma0 = sigma0;
	L.omin = omin;
	L.smin = smin;
	L.smax = smax;

	-----------------------------
	-- First Octave
	-----------------------------

	--Initilize the octave with S sub-levels 
	L.octave = {};
	L.octave[1] = zeros3(smax-smin + 1, M, N);

	--Initilize the first sub-level
	local sig =((sigma0 * k^smin)^2 - (sigmaN / 2^omin)^2)^0.5;
	L.octave[1][1] = GaussianF(I, sig);
	for s = smin + 1, smax do
		local dsigma = k^s * dsigma0;
		L.octave[1][s + so] = GaussianF(L.octave[1][s + so], dsigma);
	end

	------------------------------
	--Folowing Octaves
	------------------------------
	for o = 2, O do
		local sbest = min(smin + S, smax);
		local TMP = HalfSize(L.octave[o-1][sbest + so]);
		local sigma_next = sigma0 * k^smin;
		local sigma_prev = sigma0 * k^(sbest-S);

		if sigma_next>sigma_prev then
			sig =(sigma_next^2 - sigma_prev^2)^0.5;
			TMP = GaussianF(TMP, sig);
		end

		local M = #TMP;
		local N = #TMP[1];
		L.octave[o] = zeros3(smax-smin + 1, M, N);
		L.octave[o][1] = TMP;

		for s = smin + 1, smax do
			local dsigma = k^s * dsigma0;
			L.octave[o][s + so] = GaussianF(L.octave[o][s + so-1], dsigma0);
		end
	end
	return L;
end
local gaussian = SIFT.gaussian;

-- Substraction of consecutive levels of the scale space SS.
function SIFT.diffofg(L)
	local D = {};
	D.smin = L.smin;
	D.smax = L.smax-1;
	D.omin = L.omin;
	D.O = L.O;
	D.S = L.S;
	D.sigma0 = L.sigma0;

	for o = 1, D.O do
		local S = #L.octave[o];
		local M = #L.octave[o][1];
		local N = #L.octave[o][1][1];
		D.octave = {};
		D.octave[o] = zeros3(S-1, M, N);

		for s = 1, S-1 do
			D.octave[o][s] = ArrayAddArray(L.octave[o][s + 1], ArrayMutl(L.octave[o][s], -1));
		end
	end
	return D;
end
local diffofg = SIFT.diffofg;

-- Returns the indexes of the local maximizers of the octave.
function SIFT.localmax(octave, thresh, smin)
	local S = #octave;
	local N = #octave[1];
	local M = #octave[1][1];
	local nb = 1;
	local k = 0.0002;
	local J = {{}, {}, {}};
	for s = 2, S-1 do
		for j = 20, M-20 do
			for i = 12, N-12 do
				local a = octave[s][i][j];
				if((a>thresh + k and
				a>octave[s-1][i-1][j-1] + k and a>octave[s-1][i-1][j] + k and
				a>octave[s-1][i-1][j + 1] + k and a>octave[s-1][i][j-1] + k and
				a>octave[s-1][i][j + 1] + k and a>octave[s-1][i + 1][j-1] + k and 
				a>octave[s-1][i + 1][j] + k and a>octave[s-1][i + 1][j + 1] + k and 
				a>octave[s][i-1][j-1] + k and a>octave[s][i-1][j] + k and
				a>octave[s][i-1][j + 1] + k and a>octave[s][i][j-1] + k and
				a>octave[s][i][j + 1] + k and a>octave[s][i + 1][j-1] + k and 
				a>octave[s][i + 1][j] + k and a>octave[s][i + 1][j + 1] + k and 
				a>octave[s + 1][i-1][j-1] + k and a>octave[s + 1][i-1][j] + k and
				a>octave[s + 1][i-1][j + 1] + k and a>octave[s + 1][i][j-1] + k and
				a>octave[s + 1][i][j + 1] + k and a>octave[s + 1][i + 1][j-1] + k and 
				a>octave[s + 1][i + 1][j] + k and a>octave[s + 1][i + 1][j + 1] + k and 
				a>octave[s-1][i][j] + k and a>octave[s + 1][i][j] + k) or
				(a<thresh + k and 
				a<octave[s-1][i-1][j-1]-k and a<octave[s-1][i-1][j]-k and
				a<octave[s-1][i-1][j + 1]-k and a<octave[s-1][i][j-1]-k and
				a<octave[s-1][i][j + 1]-k and a<octave[s-1][i + 1][j-1]-k and 
				a<octave[s-1][i + 1][j]-k and a<octave[s-1][i + 1][j + 1]-k and 
				a<octave[s][i-1][j-1]-k and a<octave[s][i-1][j]-k and
				a<octave[s][i-1][j + 1]-k and a<octave[s][i][j-1]-k and
				a<octave[s][i][j + 1]-k and a<octave[s][i + 1][j-1]-k and 
				a<octave[s][i + 1][j]-k and a<octave[s][i + 1][j + 1]-k and 
				a<octave[s + 1][i-1][j-1]-k and a<octave[s + 1][i-1][j]-k and
				a<octave[s + 1][i-1][j + 1]-k and a<octave[s + 1][i][j-1]-k and
				a<octave[s + 1][i][j + 1]-k and a<octave[s + 1][i + 1][j-1]-k and 
				a<octave[s + 1][i + 1][j]-k and a<octave[s + 1][i + 1][j + 1]-k and 
				a<octave[s-1][i][j]-k and a<octave[s + 1][i][j]-k)) then
					J[1][nb] = j-1;
					J[2][nb] = i-1;
					J[3][nb] = s + smin-1;
					local nb = nb + 1; 
				end
			end
		end
	end
	return J;
end
local localmax = SIFT.localmax;

-- Refine the location, threshold strength and remove points on edges
function SIFT.extrafine(oframes, octave, smin, thresh, r)
	local S = #octave;
	local M = #octave[1];
	local N = #octave[1][1];
	local L = #oframes;
	local K = #oframes[1];
	local comp = 1;
	local J = {{}, {}, {}};
	for p = 1, K do
		local b = zeros(1, 3);
		local x = oframes[1][p] + 1;
		local y = oframes[2][p] + 1;
		local s = oframes[3][p] + 1 - smin;
		local val = octave[s][x][y];
		local Dx = 0;
		local Dy = 0;
		local Ds = 0;
		local Dxx = 0;
		local Dyy = 0;
		local Dss = 0;
		local Dxy = 0;
		local Dxs = 0;
		local Dys = 0;
		local dx = 0;
		local dy = 0;
		local A = {{}, {}, {}};
		local b = {};
		local c = {};

		for i = 1, 5 do
			x = x + dx;
			y = y + dy;
			-- Compute the gridient
			Dx = 0.5 * (octave[s][y][x + 1]-octave[s][y][x-1]);
			Dy = 0.5 * (octave[s][y + 1][x]-octave[s][y-1][x]);
			Ds = 0.5 * (octave[s + 1][y][x]-octave[s-1][y][x]);
			-- Compute the Hessian
			Dxx = octave[s][y][x + 1] + octave[s][y][x-1]-2 * octave[s][y][x];
			Dyy = octave[s][y + 1][x] + octave[s][y-1][x]-2 * octave[s][y][x];
			Dss = octave[s + 1][y][x] + octave[s-1][y][x]-2 * octave[s][y][x];

			Dys = 0.25 * (octave[s + 1][y + 1][x] + octave[s-1][y-1][x]-octave[s + 1][y-1][x]-octave[s-1][y + 1][x]);
			Dxy = 0.25 * (octave[s][y + 1][x + 1] + octave[s][y-1][x-1]-octave[s][y-1][x + 1]-octave[s][y + 1][x-1]);
			Dxs = 0.25 * (octave[s + 1][y][x + 1] + octave[s-1][y][x-1]-octave[s-1][y][x + 1]-octave[s + 1][y][x-1]);

			A = {{Dxx, Dxy, Dxs}, {Dxy, Dyy, Dys}, {Dxs, Dys, Dss}};
			b = {{-Dx, -Dy, -Ds}};
			c = MatrixMultiple(b, inv(A));
			-- If the translation of the keypoint is big, 
			-- move the keypoint and re-interrate the computation.
			-- Otherwise we are all set.
			if(c[1][1] > 0.6 and x < N-2) then
				if(c[1][1] < -0.6 and x > 1) then
					dx = 0;
				else
					dx = 1;
				end
			else
				if(c[1][1] < 0.6 and x > 1) then
					dx = -1;
				else
					dx = 0;
				end
			end

			if(c[1][2] > 0.6 and y < N-2) then
				if(c[1][2] < -0.6 and y > 1) then
					dy = 0;
				else
					dy = 1;
				end
			else
				if(c[1][2] < -0.6 and y > 1) then
					dy = -1;
				else
					dy = 0;
				end
			end

			if(dx == 0 and dy == 0) then
				break;
			end
		end
		val = val + 0.5 * (Dx * c[1][1] + Dy * c[1][2] + Ds * c[1][3]);
		local score =(Dxx + Dyy) * (Dxx + Dyy) / (Dxx * Dyy-Dxy * Dxy);
		local xn = x + c[1][1];
		local yn = y + c[1][2];
		local sn = s + c[1][2];

		if(abs(val) > thresh and score >=(r + 1) * (r + 1) / r and
		score >= 0 and abs(c[1][1]) < 1.5 and abs(c[1][2]) < 1.5 and
		c[1][3] < 1.5 and xn >= 0 and xn < M-1 and yn >=0 and
		yn <= N-1 and sn >= 0 and sn <= S-1) then
			J[1][comp] = xn-1;
			J[2][comp] = yn-1;
			J[3][comp] = sn-1 + smin;
			comp = comp + 1;
		end
	end
	return J;
end
local extrafine = SIFT.extrafine;

--[[This function computes the major orientation of the keypoint (oframes).
Note that there can be multiple major orientation. In that case, the 
SIFT kes will be duplicated for each major orientation]]
function SIFT.orientation(oframes, octave, S, smin, sigma0)
	local frames = {{}, {}, {}, {}};
	local win_factor = 1.5;
	local NBINS = 36;
	local histo = zeros(1, NBINS);
	local s_num = #octave;
	local M = #octave[1];
	local N = #octave[1][1];
	local key_num = #oframes[1];
	local magnitudes = zeros3(s_num, M, N);
	local angles = zeros3(s_num, M, N);
	local dx_filter = {{-0.5, 0, 0.5}};
	local dy_filter = {{-0.5}, {0}, {0.5}};
	-- Compute image gradients
	for si = 1, s_num do
		local img = octave[si];
		local gradient_x = conv2(img, dx_filter);
		local gradient_y = conv2(img, dy_filter);
		for i = 1, M do 
			for j = 1, N do 
				magnitudes[si][i][j] = sqrt(gradient_x[i][j]^2 + gradient_y[i][j]^2);
				angles[si][i][j] = mod(atan(gradient_y / gradient_x) + 2 * pi, 2 * pi);
			end
		end
	end
	local x = oframes[1];
	local y = oframes[2];
	local s = oframes[3];
	local x_round = {};
	local y_round = {};
	local scales = {};
	for i = 1, key_num do
		x_round[i] = floor(oframes[1][i] + 0.5);
		y_round[i] = floor(oframes[2][i] + 0.5);
		scales[i] = floor(oframes[3][i] + 0.5)-smin;
	end
	for p = 1, key_num do
		local sp = scales[p];
		local xp = x_round[p];
		local yp = y_round[p];
		local sigmaw = win_factor * sigma0 * (2^(sp / S));
		local W = floor(3 * sigmaw);
		for xs = xp - max(W, xp-1), min((N-2),(xp + W)) do
			for ys = yp - max(W, yp-1), min((M-2), yp + W) do
				local dx = xs - x[p];
				local dy = ys - y[p];
				if dx^2 + dy^2 <= W^2 then 
					local wincoef = exp(-(dx^2 + dy^2) / (2 * sigmaw^2));
					local bin = ceil(NBINS * angles(s + 1, ys, xs) / (2 * pi));
					histo[1][bin] = histo[1][bin] + wincoef * magnitudes(s + 1, ys, xs);
				end
			end
		end 
		local theta_max = table.maxn(histo[1]);
		local theta_indx = {};
		local theta_indx_count = 0;
		for i = 1, 36 do
			if histo[1][i] > 0.8 * theta_max then
				theta_indx_count = theta_indx_count + 1;
				theta_indx[theta_indx_count] = histo[1][i];
			end
		end
		for i = 1, #theta_indx do
			local theta = 2 * pi * theta_indx[i] / NBINS;
			table.insert(frames[1], x[p]);
			table.insert(frames[2], y[p]);
			table.insert(frames[3], sp);
			table.insert(frames[4], theta);
		end
	end
	return frames;
end
local orientation = SIFT.orientation;

-- The SIFT descriptor
function SIFT.descriptor(octave, oframes, sigma0, S, smin, magnif, NBP, NBO)
	local key_num = #oframes[1];
	local s_num = #octave;
	local M = #octave[1];
	local N = #octave[1][1];
	local descriptors = {};
	local magnitudes = zeros3(s_num, M, N);
	local angles = zeros3(s_num, M, N);
	local dx_filter = {{-0.5, 0, 0.5}};
	local dy_filter = {{-0.5}, {0}, {0.5}};
	-- Compute image gradients
	for si = 1, s_num do
		local img = octave[si];
		local gradient_x = conv2(img, dx_filter);
		local gradient_y = conv2(img, dy_filter);
		for i = 1, M do 
			for j = 1, N do 
				magnitudes[si][i][j] = sqrt(gradient_x[i][j]^2 + gradient_y[i][j]^2);
				angles[si][i][j] = mod(atan(gradient_y / gradient_x) + 2 * pi, 2 * pi);
			end
		end
	end
	local x = oframes[1];
	local y = oframes[2];
	local s = oframes[3];
	local x_round = {};
	local y_round = {};
	local scales = {};
	for i = 1, key_num do
		x_round[i] = floor(oframes[1][i] + 0.5);
		y_round[i] = floor(oframes[2][i] + 0.5);
		scales[i] = floor(oframes[3][i] + 0.5)-smin;
	end
	for p = 1, key_num do
		local sp = scales[p];
		local xp = x_round[p];
		local yp = y_round[p];
		local theta0 = oframes[4][p];
		local sinth0 = sin(theta0);
		local costh0 = cos(theta0);
		local sigma = sigma0 * 2^(sp / S);
		local SBP = magnif * sigma;
		local W = floor(0.8 * SBP * (NBP + 1) / 2 + 0.5);
		local descriptor = zeros3(NBP, NBP, NBO);
		for dxi = max(-W, 1 - xp), min(W, N-2 - xp) do
			for dyi = max(-W, 1 - yp), min(W, M-2 - yp) do
				local mag = magnitudes(sp, yp + dyi, xp + dxi);
				local angle0 = angles(sp, yp + dyi, xp + dyi);
				local angle = mod(theta0-angle0, 2 * pi);
				local dx = xp + dxi-x[p];
				local dy = yp + dyi-y[p];
				local nx =(costh0 * dx + sinth0 * dy) / SBP;
				local ny =(costh0 * dy-sinth0 * dx) / SBP;
				local nt = NBO * angle / (2 * pi);
				local wsigma = NBP / 2;
				local wincoef = exp(-(nx * nx + ny * ny) / (2 * wsigma * wsigma));
				local binx = floor(nx-0.5);
				local biny = floor(ny-0.5);
				local bint = floor(nt);
				local rbinx = nx-(binx + 0.5);
				local rbiny = ny-(biny + 0.5);
				local rbint = nt-bint;
				for dbinx = 0, 1 do
					for dbiny = 0, 1 do
						for dbint = 0, 1 do
							if((binx + dbinx >= -wsigma) and 
							(binx + dbinx < wsigma) and
							(biny + dbiny >= -wsigma) and
							(biny + dbiny < wsigma)) then
								local weight =(wincoef * mag * abs(1 - dbinx-rbinx)*
								abs(1 - dbiny-rbiny) * abs(1 - dbint-rbint));
								descriptor[binx + dbinx + wsigma + 1][biny + dbiny + wsigma + 1][mod((bint + dbint), NBO) + 1] = (
								descriptor[binx + dbinx + wsigma + 1][biny + dbiny + wsigma + 1][mod((bint + dbint), NBO) + 1] + weight);
							end
						end
					end
				end
			end
		end
		local descriptor0 = zeros(NBP * NBP * NBO, 1);
		for i = 1, NBP * NBP * NBO do
			local descriptor0_x = mod(mod(i, NBO), NBP);
			local descriptor0_y = ceil(mod(i, NBO) / NBP);
			local descriptor0_s = ceil(i / NBO);
			descriptor0[i][1] = descriptor[descriptor0_x][descriptor0_y][descriptor0_s];
			descriptor0Norm = descriptor0Norm +(descriptor0[i])^2
		end
		descriptor0Norm = sqrt(descriptor0Norm);
		descriptor0 = ArrayMutl(descriptor0, descriptor0Norm);
		if p==1 then
			descriptors = descriptor0;
		elseif p>1 then
			descriptors = connect(descriptors, descriptor0);
		end
	end
	return descriptors;
end
local descriptor = SIFT.descriptor;

-- The SIFT algorithm
function SIFT.DO_SIFT(I, O, S)
	local S = 3;
	local omin = 0;
	local O = 4;
	local sigma0 = 1.6 * 2^(1 / S);
	local sigman = 0.5;
	local thresh = 0.1 / S; --0.01/S;
	local r = 18;
	local NBP = 4;
	local NBO = 8;
	local magnif = 3;
	local frames = {{}, {}, {}, {}};
	local descriptors = {};

	LOG.std("---------- Extract SIFT features from an image ----------");
	LOG.std("SIFT: constructing scale space with DoG ..."); 

	local scalespace = gaussian(I, O, S, omin, -1, S + 1);
	local difofg = diffofg(scalespace);

	for o = 1, scalespace.O do
		LOG.std("SIFT: computing octave: ", o-1 + omin);
		local oframesPrime = localmax(difofg.octave[o], 0.8 * thresh, difofg.smin);
        
		LOG.std("SIFT: initial keypoints: ", #oframesPrime[1]);


        -- Remove pointd too close to the boundary
		local rad = {}; 
		local oframesLength = #oframesPrime[3];
		for i = 1, oframesLength do
			red[i] = magnif * scalespace.sigma0 * (2^(oframesPrime[3][i] / scalespace.S)) * NBP / 2;
		end
		local oframes = {};
		for i = 1, 3 do
			oframes[i] = {};
		end
		local oframesCount = 0;
		for i = 1, oframesLength do
			if((oframesPrime[1][i]-red[i]>=1) and
			(oframesPrime[1][i] + red[i]<=(#scalespace.octave[o][1][1])) and
			(oframesPrime[2][i]-red[i]>=1) and
			(oframesPrime[2][i] + red[i]<=(#scalespace.octave[o][1]))) then
				oframesCount = oframesCount + 1;
				oframes[1][oframesCount] = oframesPrime[1][i];
				oframes[2][oframesCount] = oframesPrime[2][i];
				oframes[3][oframesCount] = oframesPrime[3][i];
			end
		end
		LOG.std("SIFT: keypoints # ", oframesCount, " after discarding from boundary");
      	-- Refine the location, threshold strength and remove points on edges
		local oframesExtrafined = extrafine(oframes, difofg.octave[o], difofg.smin, thresh, r);
		LOG.std("SIFT: keypoints # ", #oframesExtrafined[1], " after discarding from low constrast and edges");
		LOG.std("SIFT: compute orientations of keypoints");
       	-- Computer the orientations
		local oframesOrientation = orientation(oframesExtrafined, scalespace.octave[o], scalespace.S, scalespace.smin, scalespace.sigma0);
       	-- Store frames
		for i = 1, #oframesOrientation[1] do
			frames[1][i] = 2^(o-1 + scalespace.omin) * oframesOrientation[1][i];
			frames[2][i] = 2^(o-1 + scalespace.omin) * oframesOrientation[2][i];
			frames[3][i] = 2^(o-1 + scalespace.omin) * scalespace.sigma0 * 2^(oframesOrientation[3][i] / scalespace.S);
			frames[4][i] = oframesOrientation[4][i];
		end
		LOG.std("SIFT: keypoints # ", #oframesOrientation[1], " after orientation computation");
       	-- Descriptors
		LOG.std("SIFT: computer descriptors...");
		local sh = descriptor(scalespace.octave[o], oframesOrientation, scalespace.sigma0, scalespace.S, scalespace, smin, magnif, NBP, NBO);
		if o == 1 then 
			descriptors = sh;
		elseif o > 1 then
			descriptors = connect(descriptors, sh);
		end
	end
	LOG.std("SIFT: total keypoints: ", #frames[1]);
	return frames, descriptors, scalespace, difofg;
end
local DO_SIFT = SIFT.DO_SIFT;
