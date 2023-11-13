function [nData, binId, dataMetric] = plot_histogram(data, binRange, plotMetric, color, add_on)
%PLOT_HISTOGRAM function takes input data and binRange(opt), to return a
%figure, nData, binId, and dataMetric. 

% [nData, binId, dataMetric] = plot_histogram(data, binRange, plotMetric, color, add_on)

% INPUTS: 
    % data: vector of the data you want binned and plotted
    % binRange: optional 3-element vector designating the min and max of
    % the bins as well as desired bin size ([minVal, maxVal, binSize])
    % the optional 4th input is the color you want for bar faces - default
        % is blue
% OUTPUTS: 
    % a figure with the histogram
    % nData: 1 x number_of_bins vector with the number of cases per bin
    % binId: 1 x length(data) vector indicating the bin number of each data
        % point

% Veronica Scerra, 11/2023

if nargin < 4
    color = [.2 0 .9];
end


bins = binRange(1):binRange(3):binRange(2);
[nData, binId] = histc(data, bins);
dataMetric = plotMetric(data);

bar(bins, nData,'FaceColor',color)
hold on
box off
xlim([binRange(1), binRange(2)])

if nargin < 5 || add_on == 0
fact = floor(log10(max(nData)));
y_max = (ceil(max(nData) / 10^fact)) * 10^fact;
ylim([0, y_max])
ylabel('number of trials')
set(gca, 'TickDir', 'out', 'Ytick', [0, y_max/2, y_max])
end
end

