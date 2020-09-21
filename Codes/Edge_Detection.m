clc, clear all, close all

I = imread('Test.jpg');
Igray = rgb2gray(I);

figure(1); imshow(I)
figure(2); imhist(Igray(:,:,:))

a = edge(Igray,'roberts',0.017);
b = edge(Igray,'sobel',0.017);
c = edge(Igray,'prewitt',0.017);
d = edge(Igray,'canny',0.017);
e = edge(Igray,'log',0.017);

figure(3)
subplot(2,3,1), imshow(I), title('Original')
subplot(2,3,2), imshow(a), title('Roberts')
subplot(2,3,3), imshow(b), title('Sobel')
subplot(2,3,4), imshow(c), title('Prewitt')
subplot(2,3,5), imshow(d), title('Canny')
subplot(2,3,6), imshow(e), title('Log')

