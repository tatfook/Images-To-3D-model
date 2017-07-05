imP={}
require"imlua"
require"imlua_process"
--创建0矩阵
function imP.zeros(Width,Height,ColorSpace,DataType) 
	Zero = im.ImageCreate(Width,Height,ColorSpace,DataType);
	if (Width>0 and Height>0 and 
		(ColorSpace==0 or ColorSpace==1 or ColorSpace==2) and
		DataType==0) then
		Width=math.ceil(Width);
		Height=math.ceil(Height);
		D=Zero:Depth();
		for w=0,Width-1 do
			for h=0,Height-1 do
				for d=0,D-1 do
					Zero[d][h][w]=0;
				end
			end
		end
		--保存图片
		--Zero:Save("Zero.jpg","JPEG");
		return Zero;	
	elseif Width==nil then
		print("Error: Width is nil")
	elseif Width<=0 then
		print("Error: Width小于0");
	elseif Height==nil then
		print("Error: Height is nil")
	elseif Height<=0 then
		print("Error: Height小于0");
	elseif ColorSpace==nil then
		print("Error: ColorSpace is nil")
	elseif not (ColorSpace==0 or ColorSpace==1 or ColorSpace==2) then
		print("Error: ColorSpace不在范围");
	elseif DataType==nil then
		print("Error: DataType is nil")
	elseif DataType~=0 then
		print("Error: DataType类型错误")
	end
end



--图像转灰度图
function imP.ToGrey(image)
	-- body
	local t=image:Depth();	
	if t==0 then
		--保存图片
		--image:Save("Grey.jpg","JPEG")
		return image;		
	else
		local Grey=imP.zeros(image:Width(),image:Height(),2,image:DataType());
	    for row=0, image:Height()-1 do
		    for colum=0, image:Width()-1 do
		    	for dep=0,t-1 do
			    Grey[0][row][colum]=(Grey[0][row][colum]
			            +image[dep][row][colum]/t);
			    end
			end
		end
		--保存图片
		--image:Save("Grey.jpg","JPEG")
		return Grey;

	end
end

--邻近取整
function imP.round(x)
	-- body
	local o
	if (math.ceil(x)-x)<=(x-math.floor(x)) then
		o=math.ceil(x);
	else
		o=math.floor(x);
	end
	return o;
end

--[[图像缩放
     order=0,1,3.
     0--nearest interpolation
     1--bilinear interpolation
     3--bicubic interpolation]]
function imP.imresize( image,dim,order )
	-- body
	if order==nil then
		order=3;
	end
	if not (order==0 or order==1 or order==3) then
		print("Error: order取值出错");
	elseif dim<=0 then
		print("Error: dim应大于0")
	else
		w=image:Width();
		h=image:Height();
		ww=imP.round(dim*w);
		hh=imP.round(dim*h);
		NewI=im.ImageCreate(ww,hh,image:ColorSpace(),image:DataType());
		im.ProcessResize(image,NewI,order);
		--保存图片
	    NewI:Save("imresize.jpg","JPEG")
	    return NewI;
	end		
end

return imP