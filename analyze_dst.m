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



%% 
% Reaction time analysis
[nRt, xRt] = histc(rtData(ccorrect==1), rtBins);
meanRt = mean(rtData(ccorrect == 1));
formatted_rt = sprintf('%.2f', meanRt); % format the variable to use in the title
% Plot the histogram
figure(1)
hold on
bar(rtBins,nRt/sum(nRT))
box off
xlim([0, 400])
textMssg = ['mean reaction time of ', formatted_rt , ' for correct DST trials'];
title(textMssg)
xlabel('reaction time [ms]')
ylabel('number of trials')
set(gca, 'TickDir','out','Ytick',[0, 1000, 2000, 3000, 4000])

lowRt = find(xRt==1);


