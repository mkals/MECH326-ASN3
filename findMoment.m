% Takes in vector of shear, V, along the shaft and the number of slices,
% length, taken
function [Mlist]=findMoment(Vlist, length)
    % Initialize Vlist vector
    Mlist = zeros(1, length);
    Mlist(1) = Vlist(1);
    for i = 2:length
        Mlist(i) = Mlist(i-1) + Vlist(i);
    end
    
    x = linspace(0, length, length);
    
    % TODO: graph labeling
    plot(x, Mlist)
end