% This script is for exploratory data analysis of the DST task data 
% You can either run the ETL_dst.m script to generate the trialTab and
% tabAb2 data used, or you can load the saved data matrices in
% dataTab_dst.mat


load dataTab_dst
% ETL_dst

% Define variables for use

 % In completed trials
oplusa = trialTab(:,5);
rtData = trialTab(:,6);
saccadeStart = trialTab(:,9);
goTime = trialTab(:,8);
fileNo = trialTab(:,11);
trialNo = trialTab(:,10);
ccorrect = trialTab(:,7);
pcorrect = trialTab(:,12);

 % In aborted trials
oplusa_ab = tabAb2(:,5);
rtData_ab = tabAb2(:,6);
saccadeStart_ab = tabAb2(:,9);
goTime_ab = tabAb2(:,8);
fileNo_ab = tabAb2(:,11);
trialNo_ab = tabAb2(:,10);
ccorrect_ab = tabAb2(:,7);
pcorrect_ab = tabAb2(:,12);

% analysis parameters
rtBins = 0:10:400;



%% === Reaction time analysis ===
rtBins = [0, 400, 10];
% Plot the histograms for Reaction Time
figure(1); hold on
subplot(121)
[nRt, xRt, mean_rt] = plot_histogram(rtData, rtBins, @mean);
hold on
formatted_rt = sprintf('%.2f',mean_rt); 
textMssg = ['mean reaction time of ', formatted_rt , ' for correct DST trials'];
title(textMssg)
xlabel('reaction time [ms]')

subplot(122)
[nRtAb, xRtAb, mean_rtAb] = plot_histogram(rtData_ab, rtBins, @mean);
hold on
formatted_rt = sprintf('%.2f',mean_rtAb); 
textMssg = ['mean reaction time of ', formatted_rt , ' for error DST trials'];
title(textMssg)
xlabel('reaction time [ms]')

hold off

lowRt = find(xRt < 6);
lowRtAb = find(xRtAb < 6);

%% === OPlusA analysis ===
opaBins = [100, 700, 50];
% Plot histograms for O + A data
figure(2); hold on
subplot(121)
[nOpa, xOpa, med_opa] = plot_histogram(oplusa, opaBins, @median);
hold on
formatted_opa = sprintf('%.0f',med_opa); 
textMssg = ['median reaction time of ', formatted_opa , ' for correct DST trials'];
title(textMssg)
xlabel('O + A time [ms]')

subplot(122)
[nOpaAb, xOpaAb, med_opaAb] = plot_histogram(oplusa_ab, opaBins, @median);
hold on
formatted_opa = sprintf('%.0f',med_opaAb); 
textMssg = ['median reaction time of ', formatted_opa , ' for correct DST trials'];
title(textMssg)
xlabel('O + A time [ms]')