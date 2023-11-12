% 51.2 points for 30 deg.
% 75% of 4096 a/d range = 3072 available points
% 3072 points/(30 degrees * 2 sides) = 51.2 points/30 degree
% => 0.5859 degrees per point
% => 1.7067 points per degree
% velocity[i] = (-2 * x[i-2] - x[i-1] + x[i+1] + 2 * x[i+2])/10H where H is
% the sampling rate in sec (=0.002 in our case)

% Veronica Scerra, 11/2023

function [rt ex ey vel ss] = calcVelIndy_Easy(trial, fixIdx)%this takes each dat trial, fixIdx is the gap row in statedata (8 or 9)
e = trial.eyedata;
vel = zeros(1,size(e,1)-3);
pos = sqrt(e(:,1).*e(:,1) + e(:,2).*e(:,2));   %plotted eyedata and velocities to come up with threshold(th)
th = 150; % 300 for Ravi
wTh = 2000; % weirdly high velocity, don't count this blip as saccade.
saccTh = 30; % velocity threshold at which RT is computed
for i = 3:size(e,1)-3
    vel(i-2) = (-2*pos(i-2) - pos(i-1) + pos(i+1) + 2*pos(i+2))/(10*0.002);%formula taken from eye move to calc vel
end
ss = 0;
rt = -1; %if you get this returned = abnormal trial
ex = 0; ey = 0;
go = trial.statedata(fixIdx,1);
i = go/2;
if i>=length(vel); return; end %vel is same length as 2 elements less than eyedata matrix, this say that if the velocity matrix is smaller than time of go signal abort trial
while 1  %actual computation of ss
    velId = find(vel(i+1:end)>th, 1);%find 1st point at which vel is greater than th but after go signal
    if isempty(velId); return; end %if there is no ss in whole (only way isempty(velId)
    velId = velId + i;
    if vel(velId+1)>th && vel(velId+1)>=vel(velId)
        if vel(velId+1)>=wTh || vel(velId+2)>=wTh || vel(velId+3)>=wTh
            velId = find(vel(i+1:end)<th, 1); %this line finds the end of the blip, if the above line discovers a blip of wth
            if isempty(velId); return; end
            velId = velId + i;
        else
            ss = velId;
            break;       
        end
    end
    i = velId;
end
i = velId;
while 1
    velId = find(vel(i+1:end)<th, 1);%looks for trials where the vel curve is incomplete, vel curve should have up and dw slope
    if isempty(velId); return; end
    velId = velId + i;
    if vel(velId+1)<th && vel(velId+1)<=vel(velId)
        break;
    end
    i = velId;
end
if ss*2-go> 400; rt = -2; return; end % 600 for TAFC task, 400 for delayed saccade
%if you get -2, abnormal in the sense that it was a delayed or late
%saccade, ss*2-go should be less than the overall trial time for a normal
%saccade
% ex = e(saccStart+15,1);
% ey = e(saccStart+15,2);
ex = e(velId,1);%looking at the eye positions at the 150 mark, they should be near the target so that we can call it a correct or incorrect trial
ey = e(velId,2);
velId = ss;
while vel(velId)>saccTh %backtracking trying to find the time point where it goes below 50
    velId = velId-1;
end
rt = (velId+1)*2 - go; %%getting the actual rt
% rt = saccStart*2 - go;
return;