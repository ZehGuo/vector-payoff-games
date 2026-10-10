%% A shortcut for proving stability: change coordinates, then use a Lyapunov function
% Paper: Z. Guo, T. Hayakawa, "A coordinate transformation method for stability
%        analysis of Nash equilibria with vector payoff functions",
%        European Control Conference (ECC).
%
% Checking stability region by region (stability_cases.m) is long and hard
% to extend.  Idea: map each state x to  x_tilde = eta(x)  with
%     eta_i(x) = x^i - (best response of the payoff player i follows),
%     eta_i(x) = 0   if player i is not moving.
% The whole equilibrium set collapses to the ORIGIN, and in each quadrant the
% new motion is LINEAR:  x_tilde' = tilde A_(j1,j2) x_tilde.
% If the origin of this piecewise-linear system is stable, so is the
% equilibrium set.  Stability of the origin is proved with a piecewise
% quadratic Lyapunov function V = x_tilde' P_(j1,j2) x_tilde (an "energy"
% that never increases), found by solving linear matrix inequalities (LMIs).
%
% Requires the Optimization Toolbox (coneprog) to SOLVE the inequalities; without
% it, the script still verifies the matrix T printed in the paper.

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'functions'));
fprintf('\n== Coordinate change + Lyapunov function ==\n');

%% 1. The example of the paper (values as in the published simulation)
G.A = {[-2 -1; -1 -3], [-1 -1; -1 -3];
       [-7 -1; -1 -4], [-3 1; 1 -4]};
G.b = {[8; 0], [8; 0];
       [0; 0], [0; 0]};
G.alpha = [0.25 2; 0.25 0.25];
x0 = [2.3; 7.9];

% Four determinants of the same sign -> the equilibrium set is bounded and connected
d = zeros(2);
for j1 = 1:2
    for j2 = 1:2
        d(j1, j2) = det([G.A{1,j1}(1,:); G.A{2,j2}(2,:)]);
    end
end
check('all four determinants have the same sign', all(d(:) > 0) || all(d(:) < 0), mat2str(d(:)', 3));

%% 2. Piecewise-linear motion after the coordinate change
% Quadrant of x_tilde <-> payoffs followed: x_tilde_i < 0 <-> j_i = 1, > 0 <-> j_i = 2.
At = cell(2);
for j1 = 1:2
    for j2 = 1:2
        A1 = G.A{1, j1}; A2 = G.A{2, j2};
        M = [1, A1(1,2) / A1(1,1); A2(1,2) / A2(2,2), 1];
        At{j1, j2} = M * diag([G.alpha(1,j1) * A1(1,1), G.alpha(2,j2) * A2(2,2)]);  
    end
end
for j1 = 1:2
    for j2 = 1:2
        fprintf('   tilde A_(%d,%d) = %s\n', j1, j2, mat2str(At{j1, j2}, 4));
    end
end
% As stated in the paper: x0 lies in D_(2,2) and eta(x0) = (2.2, 7.325).
[~, branch0] = pseudo_gradient(G, x0);
check('x0 lies in D_(2,2) and eta(x0) = (2.2, 7.325), as stated in the paper', ...
      isequal(branch0', [2 2]) && norm(transform(G, x0) - [2.2; 7.325]) < 1e-12);

%% 3. Lyapunov certificate: solve the LMIs
% For each quadrant: E x_tilde >= 0 describes the quadrant, F = [E; I],
% P = F' T F (so V is continuous across quadrant borders), U = W = [0 1; 1 0].
E = {-eye(2), diag([-1 1]); diag([1 -1]), eye(2)};
U = [0 1; 1 0];  W = U;
lmiMargin = @(T) lmi_margin(T, At, E, U, W);

Tpaper = [ 3.6237  0.6013 -1.6720  0.5908;
           0.6013  3.9770  0.6784 -0.2266;
          -1.6720  0.6784  3.6237 -1.8593;
           0.5908 -0.2266 -1.8593  3.9770];
check('matrix T printed in the paper satisfies the LMIs', lmiMargin(Tpaper) > 0, ...
      sprintf('smallest eigenvalue margin %.3f', lmiMargin(Tpaper)));

if exist('coneprog', 'file') == 2
    T = solve_lmi(At, E, U, W);
    check('our own solution of the LMIs is feasible', lmiMargin(T) > 0, ...
          sprintf('smallest eigenvalue margin %.3f', lmiMargin(T)));
else
    fprintf('   (coneprog not found: using the printed T)\n');
    T = Tpaper;
end
P = cell(2);
for j1 = 1:2
    for j2 = 1:2
        F = [E{j1, j2}; eye(2)];
        P{j1, j2} = F' * T * F;
    end
end
V = @(Xt) lyap_value(Xt, P);

%% 4. Simulate both systems and check the Lyapunov function decreases
[t, X] = simulate_game(G, x0, 30, 6000);
[eta, consistent] = transform(G, X);
check('quadrant of eta(x(t)) always matches the payoffs being followed', consistent);

Xt = simulate_transformed(At, transform(G, x0), t);
Vx = V(eta);                               % V along the ORIGINAL trajectory, V(x) = V_tilde(eta(x))
Vt = V(Xt);                                % V along the transformed system
check('V(eta(x(t))) never increases along the original trajectory', all(diff(Vx) <= 1e-9 * max(Vx)));
% (small tolerance: the fixed-step solver chatters slightly along the sliding axis)
check('V decreases along the transformed trajectory and reaches ~0', ...
      all(diff(Vt) <= 1e-6 * max(Vt)) && Vt(end) < 1e-4 * Vt(1), ...
      sprintf('V: %.1f -> %.1e', Vt(1), Vt(end)));
[S1, S2] = meshgrid(linspace(-2, 14, 800), linspace(-6, 10, 800));   % sample the equilibrium set
S = [S1(:)'; S2(:)'];
S = S(:, in_nash_set(G, S));
dEnd = distance_to_set(X(:, end), S);
check('original trajectory converges to the equilibrium set', dEnd < 0.03, ...
      sprintf('end (%.3f, %.3f), distance to the set %.3f', X(:, end), dEnd));

%% 5. Figure
levels = Vx(1) * [0.08 0.25 0.5 1];        % level sets through and inside V(x0)
fig = figure('Position', [50 50 1250 520]);
subplot(1, 2, 1); hold on
win = [-2 14 -6 10];
[Y1, Y2] = meshgrid(linspace(win(1), win(2), 300), linspace(win(3), win(4), 300));
Y = [Y1(:)'; Y2(:)'];
Fy = pseudo_gradient(G, Y);
hs = streamslice(Y1, Y2, reshape(Fy(1,:), size(Y1)), reshape(Fy(2,:), size(Y1)), 1);
set(hs, 'Color', [0.7 0.85 0.65]);
contour(Y1, Y2, reshape(V(transform(G, Y)), size(Y1)), levels, 'k:', 'LineWidth', 1);
plot_game(G, win(1:2), win(3:4));
plot(X(1, :), X(2, :), '-', 'Color', [0 0.55 0.2], 'LineWidth', 2.2);
plot(x0(1), x0(2), 'ko', 'MarkerFaceColor', 'k');
axis equal; axis(win);
title({'(a) original system: trajectory x(t), equilibrium set (purple),', 'dotted: level sets of V(\eta(x))'});

subplot(1, 2, 2); hold on
win2 = [-4 8 -4 8];
[Z1, Z2] = meshgrid(linspace(win2(1), win2(2), 300), linspace(win2(3), win2(4), 300));
Z = [Z1(:)'; Z2(:)'];
Fz = zeros(size(Z));
for k = 1:size(Z, 2), Fz(:, k) = transformed_field(Z(:, k), At); end
hs = streamslice(Z1, Z2, reshape(Fz(1,:), size(Z1)), reshape(Fz(2,:), size(Z1)), 1);
set(hs, 'Color', [0.7 0.85 0.65]);
contour(Z1, Z2, reshape(V(Z), size(Z1)), levels, 'k:', 'LineWidth', 1);
xline(0, 'k-'); yline(0, 'k-');
h1 = plot(eta(1, :), eta(2, :), '-', 'Color', [0 0.55 0.2], 'LineWidth', 2.2);
h2 = plot(Xt(1, :), Xt(2, :), '--', 'Color', [0 0.3 0.1], 'LineWidth', 1.8);
plot(eta(1, 1), eta(2, 1), 'ko', 'MarkerFaceColor', 'k');
legend([h1 h2], {'$\eta(x(t))$: image of the original trajectory', ...
                 '$\tilde{x}(t)$: transformed piecewise-linear system'}, ...
       'Location', 'southwest', 'Interpreter', 'latex');
axis equal; axis(win2);
xlabel('$\tilde{x}_1$', 'Interpreter', 'latex'); ylabel('$\tilde{x}_2$', 'Interpreter', 'latex');
title({'(b) transformed state: the equilibrium set collapses to the origin,', 'dotted: level sets of the Lyapunov function V'});
sgtitle('A coordinate change turns stability of a SET into stability of a POINT');
save_figure(fig, 'stability_lyapunov');

%% ------------------------------------------------------------------------
function [Xt, consistent] = transform(G, X)
% Coordinate change eta: signed distance to the followed best-response line.
[~, branch] = pseudo_gradient(G, X);
Xt = zeros(size(X));
consistent = true;
for i = 1:2
    for j = 1:2
        on = branch(i, :) == j;
        Xt(i, on) = own_gradient(G, i, j, X(:, on)) / G.A{i, j}(i, i);
        % following payoff 1 must give a negative coordinate, payoff 2 a positive one
        consistent = consistent && all(sign(Xt(i, on)) == 2 * j - 3);
    end
end
end

function Z = simulate_transformed(At, z0, t)
% Integrate the piecewise-linear system with small fixed Euler steps.
% On the negative x_tilde_1 axis both neighbouring quadrants push the state
% onto the axis, so the solution slides along it; adaptive solvers such as
% ode45 stall there, while small fixed steps follow the sliding motion.
nSub = 20;                                    % Euler steps per output sample
Z = zeros(2, numel(t));
Z(:, 1) = z0;
for k = 2:numel(t)
    h = (t(k) - t(k - 1)) / nSub;
    z = Z(:, k - 1);
    for n = 1:nSub
        z = z + h * transformed_field(z, At);
    end
    Z(:, k) = z;
end
end

function f = transformed_field(z, At)
% Piecewise-linear motion: the quadrant of z selects tilde A_(j1,j2).
j1 = 1 + (z(1) > 0);
j2 = 1 + (z(2) > 0);
f = At{j1, j2} * z;
end

function v = lyap_value(Z, P)
% Piecewise quadratic Lyapunov function V(z) = z' P_(j1,j2) z, with P = F' T F.
v = zeros(1, size(Z, 2));
for k = 1:size(Z, 2)
    j1 = 1 + (Z(1, k) > 0);
    j2 = 1 + (Z(2, k) > 0);
    v(k) = Z(:, k)' * P{j1, j2} * Z(:, k);
end
end

function m = lmi_margin(T, At, E, U, W)
% Smallest eigenvalue over all inequalities: positive = feasible.
m = inf;
for k = 1:4
    F = [E{k}; eye(2)];
    Pk = F' * T * F;
    m = min([m, eig(-(At{k}' * Pk + Pk * At{k} + E{k}' * U * E{k}))', eig(Pk - E{k}' * W * E{k})']);
end
end

function T = solve_lmi(At, E, U, W)
% Solve the LMIs as a convex cone program: maximize a margin e such that
% every 2x2 matrix M in the inequalities satisfies M >= e*I.
% A 2x2 symmetric M = [a c; c d] is >= e*I  <=>  ||[a - d; 2c]|| <= a + d - 2e,
% a second-order cone constraint, so MATLAB's coneprog can solve it exactly.
idx = find(triu(ones(4)));                     % the 10 free entries of T
nz = numel(idx) + 1;                           % unknowns z = [entries of T; e]
Tof = @(z) unpack(z, idx);
mats = {};
for k = 1:4
    F = [E{k}; eye(2)];
    mats{end + 1} = @(z) -(At{k}' * (F' * Tof(z) * F) + (F' * Tof(z) * F) * At{k} + E{k}' * U * E{k}); %#ok<AGROW>
    mats{end + 1} = @(z) F' * Tof(z) * F - E{k}' * W * E{k};                                         %#ok<AGROW>
end
soc = [];
for k = 1:numel(mats)
    % Each entry of M is affine in z: read off its coefficients.
    M0 = mats{k}(zeros(nz, 1));
    Ma = zeros(3, nz);
    for n = 1:nz
        en = zeros(nz, 1); en(n) = 1;
        Mn = mats{k}(en) - M0;
        Ma(:, n) = [Mn(1,1); Mn(2,2); Mn(1,2)];
    end
    c = [M0(1,1); M0(2,2); M0(1,2)];
    eVec = zeros(1, nz); eVec(end) = 1;
    Acone = [Ma(1,:) - Ma(2,:); 2 * Ma(3,:)];
    bcone = -[c(1) - c(2); 2 * c(3)];
    dcone = (Ma(1,:) + Ma(2,:) - 2 * eVec)';
    soc = [soc, secondordercone(Acone, bcone, dcone, -(c(1) + c(2)))]; %#ok<AGROW>
end
f = zeros(nz, 1); f(end) = -1;                 % maximize the margin e
lb = [-100 * ones(nz - 1, 1); -inf];  ub = [100 * ones(nz - 1, 1); 1];
z = coneprog(f, soc, [], [], [], [], lb, ub, optimoptions('coneprog', 'Display', 'off'));
T = Tof(z);
end

function T = unpack(z, idx)
T = zeros(4);
T(idx) = z(1:numel(idx));
T = T + triu(T, 1)';
end
