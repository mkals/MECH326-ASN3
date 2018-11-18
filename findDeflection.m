function y = findDeflection(x, d, xs, M, E)
    I = pi/64*(d*1e-3).^4;
    
    yxx = M./(E*I);
    yx = zeros(size(x));
    yNoConst = zeros(size(x));
    for i = 2:length(x)
        yx(i) = trapz(x(1:i),yxx(1:i));
        yNoConst(i) = trapz(x(1:i),yx(1:i));
    end
    
    yp = @(s) ppval(pchip(yNoConst,x),s);
    
    C = -yp(xs(2));
    
    C = A\b
    y = yNoConst + C(1)*x + C(2);
end
