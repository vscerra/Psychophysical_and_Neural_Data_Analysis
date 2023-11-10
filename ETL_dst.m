% This script loads, transforms, and aggregates the data from the delayed-saccade task (DST)and
% generates a trialTab variable with all pertinent task data for generating
% figures or referencing neural data. This script also saves eye velocity
% and eye position data for all trials used for analysis.
% Veronica Scerra
% - initial script from Gabriela Costello - 2014
% (analyzeCS_reereesingletarg.m)
% - modified in 2015 for new task time codes
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
    
clear
load dataGuide
% path='C:\Users\vscerra\My Documents\MATLAB\CleanStart\NewTask\Ravi\';
path='C:\Users\vscerra\Documents\MATLAB\CleanStart\github_files\dataFiles_Indy\';
cd(path);  %changes current folder to one specified by the (path)

% d=dir([cdir filename '.dat']);
% d = dir('*.dat');

d = dataGuide;

% DST Task specific variables
types = strvcat('dstS1','dstS2','dstS3','dstS');
goCodes = [8, 9];
tOnCodes = [4, 5];
tRows = [2, 4];
MOE = 6; %requires at most 6 degrees of separation between target and final eye position for it to be considered a correct trial
corr = 0;
% Initializing variables to be used in the loop
k = 0;
trialTab = [];
file_names = [];
vels = cell(1,9000);
eyed = cell(1,9000);
trialInfo = zeros(1391,2);
trialInfo(:,1)=1:1391;
% initializing variables for storing information about aborted trials
ab_nogo = 0; ab_rt = 0; ab_mismatch = 0; ab_Tgt = 0; %initializing variables at 0
trialAb2 = zeros(1,8);
tabAb2 = [];
velsAb2 = cell(1,1000);
eyedAb2 = cell(1,1000);


%%
for j = 1:length(d)
    try
        dat = g_readData(dataGuide(j).name);
        file_names = strvcat(file_names,d(j).name);
        disp(d(j).name)
        for i = 1:size(dat,2)
            try
                if ~isempty(strmatch(dat(i).TYPENAME, types, 'exact'))
                    stateData = dat(i).statedata;
                    k = k+1;
                    % Find when the go command was issued ("goState")
                    goState = goId(stateData, goCodes);
                    if isnan(goState); ab_nogo = ab_nogo+1; trialInfo(k,2) = -9;
                        print('no go state')
                        continue;
                    end
                    
                    % Check if the trial was completed
                    if max(stateData(:,3)) < 10;
                        %disp('State 10 not found completed by subject')
                        trialInfo(k,2) = -3;
                        continue;
                    else
                        
                        % Look for the target information for the trial
                        targetState = targetId(stateData, tOnCodes, tRows);
                        if isnan(targetState)
                            disp('No target state')
                            ab_Tgt = ab_Tgt+1;
                            continue;
                        end
                        tx = dat(i).TAR(targetState,1);
                        ty = dat(i).TAR(targetState,2);
                        trial_no = dat(i).TRIAL(:,1);
                        if (abs(tx) + abs(ty)) == 0
                            continue;
                        else
                            
                            % Calculate the reaction time, filter out trials with bad
                            % reaction times
                            [rt, ex, ey, vel, saccadeStart] = calcVelIndy_Easy(dat(i), goState); %ex=eye x plane, ey = eye y plane, vel = velocity matrix, saccadeStart = saccade start time
                            if rt < 0 %previous line calcs rt, this script checks to see if rt is normal or not
                                %                             disp('bad rt')
                                %                             disp(i)
                                ab_rt = ab_rt+1;
                                trialInfo(k,2) = rt;
                                continue; %don't bother continuing, just stay at the start of the loop, begin next trial
                            end;
                            
                            % Confirm that the analytically determined trial outcome matches
                            % the program trial evaluation
                            calcCorrect = confirmCorrect([tx, ty], [ex, ey], MOE);
                            programCorrect = ~isempty(find(dat(i).statedata(:,3)==12,1)); %looking at the buzzer state to see if monkey was correct
                            if calcCorrect ~= programCorrect %including only matching trials between our correct and gramalkin correct
                                ab_mismatch = ab_mismatch+1; %ab 2 should be low, because if it is high, it means the monkey is getting away with a lot of corrective saccades
                                trialInfo(k,2) = -5;
                                trialAb2 = [tx ty ex ey dat(i).OPLUSA rt calcCorrect dat(i).statedata(goState,1)/2 saccadeStart trial_no j programCorrect];
                                tabAb2 = [tabAb2; trialAb2];
                                velsAb2{ab_mismatch} = vel;
                                eyedAb2{ab_mismatch} = dat(i).eyedata;
                                trialAb2 = zeros(1,8);
                                continue;
                            end;
                            oPlusA = dat(i).OPLUSA;
                            
                            % Populate the temporary trial variable
                            trial = [tx ty ex ey oPlusA rt]; %actual analysis begins here, with the good trials
                            trial(7) = calcCorrect;
                            trial(8) = dat(i).statedata(goState,1)/2; %go signal time
                            trial(9) = saccadeStart;
                            trial(10) = trial_no;
                            trial(11) = j;
                            trial(12) = programCorrect;
                            
                          
                            
                            % Append trial to the compiling trialTab
                            trialTab = [trialTab; trial];
                            tNo = tNo + 1;
                            trialInfo(k,2) = 1;
                            vels{tNo} = vel;
                            eyed{tNo} = dat(i).eyedata;
                        end
                    end
                end
            catch
                trialInfo(k,2) = -5;
                continue;
            end
        end
    catch
        disp('can''t read file');
    end
end
