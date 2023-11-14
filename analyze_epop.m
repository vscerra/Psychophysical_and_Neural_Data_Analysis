% This script is for exploratory data analysis of the Epop task data 
% You can either run the ETL_pop.m script to generate the trialTab, or you can load the saved data matrices in
% dataTab_epop.mat


load dataTab_epop %load the data if you've already processed it
% ETL_dst

% Define variables for use

 % In completed trials
oplusa = trialTab(:,5);
rtData = trialTab(:,6);
saccadeStart = trialTab(:,9);
goTime = trialTab(:,8);

% analysis parameters
rtBins = [0, 400, 10];


overall_success_rate = sum(trialTab(:,7))/length(trialTab);
%% === Reaction time analysis ===

% Plot the histograms for Reaction Time
figure(1); clf; hold on
[nRt, xRt, mean_rt] = plot_histogram(rtData, rtBins, @mean);
hold on
formatted_rt = sprintf('%.2f',mean_rt); 
textMssg = ['mean reaction time of ', formatted_rt , 'ms for correct DST trials'];
title(textMssg)
xlabel('reaction time [ms]')

hold off

lowRt = find(xRt < 6);

%% === OPlusA analysis ===
opaBins = [100, 700, 50];
% Plot histograms for O + A data
figure(2); clf; hold on
[nOpa, xOpa, med_opa] = plot_histogram(oplusa, opaBins, @median);
formatted_opa = sprintf('%.0f',med_opa); 
textMssg = ['median O + A of ', formatted_opa , 'ms for correct DST trials'];
title(textMssg)
xlabel('O + A time [ms]')
hold off

%% === Go-Saccade offset ===
figure(3); clf;
gsOffset = saccadeStart - goTime;
gsoBins = [0,200, 10];
[nGSO, xGSO, mean_GSO] = plot_histogram(gsOffset, gsoBins, @mean);
formatted_gso = sprintf('%.2f',mean_GSO); 
hold on
textMssg = ['mean Go-Saccade offset of ', formatted_gso , 'ms for correct DST trials'];
title(textMssg)
xlabel('Saccade Start - Go time [ms]')


