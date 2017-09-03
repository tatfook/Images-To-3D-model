img0(:,:,3) = load('R.txt');
img0(:,:,2) = load('G.txt');
img0(:,:,1) = load('B.txt');
img0 = uint8(img0);
points3D = load('points3D.txt');
mp1 = load('mp1.txt')';
mp2 = load('mp2.txt')';

for i = 1:5
arv = sum((points3D(:, 3) - mean(points3D)).^2, 2);
p = arv(:,1) < 2*mean(arv);
points3D = points3D(p==1,:);
mp1 = mp1(p==1,:);
mp2 = mp2(p==1,:);
end
cls = reshape(img0, [size(img0, 1) * size(img0, 2), 3]);
colorIdx = sub2ind([size(img0, 1), size(img0, 2)], round(mp1(:, 1)),round(mp1(:, 2)));
ptCloud = pointCloud(points3D, 'Color', cls(colorIdx, :));
% pcwrite(ptCloud,[res_dir,filename],'PLYFormat','ascii');
% disp(['ply saved to ',res_dir,filename,'.ply']);
figure
pcshow(ptCloud, 'VerticalAxis', 'y', 'VerticalAxisDir', 'down', 'MarkerSize', 145);

