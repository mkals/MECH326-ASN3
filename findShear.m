% Takes in vector of forces, F, along the shaft and the number of slices,
% length, taken
function [Vlist]=findShear(Flist, length)
    % Initialize Vlist vector
    Vlist = zeros(1, length);
    Vlist(1) = Flist(1);
    for i = 2:length
        Vlist(i) = Vlist(i-1) + Flist(i);
    end
    
    x = linspace(0, length, length);
    
    % TODO: graph labeling
    plot(x, Vlist)
end