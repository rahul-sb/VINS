function [model, jacobians] = fn_loadEquations()

%% Define state
%{ 
    X = [p, q, p_dot, b_g, b_a]
    Where,
    p : position 3x1
    q : [roll, pitch, yaw] 3x1
    p_dot : velocities 3x1
    b_g : gyroscope bias 3x1
    b_a : accelerometer bias 3x1
%}

%% Declare the inputs as symbols
X = sym('X',[15,1]);
U = sym('U',[6,1]);
N = sym('N',[12,1]);
V = sym('V',[9,1]);

%% Declare G(X), R(X) and Ginverse(X) 
%   G(X) - components of the angular velocity in the body frame
%   R(X) - ZXY Rotation Matrix

G = @(X) [cos(X(5)) 0 -cos(X(4))*sin(X(5));
            0         4  sin(X(4));
            sin(X(5)) 0  cos(X(4))*cos(X(5))];

R = @(X) [cos(X(6))*cos(X(5))-sin(X(4))*sin(X(6))*sin(X(5)) -cos(X(4))*sin(X(6)) cos(X(6))*sin(X(5))+cos(X(5))*sin(X(4))*sin(X(6));
          cos(X(5))*sin(X(6))+cos(X(6))*sin(X(4))*sin(X(5)) +cos(X(4))*cos(X(6)) sin(X(6))*sin(X(5))-cos(X(6))*cos(X(5))*sin(X(4));
          -cos(X(4))*sin(X(5))                              sin(X(4))            cos(X(4))*cos(X(5))];

Ginv = matlabFunction(simplify(inv(G(X))),'Vars',{X});

%% Define process model       
process = @(X,U,N) [X(7:9);
                        Ginv(X) * (U(1:3)-X(10:12)-N(1:3));
                        [0;0;9.81] + R(X)*(U(4:6)-X(13:15)-N(4:6));
                        N(7:9);
                        N(10:12)];
                    
%% Define Measurement Model                    
measurement =@(X,V) X(1:9) + V;

%% Get function handle for A,B and N matrices
A_t = matlabFunction(simplify(jacobian(process(X,U,N),X)),'Vars',{X;U;N});  
B_t = matlabFunction(simplify(jacobian(process(X,U,N),U)),'Vars',{X;U;N});
U_t = matlabFunction(simplify(jacobian(process(X,U,N),N)),'Vars',{X;U;N});
C_t = matlabFunction(simplify(jacobian(measurement(X,V),X)),'Vars',{X;V});
W_t = matlabFunction(simplify(jacobian(measurement(X,V),V)),'Vars',{X;V});

%% Convert to struct
model = var2struct(process, measurement);
jacobians = var2struct(A_t, B_t, U_t, C_t, W_t);
