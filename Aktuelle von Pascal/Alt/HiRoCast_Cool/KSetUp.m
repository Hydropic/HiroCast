%body0 = rigidBody('body0');
%jnt0 = rigidBodyJoint('base_link-base','fixed');
%body0.Joint = jnt0;

robot = rigidBodyTree;
robot.DataFormat = 'row';
%addBody(robot,body0,'base');

%%Roboter bauen
body1 = rigidBody('body1');
jnt1 = rigidBodyJoint('jnt1', 'revolute');
jnt1.PositionLimits = [deg2rad(-185),deg2rad(185)];
jnt1.HomePosition = deg2rad(0);

tform = [cos(pi)    0 sin(pi)   0;
         0          1 0         0;
         -sin(pi)   0 cos(pi)   0.5225;
         0          0 0         1];
setFixedTransform(jnt1,tform);
body1.Joint = jnt1;

addBody(robot,body1,'base');

%%Body2
body2 = rigidBody('body2');
jnt2 = rigidBodyJoint('jnt2','revolute');
%AW Software:
%jnt2.PositionLimits = [-0.698132,+1.91986];
jnt2.HomePosition = deg2rad(-90);
jnt2.PositionLimits = [deg2rad(-130), deg2rad(14)];
%Beta pi/2 
tform2 =    [cos(-pi/2)  0   sin(-pi/2)   0;
             0          1   0           -0.5;
             -sin(-pi/2) 0   cos(-pi/2)   -0.5225;
             0          0   0           1];
setFixedTransform(jnt2,tform2);
body2.Joint = jnt2;
addBody(robot,body2,'body1');

%%Body3
body3 = rigidBody('body3');
jnt3 = rigidBodyJoint('jnt3','revolute');
%AW Software:
%jnt3.PositionLimits = [-3.21141,+1.0472];
%LFF:
jnt3.PositionLimits = [deg2rad(-100), deg2rad(144)];
jnt3.HomePosition = deg2rad(0);
tform3 =    [cos(pi)  -sin(pi)   0      0;
             sin(pi)   cos(pi)   0   -1.3;
             0           0       1      0;
             0           0       0      1];
setFixedTransform(jnt3,tform3);
body3.Joint = jnt3;
addBody(robot,body3,'body2');

%%Body4
body4 = rigidBody('body4');
jnt4 = rigidBodyJoint('jnt4','revolute');
%Software:
%jnt4.PositionLimits = [-6.10865,+6.10865];
%AW LFF:
jnt4.PositionLimits = [deg2rad(-350), deg2rad(350)];
jnt4.HomePosition = 0;
tform4 =    [1  0           0           0;
             0  cos(pi/2)   -sin(pi/2)   0.712;
             0  sin(pi/2)   cos(pi/2)     0;
             0  0           0           1];

setFixedTransform(jnt4,tform4);
body4.Joint = jnt4;
addBody(robot,body4,'body3');

%%Body5
body5 = rigidBody('body5');
jnt5 = rigidBodyJoint('jnt5','revolute');
%AW Software:
%jnt5.PositionLimits = [-2.05949,+2.05949];
%AW LFF:
jnt5.PositionLimits = [deg2rad(-120), deg2rad(120)];
jnt5.HomePosition = deg2rad(0);
tform5 =    [1  0           0               0;
             0  cos(-pi/2)   -sin(-pi/2)      0;
             0  sin(-pi/2)   cos(-pi/2)       -0.313;
             0  0           0               1];
setFixedTransform(jnt5,tform5);
body5.Joint = jnt5;
addBody(robot,body5,'body4');

%%Body6
body6 = rigidBody('body6');
jnt6 = rigidBodyJoint('jnt6','revolute');
%AW Software:
%jnt6.PositionLimits = [-6.10865,+6.10865];
%AW LFF:
jnt6.PositionLimits = [deg2rad(-350),deg2rad(350)];
jnt6.HomePosition = 0;
tform6 =    [1      0           0                0;
             0      cos(pi/2)   -sin(pi/2)       0.29;
             0      sin(pi/2)   cos(pi/2)        0;
             0      0           0                1];
setFixedTransform(jnt6,tform6);
body6.Joint = jnt6;
addBody(robot,body6,'body5');

%%Endeffector
bodyEndEffector = rigidBody('endeffector');
R7 = RotationUmZ(deg2rad(30))*RotationUmY(deg2rad(90))*RotationUmX(deg2rad(-90))*RotationUmZ(deg2rad(-45));
V7 = [0 0 -0.450];
tform7 = [R7    V7';
          0 0 0 1];
setFixedTransform(bodyEndEffector.Joint,tform7);
addBody(robot,bodyEndEffector,'body6');

%wichtig für Laufbahn
robot.DataFormat = 'row';

%%Roboter Anzeigen
%homeConfiguration(robot) = deg2rad([183.97 -71.08 -108.01 62.40 -58.35 -75.11]);
KUKA = show(robot);
KUKA.XLim = [-4, 4];
KUKA.YLim = [-4, 4];
KUKA.ZLim = [0,4.5];

%show(robot, deg2rad([0 -90 100 0 0 0]));

% %before this you have plotted a surface in axis hAx
% axis(hAx,'equal')
% %Get X, Y and Z data for plotting the axes...
% X_range = hAx.XLim(2) - hAx.XLim(1);
% X_start = hAx.XLim(1);
% X_delta = X_range/20;
% 
% Y_delta = (hAx.YLim(2) - hAx.YLim(1))/20;
% Y_start = hAx.YLim(1);
% 
% Z_delta = (hAx.ZLim(2) - hAx.ZLim(1))/20;
% Z_start = hAx.ZLim(1);
% 
% X_Line = line(hAx,[X_start+X_delta X_start+X_delta*5],[Y_start+Y_delta Y_start+Y_delta],[Z_start+Z_delta Z_start+Z_delta]); % x Line
% Y_Line = line(hAx,[X_start+X_delta X_start+X_delta],[Y_start+Y_delta Y_start+Y_delta*5],[Z_start+Z_delta Z_start+Z_delta]); % Y Line
% Z_Line = line(hAx,[X_start+X_delta X_start+X_delta],[Y_start+Y_delta Y_start+Y_delta],[Z_start+Z_delta Z_start+Z_delta*5]); %Z Line
% X_text = text(hAx,X_start+X_delta*6,Y_start+Y_delta,Z_start+Z_delta,'x');
% Y_text = text(hAx,X_start+X_delta,Y_start+Y_delta*6,Z_start+Z_delta,'y');
% Z_text = text(hAx,X_start+X_delta,Y_start+Y_delta,Z_start+Z_delta*6,'z');