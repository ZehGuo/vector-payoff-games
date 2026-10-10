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

%% 5. Figure: the path on the map (a) and player 2's two goals in time (b)
st = style();
fig = figure('Position', [100 100 1250 560]);
tl = tiledlayout(1, 2, 'TileSpacing', 'compact');

nexttile; hold on
win = [12 20 -10 -3];
shade_losses(G, win(1:2), win(3:4), 2);     % where player 2 would lose both goals
plot_game(G, win(1:2), win(3:4));
axis(win);
draw_path(X, [0.2 0.6], G);
plot(X(1, k2), X(2, k2), 'ks', 'MarkerFaceColor', 'w', 'MarkerSize', 9);
text(X(1, k2) + 0.15, X(2, k2) + 0.35, 'position at t_2', 'FontSize', 10);
text(x0(1), x0(2) + 0.35, 'start (t = 0)', 'FontSize', 10, 'HorizontalAlignment', 'center');
title({'(a) the path never enters the light-blue region,', ...
       '\rmso player 2 never loses both goals at the same moment'});

nexttile; hold on
plot_goal_changes(G, t, X, 2);
xline(t(k2), 'k-', 'HandleVisibility', 'off');
plot(t(k2) * [1 1], [J(3, k2) - J(3, 1), J(4, k2) - J(4, 1)], 'ks', 'MarkerFaceColor', 'w', 'MarkerSize', 9);
text(t(k2) + 0.05, 4, {'t_2: both goals are now', 'below their start values'}, 'FontSize', 10);
% Which goal falls when: the two goals take turns.
[~, k1] = min(J(3, :));                       % goal 1 falls until here
[~, kTop] = max(J(4, :));                     % goal 2 falls from here on
text(t(k1) / 2, J(3, k1) - J(3, 1) - 1.5, 'goal 1 falls', 'Color', st.blue, 'FontSize', 10);
text(t(kTop) + 0.45, J(4, kTop) - J(4, 1) - 3, 'then goal 2 falls', 'Color', st.blue, 'FontSize', 10);
title({'(b) player 2''s goals take turns falling,', ...
       '\rmand from t_2 on it is worse off than at the start'});

lgd = standard_legend({'goals', 'set', 'path', 'loss2'}, 4);
lgd.Layout.Tile = 'south';
title(tl, 'The trap: at every moment player 2 keeps one goal rising, yet it ends up worse off', 'FontSize', 14);
save_figure(fig, 'improvement_trap');
