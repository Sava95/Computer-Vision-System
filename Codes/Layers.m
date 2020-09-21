% clc, close all
clearvars -except net
net = alexnet;
im = imread('Test.jpg');
% imshow(im)

imgSize = size(im);
imgSize = imgSize(1:2);

act1 = activations(net,im,'pool1');
sz = size(act1);
act1 = reshape(act1,[sz(1) sz(2) 1 sz(3)]);
I = imtile(mat2gray(act1),'GridSize',[8 12]);
figure(1),imshow(I)