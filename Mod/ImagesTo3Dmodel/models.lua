--[[
Title: 
Author(s): BerryZSZ
Date: 2017/7/12
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/ImagesTo3Dmodel/models.lua");
------------------------------------------------------------
]]
function zeros(height,width)
	-- Creat the zeros matrix.
	local array={};
	for h=1, height do
		array[h]={};
		for w=1, width do
			array[h][w]=0;
		end
	end
	return array;	
end

function CreatTXT(array)
	-- Creat the txt file of the array.
	local file = io.open("lena.txt","w");
	local h=table.getn(array);
	if h~=nil then
		for j=1,h do
			w=table.getn(array[j]);
			if w~=nil then
				for i=1,w do
					file: write(array[j][i],"\0");
				end
			end
			file: write("\n");
		end
	end
	file: close();
end

function DotProduct(array1, array2)
	-- Array dot product.
	local h=table.getn(array1);
	local w=table.getn(array1[1]);
	local array=zeros(h,w);
	for i=1, h do
		for j=1, w do
			array[i][j]=array1[i][j]*array2[i][j];
			--print(i,j,array[i][j])
		end
	end
	return array;
end


function ArraySum(array)
	-- Here the array is matrix. Sum each elements of the array.
	local h=table.getn(array);
	local w=table.getn(array[1]);
	local sum=0;
	for i=1, h do
		for j=1, w do 
			sum=sum+array[i][j];
		end
	end
	return sum;
end
-- array1={{1,2,3},{4,5,6},{7,8,9}};
-- array2={{1,2,3},{4,5,6},{7,8,9}};
-- array=DotProduct(array1,array2);
-- sum=ArraySum(array);
-- print(sum)

function ArrayShow(array)
	-- Show the each element of the array.
	for i, v in ipairs(array) do
		for j, m in ipairs(array[i]) do
			print(i,j,m);
		end
	end
end

function ArrayMutl(array,n)
	-- Array mutliplies number.
	local h=table.getn(array);
	local w=table.getn(array[1]);
	local array_o=zeros(h,w)
	for i=1, h do
		for j=1, w do
			array_o[i][j]=array[i][j]*n;
		end
	end
	return array_o;
end
--ArrayShow(ArrayMutl(array,3))

function ArrayAdd(array,n)
	-- Array addes number.
	local h=table.getn(array);
	local w=table.getn(array[1]);
	local array_o=zeros(h,w);
	for i=1, h do
		for j=1, w do
			array_o[i][j]=array[i][j]+n;
		end
	end
	return array_o;
end
--ArrayShow(ArrayAdd(array,3))

function Round(n)
	-- Find the nearest integer.
	if (math.ceil(n)-n) >= (n-math.floor(n)) then
		local t=math.floor(n);
		return(t)
	else
		local c=math.ceil(n);
		return(c)
	end
end
--print(Round(3.5),Round(3.4),Round(3.6))


function GetGaussian(wsize,sig)
	-- Get the Gaussian nucleus from the window size(wsize) and the sigma(sig).
	if sig==nil then
		sig=1;
	end
	local w=math.ceil(wsize/2);
	local n=math.pow(10,math.ceil(-math.log10(1/sig^2*math.exp(-(w-1)^2/sig^2))));
	local g=zeros(wsize,wsize);
	for i=1, wsize do
		for j=1, wsize do
			g[i][j]=Round(n*(1/sig^2)*math.exp(-((i-w)^2+(j-w)^2)/2/sig^2));
		end
	end
	sum=ArraySum(g)
	g=ArrayMutl(g,1/sum);
	return g;

end
--a=GetGaussian(5);
-- ArrayShow(a);
-- print(ArraySum(a))


function GaussianF(array,sig)
	-- Gaussian Filter
	local h=table.getn(array);
	local w=table.getn(array[1]);
	local G=zeros(h,w);
	if sig==nil then
		sig=1;
	end
	wsize=Round(3*sig);
	if math.mod(wsize,2)==0 then
		wsize=wsize+1;
	end
	local d=math.floor(wsize/2);
	local u=math.ceil(wsize/2);
	local g=GetGaussian(wsize,sig);
	ArrayShow(g);
	local A=zeros(wsize,wsize);
	for i=1+d, h-d do
		for j=1+d, w-d do
			for a=1, wsize do
				for b=1,wsize do
					A[a][b]=array[i+a-u][j+b-u];
				end
			end
			G[i][j]=ArraySum(DotProduct(A,g));
		end
	end
	return G;
end
--arrayG={{1,2,3,4,5},{1,2,3,4,5},{1,2,3,4,5},{1,2,3,4,5},{1,2,3,4,5}};
--G=GaussianF(arrayG);
--ArrayShow(G);