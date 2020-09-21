close all, clc

load CNN_all 

%% Setting up Video
% Left camera
vid = videoinput('gentl',1,'BayerGB8');%, 'RGB24_640x480') BILO :YUY2_320x240
src = getselectedsource(vid);
triggerconfig(vid,'manual');

set(vid,'FramesPerTrigger',15);

set(vid,'TriggerRepeat', Inf);

set(vid,'ReturnedColorSpace','rgb')

set(vid, 'ReturnedColorSpace','RGB')

src.BalanceWhiteAuto = 'Once';

start(vid)
%%%%%% Za gledanje snimka
vidRes = vid.VideoResolution; 
nBands = vid.NumberOfBands; 
hImage = image( zeros(vidRes(2), vidRes(1), nBands) ); 
preview(vid, hImage); 

% Right camera
vid1 = videoinput('gentl',2,'BayerGB8');
src1 = getselectedsource(vid1);
triggerconfig(vid1,'manual');

set(vid1,'FramesPerTrigger',15);

set(vid1,'TriggerRepeat', Inf);

set(vid1,'ReturnedColorSpace','rgb')

set(vid, 'ReturnedColorSpace','RGB')

src1.BalanceWhiteAuto = 'Once';

start(vid1)
%%%%%% Za gledanje snimka
vidRes1 = vid1.VideoResolution; 
nBands1 = vid1.NumberOfBands; 
figure(2)
hImage1 = image( zeros(vidRes1(2), vidRes1(1), nBands1) ); 
preview(vid1, hImage1);

%% Take Image
slika = getsnapshot(vid);
slika1 = getsnapshot(vid1);

I1 = slika(:,:,:);
I2 = slika1(:,:,:);

I1 = imresize(I1,[400 400]);
I2 = imresize(I2,[400 400]);

[BW1,BBB1] = segmentation(I1);
[BW2,BBB2] = segmentation(I2);


figure, imshow(I1);
hold on
%title(['There are ', num2str(size(obj_position,1)),' objects in the image'])

for i = 1:size(BBB1,1)
    v(i) = rectangle('Position',BBB1(i,:));
    set(v(i),'EdgeColor',[.75 0 0]);
    
end

for i=1:size(BBB1,1)
    obj = imcrop(I,BBB1(i,:));
    obj_resize = imresize(obj, [227 227]);

    label(i) = classify(CNN_all, obj_resize);

    text(BBB1(i,1)-12,BBB1(i,2)-12,char(label(i)),'Color','Black')

end
