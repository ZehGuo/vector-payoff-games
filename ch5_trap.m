%% Chapter 5 - The trap of weak Pareto improvement
% Thesis: Definition 6 and Fig. 5.1.
%
% Weak Pareto improvement only asks that, at EVERY MOMENT, each agent has at
% least one payoff that is not decreasing.  This does not prevent the
% following: agent i's two payoffs take turns decreasing, so that at a later
% time t2 BOTH payoffs are lower than at an earlier time t1.  Comparing the
% two moments, the agent is simply worse off.  The thesis calls this the
% "trap of weak Pareto improvement" (Definition 6).  This script shows a
% trajectory that is weakly Pareto improving and still traps agent 2.

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'functions'));
fprintf('\n== Chapter 5: trap of weak Pareto improvement (Fig. 5.1) ==\n');

%% 1. The game of Fig. 5.1 (thesis caption)
G.A = {[-2 1; 1 -3], [-2 -1; -1 -10];
       [-4 1; 1 -4], [-5 -1; -1 -2]};
G.b = {[5; -5], [20; 124];
       [90; 0],  [72; 0]};
G.c = [0 0; 667.64 561.65];
% Sensitivities alpha^i_j.  The caption prints (1.2, 1.2, 1.25, 1), but with
% those values the trajectory briefly enters the region where both payoffs
% of agent 2 fall, contradicting Fig. 5.1(a).  The values below are the ones
% effectively used in the original simulation code (see NOTES.md).
G.alpha = [1 1.2; 1 2];
x0 = [18.5; -8.71];

%% 2. Simulate the pseudo-gradient dynamics (3.8)
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

%% 3. Check: weakly Pareto improving at every moment (Definition 5)
tol = -1e-6 * max(abs(dJ(:)));
weak1 = all(max(dJ(1:2, :)) >= tol);
weak2 = all(max(dJ(3:4, :)) >= tol);
check('trajectory is weakly Pareto improving for both agents', weak1 && weak2);

%% 4. Check: agent 2 falls into the trap (Definition 6)
% Look for the first t2 at which BOTH payoffs of agent 2 are below their
% values at t1 = 0.
below = J(3, :) < J(3, 1) & J(4, :) < J(4, 1);
k2 = find(below, 1);
check('agent 2 is trapped: J^2(x(t2)) < J^2(x(0)) in both components', ~isempty(k2), ...
      sprintf('first such t2 = %.2f', t(k2)));
[~, kThesis] = min(abs(t - 2.75));
check('... in particular for the pair t1 = 0, t2 = 2.75 used in the thesis', below(kThesis));
% Agent 1 is not trapped: no pair t1 < t2 with both of its payoffs lower.
trapped1 = false;
for k = 2:numel(t)
    trapped1 = trapped1 || any(J(1, 1:k-1) > J(1, k) & J(2, 1:k-1) > J(2, k));
end
check('agent 1 is not trapped', ~trapped1);

%% 5. Figure
fig = figure('Position', [100 100 1150 450]);
subplot(1, 2, 1); hold on
win = [12 22 -12 -2];
[P1, P2] = meshgrid(linspace(win(1), win(2), 400), linspace(win(3), win(4), 400));
P = [P1(:)'; P2(:)'];
Fp = pseudo_gradient(G, P);
% Region where BOTH payoffs of agent 2 would decrease (must be avoided).
d21 = sum((G.A{2,1} * P + G.b{2,1}) .* Fp, 1);
d22 = sum((G.A{2,2} * P + G.b{2,2}) .* Fp, 1);
bothDown = reshape(d21 < 0 & d22 < 0, size(P1));
image(P1(1, :), P2(:, 1), repmat(reshape([0.95 0.55 0.75], 1, 1, 3), size(P1)), 'AlphaData', 0.6 * bothDown);
contour(P1, P2, reshape(payoff_value(G, 2, 1, P), size(P1)), 15, ':', 'Color', [0.95 0.6 0.2]);
contour(P1, P2, reshape(payoff_value(G, 2, 2, P), size(P1)), 15, ':', 'Color', [0.35 0.35 0.75]);
plot_game(G, win(1:2), win(3:4));
plot(X(1, :), X(2, :), 'k-', 'LineWidth', 2);
plot(x0(1), x0(2), 'ko', 'MarkerFaceColor', 'k');
plot(X(1, k2), X(2, k2), 'ks', 'MarkerFaceColor', 'y', 'MarkerSize', 8);
title({'(a) trajectory avoids the pink region', '(where both payoffs of agent 2 fall)'});

subplot(1, 2, 2); hold on
plot(t, J(3, :) - J(3, 1), '-', 'Color', [0.95 0.6 0.2], 'LineWidth', 1.8);
plot(t, J(4, :) - J(4, 1), '-', 'Color', [0.35 0.35 0.75], 'LineWidth', 1.8);
yline(0, 'k:');
xline(t(k2), 'k--', sprintf('t_2 = %.2f', t(k2)));
xlabel('time t'); ylabel('J^2_j(x(t)) - J^2_j(x_0)');
legend({'J^2_1', 'J^2_2'}, 'Location', 'southeast');
title({'(b) after t_2 both payoffs of agent 2', 'are below their starting values'});
box on
sgtitle({'Chapter 5: weakly Pareto improving, yet agent 2 ends up worse off', ...
         ['\fontsize{9}(a) red/blue dashed: best-response lines BR^1_2, BR^2_2; purple: Nash set; ' ...
          'dotted: level curves of J^2_1 (orange) and J^2_2 (blue); yellow square: x(t_2)']});
save_figure(fig, 'ch5_trap');
