function [y, yx] = findDeflection(x, d, xs, M, E)
    I = pi/64*(d*1e-3).^4;
    
    % Perform numeric integration along the shaft
    yxx = M./(E*I);
    yx = zeros(size(x));
    y = zeros(size(x));
    for i = 2:length(x)
        yx(i) = trapz(x(1:i),yxx(1:i));
        y(i) = trapz(x(1:i),yx(1:i));
    end
    
    % Interpolate deflection to get continous function
    yp = @(s) ppval(pchip(x,y), s);
    
    % Determine integration constants
    A = [xs(1) 1; 
         xs(2) 1];
    b = -[yp(xs(1)) yp(xs(2))]';
    C = A\b; % vector containing constants
    
    yx = yx + C(1);
    y  = y  + C(1)*x + C(2);
end
