%% The trap: better off at every moment, yet worse off overall
% Paper: Z. Guo, T. Hayakawa, "Two-agent noncooperative dynamical systems with
%        quadratic vector-valued payoff functions and weak Pareto improvement",
%        IEEE Control Systems Letters, 2024, https://doi.org/10.1109/LCSYS.2024.3522596
%
% Weak Pareto improvement only asks that, at EVERY MOMENT, each player has at
% least one payoff that is not decreasing.  This does not prevent the
% following: a player's two payoffs take turns decreasing, so that at a later
% time t2 BOTH payoffs are lower than at an earlier time t1.  Comparing the
% two moments, the player is simply worse off.  We call this the "trap".
% This script shows a trajectory that is weakly Pareto improving and still
% traps player 2.

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'functions'));
fprintf('\n== The trap of weak Pareto improvement ==\n');

%% 1. The game
G.A = {[-2 1; 1 -3], [-2 -1; -1 -10];
       [-4 1; 1 -4], [-5 -1; -1 -2]};
G.b = {[5; -5], [20; 124];
       [90; 0],  [72; 0]};
G.c = [0 0; 667.64 561.65];
% Speeds alpha^i_j of the players (as in the published simulation).
G.alpha = [1 1.2; 1 2];
x0 = [18.5; -8.71];

%% 2. Simulate the players' movement
[t, X] = simulate_game(G, x0, 4, 4000);
F = pseudo_gradient(G, X);
J = zeros(4, numel(t));  dJ = J;  r = 0;
for i = 1:2
    for j = 1:2
        r = r + 1;
        J(r, :) = payoff_value(G, i, j, X);
        dJ(r, :) = sum((G.A{i,j} * X + G.b{i,j}) .* F, 1);   % time derivative of J^i_j
    end
end

%% 3. Check: weakly Pareto improving at every moment
tol = -1e-6 * max(abs(dJ(:)));
weak1 = all(max(dJ(1:2, :)) >= tol);
weak2 = all(max(dJ(3:4, :)) >= tol);
check('trajectory is weakly Pareto improving for both players', weak1 && weak2);

%% 4. Check: player 2 falls into the trap
% Look for the first t2 at which BOTH payoffs of player 2 are below their
% values at t1 = 0.
below = J(3, :) < J(3, 1) & J(4, :) < J(4, 1);
k2 = find(below, 1);
check('player 2 is trapped: J^2(x(t2)) < J^2(x(0)) in both components', ~isempty(k2), ...
      sprintf('first such t2 = %.2f', t(k2)));
[~, kPaper] = min(abs(t - 2.75));
check('... in particular for the pair t1 = 0, t2 = 2.75 shown in the paper', below(kPaper));
% Player 1 is not trapped: no pair t1 < t2 with both of its payoffs lower.
trapped1 = false;
for k = 2:numel(t)
    trapped1 = trapped1 || any(J(1, 1:k-1) > J(1, k) & J(2, 1:k-1) > J(2, k));
end
check('player 1 is not trapped', ~trapped1);

%% 5. Figure
fig = figure('Position', [100 100 1150 450]);
subplot(1, 2, 1); hold on
win = [12 22 -12 -2];
[P1, P2] = meshgrid(linspace(win(1), win(2), 400), linspace(win(3), win(4), 400));
P = [P1(:)'; P2(:)'];
Fp = pseudo_gradient(G, P);
% Region where BOTH payoffs of player 2 would decrease (must be avoided).
d21 = sum((G.A{2,1} * P + G.b{2,1}) .* Fp, 1);
d22 = sum((G.A{2,2} * P + G.b{2,2}) .* Fp, 1);
bothDown = reshape(d21 < 0 & d22 < 0, size(P1));
image(P1(1, :), P2(:, 1), repmat(reshape([0.95 0.55 0.75], 1, 1, 3), size(P1)), 'AlphaData', 0.6 * bothDown);
plot_game(G, win(1:2), win(3:4));
plot(X(1, :), X(2, :), 'k-', 'LineWidth', 2);
plot(x0(1), x0(2), 'ko', 'MarkerFaceColor', 'k');
plot(X(1, k2), X(2, k2), 'ks', 'MarkerFaceColor', 'y', 'MarkerSize', 8);
xlabel('x^1'); ylabel('x^2');
title({'(a) the path never enters the pink region,', 'where both goals of player 2 would fall at once'});

subplot(1, 2, 2); hold on
plot(t, J(3, :) - J(3, 1), '-', 'Color', [0.10 0.45 0.85], 'LineWidth', 1.8);
plot(t, J(4, :) - J(4, 1), '--', 'Color', [0.10 0.45 0.85], 'LineWidth', 1.8);
yline(0, 'k:', 'HandleVisibility', 'off');
xline(t(k2), 'k-', sprintf('t_2 = %.2f', t(k2)), 'HandleVisibility', 'off');
xlabel('time t'); ylabel('change since the start');
legend({'J^2_1 (player 2, goal 1)', 'J^2_2 (player 2, goal 2)'}, 'Location', 'southeast');
title({'(b) still, from time t_2 on, both goals of player 2', 'are below where they started'});
box on
sgtitle({'The trap: at every moment player 2 gains on one goal, yet it ends up worse off', ...
         ['\fontsize{9}(a) black: path from the dot; yellow square: position at time t_2; purple: equilibrium set; ' ...
          'red/blue lines: best-response lines of player 1/2']});
save_figure(fig, 'improvement_trap');
