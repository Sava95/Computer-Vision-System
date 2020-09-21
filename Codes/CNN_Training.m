clear, close, clc
%% Load pretrained CNN
net = alexnet;
layers = net.Layers;
% sz = net.Layers(1).InputSize;
%% Modify the network
layers(23) = fullyConnectedLayer(4,'Name','fc8');
layers(25) = classificationLayer('Name','output');

%% Load image and set up data
trainingImages= imageDatastore('D:\Desktop\Google Drive\Sava_Nedeljkovic_1819\Testovi_2.Jul\Features','IncludeSubfolders', true, 'LabelSource','foldername');
testImages = imageDatastore('D:\Desktop\Google Drive\Sava_Nedeljkovic_1819\Slike za testiranje 02.08\Features 02.08','IncludeSubfolders', true, 'LabelSource','foldername');

%% Re-train the Network
opts = trainingOptions('sgdm','InitialLearnRate',0.001,'LearnRateDropFactor', 0.3, 'MaxEpochs',5, 'MiniBatchSize', 100,...
       'Plots','training-progress');
Alex_net = trainNetwork(trainingImages, layers, opts);

%% Measure network accuracy 
predictedLabels = classify(Alex_net, testImages);
accuracy = mean(predictedLabels == testImages.Labels)
%% Confusion matrix
[CM,ORDER] = confusionmat(testImages.Labels,predictedLabels);
confusionchart(CM,ORDER);
title('Matrica Odlucivanja');

save Alex_net
AlexNet_FINAL = Alex_net;
save AlexNet_FINAL AlexNet_FINAL
%save ('soljevi','layers') 