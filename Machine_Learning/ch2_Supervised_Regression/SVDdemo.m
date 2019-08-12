%%SVD奇异值分解探索

%知乎：https://www.zhihu.com/question/22237507/answer/53804902
clear;
clc;
P=imread('Ueno Juri.jpg'); % 调入图片
M=rgb2gray(P);
% imshow(M);
m=double(M);%将图像数据转化成double类型
[U,S,V] = svd(m);

%%还原测试
% back = U * S * V';
% back = uint8(back);
% imshow(back);

%取第一项
figure(1);
S1 = zeros(size(S));
S1(1,1) = S(1,1);
P_1 = U * S1 * V';
P_1 = uint8(P_1);
imshow(P_1);

%取5项
figure(2);
S2 = zeros(size(S));
for i = 1:5
    S2(i,i) = S(i,i);
end

P_2 = U * S2 * V';
P_2 = uint8(P_2);
imshow(P_2);

%取20项
figure(3);
S3 = zeros(size(S));
for i = 1:20
    S3(i,i) = S(i,i);
end

P_3 = U * S3 * V';
P_3 = uint8(P_3);
imshow(P_3);


%取50项
figure(4);
S4 = zeros(size(S));
for i = 1:50
    S4(i,i) = S(i,i);
end

P_4 = U * S4 * V';
P_4 = uint8(P_4);
imshow(P_4);