img0(:,:,1) = load('R.txt');
img0(:,:,2) = load('G.txt');
img0(:,:,3) = load('B.txt');
img0 = uint8(img0);
points3D = load('points3D.txt');
mp1 = load('mp1.txt')';
mp2 = load('mp2.txt')';


cls = reshape(img0, [size(img0, 1) * size(img0, 2), 3]);
colorIdx = sub2ind([size(img0, 1), size(img0, 2)], round(mp1(:,2)),round(mp1(:, 1)));
ptCloud = pointCloud(points3D, 'Color', cls(colorIdx, :));
% pcwrite(ptCloud,[res_dir,filename],'PLYFormat','ascii');
% disp(['ply saved to ',res_dir,filename,'.ply']);
figure
pcshow(ptCloud, 'VerticalAxis', 'y', 'VerticalAxisDir', 'down', 'MarkerSize', 45);

