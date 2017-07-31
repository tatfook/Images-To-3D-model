--[[
Title: 
Author(s): BerryZSZ
Date: 2017/7/19
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/ImagesTo3Dmodel/imP.lua",true);
local filename = "Mod/ImagesTo3Dmodel/lena.png";
array=imP.imread2Grey(filename);
R=imP.HarrisCD(array)
imP.CreatTXT(R, "D:/University/SOC2017/ParaCraftSDK-master/ParaCraftSDK-master/_mod/ImagesTo3Dmodel/Mod/ImagesTo3Dmodel/harris.txt");
------------------------------------------------------------
------------------------------------------------------------
local zeros = imP.tensor.zeros;
local zeros3 = imP.tensor.zeros3;
local Round = imP.Round;
local imread2Grey = imP.imread2Grey;
local CreatTXT = imP.CreatTXT;
local DotProduct = imP.tensor.DotProduct;
local ArraySum = imP.tensor.ArraySum;
local ArrayShowE = imP.tensor.ArrayShowE;
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

------------------------------------------------------------
]]

local imP = commonlib.gettable("imP");
local imP.tensor = commonlib.inherit(nil, commonlib.gettable("imP.imP.tensor"));


-- Creat the zeros matrix.
function imP.tensor.zeros(height, width)
	local array = {};
	for h = 1, height do
		array[h] = {};
		for w = 1, width do
			array[h][w] = 0;
		end
	end
	return array;	
end
local zeros = imP.tensor.zeros;
-- a=zeros(2,2);

-- Creat the 3D zeros matrix.
function imP.tensor.zeros3(h, w, d)
	local self = {};
	for i = 1, h do
		self[i] = {};
		for j = 1, w do
			self[i][j] = {};
			for k = 1, d do
				self[i][j][k] = 0;
			end
		end
	end
	return self;
end
local zeros3 = imP.tensor.zeros3;


-- Find the nearest integer.
function imP.Round(n)
	if(math.ceil(n)-n) >=(n-math.floor(n)) then
		local t = math.floor(n);
		return(t)
	else
		local c = math.ceil(n);
		return(c)
	end
end
local Round = imP.Round;
--print(Round(9.3));


--Read the image and creat the Grey image.
function imP.imread2Grey(filename)
	local file = ParaIO.open(filename, "image");
	if(file:IsValid()) then
		local ver = file:ReadInt();
		local width = file:ReadInt();
		local height = file:ReadInt();
		-- how many bytes per pixel, usually 1, 3 or 4
		local bytesPerPixel = file:ReadInt();
		-- echo({ver, width = width, height = height, bytesPerPixel = bytesPerPixel})
		local pixel = {};
		local array = zeros(height, width);
		for j = 1, height do
			for i = 1, width do
				pixel = file:ReadBytes(bytesPerPixel, pixel);
				array[j][i] = pixel[1];
				for h = 2, bytesPerPixel do				    
					array[j][i] = array[j][i] + pixel[h];
				end
				array[j][i] = Round(array[j][i] / bytesPerPixel);
				--echo({i, j,array[j][i]});
			end
		end
		return array;
	else
		print("The file is not valid");
	end
end
local imread2Grey = imP.imread2Grey;


-- Creat the txt file of the array.
function imP.CreatTXT(array, filename)	
	local file = io.open(filename, "w");
	local h = #(array);
	if h ~= nil then
		for j = 1, h do
			local w = #(array[j]);
			if w ~= nil then
				for i = 1, w do
					file:write(array[j][i], "\t");
				end
			end
			file:write("\r");
		end
	end
	file:close();
end
local CreatTXT = imP.CreatTXT;



-- Array dot product.
function imP.tensor.DotProduct(array1, array2)
	local h = #(array1);
	local w = #(array1[1]);
	array = zeros(h, w);
	for i = 1, h do
		for j = 1, w do
			array[i][j] = array1[i][j] * array2[i][j];
		end
	end
	return array;
end
local DotProduct = imP.tensor.DotProduct;


-- Here the array is matrix. Sum each elements of the array.
function imP.tensor.ArraySum(array)
	local h = #(array);
	local w = #(array[1]);
	local sum = 0;
	for i = 1, h do
		for j = 1, w do 
			sum = sum + array[i][j];
		end
	end
	return sum;
end
local ArraySum = imP.tensor.ArraySum;
-- array1={{1,2,3},{4,5,6},{7,8,9}};
-- array2={{1,2,3},{4,5,6},{7,8,9}};
-- array=DotProduct(array1,array2);
-- sum=ArraySum(array);
-- print(sum)


-- Show the each element of the array.
function imP.tensor.ArrayShowE(array)
	for i, v in pairs(array) do
		for j, m in pairs(array[i]) do
			print(i, j, m);
		end
	end
end
local ArrayShowE = imP.tensor.ArrayShowE;

-- Show the array.
function imP.tensor.ArrayShow(array)
	for i, v in pairs(array) do
		print(table.concat(v, " "));
	end
end
local ArrayShow = imP.tensor.ArrayShow;

-- Show the 3D array.
function imP.tensor.ArrayShow3(array)
	for i, v in pairs(array) do
		for j, w in pairs(v) do
			print(table.concat(w, " "));
		end
	end
end
local ArrayShow3 = imP.tensor.ArrayShow3;

-- Array mutliplies number.
function imP.tensor.ArrayMutl(array, n)
	local h = #(array);
	local w = #(array[1]);
	local array_o = zeros(h, w)
	for i = 1, h do
		for j = 1, w do
			array_o[i][j] = array[i][j] * n;
		end
	end
	return array_o;
end
local ArrayMutl = imP.tensor.ArrayMutl;
--ArrayShow(ArrayMutl(array,3))


-- Array addes number.
function imP.tensor.ArrayAdd(array, n)
	local h = #(array);
	local w = #(array[1]);
	local array_o = zeros(h, w);
	for i = 1, h do
		for j = 1, w do
			array_o[i][j] = array[i][j] + n;
		end
	end
	return array_o;
end
local ArrayAdd = imP.tensor.ArrayAdd;
--ArrayShow(ArrayAdd(array,3))


-- Two having same heigth and width array add
function imP.tensor.ArrayAddArray(array1, array2)
	local h1 = #(array1);
	local w1 = #(array1[1]);
	local h2 = #(array2);
	local w2 = #(array2[1]);
	if(h1==h2 and w1==w2) then
		local array = zeros(h1, w1);
		for i = 1, h1 do
			for j = 1, w1 do
				array[i][j] = array1[i][j] + array2[i][j];
			end
		end
		return array;
	end
end
local ArrayAddArray = imP.tensor.ArrayAddArray;
-- a={{1,2,3},{1,2,3}};
-- b={{4,5,6},{4,5,6}};
-- ArrayShow(ArrayAddArray(a,b))

-- Find the Max Value of the 2D Array
function imP.tensor.Array2Max(array)
	local max = array[1][1];
	for i, v in ipairs(array) do
		for j, m in ipairs(array[i]) do	
			if m>max then
				max = m;
			end
		end
	end 
	return max;
end
local Array2Max = imP.tensor.Array2Max;


-- Find the Min Value of the 2D Array
function imP.tensor.Array2Min(array)
	local min = array[1][1];
	for i, v in ipairs(array) do
		for j, m in ipairs(array[i]) do
			if m<min then
				min = m;
			end
		end
	end 
	return min;
end
local Array2Min = imP.tensor.Array2Min;


-- Find the Max Value of the 3D Array
function imP.tensor.Array3Max(array)
	local max = array[1][1][1];
	for i, v in ipairs(array) do
		for j, m in ipairs(array[i]) do
			for p, q in ipairs(array[i][j]) do
				if q>max then
					max = q;
				end
			end
		end
	end 
	return max;
end
local Array3Max = imP.tensor.Array3Max;


-- Find the Min Value of the 3D Array
function imP.tensor.Array3Min(array)
	local min = array[1][1][1];
	for i, v in ipairs(array) do
		for j, m in ipairs(array[i]) do
			for p, q in ipairs(array[i][j]) do
				if q<min then
					min = q;
				end
			end
		end
	end 
	return min;
end
local Array3Min = imP.tensor.Array3Min;
-- a={{{1,2,3},{1,2,3},{1,2,3}},{{1,2,3},{1,2,3},{1,2,3}},{{1,2,3},{1,2,3},{1,2,3}}};
-- print(Array3Min(a),Array3Max(a))
-- b={{1,2,3},{1,2,3},{1,2,3}};
-- print(Array2Min(b),Array2Max(b))


-- Get the Gaussian nucleus from the window size(wsize) and the sigma(sig).
function imP.GetGaussian(sig)
	if sig==nil then
		sig = 1;
	end
	local wsize = 2 * math.ceil(2 * sig) + 1;
	local w = math.ceil(wsize / 2);
	--local n=math.pow(10,math.ceil(-math.log10(1/sig^2*math.exp(-(w-1)^2/sig^2))));
	local g = zeros(wsize, wsize);
	for i = 1, wsize do
		for j = 1, wsize do
			g[i][j] =(1 / sig^2) * math.exp(-((i-w)^2 +(j - w)^2) / 2 / sig^2);
		end
	end
	sum = ArraySum(g)
	g = ArrayMutl(g, 1 / sum);
	return g;
end
local GetGaussian = imP.GetGaussian;
-- a=GetGaussian(5);
-- ArrayShow(a);
-- print(ArraySum(a))


-- Gaussian Filter
function imP.GaussianF(array, sig)
	local h = #(array);
	local w = #(array[1]);
	local G = zeros(h, w);
	if sig==nil then
		sig = 1;
	end
	local wsize = 2 * math.ceil(2 * sig) + 1;
	local d = math.floor(wsize / 2);
	local u = math.ceil(wsize / 2);
	local g = GetGaussian(sig);
	--ArrayShow(g);
	local A = zeros(wsize, wsize);
	for i = 1 + d, h - d do
		for j = 1 + d, w - d do
			for a = 1, wsize do
				for b = 1, wsize do
					A[a][b] = array[i + a-u][j + b-u];
				end
			end
			G[i][j] = ArraySum(DotProduct(A, g));
		end
	end
	return G;
end
local GaussianF = imP.GaussianF;
-- arrayG={{1,2,3,4,5},{1,2,3,4,5},{1,2,3,4,5},{1,2,3,4,5},{1,2,3,4,5}};
-- G=GaussianF(arrayG);
-- ArrayShow(G);



-- Difference of Gaussian
function imP.DoG(array, sig, n)
	if n==nil then
		n = 4;
	end
	if sig==nil then
		sig = 1;
	end
	local k = math.pow(2, 1 / n);
	local d = math.ceil(2 * sig * math.pow(k, n-1)) + 1;
	local h = #(array);
	local w = #(array[1]);
	local G = {};
	for i = 1, n do
		G[i] = GaussianF(array, sig * math.pow(k, i-1));
	end
	local DoG = {};
	for i = 1, n-1 do
		DoG[i] = ArrayAddArray(G[i + 1], ArrayMutl(G[i], -1));
	end
	local A = {};
	for i = 1, 3 do
		A[i] = zeros(3, 3);
	end
	local F = zeros(h, w);
	for q = 2, n-2 do
		for i = 1 + d, h - d do 
			for j = 1 + d, w - d do
				for x = 1, 3 do
					for m = 1, 3 do
						for n = 1, 3 do
							A[x][m][n] = DoG[q + x-2][i + m-2][j + n-2];
						end
					end
				end
				if DoG[q][i][j]==Array3Max(A) then
					F[i][j] = q + F[i][j];
				elseif DoG[q][i][j]==Array3Min(A) then
					F[i][j] = q + n + F[i][j];
				else
					F[i][j] = 0;
				end
			end
		end
	end
	return F;
end
local DoG = imP.DoG;


-- Generate a meshgrid. 
-- Horizontal:mode=0, vertical: mode=1
function imP.tensor.meshgrid(a, b, mode)
	if(mode~=0 and mode~=1) then
		mode = 0;
	end
	local d = math.abs(a-b) + 1;
	local array = zeros(d, d);
	if mode==0 then
		for i = 1, d do
			for j = 1, d do
				array[i][j] = i;
			end
		end
	else
		for i = 1, d do
			for j = 1, d do
				array[i][j] = j;
			end
		end
	end
	array = ArrayAdd(array, a-1);
	return array;
end
local meshgrid = imP.tensor.meshgrid;
-- a=meshgrid(-1,6,1);
-- ArrayShow(a)


-- Computer the convolation of 2D array.
-- Where A is origanal array, B is the kenel.
function imP.tensor.conv2(A, B)
	local h = #(A);
	local w = #(A[1]);
	local hsize = #(B);
	local wsize = #(B[1])
	local d = math.floor(hsize / 2);
	local u = math.floor(wsize / 2);
	local N = zeros(h, w);
	local M = zeros(hsize, wsize);
	for i = 1 + d, h - d do
		for j = 1 + u, w - u do
			for p = 1, hsize do
				for q = 1, wsize do
					M[p][q] = A[i + p-d-1][j + q-u-1];
				end
			end
			N[i][j] = ArraySum(DotProduct(M, B));
		end
	end
	return N;
end
local conv2 = imP.tensor.conv2;
-- C={{1,2,3,4,5},{1,2,3,4,5},{1,2,3,4,5},{1,2,3,4,5},{1,2,3,4,5}};
-- B={{1,2,3},{4,5,6},{7,8,9}};
-- D={{-1,2,-1}};E={{-1},{2},{-1}};
-- a=conv2(C,E);
-- ArrayShow(a);


-- Comput 2 Dimension matrix determinant.
function imP.tensor.Det2(array)
	local D = array[1][1] * array[2][2]-array[1][2] * array[2][1];
	return D;
end
local Det2 = imP.tensor.Det2;


-- Comput 2 Dimension matrix trace.
function imP.tensor.Trace2(array)
	local T = array[1][1] + array[2][2];
	return T;
end
local Trace2 = imP.tensor.Trace2;


-- Herris Corner Detector
function imP.HarrisCD(array)
	local sig = 1;
	local wsize = 7;
	local h = #(array);
	local w = #(array[1]);
	local xx = meshgrid(-3, 3, 1);
	local yy = meshgrid(-3, 3, 0);
	local M = ArrayAddArray(DotProduct(xx, xx), DotProduct(yy, yy));
	local Gxy = zeros(wsize, wsize);
	for i = 1, wsize do
		for j = 1, wsize do
			Gxy[i][j] = math.exp(-(M[i][j] / 2 / sig^2));
		end
	end
	local Gx = DotProduct(xx, Gxy);
	local Gy = DotProduct(yy, Gxy);
	local Ix = conv2(array, Gx);
	local Iy = conv2(array, Gy);
	local Ix2 = DotProduct(Ix, Ix);
	local Iy2 = DotProduct(Iy, Iy);
	local Ixy = DotProduct(Ix, Iy);
	Ix2 = GaussianF(Ix2, 1);
	Iy2 = GaussianF(Iy2, 1);
	Ixy = GaussianF(Ixy, 1);
	local R = zeros(h, w);
	local Rmax = 0;
	local M = zeros(2, 2);
	for i = 1, h do
		for j = 1, w do
			M = {{Ix2[i][j], Ixy[i][j]}, {Ixy[i][j], Iy2[i][j]}};
			R[i][j] = Det2(M)-0.06 * Trace2(M);
			if R[i][j]>Rmax then
				Rmax = R[i][j];
			end
		end
	end
	-- local count=0;
	local result = zeros(h, w);
	for i = 1, h do
		for j = 1, w do
			if R[i][j]>0.01 * Rmax then
				result[i][j] = 1;
				-- count=count+1;
			end
		end
	end
	return result;
end
local HarrisCD = imP.HarrisCD;


--Get a column in a Matrix
function imP.tensor.GetColumn(M, column)
	local self = zeros(1, #M);
	for i = 1, #M do
		self[1][i] = M[i][column];
	end
	return self;
end
local GetColumn = imP.tensor.GetColumn;

-- Matrix multiple
--[[a={{1, 2},{4, 5}};
b={{1, 2},{1, 5}};
c=MatrixMultiple(a,b);
ArrayShow(c)]]
function imP.tensor.MatrixMultiple(M1, M2)
	local row1 = #M1;
	local column1 = #M1[1];
	local row2 = #M2;
	local column2 = #M2[1];
	if column1 == row2 then
		local self = zeros(row1, column2);
		for i = 1, row1 do
			for j = 1, column2 do	
				self[i][j] = ArraySum(DotProduct({M1[i]}, GetColumn(M2, j)));
			end
		end
		return self;
	end
end
local MatrixMultiple = imP.tensor.MatrixMultiple;

-- Determine of 2 or 3 dimensions martrix
--[[
a={{1, 2},{4, 5}};
b={{1, 2, 3},{4, 5, 6},{7, 8, 9}};
print(det(a),det(b))]]
function imP.tensor.det(M)
	local row = #M;
	local column = #M[1];
	if(row == column) and(row == 2) then
		local det2 = M[1][1] * M[2][2]-M[1][2] * M[2][1];
		return det2;
	elseif(row == column) and(row == 3) then
		local det3 =(M[1][1] * M[2][2] * M[3][3] + M[1][2] * M[2][3] * M[3][1]
		+ M[1][3] * M[2][1] * M[3][2]-M[1][1] * M[2][3] * M[3][2]
		-M[1][2] * M[2][1] * M[3][3]-M[1][3] * M[2][2] * M[3][1]);
		return det3;
	end	
end
local det = imP.tensor.det;


-- The Sub martrix which remove the i-th row and j-th column
--[[
b={{1, 2, 3},{4, 5, 6},{7, 8, 9}};
ArrayShow(b)
ArrayShow(SubMartrix(b,1,0))
ArrayShow(SubMartrix(b,2,2))]]
function imP.tensor.SubMartrix(M, i, j)
	local row = #M;
	local column = #M[1];
	local self = zeros(row, column);
	for m = 1, row do
		for n = 1, column do
			self[m][n] = M[m][n];
		end
	end
	if(i <= row) and(j <= column) and(i > 0) and(j >0 ) then
		table.remove(self, i);
		for i = 1, row-1 do
			table.remove(self[i], j);
		end
	elseif(i <= row) and(j == 0) then
		table.remove(self, i);
	elseif(i == 0) and(j <= column) then
		for i = 1, row do
			table.remove(self[i], j);
		end
	end
	return self;
end
local SubMartrix = imP.tensor.SubMartrix;


-- Inverse Matrix of 2 or 3 dimensions martrix
--[[
a={{1, 2},{4, 5}};
b={{1, 2, 3},{4, 5, 6},{7, 8, 10}};
ArrayShow(inv(a))
ArrayShow(inv(b))]]
function imP.tensor.inv(M)
	local row = #M;
	local column = #M[1];
	if(row == column) and(row == 2) then
		local inv2 = ArrayMutl({{M[2][2], -M[1][2]}, {-M[2][1], M[1][1]}}, 1 / det(M));
		return inv2;
	elseif(row == column) and(row == 3) then
		local inv3 = zeros(3, 3);
		local det3 = det(M);
		for i = 1, 3 do
			for j = 1, 3 do	
				inv3[j][i] =(-1)^(i + j) * det(SubMartrix(M, i, j)) / det3;
				--print(inv3[i][j], det(SubMartrix(M,i,j)),det3)
			end
		end
		return inv3;
	end	
end
local inv = imP.tensor.inv;

--return the key of specified value
--@param value: double or integer
--@param bool: 如果bool为true，返回value索引，否则返回不等于value的索引
--@return x,y:  ...  默认返回0元素真索引
--如果tab为1维，返回的y为nil88
function imP.tensor.find(tab, value, bool)
	if value==nil then
		value = 0;
	end
	if bool==nil then
		bool = true;
	end	
	local x = {};
	local y = {};
	if bool == true then
		for k, v in pairs(tab) do 
			if type(tab[k]) == "table" then
				for j, i in pairs(tab[k]) do
					if i==value then 
						x[#x + 1] = k;
						y[#y + 1] = j;
					end
				end
			else
				if v==value then
					x[#x + 1] = k;
					y[#y + 1] = nil;
				end
			end
		end 
	else
		for k, v in pairs(tab) do 
			if type(tab[k]) == "table" then
				for j, i in pairs(tab[k]) do
					if i~=value then 
						x[#x + 1] = k;
						y[#y + 1] = j;
					end
				end
			else
				if v~=value then
					x[#x + 1] = k;
					y[#y + 1] = nil;
				end
			end
		end 
	end
	return x, y
end
local find = imP.tensor.find;

--截取vector中n到m的一部分
function imP.tensor.subvector(vector, n, m)
	if n==nil then
		n = 1;
	end

	if m==nil then
		m = #vector;
	end	
	local subv = {};
	if n ~= m then
		for i = n, m do
			subv[#subv + 1] = vector[i]; --type is table
		end
	else
		subv = vector[m];  --type is number
	end
	return subv;
end
local subvector = imP.tensor.subvector;

--截取matrix中一部分
function imP.tensor.submatrix(matrix, a, b, c, d)
	if a==nil then
		a = 1;
	end	
	if b==nil then
		m = #matrix;
	end	
	if c==nil then
		c = 1;
	end	
	if d==nil then
		d = #matrix[1];
	end	
	local subm = {};
	for i = 1, b-a + 1 do
		subm[i] = {}
		for j = 1, d-c + 1 do 
			subm[i][j] = matrix[i-1 + a][j - 1 + c];
		end
	end
	return subm;
end
local submatrix = imP.tensor.submatrix;

--connect 2 vector
function imP.tensor.connect(A, B)
	local row1 = #A;
	local column1 = #A[1];
	local row2 = #B;
	local column2 = #B[1];
	if row1 == row2 then
		local self = zeros(row1, column1 + column2);
		for j = 1, column1 + column2 do
			for i = 1, row1 do
				if j <= column1 then
					self[i][j] = A[i][j];
				elseif j > column1 then
					self[i][j] = B[i][j-column1];
				end
			end
		end
		return self;
	end
end
local connect = imP.tensor.connect;


--turn the size of A to m * n
--return type is table
function imP.tensor.reshape(A, m, n)
	local a = #A;
	local b = #A[1];
	local V = {};
	local result = {};
	if b ~= nil then --A is a matrix
		for k, v in pairs(A) do
			V = connect(V, A[k]);
		end
		if m == 1 then
			result = V;
		else
			for i = 1, m do
				result[i] = subvector(V, 1 + n * (i - 1), n * i);
			end
		end
	else --A is a vector, m usually will not be 1
		for i = 1, m do 
			result[i] = subvector(A, 1 + n * (i - 1), n * i);
		end		
	end
	return result;
end
local reshape = imP.tensor.reshape;

-- Matrix transposition
function imP.tensor.transposition(M)
	local row = #M;
	local column = #M[1];
	local self = zeros(column, row);
	for i = 1, row do
		for j = 1, column do
			self[j][i] = M[i][j];
		end
	end
	return self;
end
local transposition = imP.tensor.transposition;
