I=load('lena.txt');
[m,n]=size(I);
o_I=zeros(m,n);
for i=1:m
    o_I(i,:)=I(m+1-i,:);
end
figure
imshow(o_I,[])