%% Designing taxes and subsidies so that everybody gains, at no cost
% Paper: Z. Guo, T. Hayakawa, "Two-agent noncooperative dynamical systems with
%        quadratic vector-valued payoff functions and weak Pareto improvement",
%        IEEE Control Systems Letters, 2024, https://doi.org/10.1109/LCSYS.2024.3522596
%
% A manager picks priorities eta^i_j, which define a social welfare
% U(x) = sum eta^i_j J^i_j(x) and a target state x_hat where U is largest.
% Incentives can only be added to the money-type payoff J^i_1 of each player.
% In the simplest version of the design, the money payoff with incentive is
%   tilde J^i_1(x) = zeta_i * sigma * (U(x) - U(x0)) + J^i_1(x0),
% i.e. player i is paid the share zeta_i of the (scaled) social welfare gain.
% The incentive itself is p^i(x) = tilde J^i_1(x) - J^i_1(x).
% If a few conditions hold (checked below), the trajectory with incentives
% is weakly Pareto improving, nobody falls into the trap, the manager never
% pays out net money, and the players settle near the target.

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'functions'));
fprintf('\n== Incentive design ==\n');

%% 1. The game and the manager's choices
G.A = {[-4 1; 1 -10],   [-4 -1; -1 -3];
       [-16 8; 8 -16],  [-5 -1; -1 -2]};
G.b = {[5; -440], [30; -20];
       [360; 0],  [58.5; 0]};
G.alpha = ones(2);              % players' speeds (the guarantee holds for any alpha > 0)
eta = [0.7 4; 1 2];             % manager's priorities eta^i_j
x0 = [16; -15];
sigma = 0.05;                   % incentive scale
zeta = [0.3; 0.7];              % shares of the welfare gain, zeta_1 + zeta_2 = 1

% Social welfare U(x) = 1/2 x'HU x + gU'x and the target state x_hat
HU = 0; gU = 0;
for i = 1:2
    for j = 1:2
        HU = HU + eta(i,j) * G.A{i,j};
        gU = gU + eta(i,j) * G.b{i,j};
    end
end
xhat = -HU \ gU;
Ufun = @(X) 0.5 * sum(X .* (HU * X), 1) + gU' * X;
fprintf('   target state x_hat = (%.4f, %.4f)\n', xhat);

%% 2. Game with incentives: replace J^i_1 by tilde J^i_1
Gt = G;
Gt.c = zeros(2);               % constants c^i_j (zero in the original game)
for i = 1:2
    Gt.A{i,1} = zeta(i) * sigma * HU;
    Gt.b{i,1} = zeta(i) * sigma * gU;
    Gt.c(i,1) = payoff_value(G, i, 1, x0) - zeta(i) * sigma * Ufun(x0);
end
incentive = @(i, X) payoff_value(Gt, i, 1, X) - payoff_value(G, i, 1, X);   % p^i(x)

%% 3. Conditions of the guarantee
% With incentives, all four determinants of the new game are positive (so its
% equilibrium set is bounded and stable), and every payoff is concave in the
% player's own number.
dt = zeros(2);
for j1 = 1:2
    for j2 = 1:2
        dt(j1, j2) = det([Gt.A{1,j1}(1,:); Gt.A{2,j2}(2,:)]);
    end
end
check('all four determinants positive and payoffs concave', ...
      all(dt(:) > 0) && G.A{1,2}(1,1) < 0 && G.A{2,2}(2,2) < 0 && Gt.A{1,1}(1,1) < 0 && Gt.A{2,1}(2,2) < 0, ...
      sprintf('dets = %s', mat2str(dt(:)', 3)));
% In this simplest design the new best-response lines of payoff 1 pass through x_hat,
% so the target is an equilibrium of the game with incentives.
check('x_hat is an equilibrium of the game with incentives', ...
      abs(own_gradient(Gt, 1, 1, xhat)) < 1e-9 && abs(own_gradient(Gt, 2, 1, xhat)) < 1e-9 && in_nash_set(Gt, xhat, 1e-9));
check('budget rule: p^1(x0) = p^2(x0) = 0', abs(incentive(1, x0)) < 1e-9 && abs(incentive(2, x0)) < 1e-9);

%% 4. Simulate without and with the incentive
tEnd = 10;                      % slow at the end: the incentive is scaled by sigma
[t0, X0] = simulate_game(G, x0, tEnd, 3000);
[t1, X1] = simulate_game(Gt, x0, tEnd, 3000);

% Payoffs along both trajectories (incentivized money payoff for the new game)
[J0, dJ0] = payoff_history(G, X0);
[J1, dJ1] = payoff_history(Gt, X1);
tol = -1e-6 * max(abs(dJ1(:)));
weak = @(dJ) all(max(dJ(1:2, :)) >= tol) && all(max(dJ(3:4, :)) >= tol);
budgetTotal = incentive(1, X1) + incentive(2, X1);

loser = find([any(max(dJ0(1:2, :)) < tol), any(max(dJ0(3:4, :)) < tol)]);
check('without incentive the trajectory is NOT weakly Pareto improving', ~weak(dJ0), ...
      sprintf('player(s) %s lose on both payoffs at some time', mat2str(loser)));
check('with incentive the trajectory is weakly Pareto improving', weak(dJ1));
% In this simplest design, tilde J^i_1 itself never decreases, so no payoff vector can
% become worse in both components later: nobody is trapped.
check('with incentive tilde J^i_1 never decreases (no trap)', ...
      all(dJ1(1, :) >= tol) && all(dJ1(3, :) >= tol));
check('budget rule: p^1 + p^2 <= 0 along the whole trajectory', all(budgetTotal <= 1e-9), ...
      sprintf('max p^1+p^2 = %.2e', max(budgetTotal)));
check('incentivized trajectory converges to the target x_hat', norm(X1(:, end) - xhat) < 0.05, ...
      sprintf('end (%.2f, %.2f), distance to x_hat %.2f', X1(:, end), norm(X1(:, end) - xhat)));

%% 5. Figure: maps of the two paths (top) and how each goal changes (bottom)
st = style();
win = [-5 32 -18 12];
fig = figure('Position', [50 50 1400 900]);
tl = tiledlayout(2, 2, 'TileSpacing', 'compact');

nexttile; hold on
plot_game(G, win(1:2), win(3:4));
axis(win);
draw_path(X0, 0.3, G);
plot(xhat(1), xhat(2), 'kp', 'MarkerFaceColor', 'y', 'MarkerSize', 13);
title({'(a) WITHOUT incentive', '\rmthe players stop at an equilibrium away from the target'});

nexttile; hold on
[Y1, Y2] = meshgrid(linspace(win(1), win(2), 400), linspace(win(3), win(4), 400));
Y = [Y1(:)'; Y2(:)'];
inBud = incentive(1, Y) + incentive(2, Y) <= 0;
image(Y1(1, :), Y2(:, 1), repmat(reshape(st.orange, 1, 1, 3), size(Y1)), 'AlphaData', 0.6 * reshape(inBud, size(Y1)));
set(gca, 'YDir', 'normal');
plot_game(Gt, win(1:2), win(3:4));
axis(win);
draw_path(X1, 0.3, Gt);
plot(xhat(1), xhat(2), 'kp', 'MarkerFaceColor', 'y', 'MarkerSize', 13);
title({'(b) WITH incentive (lines and purple: the new game)', ...
       '\rmthe target is now an equilibrium; the path reaches it inside the budget region'});

% Without incentive the money goals change ~50 times more than the others,
% so they are shown divided by 10.
nexttile;
plot_goal_changes(G, t0, X0, [1 2], [10 1; 10 1]);
title({'(c) WITHOUT incentive: player 1 loses both goals for a long time', ...
       '\rm(goal 1 = money, shown divided by 10)'});

nexttile; hold on
plot(t1, budgetTotal, ':', 'Color', [0.4 0.4 0.4], 'LineWidth', 2);   % first, so the axis range includes it
plot_goal_changes(Gt, t1, X1);
title({'(d) WITH incentive: nobody ever loses both goals', ...
       '\rm(goal 1 = money + incentive); the manager''s payment (grey) stays below zero'});

lgd = standard_legend({'goals', 'set', 'path', 'loss1', 'loss2', 'target', 'budget', 'payment'}, 4);
lgd.Layout.Tile = 'south';
title(tl, {'Incentive: each player''s money goal is replaced by a share of society''s gain', ...
           sprintf('\\fontsize{10}strength \\sigma = %.2f, shares \\zeta_1 = %.1f and \\zeta_2 = %.1f', sigma, zeta)}, 'FontSize', 14);
save_figure(fig, 'incentive_design');

%% ------------------------------------------------------------------------
function [J, dJ] = payoff_history(G, X)
% Values and time derivatives of the four payoffs along a trajectory X.
F = pseudo_gradient(G, X);
J = zeros(4, size(X, 2)); dJ = J; r = 0;
for i = 1:2
    for j = 1:2
        r = r + 1;
        J(r, :) = payoff_value(G, i, j, X);
        dJ(r, :) = sum((G.A{i,j} * X + G.b{i,j}) .* F, 1);
    end
end
end
