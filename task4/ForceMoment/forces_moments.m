 % Input:
%       x: 12 states
%       delta: 4 control surfaces
%       wind: 6 wind parameters. three for steady wind and three for gust
%       "P" stores all the necessary parameters of the aircraft and atomasphere.
%       For example, the mass of the aircraft can be extracted by P.mass;
%       the gravity constant can be extracted by P.gravity;
%       and mean chord of the aircraft wing can be extracted by P.c; etc.
%       The names of the parameters are consistent with the lecture notes.

% Output:
%       "out" will contrain the overall Force and Torque; 
%                           the airspeed magnitude Va;
%                           the angle of attack alpha;
%                           the sideslip angle beta; and 
%                           the wind in NED frame w_n, w_e, w_d.

function out = forces_moments(x, delta, wind, P)
    pn      = x(1);
    pe      = x(2);
    pd      = x(3);
    u       = x(4);
    v       = x(5);
    w       = x(6);
    phi     = x(7);
    theta   = x(8);
    psi     = x(9);
    p       = x(10);
    q       = x(11);
    r       = x(12);
    delta_e = delta(1);
    delta_a = delta(2);
    delta_r = delta(3);
    delta_t = delta(4);
    w_ns    = wind(1); % steady wind - North
    w_es    = wind(2); % steady wind - East
    w_ds    = wind(3); % steady wind - Down
    u_wg    = wind(4); % gust along body i-axis
    v_wg    = wind(5); % gust along body j-axis    
    w_wg    = wind(6); % gust along body k-axis

    % Define transformation matrix from vehicle frame to body frame
    R_v_b = [cos(theta)*cos(psi) cos(theta)*sin(psi) -sin(theta);
        sin(phi)*sin(theta)*cos(psi)-cos(phi)*sin(psi) sin(phi)*sin(theta)*sin(psi)+cos(phi)*cos(psi) sin(phi)*cos(theta);
        cos(phi)*sin(theta)*cos(psi)+sin(phi)*sin(psi) cos(phi)*sin(theta)*sin(psi)-sin(phi)*cos(psi) cos(phi)*cos(theta)];

    % Define transformation matrix from body frame to vehicle frame
    R_b_v = transpose(R_v_b);

    % Compute overall wind data in body frame
    V_w_b =(R_v_b)*[w_ns;w_es;w_ds]+[u_wg;v_wg;w_wg];

    % Compute overall wind in NED frame
    V_w_NED =[w_ns;w_es;w_ds];

    % define the wind components in NED frame
    w_n = V_w_NED(1);
    w_e = V_w_NED(2);
    w_d = V_w_NED(3);
    
    % Compute airspeed vector in body frame
    V_a_b =[u_w;v_w;w_w];
    
    % Compute airspeed magnitute
    Va =sqrt(u_r^2+v_r^2+w_r^2);

    % Compute alpha and beta
    alpha =arctan(w_r/u_r) ;
    beta =arcsin(v_r/sqrt(u_r^2+v_r^2+w_r^2));
    
    % Compute the parameters used in the models of forces and torques
    sigma_alpha = (1+exp(-P.M*(alpha-P.alpha0))+exp(P.M*(alpha+P.alpha0)))/...
                ((1+exp(-P.M*(alpha-P.alpha0)))*(1+exp(P.M*(alpha+P.alpha0))));
    C_L = (1-sigma_alpha)*(P.C_L_0+P.C_L_alpha*alpha)+...
         sigma_alpha*(2*sign(alpha)*sin(alpha)^2*cos(alpha));
    C_D = P.C_D_p+(P.C_L_0+P.C_L_alpha*alpha)^2/(pi*P.e*(P.b^2/P.S_wing));
    C_X = -C_D*cos(alpha)+C_L*sin(alpha);
    C_X_q = -P.C_D_q*cos(alpha)+P.C_L_q*sin(alpha);
    C_X_delta_e = -P.C_D_delta_e*cos(alpha)+P.C_L_delta_e*sin(alpha);
    C_Z = -C_D*sin(alpha)-C_L*cos(alpha);
    C_Z_q = -P.C_D_q*sin(alpha)-P.C_L_q*cos(alpha);
    C_Z_delta_e = -P.C_D_delta_e*sin(alpha)-P.C_L_delta_e*cos(alpha);
    
    % Gravitational force (ensure gForce is a column vector)
    gForce =  [-m*g*sin(theta);m*g*cos(theta)*sin(phi);m*g*cos(theta)*cos(phi)];
    
    % Aerodynamic force (ensure aForce is a column vector)
    aForce = [];
    
    % Propulsion force (ensure pForce is a column vector)
    pForce = ([];
    
    % Overall force 
    Force = gForce + aForce + pForce;

    % Torques due to aerodynamics and propulsion (ensure Torque is a column vector)
    Torque = [];


    % Construct the output vector
    out = [Force; Torque; Va; alpha; beta; w_n; w_e; w_d];
end

