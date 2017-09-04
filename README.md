# Images To 3D model

本项目是基于SIFT, SFM算法的三维结构重建算法。 Mod/ImagesTo3Dmodel 中文件为function文件， Mod/Test 中文件为测试文件。

1. SIFT 为图像特征检测的算法， 可用测试文件 TestSIFT 可检测图片特征值及位置。 TestSIFTmatching 可检测两张图片的特征点及匹配。 将路径改为自己的图片即可使用。

2. SVD 为基于 QR 算法的矩阵特征值计算。 可用TestSVD计算特征值。 改变矩阵即可。

3. SFM 是通过对同一物体不同角度拍摄两张不同照片， 进行检测恢复三维结构。 TestSFM 可测试， 想要测试自己的照片更改路径，并且其中在function SFM.DO_SFM 中的col矩阵为 [intrinsic matrix](https://en.wikipedia.org/wiki/Camera_resectioning) 需要根据自己的需求更改。

Reference:
- [SFM](https://github.com/BerryZSZ/3D-reconstruction.git)



