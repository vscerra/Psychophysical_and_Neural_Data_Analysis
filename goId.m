function [goState] = goId(stateData, goCodes)
% goId: This function takes the stateData for a trial (from the dat structure)
% and the codes assigned to the "go" and returns the stateData row corresponding
% to the "go" command

%  [goState] = goId(stateData, goCodes)

% Inputs : 
    % stateData : matrix of values from the dat structure containing state
            % start times, end times, and the state "code"
    % goCodes : values from the timing files for the "go" state recorded in
            % the stateData, these vary by task
% Outputs : 
    % goState : this is the row number corresponding to the data for the
            % "go" command in the data structure
            
% Veronica Scerra, 2023
goState = [];
for i = 1:length(goCodes)
    goState = find(stateData(:,3) == goCodes(i));
    if ~isempty(goState)
        break
    else
        continue
    end
end 
if isempty(goState)
    goState = NaN;
end
end
