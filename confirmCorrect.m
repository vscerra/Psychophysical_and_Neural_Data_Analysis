function [calcCorrect] = confirmCorrect(tLoc, eyeLoc, MOE)
% CONFIRMCORRECT : This function compares eye location to target location
% to verify the calculated trial success 

%  [calcCorrect] = confirmCorrect(tLoc, eyeLoc, MOE)

% Inputs: 
    % tLoc : 2-element vector with target X,Y location
    % eyeLoc : 2-element vector with eye X,Y location
    % MOE : margin of error allowable in eye-target match up
   
% Veronica Scerra, 11/23
    
compX = abs(tLoc(1) - eyeLoc(1)); %looks at where monkey's eyes are in relation to where the targets are
compY = abs(tLoc(2) - eyeLoc(2)); %subtract target value from the monkey's eye values, tells you how far his eyes are from a target in a given trial
                   
if tLoc(1) >= -3 && tLoc(1) <= 3 %only looking at the larget number of the two target coordinate values
   calcCorrect = sign(tLoc(2)) == sign(eyeLoc(2)) && compX < MOE && compY < MOE;
elseif tLoc(2) >= -3 && tLoc(2) <= 3
   calcCorrect = sign(tLoc(1)) == sign(eyeLoc(1)) && compX < MOE && compY < MOE; %accurate or inaccurate
else
   calcCorrect = sign(tLoc(1)) == sign(eyeLoc(1)) && sign(tLoc(2)) == sign(eyeLoc(2)) && compX < MOE && compY < MOE;
end
end