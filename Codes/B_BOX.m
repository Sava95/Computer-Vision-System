function [BBB] = B_BOX(I,BW)

% Object labeling
bw = zeros(size(I));
bw = bwconncomp(BW,8);
bw_lab = zeros(size(I));
bw_lab = labelmatrix(bw); % tu se nalaze numerisani objekti
RGB_label = zeros(size(I));
RGB_label = label2rgb(bw_lab, @copper, 'c', 'shuffle');
% figure(), imshow(RGB_label,'InitialMagnification','fit')

% Extraction of labeled objects 
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
    lab_obj(:,:,x) = group;
end

% Extraction of small and big objects
p = 1;
RP = regionprops(bw_lab(:,:,:),'Area');
for i = 1:size(lab_obj,3)
    if RP(i).Area > 1500 && RP(i).Area < 95000
        objects(:,:,p) = lab_obj(:,:,i);
        p = p+1;
    end
end

% Bounding Box

% figure, imshow(I);
% hold on;
position = zeros(size(objects,3),4);
for i = 1:size(objects,3)
    stats = regionprops(objects(:,:,i),'BoundingBox');
    box = stats.BoundingBox;
    
%         h(i) = rectangle('Position',box);
%         set(h(i),'EdgeColor',[.75 0 0]);
    
    position(i,1:4) = floor(box);
end

% title(['There are ', num2str(size(objects,3)),' objects in the image'])

% Bigger Bounding Box
BBB = zeros(size(position,1),size(position,2));
N = 5;

BBB(:,1) = position(:,1) - N;
BBB(:,2) = position(:,2) - N;
BBB(:,3) = position(:,3) + N*2;
BBB(:,4) = position(:,4) + N*2;

for i = 1:size(BBB,1) % ogranicenje BBB - gore/levo
    if BBB(i,1) < 0 
        BBB(i,1) = 1;
    end
    
    if BBB(i,2) < 0 
        BBB(i,2) = 1;
    end
end

for i = 1:size(BBB,1) % ogranicenje BBB - dole/desno
    Width(i) = BBB(i,1) + BBB(i,3);
    Hight(i) = BBB(i,2) + BBB(i,4);
    
    if Width(i) > size(I,2)
        Width(i) = size(I,2); % j osa - x 
        BBB(i,3) = Width(i) - BBB(i,1);
    end
    
    if  Hight(i) > size(I,1)
        Higth(i) = size(I,1); % i osa - y
        BBB(i,4) = Higth(i) - BBB(i,2);
    end
end

end

