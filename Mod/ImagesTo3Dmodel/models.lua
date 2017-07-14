--[[
Title: 
Author(s): BerryZSZ
Date: 2017/7/12-14
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

function CreatTXT(array,filename)
	-- Creat the txt file of the array.
	local file = io.open(filename,"w");
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
	for i, v in pairs(array) do
		for j, m in pairs(array[i]) do
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

function ArrayAddArray(array1, array2)
	-- Two having same heigth and width array add
	local h1=table.getn(array1);
	local w1=table.getn(array1[1]);
	local h2=table.getn(array2);
	local w2=table.getn(array2[1]);
	if (h1==h2 and w1==w2) then
		local array=zeros(h1,w1);
		for i=1, h1 do
			for j=1, w1 do
				array[i][j]=array1[i][j]+array2[i][j];
			end
		end
		return array;
	end
end
-- a={{1,2,3},{1,2,3}};
-- b={{4,5,6},{4,5,6}};
-- ArrayShow(ArrayAddArray(a,b))

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
function Array2Max(array)
	-- Find the Max Value of the 2D Array
	local max=array[1][1];
	for i, v in ipairs(array) do
		for j, m in ipairs(array[i]) do	
			if m>max then
			   max=m;
			end
		end
	end 
    return max;
end
function Array2Min(array)
	-- Find the Min Value of the 2D Array
	local min=array[1][1];
	for i, v in ipairs(array) do
		for j, m in ipairs(array[i]) do
			if m<min then
			   min=m;
		    end
		end
	end 
    return min;
end

function Array3Max(array)
	-- Find the Max Value of the 3D Array
	local max=array[1][1][1];
	for i, v in ipairs(array) do
		for j, m in ipairs(array[i]) do
			for p, q in ipairs(array[i][j]) do
			    if q>max then
				   max=q;
			    end
		    end
		end
	end 
    return max;
end
function Array3Min(array)
	-- Find the Min Value of the 3D Array
	local min=array[1][1][1];
	for i, v in ipairs(array) do
		for j, m in ipairs(array[i]) do
		    for p, q in ipairs(array[i][j]) do
			    if q<min then
				   min=q;
			    end
		    end
		end
	end 
    return min;
end
 --a={{{1,2,3},{1,2,3},{1,2,3}},{{1,2,3},{1,2,3},{1,2,3}},{{1,2,3},{1,2,3},{1,2,3}}};
 --print(ArrayMin(a),ArrayMax(a))
 --b={{1,2,3},{1,2,3},{1,2,3}};
--print(ArrayMin(b),ArrayMax(b))

function GetGaussian(sig)
	-- Get the Gaussian nucleus from the window size(wsize) and the sigma(sig).
	if sig==nil then
		sig=1;
	end
	local wsize=2*math.ceil(2*sig)+1;
	local w=math.ceil(wsize/2);
	--local n=math.pow(10,math.ceil(-math.log10(1/sig^2*math.exp(-(w-1)^2/sig^2))));
	local g=zeros(wsize,wsize);
	for i=1, wsize do
		for j=1, wsize do
			g[i][j]=(1/sig^2)*math.exp(-((i-w)^2+(j-w)^2)/2/sig^2);
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
	local wsize=2*math.ceil(2*sig)+1;
	local d=math.floor(wsize/2);
	local u=math.ceil(wsize/2);
	local g=GetGaussian(sig);
	--ArrayShow(g);
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
-- arrayG={{1,2,3,4,5},{1,2,3,4,5},{1,2,3,4,5},{1,2,3,4,5},{1,2,3,4,5}};
-- G=GaussianF(arrayG);
-- ArrayShow(G);



function DoG(array,sig,n)
	-- Difference of Gaussian
	if n==nil then
		n=4;
	end
	if sig==nil then
		sig=1;
	end
	local k=math.pow(2,1/n);
	local d=math.ceil(2*sig*math.pow(k,n-1))+1;
	local h=table.getn(array);
	local w=table.getn(array[1]);
	local G={};
	for i=1, n do
		G[i]=GaussianF(array,sig*math.pow(k,i-1));
	end
	local DoG={};
	for i=1, n-1 do
		DoG[i]=ArrayAddArray(G[i+1],ArrayMutl(G[i],-1));
	end
	local A={};
	for i=1, 3 do
		A[i]=zeros(3,3);
	end
	local F=zeros(h,w);
	for  q=2, n-2 do
		for i=1+d, h-d do 
			for j=1+d, w-d do
				for x=1, 3 do
					for m=1, 3 do
						for n=1, 3 do
							A[x][m][n]=DoG[q+x-2][i+m-2][j+n-2];
						end
					end
				end
				if DoG[q][i][j]==Array3Max(A) then
					F[i][j]=q+F[i][j];
				elseif DoG[q][i][j]==Array3Min(A) then
					F[i][j]=q+n+F[i][j];
				else
					F[i][j]=0;
				end
			end
		end
	end
	return F;
end



