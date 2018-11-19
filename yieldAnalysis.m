% Returns safety factor
% Inputs:
% VList - Vector of shear
% MList - Vector of moment
% TList - Vector of torsion
% dList - Vector of diameters
% S_ut - Ultimate Tensile Strength
% length - Number of slices taken
function safetyFactor = yieldAnalysis(VList, MList, TList, dList, S_ut, length)
    safetyFactor = 0;
    rList = (dList./2).*1e-3;
    tau_shear = zeros(1, length);
    sigma = zeros(1, length);
    tau_torsion = zeros(1, length);
    
    A = zeros(1, length);
    I = zeros(1, length);
    
    %% Find max shear stress: tau_shear = F/A
    for i = 1:length
        A(i) = pi*(rList(i))^2;
        tau_shear(i) = VList(i) / A(i);
    end
    
    %% Find max bending stress: sigma = (M*y)/I
    for i = 1:length
        I(i) = (pi/64)*(2*rList(i))^4;
        sigma(i) = MList(i)*(dList(i)/2) / I(i);
    end
    
    %% Find max Torsion stress: tau_torsion = (T*r)/J
    for i = 1:length
        J(i) = 2 * I(i);
        tau_torsion(i) = TList(i)*(dList(i)/2) / J(i);
    end
    
    [maxTauShear, indexMaxTauShear] = max(tau_shear);
    [maxSigma, indexMaxSigma] = max(sigma);
    [maxTauTorsion, indexMaxTauTorsion] = max(tau_torsion);
    
    safetyFactorShear = S_ut / maxTauShear
    safetyFactorBending = S_ut / maxSigma
    safetyFactorTorsion = S_ut / maxTauTorsion
    
    safetyFactor = min([safetyFactorShear, safetyFactorBending, safetyFactorTorsion]);
end