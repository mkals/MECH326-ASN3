% Main script
g = 9.81;
shaftSpeed = 300*2*pi/60; %rad/s

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
leftPoint = 0;
rightPoint = 575e-3;

N = 1000; % num points

% 1020 Cold Drawn Carbon Steel
% https://www.makeitfrom.com/material-properties/Cold-Drawn-1020-Carbon-Steel/
E = 190e9; % Young's modulus
rho = 7.9e3; %kg/m^3

x = linspace(leftPoint, rightPoint, N);
dx = (rightPoint-leftPoint)/(N-1);

% Initial guess based on previous runs
d1 = 45; d2 = 55; d3 = 65; d4 = 80; d5 = 60;

iX = @(x) int16(x/dx)+1;
xShoulder = [0.000 0.150 0.440 0.460 0.485 0.575];
iShoulder = iX(xShoulder);

% Make diameter vector
dVec = zeros(1,N);
dVec(iShoulder(1):iShoulder(2)) = d1;
dVec(iShoulder(2):iShoulder(3)) = d2;
dVec(iShoulder(3):iShoulder(4)) = d3;
dVec(iShoulder(4):iShoulder(5)) = d4;
dVec(iShoulder(5):iShoulder(6)) = d5;

% Forces along shaft (N)
F = [1.59e3*ones(1,190) -1.28e3*ones(1,667) 3.86e3*ones(1,143)];

% weight vector
W = pi/4*(dVec*1e-3).^2*rho * g; %weight of shaft
W(iX(0.100)) = W(iX(0.100)) + 48.2*g; % add weight of spur gear
W(iX(0.525)) = W(iX(0.525)) + 5.9*g;  % add weight of worm gear
% figure(6) % plot weights
% plot(x,W)

F = F - W; % Add weights to force, acting in the -y direction

% Moment along shaft (Nm)
for i=1:N
   M(i) = mean(F(1:i))*x(i); 
end

F(end) = 0;

% Torque along shaft
T = [zeros(1,190) 540*ones(1,810)];
T(end) = 0;

% Axial Force along shaft
F_axial = [zeros(1,856) 22.4e3*ones(1,144)];
F_axial(end) = 0;

figure(1)
subplot(2,2,1)
plot(x,F)
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
Ma = M(ceil(475/525*N)); % Nm
Tm = 540; % Nm

for i=1:length(table_112(:,1))
    d = table_112(i,1);
    D = 1.3*d;
    r = table_112(i,4);
    if r>1
        r=1;
    end
    n4 = fatigueAnalysis(r,d,D,Ma,Tm);
    if n4 >= 3
        d5 = d;
        [~, index] = min(abs(table_112(:,1)-D));
        d4 = table_112(index,1);
        break
    end
end

% Next check interface for right bearing and its shoulder.
Ma = M(ceil(450/525*N)); % Nm
Tm = 540; % Nm

[~, index] = min(abs(table_112(:,1)-d4/1.2));
d3 = table_112(index,1);
r = table_112(index,4);
if r>1
    r=1;
end
n3 = fatigueAnalysis(r,d3,d4,Ma,Tm);

% Next check interface for right bearing shoulder and longer part of the 
% shaft.
Ma = M(ceil(450/525*N)); % Nm
Tm = 540; % Nm

[~, index] = min(abs(table_112(:,1)-d3/1.2));
d2 = table_112(index,1);
r = table_112(index,4);
if r>1
    r=1;
end
n2 = fatigueAnalysis(r,d3,d4,Ma,Tm);

% Next check interface for left bearing shoulder.
Ma = M(ceil(100/525*N)); % Nm
Tm = 0; % Nm

[c, index] = min(abs(table_112(:,1)-d2/1.2));
d1 = table_112(index,1);
r = table_112(index,4);
if r>1
    r=1;
end
n1 = fatigueAnalysis(r,d3,d4,Ma,Tm);

% Shaft contour
contour = [d1*ones(1,190) d2*ones(1,619) d3*ones(1,48) d4*ones(1,48) d5*ones(1,95)];

% Compute deflection and check values
xBearings = [0.000 0.450]; % bearing locations
xGears    = [0.100 0.525]; % gear locations

xBearingsIndex = int16(xBearings/dx)+1;
xGearsIndex = int16(xGears/dx)+1;

[y, yx] = findDeflection(x, contour, xBearings, M, E);

inToMm = 25.4; % converting inches to mm

figure(4)
plot(x,y*1e3);
title('Deflection')
xlabel('Position (m)'); ylabel('Deflection (mm)');
fprintf('Deflection at spur gear is %.1e mm and at worm it is %.1e mm.\n', y(xGearsIndex(1))*1e3, y(xGearsIndex(1))*1e3)
% Both gears have > 3 teeth/inch
fprintf('Max deflection at spur gear is %.1e mm and at worm it is %.1e mm.\n\n', 0.01*inToMm, 0.01*inToMm)

figure(5)
plot(x,yx)
title('Slope')
xlabel('Position (m)'); ylabel('Slope (rad)');
[yxmax, imax] = max(yx);
fprintf('Slope at bearing A is %.1e rad and at B it is %.1e rad.\n', yx(xBearingsIndex(1)), yx(xBearingsIndex(2)))
% Assume deep-groove ball bearing at A and tapered roller bearing at B.
fprintf('Max slope at bearing A is %.1e rad and at B it is %.1e rad.\n\n', 0.001, 0.0005)

% Check deflection
maxSpeed = findCriticalSpeed(x, y, W); %rad/s
assert(shaftSpeed < maxSpeed);

% Plot final shaft design
figure(2)
hold on
plot(x,contour/2, 'b')
plot(x,-contour/2, 'b')
plot(x(1)*[1 1], [1 -1]*contour(1)/2, 'b')
plot(x(end)*[1 1], [1 -1]*contour(end)/2, 'b')
hold off
%axis([0 550e-3 30 70])
xlabel('Position (m)'); ylabel('Shaft Outline (mm)');

%close all

