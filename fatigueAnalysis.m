function safetyFactor = fatigueAnalysis(r,d,D)
% Assume that the critical point in the shaft has been determined.
% r = fillet radius, d = smaller diameter, D = larger diameter
safetyFactor = 0;

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

% End-mill keyseat Kt and Kts for r/d = 0.02
keyKt = 2.14;
keyKts = 3.0;

% Table 11-2 Transverse (row1 = Bore Diameter, row3 = Bearing Width, row4 =
% Fillet Radius).  Note we are supposed to have a fillet radius <= 1mm for
% the gears.
table_112 = [10 30 9 0.6 12.5 27 5.07 2.24 4.94 2.12;
    12 32 10 0.6 14.5 28 6.89 3.10 7.02 3.05;
    15 35 11 0.6 17.5 31 7.80 3.55 8.06 3.65;
    17 40 12 0.6 19.5 34 9.56 4.50 9.95 4.75;
    20 47 14 1.0 25 41 12.7 6.20 13.3 6.55;
    25 52 15 1.0 30 47 14.0 6.95 14.8 7.65;
    30 62 16 1.0 35 55 19.5 10.0 20.3 11.0;
    35 72 17 1.0 41 65 25.5 13.7 27.0 15.0;
    40 80 18 1.0 46 72 30.7 16.6 31.9 18.6;
    45 85 19 1.0 52 77 33.2 18.6 35.8 21.2;
    50 90 20 1.0 56 82 35.1 19.6 37.7 22.8;
    55 100 21 1.5 63 90 43.6 25.0 46.2 28.5;
    60 110 22 1.5 70 99 47.5 28.0 55.9 35.5;
    65 120 23 1.5 74 109 55.9 34.0 63.7 41.5;
    70 125 24 1.5 79 114 61.8 37.5 68.9 45.5;
    75 130 25 1.5 86 119 66.3 40.5 71.5 49.0;
    80 140 26 2.0 93 127 70.2 45.0 80.6 55.0;
    85 150 28 2.0 99 136 83.2 53.0 90.4 63.0;
    90 160 30 2.0 104 146 95.6 62.0 106 73.5;
    95 170 32 2.0 110 156 108 69.5 121 85.0]';

end