function safetyFactor = fatigueAnalysis(r,d,D,Ma,Tm)
% Assume that the critical point in the shaft has been determined.
% r = fillet radius, d = smaller diameter, D = larger diameter (all in mm)
% Ma = alternating moment, Tm = midrange torque
safetyFactor = 0;

% 1020 Cold Drawn Carbon Steel
% https://www.makeitfrom.com/material-properties/Cold-Drawn-1020-Carbon-Steel/
Sut = 460e6; %Pa (67e3 psi)
Sy = 380e6; %Pa (55e3 psi)
Se_prime = 250e6; %Pa (36e3 psi)

% Marin Factors
ka = (4.51)*(Sut/1e6)^(-0.265); %Surface factor for cold drawn Steel
if (d >= 2.79 && d <= 51) %Size factor
    kb = (1.24)*d^(-0.107);
elseif (d > 51 && d <= 254)
    kb = (1.51)*d^(-0.157);
end
kc = 1; %Loading factor for bending
kd = 1; %Temperature factor
ke = 1; %Reliability factor, assume perfect reliability
kf = 1; %Miscellaneous effects factor

Se = ka*kb*kc*kd*ke*kf*Se_prime;

% Notch Sensitivity
sqrta = 0.246-3.08e-3*(67)+1.51e-5*(67)^2-2.67e-8*(67)^3; %Equation 6-35a
q = 1/(1+sqrta/sqrt(r/0.04)); %Equation 6-34 can be used for shear

% Stress concentration factors for the shoulder in question.
% www.amesweb.info/StressConcentrationFactor/SteppedShaftWithShoulderFillet.aspx
h = (D-d)/r;

if (h >= 0.1 && h <= 2)
    C1 = 0.947+1.206*sqrt(h)-0.131*h;
    C2 = 0.022-3.405*sqrt(h)+0.915*h;
    C3 = 0.869+1.777*sqrt(h)-0.555*h;
    C4 = -0.81+0.422*sqrt(h)-0.26*h;
elseif (h >= 2)
    C1 = 1.232+0.832*sqrt(h)-0.008*h;
    C2 = -3.813+0.968*sqrt(h)-0.26*h;
    C3 = 7.423-4.868*sqrt(h)+0.869*h;
    C4 = -3.839+3.070*sqrt(h)-0.6*h;
end

% 0.25 <= (D-d)/r <= 4
C5 = 0.905+0.783*sqrt(h)-0.075*h;
C6 = -0.437-1.969*sqrt(h)+0.553*h;
C7 = 1.557+1.073*sqrt(h)-0.578*h;
C8 = -1.061+0.171*sqrt(h)+0.086*h;

Kt = C1+C2*(2*(D-d)/D)+C3*(2*(D-d)/D)^2+C4*(2*(D-d)/D)^3;
Kts = C5+C6*(2*(D-d)/D)+C7*(2*(D-d)/D)^2+C8*(2*(D-d)/D)^3;

Kf = 1+q*(Kt-1);
Kfs = 1+q*(Kts-1);

% Safety factor calculation using Soderberg criterion
n = 16/(pi*(d/1000)^3)*((2*Kf*Ma/Se)+3^(1/2)*(Kfs*Tm/Sy));
safetyFactor = 1/n;
end