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

-- Resize the image to its half
function SIFT.HalfSize( array )
	local h = #array;
	local w = #array[1];
	local self = zeros(math.ceil(h/2),math.ceil(w/2));
	for i = 1, h, 2 do
		for j = 1, w, 2 do
			self[(i + 1)/ 2][(j + 1)/ 2] = array[i][j];
		end
	end
	return self;
end
local HalfSize = SIFT.HalfSize;
-- a = {{1,2,3,4,5},{1,2,3,4,5},{1,2,3,4,5},{1,2,3,4,5}};
-- b = HalfSize(a);
-- ArrayShow(b)

-- Resize the image to its double 
function SIFT.DoubleSize( array )
	local h = #array;
	local w = #array[1];
	local self = zeros(2*h,2*w);
	for i = 1, h do
		for j = 1, w do
			self[2*i-1][2*j-1] = array[i][j]
		end
	end
	for i = 1, h-1 do
		for j = 1, w-1 do
			self[2*i][2*j] = 0.25*(array[i][j] + 
				array[i][j+1]+array[i+1][j]+array[i+1][j+1]);
			self[2*i-1][2*j] = 0.5*(array[i][j]+array[i][j+1]);
			self[2*i][2*j-1] = 0.5*(array[i][j]+array[i+1][j]);
		end
	end
	for i = 1, 2*h-1 do
		if math.fmod(i, 2)==0 then
		    self[i][2*w-1] = 0.5*(self[i-1][2*w-1]+self[i+1][2*w-1]);
		end
		self[i][2*w] = self[i][2*w-1];
	end
	for i = 1, 2*w-1 do
		if math.fmod(i, 2)==0 then
		    self[2*h-1][i] = 0.5*(self[2*h-1][i-1]+self[2*h-1][i+1]);
		end
		self[2*h][i] = self[2*h-1][i];
	end
	self[2*h][2*w] = self[2*h-1][2*w-1];
	return self
end
local DoubleSize = SIFT.DoubleSize;
-- a = {{1,2,3,4,5},{5,4,6,2,1},{1,2,3,4,5},{5,4,3,2,1}};
-- b=DoubleSize(a);
-- ArrayShow(a)
-- ArrayShow(b)





function SIFT.gaussian(I, O, S, omin, smin, smax)
	if omin<0 then
		for o=1, -omin do
			I=DoubleSize(I);
		end
	elseif omin>0 then
		for o=1, -omin do
			I=HalfSize(I);
		end
	end
	local M = #I;
	local N = #I;
	local k = 2^(1/S);
	local sigma0 = 1.6*k;
	local dsigma0 = sigma0*(1-1/k^2)^0.5;
	local sigmaN = 0.5;
	local so = -smin+1;

	--Scale space structure 
	local L={};
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
	L.octave[1] = zeros3(smax-smin+1, M, N);

	--Initilize the first sub-level
	local sig = ((sigma0*k^smin)^2-(sigmaN/2^omin)^2)^0.5;
	L.octave[1][1] = GaussianF(I, sig);
	for s = smin+1, smax do
		local dsigma = k^s*dsigma0;
		L.octave[1][s+so] = GaussianF(L.octave[1][s+so],dsigma);
	end

	------------------------------
	--Folowing Octaves
	------------------------------
	for o = 2, O do
		local sbest = min(smin+S, smax);
		local TMP = HalfSize(L.octave[o-1][sbest+so]);
		local sigma_next = sigma0*k^smin;
		local sigma_prev = sigma0*k^(sbest-S);

		if sigma_next>sigma_prev then
			sig = (sigma_next^2-sigma_prev^2)^0.5;
			TMP = GaussianF(TMP, sig);
		end

		local M = #TMP;
		local N = #TMP[1];
		L.octave[o] = zeros3(smax-smin+1, M, N);
		L.octave[o][1] = TMP;

		for s = smin+1, smax do
			local dsigma = k^s*dsigma0;
			L.octave[o][s+so] = GaussianF(L.octave[o][s+so-1],dsigma0);
		end
	end
	return L;
end
local gaussian = SIFT.gaussian;

-- Substraction of consecutive levels of the scale space SS.
function SIFT.diffofg(L)
	local D={};
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

		for s= 1, S-1 do
			D.octave[o][s] = ArrayAddArray(L.octave[o][s+1],ArrayMutl(L.octave[o][s],-1));
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
	local J={{},{},{}};
	for s= 2, S-1 do
		for j = 12, M-12 do
			for i = 12, N-12 do
				local a = octave[s][i][j];
				if ((a>thresh + k and
					a>octave[s-1][i-1][j-1]+k and a>octave[s-1][i-1][j]+k and
					a>octave[s-1][i-1][j+1]+k and a>octave[s-1][i][j-1]+k and
					a>octave[s-1][i][j+1]+k and a>octave[s-1][i+1][j-1]+k and 
					a>octave[s-1][i+1][j]+k and a>octave[s-1][i+1][j+1]+k and 
                    a>octave[s][i-1][j-1]+k and a>octave[s][i-1][j]+k and
					a>octave[s][i-1][j+1]+k and a>octave[s][i][j-1]+k and
					a>octave[s][i][j+1]+k and a>octave[s][i+1][j-1]+k and 
					a>octave[s][i+1][j]+k and a>octave[s][i+1][j+1]+k and 
					a>octave[s+1][i-1][j-1]+k and a>octave[s+1][i-1][j]+k and
					a>octave[s+1][i-1][j+1]+k and a>octave[s+1][i][j-1]+k and
					a>octave[s+1][i][j+1]+k and a>octave[s+1][i+1][j-1]+k and 
					a>octave[s+1][i+1][j]+k and a>octave[s+1][i+1][j+1]+k and 
					a>octave[s-1][i][j]+k and a>octave[s+1][i][j]+k) or
                   (a<thresh +k and 
				    a<octave[s-1][i-1][j-1]-k and a<octave[s-1][i-1][j]-k and
					a<octave[s-1][i-1][j+1]-k and a<octave[s-1][i][j-1]-k and
					a<octave[s-1][i][j+1]-k and a<octave[s-1][i+1][j-1]-k and 
					a<octave[s-1][i+1][j]-k and a<octave[s-1][i+1][j+1]-k and 
                    a<octave[s][i-1][j-1]-k and a<octave[s][i-1][j]-k and
					a<octave[s][i-1][j+1]-k and a<octave[s][i][j-1]-k and
					a<octave[s][i][j+1]-k and a<octave[s][i+1][j-1]-k and 
					a<octave[s][i+1][j]-k and a<octave[s][i+1][j+1]-k and 
					a<octave[s+1][i-1][j-1]-k and a<octave[s+1][i-1][j]-k and
					a<octave[s+1][i-1][j+1]-k and a<octave[s+1][i][j-1]-k and
					a<octave[s+1][i][j+1]-k and a<octave[s+1][i+1][j-1]-k and 
					a<octave[s+1][i+1][j]-k and a<octave[s+1][i+1][j+1]-k and 
					a<octave[s-1][i][j]-k and a<octave[s+1][i][j]-k)) then
				J[1][nb] = j-1;
				J[2][nb] = i-1;
				J[3][nb] = s+smin-1;
				local nb = nb+1; 
			    end
			end
		end
	end
	return J;
end
local localmax = SIFT.localmax;


-- The SIFT algorithm
function SIFT.SIFT(I, O, S)
	local S = 3;
	local omin = 0;
	local O = 4;
	local sigma0 = 1.6*2^(1/S);
	local sigman = 0.5;
	local thresh = 0.1/S; --0.01/S;
	local r = 18;
	local NBP = 4;
	local NBO = 8;
	local magnif = 3;
	local frames = {};
	local descriptors = {};

    LOG.std("---------- Extract SIFT features from an image ----------");
    LOG.std("SIFT: constructing scale space with DoG ..."); 

	local scalespace = gaussian(I, O, S, omin, -1, S+1);
	local difofg = diffofg(scalespace);

	for o = 1, scalespace.O do
	    LOG.std("SIFT: computing octave: ",o-1+omin);
		oframes = localmax(difofg.octave[o], 0.8*thresh, difofg.smin);
        
           LOG.std("SIFT: initial keypoints: ",#oframes[1]);
        

	end


end
