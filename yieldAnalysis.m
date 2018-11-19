% Returns safety factor
% Inputs:
% VList - Vector of shear
% MList - Vector of moment
% TList - Vector of torsion
% dList - Vector of diameters
% S_ut - Ultimate Tensile Strength
% length - Number of slices taken
function safetyFactor = yieldAnalysis(VList, MList, TList, dList, S_y, length)
    safetyFactor = 0;
    rList = (dList./2).*1e-3;
    tau_shear = zeros(1, length);
    sigma_bending = zeros(1, length);
    tau_torsion = zeros(1, length);
    
    A = zeros(1, length);
    I = zeros(1, length);
    
    %% Find max shear stress: tau_shear = F/A
    for i = 1:length
        A(i) = pi*(rList(i))^2;
        tau_shear(i) = VList(i) / A(i);
    end
    
    [maxTauShear, indexMaxTauShear] = max(tau_shear);
    safetyFactorShear = S_y / maxTauShear
    
    %% Find max bending stress: sigma = (M*y)/I
    %% Find max Torsion stress: tau_torsion = (T*r)/J
    for i = 1:length
        I(i) = (pi/64)*(2*rList(i))^4;
        J(i) = 2 * I(i);
        
        sigma_bending(i) = MList(i)*(dList(i)/2) / I(i);
        tau_torsion(i) = TList(i)*(dList(i)/2) / J(i);
        
        % Using eq 7-15
        sigma_max(i) = ( (sigma_bending(i))^2 + 3*(tau_torsion(i))^2 )^(1/2);
    end
    
    [maxSigma, indexMaxSigma] = max(sigma_max);
    
    safetyFactorBendingTorsion = S_y / maxSigma
    
    %% Find safety factor of entire shaft
    safetyFactor = min([safetyFactorShear, safetyFactorBendingTorsion]);
end