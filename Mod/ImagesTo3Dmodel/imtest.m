I=load('demo-data/church3/1.txt');
% I=load('lena.txt');
[m,n]=size(I);
o_I=zeros(m,n);
for i=1:m
    o_I(i,:)=I(m+1-i,:);
end
g=uint8(o_I);
figure
imshow(g,[])
% imwrite(g,'harris.jpg','jpg')
% c=detectHarrisFeatures(o_I);