% Cacluate the per-pixel angular difference between estimated and 'groud
% truth' normal using the 'DiLiGent' photometric stereo dataset; the results
% are visualized using box-and-whisker plot 
% For calibrated methods (5 recent methods + optimial A/G)
% Author: Boxin Shi 
% Contact: boxin.shi@gmail.com
% Release date: 20160315

clc;
close all;
clear all;

%==========01=========%
dataNameStack{1} = 'ball';
%==========02=========%
dataNameStack{2} = 'cat';
%==========03=========%
dataNameStack{3} = 'pot1';
%==========04=========%
dataNameStack{4} = 'bear';
%==========05=========%
dataNameStack{5} = 'pot2';
%==========06=========%
dataNameStack{6} = 'buddha';
%==========07=========%
dataNameStack{7} = 'goblet';
%==========08=========%
dataNameStack{8} = 'reading';
%==========09=========%
dataNameStack{9} = 'cow';
%==========10=========%
dataNameStack{10} = 'harvest';

numData = numel(dataNameStack);

% Evaluated methods directory
methodStackDir{1} = 'CVPR12FavaroCombined';
methodStackDir{2} = 'CVPR12FavaroCombined';
methodStackDir{3} = 'CVPR12FavaroCombined';
methodStackDir{4} = 'CVPR13Wu';
methodStackDir{5} = 'optimalGBR';
methodStackDir{6} = 'optimalGBR';
methodStackDir{7} = 'CVPR13Lu';

% Evaluated methods name
methodStack{1} = 'CVPR07Alldrin';
methodStack{2} = 'CVPR10Shi';
methodStack{3} = 'CVPR12Favaro';
methodStack{4} = 'CVPR13Wu';
methodStack{5} = 'optA';
methodStack{6} = 'optG';
methodStack{7} = 'CVPR13Lu';
numMethod = numel(methodStack);

% Display name for methods
methodDispName{1} = 'AM07';
methodDispName{2} = 'SM10';
methodDispName{3} = 'PF14';
methodDispName{4} = 'WT13';
methodDispName{5} = 'Opt. A';
methodDispName{6} = 'Opt. G';
% Put LM13 last, since it requires special downsample
% The sub-figure (box plots) sequence in the paper is [1, 2, 3, 4, 7, 5, 6]
methodDispName{7} = 'LM13'; 

dataFormat = 'PNG';
dataDir = '..\pmsData';
resultDir = '..\estNormalUncalib';

availableData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
availableMethod = [1, 2, 3, 4, 5, 6, 7];

% Number of normals for each data
numPx = [15791,45200,57721,41512,35278,44864,26193,27654,26421,57342];
pMax = max(numPx);
% For better visualization
% cutVal = 60;

%%
angErrStack = cell(numMethod, 1);
mxAll = zeros(numMethod, numData);

for iM = 1 : numMethod
    disp(['Working on Method no.:', num2str(iM)]);
    angErrMat = NaN(pMax, numData);
    for iD = 1 : numData
        % Load estimated results 'Normal_est'
        load([resultDir, '\', dataNameStack{iD}, dataFormat, '_Normal_', methodStack{iM}, '.mat']);
               
        % Load ground truth normal 'Normal_gt'
        load([dataDir, '\', dataNameStack{iD}, dataFormat, '\', 'Normal_gt.mat']);
        % Load masks
        mask = im2bw(imread([dataDir, '\', dataNameStack{iD}, dataFormat, '\', 'mask.png']));   
        
        % CVPR13Lu needs special resize (the original size for some data costs too much memory (> 32GB))
        if iM == 7 
            switch iD
                case 1
                    resize = 1.0;
                case 3
                    resize = 0.4;
                case 8
                    resize = 0.7;
                otherwise
                    resize = 0.5;             
            end
            Normal_gt = imresize(Normal_gt, resize, 'nearest');
            mask = imresize(mask, resize, 'nearest');
            m = find(mask == 1);
            N_gt = normal_img2vec(Normal_gt, m);  
        else
            m = find(mask == 1);
            N_gt = normal_img2vec(Normal_gt, m);
        end
        N_est = normal_img2vec(Normal_est, m);
        
        angErr = real(acos(dot(N_gt, N_est, 2))) * 180 / pi;
        disp(['MeanErr-', methodStack{iM}, '/', dataNameStack{iD}, ':', num2str(mean(angErr))]);
        mxAll(iM, iD) = mean(angErr);
        angErrMat(1:length(angErr), iD) = angErr;
    end
            
    % angErrMat(angErrMat > cutVal) = cutVal;
    angErrStack{iM} = angErrMat;
end


%%
figId = [1, 2, 3, 4, 6, 7, 5];
for methodId = 1 : length(availableMethod);
    hFig = figure(methodId);
    set(hFig, 'Position', [960 540 150 300])
    x = angErrStack{methodId};
    h = boxplot(x, 'plotstyle','compact', 'labels', {'0','1','2','3','4','5','6','7','8', '9'}, ...
               'labelorientation', 'horizontal',...
               'colors', [0.2 0.4 1],...
               'whisker', 10000);
    title(methodDispName{methodId});
    ylim([0 62]);
    
    % Calculat mean by excluding NaN
    mx = mxAll(methodId, :);
    
    hold on;
    grid on;
    scatter([1:numData], mx, [], repmat([1, 0.2, 0.2], [length(mx), 1]), 'filled');
    print(hFig, num2str(figId(methodId), 'Fig4-%02d'), '-dmeta')
end








