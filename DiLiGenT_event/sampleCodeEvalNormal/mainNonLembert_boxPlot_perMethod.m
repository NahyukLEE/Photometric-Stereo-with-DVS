% Cacluate the per-pixel angular difference between estimated and 'groud
% truth' normal using the 'DiLiGent' photometric stereo dataset; the results
% are visualized using box-and-whisker plot 
% For non-Lambertian methods (1 baseline + 8 recent methods)
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

% Evaluated methods
methodStack{1} = 'L2';
methodStack{2} = 'ACCV10Wu';
methodStack{3} = 'CVPR12Ikehata';
methodStack{4} = 'ICCV05Goldman';
methodStack{5} = 'CVPR08Alldrin';
methodStack{6} = 'CVPR10Higo';
methodStack{7} = 'ECCV12Shi';
methodStack{8} = 'CVPR12Shi';
methodStack{9} = 'CVPR14Ikehata';

numMethod = numel(methodStack);

% Display name for methods
methodDispName{1} = 'BASELINE';
methodDispName{2} = 'WG10';
methodDispName{3} = 'IW12';
methodDispName{4} = 'GC10';
methodDispName{5} = 'AZ08';
methodDispName{6} = 'HM10';
methodDispName{7} = 'ST12';
methodDispName{8} = 'ST14';
methodDispName{9} = 'IA14';

dataFormat = 'PNG';
dataDir = '..\pmsData';
resultDir = '..\estNormalNonLambert';

% Number of normals for each data
numPx = [15791,45200,57721,41512,35278,44864,26193,27654,26421,57342];
pMax = max(numPx);
% For better visualization
% cutVal = 30;

%%
angErrStack = cell(numMethod, 1);
for iM = 1 : numMethod
    disp(['Working on Method no.:', num2str(iM)]);
    angErrMat = NaN(pMax, numData);
    for iD = 1 : numData
        % Load estimated results 'Normal_est'
        load([resultDir, '\', dataNameStack{iD}, dataFormat, '_Normal_', methodStack{iM}, '.mat']);
        if iM == 1
            Normal_est = Normal_L2;
        end
        
        % Load ground truth normal 'Normal_gt'
        load([dataDir, '\', dataNameStack{iD}, dataFormat, '\', 'Normal_gt.mat']);
        % Load masks
        mask = im2bw(imread([dataDir, '\', dataNameStack{iD}, dataFormat, '\', 'mask.png']));
        m = find(mask == 1);
        N_gt = normal_img2vec(Normal_gt, m);
        N_est = normal_img2vec(Normal_est, m);

        angErr = real(acos(dot(N_gt, N_est, 2))) * 180 / pi;
        disp(['MeanErr-', methodStack{iM}, '/', dataNameStack{iD}, ':', num2str(mean(angErr))]);
        
        angErrMat(1:length(m), iD) = angErr;
    end
    
    % angErrMat(angErrMat > cutVal) = cutVal;
    angErrStack{iM} = angErrMat;
end


%%
for figId = 1 : numMethod

    hFig = figure(figId);
    set(hFig, 'Position', [960 540 150 300])
    x = angErrStack{figId};
    h = boxplot(x, 'plotstyle','compact', 'labels', {'0','1','2','3','4','5','6','7','8', '9'}, ...
               'labelorientation', 'horizontal',...
               'colors', [0.2 0.4 1],...
               'whisker', 100);
    title(methodDispName{figId});
    ylim([0 36]);
    
    % Calculat mean by excluding NaN
    mx = zeros(1, numData);
    for i = 1 : numData
        mx(i) = mean(x(1:numPx(i), i));
    end
    
    hold on;
    grid on;
    scatter([1:numData], mx, [], repmat([1, 0.2, 0.2], [length(mx), 1]), 'filled');
    print(hFig, num2str(figId, 'Fig2-%02d'), '-dmeta')
end








