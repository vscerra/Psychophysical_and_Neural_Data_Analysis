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

 % In aborted trials
oplusa_ab = tabAb2(:,5);
rtData_ab = tabAb2(:,6);
saccadeStart_ab = tabAb2(:,9);
goTime_ab = tabAb2(:,8);

% analysis parameters
rtBins = [0, 400, 10];



%% === Reaction time analysis ===

% Plot the histograms for Reaction Time
figure(1); clf; hold on
[nRt, xRt, mean_rt] = plot_histogram(rtData, rtBins, @mean);
hold on
formatted_rt = sprintf('%.2f',mean_rt); 
textMssg = ['mean reaction time of ', formatted_rt , 'ms for correct DST trials'];
title(textMssg)

% Plot error trials on same graph
[nRtAb, xRtAb, mean_rtAb] = plot_histogram(rtData_ab, rtBins, @mean, 'r', 1);
formatted_rt = sprintf('%.2f',mean_rtAb); 
textMssg = ['mean reaction time of ', formatted_rt , 'ms for error DST trials'];
ys = ylim;
text(200, ys(2)-(ys(2)*.05), textMssg, 'VerticalAlignment','bottom','HorizontalAlignment','center','Color','r')
xlabel('reaction time [ms]')

hold off

lowRt = find(xRt < 6);
lowRtAb = find(xRtAb < 6);

%% === OPlusA analysis ===
opaBins = [100, 700, 50];
% Plot histograms for O + A data
figure(2); clf; hold on
[nOpa, xOpa, med_opa] = plot_histogram(oplusa, opaBins, @median);
formatted_opa = sprintf('%.0f',med_opa); 
textMssg = ['median O + A of ', formatted_opa , 'ms for correct DST trials'];
title(textMssg)

% Plot aborted trials in same graph
[nOpaAb, xOpaAb, med_opaAb] = plot_histogram(oplusa_ab, opaBins, @median, 'r', 1);
formatted_opa = sprintf('%.0f',med_opaAb); 
textMssg = ['median O + A of ', formatted_opa , 'ms for error DST trials'];
ys = ylim;
text(400, ys(2)-(ys(2)*.05), textMssg, 'VerticalAlignment','bottom','HorizontalAlignment','center','Color','r')
xlabel('O + A time [ms]')
hold off

%% === Go-Saccade offset ===
figure(3); clf;
gsOffset = saccadeStart - goTime;
gsOffsetAb = saccadeStart_ab - goTime_ab;
gsoBins = [0,200, 10];
[nGSO, xGSO, mean_GSO] = plot_histogram(gsOffset, gsoBins, @mean);
formatted_gso = sprintf('%.2f',mean_GSO); 
hold on
textMssg = ['mean Go-Saccade offset of ', formatted_gso , 'ms for correct DST trials'];
title(textMssg)

% Plot error trials on same graph
[nGSOab, xGSOab, mean_GSOab] = plot_histogram(gsOffsetAb, gsoBins, @mean, 'r', 1);
formatted_gso = sprintf('%.2f',mean_GSOab); 
textMssg = ['mean Go-Saccade offset of ', formatted_gso , 'ms for error DST trials'];
ys = ylim;
text(100, ys(2)-(ys(2)*.05), textMssg, 'VerticalAlignment','bottom','HorizontalAlignment','center','Color','r')
xlabel('Saccade Start - Go time [ms]')


