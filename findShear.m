% Takes in vector of forces, F, along the shaft and the number of slices,
% length, taken
function [VList]=findShear(FList, length)
    % Initialize Vlist vector
    VList = zeros(1, length);
    VList(1) = FList(1);
    for i = 2:length
        VList(i) = VList(i-1) + FList(i);
    end
    
    x = linspace(0, length, length);
    
    % TODO: graph labeling
    plot(x, VList)
end