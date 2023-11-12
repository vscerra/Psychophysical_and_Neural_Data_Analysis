function [targetState] = targetId(stateData, tOnCodes, tRows)
% targetId: This function takes the stateData for a trial (from the dat structure)
% and the codes assigned to the "target-on" state and returns the stateData row corresponding
% to the "target-on" command

% [targetState] = targetId(stateData, tOnCodes, tRows)

% Inputs : 
    % stateData : matrix of values from the dat structure containing state
            % start times, end times, and the state "code"
    % tOnCodes : values from the timing files for the "target-on" state recorded in
            % the stateData, these vary by task
    % tRows : row ids from the targetData field that correlated the
            % "target-on" state with specific target presentations from the stimuli
            % files
% Outputs : 
    % targetState : this is the row number corresponding to the data for the
            % "target-on" command in the data structure
            
% Veronica Scerra, 2023
targetState = [];
for i = 1:length(tOnCodes)
    tarRow = find(stateData(:,3) == tOnCodes(i), 1);
    if ~isempty(tarRow)
        targetState = tRows(i);
        break
    else
        continue
    end
end 
if isempty(targetState)
    targetState = NaN;
end
end