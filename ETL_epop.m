% This script loads, transforms, and aggregates the data from the Easy Popout task (epop)and
% generates a trialTab variable with all pertinent task data for generating
% figures or referencing neural data. This script also saves eye velocity
% and eye position data for all trials used for analysis.
% Veronica Scerra
% - Generated in 2014
% - modified in 2015 for new task codes
% - modified in 2018 for Cell Biology paper
% - modified 11/2023 for clarity and posting on github
% - goState, targetState, confirmCorrect functions added

% Functions called:
% g_readData.m
% goId.m
% targetId.m
% confirmCorrect.m
% calcVelIndy_Easy
% Variables and data files called:
% dataGuide.mat
% dataFiles_Indy - as needed


%Targets appear at state 4. Reward state is state 9. If trial has state 7,
%it means the monkey is at target or distractor.

clear
load dataGuide
path='C:\Users\vscerra\Documents\MATLAB\CleanStart\github_files\dataFiles_Indy\';
cd(path);  %changes current folder to one specified by the (path)
cdir=path;
% d = dir([cdir filename '.dat']);
% d = dir('*.dat');
d = dataGuide;

% Epop specific task variables
types = {'EpoprG','EpoplG','EpopuG','EpopdG','EpoprR','EpoplR','EpopuR','EpopdR'};
goCodes = [7, 8];
tOnCodes = [5, 6];
tRows = [2,13];
MOE = 6; % requires at most 6 degrees of separation between the target and final eye position for it to be considered a correct trial

% Initialize variables to be used in the loop
k = 0;
corr = 0;
trialTab = [];
file_names = [];
vels = cell(1,9000);
eyed = cell(1,9000);
ab_nogo = 0; ab_Tgt = 0; ab_rt = 0; ab_mismatch = 0;

trialAb2 = zeros(1,8);
tabAb2 = [];
velsAb2 = cell(1,1000);
eyedAb2 = cell(1,1000);
trialInfo = zeros(1391,2);
trialInfo(:,1) = 1:1391;

%% === load, extract, transform data ===
for j = 1:length(d)
    try
        dat = g_readData(d(j).name);
        file_names = strvcat(file_names, d(j).name);
        disp(d(j).name)
        for i = 1:size(dat,2)
            try
                if sum(strcmp(dat(i).TYPENAME, types)) >= 1
                    stateData = dat(i).statedata;
                    k = k+1;
                    % Find when the "go" command was issued ("goState")
                    goState = goId(stateData, goCodes);
                    if isnan(goState); ab_nogo = ab_nogo + 1; trialInfo(k,2) = -9;
%                         disp('no go state')
%                         disp(i)
                        continue;
                    end
                    
                    % Check and see if the trial was completed
                    if max(stateData(:,3)) < 9;
%                         disp('State 9/10 not found completed by subject')
                        trialInfo(k,2) = -3;
                        continue;
                    else
                        %Look for the target information for the trial
                        targetState = targetId(stateData, tOnCodes, tRows);
                        if isnan(targetState)
%                             disp('No target state')
                            ab_Tgt = ab_Tgt + 1;
                            continue;
                        end
                        tx = dat(i).TAR(targetState,1);
                        ty = dat(i).TAR(targetState,2);
                        trial_no = dat(i).TRIAL(:,1);
                        if abs(tx) + abs(ty) == 0
                            continue;
                        else
                            % Calculate reaction time, filter out trials
                            % with bad reaction times
                            [rt, ex, ey, vel, saccadeStart] = calcVelIndy_Easy(dat(i), goState); %ex=eye x plane, ey=eye y plane, vel=velocity matrix, saccadeStart=saccade start time
                            if rt < 0                                         %previous line calc's rt, this script checks to see if rt is normal or not
%                                 disp('bad rt')
%                                 disp(i)
                                ab_rt = ab_rt + 1;
                                trialInfo(k,2) = rt;
                                continue;
                            end
                            
                            % Confirm that the analytically determined trial
                            % outcome matches the program trial evaluation
                            calcCorrect = confirmCorrect([tx, ty], [ex, ey], MOE);
                            programCorrect = ~isempty(find(stateData(:,3) == 11,1)); % looking for buzzer state to see if monkey was correct
                            if calcCorrect ~= programCorrect %include only trials where cc and pc match
                                disp('mismatch between calculated correct and program correct')
                                disp(i)
                                ab_mismatch = ab_mismatch + 1;
                                trialInfo(k,2) = -5;
                                trialAb2 = [tx, ty, ex, ey, dat(i).C, rt, calcCorrect, ...
                                    statedata(goIdx,1)/2, saccadeStart, trial_no, j, programCorrect]; %populating matrices to look at abnormal rt trials
                                tabAb2 = [tabAb2; trialAb2];
                                velsAb2{ab_mismatch} = vel;
                                eyedAb2{ab_mismatch} = dat(i).eyedata;
                                trialAb2 = zeros(1,8);
                                continue;
                            end;
                            oPlusA = dat(i).C;
                            
                            % Populate the temporary trial variable
                            trial = [tx, ty, ex, ey, oPlusA, rt];
                            trial(7) = calcCorrect;
                            trial(8) = stateData(goState,1) / 2; % go signal time
                            trial(9) = saccadeStart;
                            trial(10) = trial_no;
                            trial(11) = j;
                            trial(12) = programCorrect;
                            
                            % append trial info to the trialTab
                            trialTab = [trialTab; trial];
                            trialInfo(k,2) = 1;
                            vels{k} = vel;
                            eyed{k} = dat(i).eyedata;
                        end
                    end
                end
            catch
                trialInfo(k,2) = -1;
                continue;
            end
        end
    catch
        disp('Can''t read file');
    end
end











































