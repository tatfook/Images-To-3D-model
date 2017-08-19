--[[
Title: Singular value decomposition
Author(s): BerryZSZ
Date: 2017/8/17
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/ImagesTo3Dmodel/SVD.lua");
------------------------------------------------------------
------------------------------------------------------------

------------------------------------------------------------
]]
NPL.load("(gl)Mod/ImagesTo3Dmodel/imP.lua");

local SVD = commonlib.getttable("SVD");

------------------------------------------------------------
local zeros = imP.tensor.zeros;
local norm = imP.tensor.norm;
local transposition = imP.tensor.transposition;
local MatrixMultiple = imP.tensor.MatrixMultiple;
local ArraySum = imP.tensor.ArraySum;
local DotProduct = imP.tensor.DotProduct;
local eye = imP.tensor.eye;
local sign = imP.tensor.sign;
local submatrix = imP.tensor.submatrix;
local ArrayMult = imP.tensor.ArrayMult;
local ArrayAddArray = imP.tensor.ArrayAddArray;

------------------------------------------------------------
--@para: QR decomposition algorithm by Gram-Schmidt method
function SVD.QRDecompositionSch( A )
	local m = #A;
	local n = #A[1];
	if m ~= n then
		LOG.str(nil,"warn","SVD","unexpect input Array");
	end
	local Q = zeros(m, n);
	local R = zeros(n, n);
	local Qk = {};
	local transA = zeros(n,m);
	for k = 1, n do
		transA = transposition(A);
		R[k][k] = norm(transA[k]);
		if R[k][k] ~= 0 then
			for i = 1, m do
				Q[i][k] = A[i][k] / R[k][k];
				Qk[i] = Q[i][k];
			end
			for j = k+1, n do
				R[k][j] = ArraySum(DotProduct(Qk,transA[j]));
				for i = 1, m do 
					A[i][j] = A[i][j] - R[k][j]*Q[i][k];
				end
			end
		end
	end
	return Q, R;
end

--@para: QR decomposition algorithm by Householder method
function SVD.QRDecompositionHouse( A )
		local m = #A;
	local n = #A[1];
	local E = eye(n);
	local R = zeros(n, n);
	local P1 = eye(n);
	local s, w, P;
	for k = 1, n-1 do 
		s = -sign(A[k][k])*norm(submatrix(A,k,n,k,k));
		R[k][k] = -s;
		if k == 1 then
			w = transposition(submatrix(A,2,n,k,k));
			table.insert(w[1],1,A[1][1]+s);
		else
			w = transposition(submatrix(A,k+1,n,k,k));
			table.insert(w[1],1,A[k][k]+s);
			for i = 1, k-1 do
				table.insert(w[1],1,0);
				R[i][k] = A[i][k]
			end
		end
		if norm(w) ~= 0 then
			w = ArrayMult(w,1/norm(w));
		end
		P = ArrayAddArray(E, ArrayMult(MatrixMultiple(transposition(w),w), -2));
		A = MatrixMultiple(P, A);
		P1 = MatrixMultiple(P, P1);
		for j = 1, n do 
			R[j][n] = A[j][n];
		end
	end
	Q = transposition(P1);
	return Q, R;
end
local QRDecompositionHouse = SVD.QRDecompositionHouse;

function SVD.DO_SVD( A )
	local loopmax = math.max(#A, #A[1]);
	local loopcount = 0;
	local U = eye(#A);
	local S = transposition(A);
	local V = eye(#A[1]);
	local Q, e;
	while loopcount < loopmax do
		Q, S = QRDecompositionHouse(transposition(S));
		U = MatrixMultiple(U, Q);
		Q, S = QRDecompositionHouse(transposition(S));
		V = MatrixMultiple(V, Q);
		e = 

end