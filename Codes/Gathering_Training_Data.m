clear, close all, clc

load AlexNet_FINAL
CNN = AlexNet_FINAL;
inputSize = CNN.Layers(1).InputSize;

allImages = imageDatastore('Slike\Testovi_2.Jul\Test_3_levo','IncludeSubfolders', true, 'LabelSource','foldername');
% i_num = 23; size(allImages.Files,1)
for i_num = [1 47 3 8]
I = imread(allImages.Files{i_num});
I = imresize(I, [360 640]);
% figure(), imshow(I)
Igray = rgb2gray(I);
Igray = double(Igray);

%% Gaus - blur
I_gaus = zeros(size(Igray));
filter = [1 2 1; 2 4 2; 1 2 1]*1.4;
for i = 2:size(Igray,1)-1
    for j = 2:size(Igray,2)-1
        I_gaus(i,j) = (Igray(i-1,j-1) * filter(1,1) + Igray(i-1,j) * filter(1,2)  + Igray(i-1,j+1) * filter(1,3)...
            + Igray(i,j-1) * filter(2,1) + Igray(i,j) * filter(2,2)  + Igray(i,j+1) * filter(2,3) ...
            + Igray(i+1,j-1) * filter(3,1) + Igray(i+1,j) * filter(3,2)  + Igray(i+1,j+1) * filter(3,3))/16;
    end
end

% I_gaus = imgaussfilt(Igray,2); % - drugi nacin

I_int = uint8(I_gaus);
% figure(),imshow(I_int)

%% Border control
I_gaus(1,1:size(I,2)) = I_gaus(2,1:size(I,2));
I_gaus(size(I,1),1:size(I,2)) = I_gaus(size(I,1)-1,1:size(I,2));

I_gaus(1:size(I,1),1) = I_gaus(1:size(I,1),2);
I_gaus(1:size(I,1),size(I,2)) = I_gaus(1:size(I,1),size(I,2)-1);
I_gaus = uint8(I_gaus);
% figure(),imshow(I_gaus)

%% Segmentation
a = zeros(size(I));
a = edge(I_gaus,'sobel','nothinning',0.012);
BW = a;
% figure(), imshow(BW)
BW = bwareaopen(BW,300);
% figure(),imshow(BW)

%% Edge connectivity
ED = 10;
for i = 1:size(BW,1)
    for j = 1:size(BW,2)  
        if i <= ED
            if BW(i,j) == 1
                BW(1:i,j) = 1;
            end
        elseif i >= size(BW,1)-ED
            if BW(i,j) == 1
                BW(i:size(BW,1),j) = 1;
            end
        end
        
        if j <= ED
            if BW(i,j) == 1
                BW(i,1:j) = 1;
            end
        elseif j >= size(BW,2)-ED
            if BW(i,j) == 1
                BW(i,j:size(BW,2)) = 1;
            end
        end
    end
end
% figure(), imshow(BW)

%% Region clustering
BW = ~BW;
% figure(), imshow(BW)

bw = zeros(size(I));
bw = bwconncomp(BW,8);
bw_lab = zeros(size(I));
bw_lab = labelmatrix(bw); 
RGB_label = zeros(size(I));
RGB_label = label2rgb(bw_lab, @copper, 'c', 'shuffle');
% figure(), imshow(RGB_label,'InitialMagnification','fit')

%% Extraction of labeled regions
n = bw.NumObjects;
group = zeros(size(bw_lab,1),size(bw_lab,2));
for x = 1:n
    for i = 1:size(bw_lab,1);
        for j = 1:size(bw_lab,2);
            if bw_lab(i,j) == x
                group(i,j) = 1;
            else
                group(i,j) = 0;
            end
        end
    end
    gr(:,:,x) = group;
end

BW = ~BW;
% figure(),imshow(BW)
hsv_obj = BW; 
% figure(),imshow(BW)

%% RGB region analysis - za izdvajanje objekata od okruzenja
RP = regionprops(bw_lab,'PixelList');

for i = 1:n
    pix_list = RP(i).PixelList'; % koordinate
    for j = 1:size(pix_list,2)
        rgb(1:3,j) = I(pix_list(2,j),pix_list(1,j),:);  % R G B    
    end
    
    Green(i) = (sum(rgb(2,:)))/(length(rgb(2,:))); % 2 - G
    
    if Green(i) < 120
       BW = BW + gr(:,:,i);
    end
    clear rgb 
end

% figure(),imshow(BW)

%% HSV region analysis - za eliminisanje ivice okruzenja
HSV = rgb2hsv(I);
for i = 1:size(I,1)
    for j = 1:size(I,2)
        if hsv_obj(i,j) == 1 
            hue = HSV(i,j,1);
            saturation = HSV(i,j,2);
            value = HSV(i,j,3);
            
            if saturation < 0.26
               BW(i,j) = 0;
            end 

        end
    end
end

% figure(), imshow(BW);
BW = imfill(BW,'holes'); 
BW = bwareaopen(BW,300);
% figure(), imshow(BW);
BW_1 = BW; 

%% Watershed
D = zeros(size(I));
D = -bwdist(~BW);  
mask = imextendedmin(D,7);
% figure(); imshowpair(BW,mask,'blend')
D2 = zeros(size(I));
D2 = imimposemin(D,mask);
% figure(); imshow(D2,[]);
Ld2 = zeros(size(I));
Ld2 = watershed(D2);
% figure();imshow(label2rgb(Ld2))

BW(Ld2 == 0) = 0;
% figure(); imshow(BW)

%% Visualisation of the segmented image
bw_1 = bwconncomp(BW,8);
bw_lab_1 = labelmatrix(bw_1);
RGB_label = zeros(size(I));
RGB_label = label2rgb(bw_lab_1, @copper, 'c', 'shuffle'); 
figure(), imshow(RGB_label,'InitialMagnification','fit')


%% Wathershed check 
BBB = B_BOX(I,BW);

for i = 1:size(BBB,1)
    obj = imcrop(I,BBB(i,:));
    obj_resize = augmentedImageDatastore(inputSize(1:2),obj);
    [label(i), scores(i,:)] = classify(CNN, obj_resize);
    
end

[A,B,C]= unique(label,'stable'); % C ide redom 1 2 3 4 zbog stable
n_1 = bw_1.NumObjects;
RPP = regionprops(bw_lab_1,'Area','Centroid');
j=1;
for i = 1:n_1
    if RPP(i).Area > 1500 
        RP_1(j,:) = RPP(i).Centroid;
        j = j+1;
    end
end

for i = 1:size(C,1)
    if i+1 <= size(C,1)
        if C(i) == C(i+1) 
            x_1 = round(RP_1(i,2));
            y_1 = round(RP_1(i,1)); 
            
            x_2 = round(RP_1(i+1,2)); 
            y_2 = round(RP_1(i+1,1)); 
            
            obj_1 = zeros(360,640);
            obj_2 = zeros(360,640);
            
            obj_1(x_1,y_1) = 1;
            obj_2(x_2,y_2) = 1;
            
            D1 = bwdist(obj_1, 'quasi-euclidean');
            D2 = bwdist(obj_2, 'quasi-euclidean');
            
            D_sum = D1 + D2;
            if min(min(D_sum)) < 250
                path_pixels = imextendedmin(D_sum,5);
            else
                path_pixels = zeros(size(I,1),size(I,2));
            end

            BW = BW + path_pixels;
            
        end
    end  
end 
BW = im2bw(BW); 
% figure(); imshow(path_pixels)

% figure(); imshow(BW)
BBB = B_BOX(I,BW);

% figure('Resize','on'), imshow(I);
% set(gcf, 'Position',  [460, 350, 640, 420]) 
% hold on
% if size(BBB,1) == 1
%     title({['There is ', num2str(size(BBB,1)),' object in the image'];''},'FontSize',12)
% else
%     title({['There are ', num2str(size(BBB,1)),' objects in the image'];''},'FontSize',12)
%     
% end

clear label scores 

%% Classify image
for i = 1:size(BBB,1)
    obj = imcrop(I,BBB(i,:));
    obj_resize = augmentedImageDatastore(inputSize(1:2),obj);
    
    [label(i), scores(i,:)] = classify(CNN, obj_resize);
    LABEL = [char(label(i)),' - ',num2str(max(scores(i,:)*100),4),' %'];
    
%     if mod(i,2) == 0
%         text(BBB(i,1)+3,BBB(i,2)-7 + BBB(i,4),char(LABEL),'Color','Black','FontSize',10,'FontWeight','bold')
%     else
%         text(BBB(i,1)+3,BBB(i,2)-7,char(LABEL),'Color',[0 0 0],'FontSize',10,'FontWeight','bold')
%     end
%     
%     v(i) = rectangle('Position',BBB(i,:));
%     set(v(i),'EdgeColor',[0.75 0 0]);
end

%% Object extraction
for i=1:size(BBB,1)
    obj = imcrop(I,BBB(i,:));
    obj_resize = imresize(obj, [227 227]);
    pause(0.1)
  
    if i == 1;
        Slika = ['T1_Levo1_Slika_',num2str(i_num),'.jpg'];
        folder = 'D:/Desktop/Machine 1';
        fullFileName = fullfile(folder, Slika);
        imwrite(obj_resize, fullFileName);
    elseif i == 2;
        Slika = ['T1_Levo2_Slika_',num2str(i_num),'.jpg'];
        folder = 'D:/Desktop/Machine 2';
        fullFileName = fullfile(folder, Slika);
        imwrite(obj_resize, fullFileName);
    elseif i == 3;
        Slika = ['T1_Levo3_Slika_',num2str(i_num),'.jpg'];
        folder = 'D:/Desktop/Machine 3';
        fullFileName = fullfile(folder, Slika);
        imwrite(obj_resize, fullFileName);
    elseif i == 4;
        Slika = ['T1_Levo4_Slika_',num2str(i_num),'.jpg'];
        folder = 'D:/Desktop/Machine 4';
        fullFileName = fullfile(folder, Slika);
        imwrite(obj_resize, fullFileName);
    else i == 5;
        Slika = ['T1_Levo5_Slika_',num2str(i_num),'.jpg'];
        folder = 'D:/Desktop/Black Marker';
        fullFileName = fullfile(folder, Slika);
        imwrite(obj_resize, fullFileName);
    end
end
clearvars -except allImages CNN inputSize
end
