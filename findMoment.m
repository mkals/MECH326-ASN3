% Takes in vector of shear, V, along the shaft and the number of slices,
% length, taken
function [MList]=findMoment(VList, length)
    % Initialize Vlist vector
    MList = zeros(1, length);
    MList(1) = VList(1);
    for i = 2:length
        MList(i) = MList(i-1) + VList(i);
    end
    
    x = linspace(0, length, length);
    
    % TODO: graph labeling
    plot(x, MList)
end