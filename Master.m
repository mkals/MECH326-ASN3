% Main script
clear;
g = 9.81;
shaftSpeed = 300*2*pi/60; % rad/s

inToMm = 25.4; % converting inches to mm

% Table 11-2 Transverse (col1 = Bore Diameter, col3 = Bearing Width, col4 =
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
    95 170 32 2.0 110 156 108 69.5 121 85.0];

% length range (m)
leftPoint = -20e-3;  % m
rightPoint = 575e-3; % m

N = 1000; % num points

% Choose 1020 Cold Drawn Carbon Steel
% https://www.makeitfrom.com/material-properties/Cold-Drawn-1020-Carbon-Steel/
E = 190e9;      % Young's modulus
rho = 7.9e3;    % kg/m^3

%% Define x-dimension and location of shoulders, forces and components
x = linspace(leftPoint, rightPoint, N);
dx = (rightPoint-leftPoint)/(N-1);

xBearing  = [0.000 0.450];             % bearing locations
xGear     = [0.100 0.525];             % gear locations
xShoulder = [0.150 0.440 0.460 0.475]; % shoulder locations
xForce    = [0.000 0.100 0.450 0.525]; % force locations

% Compute index in x-vector
iX = @(x) int16((x-leftPoint)/dx)+1;
iBearing   = iX(xBearing);
iGear      = iX(xGear);
iShoulder  = iX(xShoulder);
iForce     = iX(xForce);

% Initial guess of segment dimaters based on previous runs
dnVec = [35 45 55 65 50];

% Make diameter vector
dVec = zeros(1,N);
dVec(1:iShoulder(1)) = dnVec(1); 
dVec(iShoulder(1):iShoulder(2)) = dnVec(2);
dVec(iShoulder(2):iShoulder(3)) = dnVec(3);
dVec(iShoulder(3):iShoulder(4)) = dnVec(4);
dVec(iShoulder(4):N) = dnVec(5);

% Forces along shaft (N)
% Includes forces on gears and weight of gears
V = zeros(1,N);
V(iForce(1):iForce(2)) = 1.59e3;  % N
V(iForce(2):iForce(3)) = -1.28e3; % N
V(iForce(3):iForce(4)) = 3.86e3;  % N

% Consider weight of shaft
W = pi/4*(dVec*1e-3).^2 *dx*rho*g; % weight of shaft
shaftWeight = sum(W);
shaftCentroid = sum(W.*x)/shaftWeight;

% Weight reactions from bearings
Wr = 0*x;
Wr(iBearing(1)) = (shaftCentroid-xBearing(1))/(xBearing(2)-xBearing(1))*shaftWeight;
Wr(iBearing(2)) = (xBearing(2)-shaftCentroid)/(xBearing(2)-xBearing(1))*shaftWeight;

% compute sheer due to weight associated reactions
Vw = 0*x;
for index = 1:N
   Vw(index) = sum(Wr(1:index)-W(1:index)); 
end
V = V + Vw; % Add sheer form weights to other sheer
V(end) = 0;

% Moment along shaft (Nm)
for i=1:N
   M(i) = mean(V(1:i))*x(i); 
end

% Torque along shaft
T = zeros(1,N);
T(iGear(1):iGear(2)) = 540; % Nm

% Axial Force along shaft
F_axial = zeros(1,N);
F_axial(iShoulder(3):iShoulder(4)) = 22.4e3; % N

figure(1)
subplot(2,2,1)
plot(x,V)
xlabel('Position (m)')
ylabel('Shear Force (N)')
subplot(2,2,2)
plot(x,M)
xlabel('Position (m)')
ylabel('Moment (Nm)')
subplot(2,2,3)
plot(x,T)
xlabel('Position (m)')
ylabel('Torque (Nm)')
subplot(2,2,4)
plot(x,F_axial)
xlabel('Position (m)')
ylabel('Axial Force (N)')

% Critical location is at left shoulder for the worm gear (high moment,
% torque and axial loading present, large change in radii).
Ma = M(iShoulder(4)); % Nm
Tm = T(iShoulder(4));     % Nm

for i=1:length(table_112(:,1))
    d = table_112(i,1);
    D = 1.3*d;
    r = min([table_112(i,4) 1]); % set radi to reccomended radii but cap at 1mm
    n4 = fatigueAnalysis(r,d,D,Ma,Tm);
    if n4 >= 3
        d5 = d;
        [~, index] = min(abs(table_112(:,1)-D));
        d4 = table_112(index,1);
        break
    end
end

% Next check interface for right bearing and its shoulder.
Ma = M(iShoulder(3)); % Nm
Tm = T(iShoulder(3)); % Nm

[~, index] = min(abs(table_112(:,1)-d4/1.2));
d3 = table_112(index,1);
r = min([table_112(index,4) 1]);
n3 = fatigueAnalysis(r,d3,d4,Ma,Tm);

% Next check interface for right bearing shoulder and longer part of the 
% shaft.
Ma = M(iShoulder(2)); % Nm
Tm = T(iShoulder(2)); % Nm

[~, index] = min(abs(table_112(:,1)-d3/1.2));
d2 = table_112(index,1);
r  = min([table_112(index,4) 1]);
n2 = fatigueAnalysis(r,d3,d4,Ma,Tm);

% Next check interface for left bearing shoulder.
Ma = M(iShoulder(1)); % Nm
Tm = T(iShoulder(1)); % Nm

[c, index] = min(abs(table_112(:,1)-d2/1.2));
d1 = table_112(index,1);
r  = min([table_112(index,4) 1]);
n1 = fatigueAnalysis(r,d3,d4,Ma,Tm);

% Shaft diameters
assert(dnVec(1)==d1, 'd1 guess wrong')
assert(dnVec(2)==d2, 'd2 guess wrong')
assert(dnVec(3)==d3, 'd3 guess wrong')
assert(dnVec(4)==d4, 'd4 guess wrong')
assert(dnVec(5)==d5, 'd5 guess wrong')

% Compute deflection and check values
[y, yx] = findDeflection(x, dVec, xBearing, M, E);

figure(4)
plot(x,y*1e3);
title('Deflection')
xlabel('Position (m)'); ylabel('Deflection (mm)');
fprintf('Deflection at spur gear is %.1e mm and at worm it is %.1e mm.\n', y(iGear(1))*1e3, y(iGear(1))*1e3)
% Both gears have > 3 teeth/inch
fprintf('Max deflection at spur gear is %.1e mm and at worm it is %.1e mm.\n\n', 0.01*inToMm, 0.01*inToMm)

figure(5)
plot(x,yx)
title('Slope')
xlabel('Position (m)'); ylabel('Slope (rad)');
[yxmax, imax] = max(yx);
fprintf('Slope at bearing A is %.1e rad and at B it is %.1e rad.\n', yx(iBearing(1)), yx(iBearing(2)))
% Assume deep-groove ball bearing at A and tapered roller bearing at B.
fprintf('Max slope at bearing A is %.1e rad and at B it is %.1e rad.\n\n', 0.001, 0.0005)

% Check critical speed
maxSpeed = findCriticalSpeed(x, y, W); %rad/s
assert(shaftSpeed < maxSpeed, 'Shaft critical speed too low');

% Plot final shaft design
figure(2)
hold on
plot(x,dVec/2, 'b')
plot(x,-dVec/2, 'b')
plot(x(1)*[1 1], [1 -1]*dVec(1)/2, 'b')
plot(x(end)*[1 1], [1 -1]*dVec(end)/2, 'b')
hold off
%axis([0 550e-3 30 70])
xlabel('Position (m)'); ylabel('Shaft Outline (mm)');

%close all