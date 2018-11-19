% Returns safety factor
% Inputs:
% VList - Vector of shear
% MList - Vector of moment
% TList - Vector of torsion
% dList - Vector of diameters
% S_ut - Ultimate Tensile Strength
% length - Number of slices taken
function safetyFactor = yieldAnalysis(VList, MList, TList, dList, S_y, length)
    
    rList = (dList./2).*1e-3;
    A = pi*rList.^2;
    
    sigma_bending = zeros(1, length);
    tau_torsion = zeros(1, length);
    
    %% Find max shear stress: tau_shear = F/A
    tau_shear = VList./A;    
    
    [maxTauShear, indexMaxTauShear] = max(tau_shear);
    safetyFactorShear = S_y / maxTauShear
    
    %% Find max bending stress: sigma = (M*y)/I
    I = pi/16*rList.^4;
    sigma_bending = MList.*rList./I;

    %% Find max Torsion stress: tau_torsion = (T*r)/J
    J = 2*I;
    tau_torsion = TList.*rList./J;

    % Using eq 7-15
    sigma_max = (sigma_bending.^2 + 3*tau_torsion.^2 ).^(1/2);
    
    [maxSigma, indexMaxSigma] = max(sigma_max);
    
    safetyFactorBendingTorsion = S_y / maxSigma
    
    %% Find safety factor of entire shaft
    safetyFactor = min([safetyFactorShear, safetyFactorBendingTorsion]);
end