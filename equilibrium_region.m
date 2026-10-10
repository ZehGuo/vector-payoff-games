%% Equilibrium region of a production-pollution game
% Paper: Z. Guo, T. Hayakawa, "Topology of Nash equilibrium set with quadratic
%        vector payoff functions", ACC 2024, https://doi.org/10.23919/ACC60939.2024.10644643
%
% Two firms choose production quantities x^1, x^2.  Each firm has TWO goals
% and no fixed way of weighing them:
%   payoff 1 = profit,   payoff 2 = environmental score.
% A state is an equilibrium if no firm can improve BOTH of its goals by
% changing its own production.  Such states form a whole REGION.
%
% This script computes the region in two independent ways and checks that
% they agree:
%   (A) weights: give each firm fixed weights for its two goals, solve the
%       resulting ordinary game, and collect the answers for all weights;
%   (B) signs:   keep x if, for each firm, profit and environment would change
%       in opposite directions when the firm moves (no move improves both).

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'functions'));
fprintf('\n== Equilibrium region of a production-pollution game ==\n');

%% 1. The game.  Payoffs J^i_j(x) = 1/2 x'A x + b'x + c, with x = [x^1; x^2].
% Market price P = 100 - 2(x^1 + x^2).
% Firm 1: profit P*x^1 - 5(x^1)^2,   environment 150 - 3(x^1)^2
% Firm 2: profit P*x^2 - 4(x^2)^2,   environment 140 - 2.5(x^2)^2
G.A = {[-14 -2; -2 0],  [-6 0; 0 0];      % firm 1: profit, environment
       [0 -2; -2 -12],  [0 0; 0 -5]};     % firm 2: profit, environment
G.b = {[100; 0], [0; 0];
       [0; 100], [0; 0]};
G.c = [0 150; 0 140];
G.alpha = ones(2);       % speeds; not used here (nobody moves in this script)

% How each payoff changes when the firm moves itself, written as M x + v.
grad = cell(1, 2);
for i = 1:2
    for j = 1:2
        grad{i}{j}.M = G.A{i, j}(i, :);
        grad{i}{j}.v = G.b{i, j}(i);
    end
end

%% 2. When is the region bounded and in one piece?
% Pick one goal per firm and stack their gradient rows into a 2x2 matrix.
% If all four such matrices have determinants of the same sign, the weighted
% game always has exactly one solution, and the region is bounded and
% connected.
d = zeros(2);
for j1 = 1:2
    for j2 = 1:2
        d(j1, j2) = det([grad{1}{j1}.M; grad{2}{j2}.M]);
    end
end
check('all four determinants have the same sign (region bounded, one piece)', ...
      all(d(:) > 0) || all(d(:) < 0), sprintf('dets = %s', mat2str(d(:)', 4)));

%% 3. Way (A): sweep the weights and solve the weighted game for each.
% Firm i puts weight a_i on profit and 1 - a_i on the environment.
n = 41;
a = linspace(0, 1, n);
[A1, A2] = meshgrid(a, a);
Xw = zeros(2, numel(A1));
for k = 1:numel(A1)
    Xw(:, k) = weighted_nash_point(grad, {[A1(k), 1 - A1(k)], [A2(k), 1 - A2(k)]});
end

% The four corners of the weight square: each firm cares about one goal only.
cornerTarget = [0, 0;                 % both firms care only about environment
                100/14, 0;            % firm 1 profit, firm 2 environment
                0, 100/12;            % firm 1 environment, firm 2 profit
                500/82, 50 - 7*500/82]';  % both care only about profit
corner = [weighted_nash_point(grad, {[0 1], [0 1]}), weighted_nash_point(grad, {[1 0], [0 1]}), ...
          weighted_nash_point(grad, {[0 1], [1 0]}), weighted_nash_point(grad, {[1 0], [1 0]})];
check('corner equilibria match hand calculation', max(abs(corner(:) - cornerTarget(:))) < 1e-9, ...
      sprintf('profit-only equilibrium = (%.4f, %.4f)', corner(1, 4), corner(2, 4)));

%% 4. Way (B): the sign test.  Compare with way (A).
check('every weighted equilibrium passes the sign test', all(in_nash_set(G, Xw, 1e-9)), ...
      sprintf('%d weight pairs', size(Xw, 2)));

% Conversely, any x passing the sign test is produced by some weights:
% choose lambda^i_1 = |g2| / (|g1| + |g2|) so the weighted gradients cancel.
[Y1, Y2] = meshgrid(linspace(0.01, 8, 60), linspace(0.01, 9, 60));
Y = [Y1(:)'; Y2(:)'];
Y = Y(:, in_nash_set(G, Y));
err = 0;
for k = 1:size(Y, 2)
    lam = cell(1, 2);
    for i = 1:2
        g1 = abs(own_gradient(G, i, 1, Y(:, k)));
        g2 = abs(own_gradient(G, i, 2, Y(:, k)));
        lam{i} = [g2, g1] / (g1 + g2);
    end
    err = max(err, norm(weighted_nash_point(grad, lam) - Y(:, k)));
end
check('every sign-test point is produced by some weights', err < 1e-9, ...
      sprintf('%d points, max error %.1e', size(Y, 2), err));

% One-to-one: each firm's two best-response lines meet OUTSIDE the region
% where the other firm is satisfied.  Then different weights always give
% different equilibria, so the weight square is copied faithfully.
p1 = [0; 50];   % firm 1's two best-response lines meet here
p2 = [50; 0];   % firm 2's two best-response lines meet here
in2 = own_gradient(G, 2, 1, p1) * own_gradient(G, 2, 2, p1) <= 0;
in1 = own_gradient(G, 1, 1, p2) * own_gradient(G, 1, 2, p2) <= 0;
check('weights <-> equilibria is one-to-one', ~in1 && ~in2);

%% 5. Figure: same colour = same weights.
colorOf = @(a1, a2) [0.25 + 0.7 * a1(:), 0.35 * ones(numel(a1), 1), 0.25 + 0.7 * a2(:)];
fig = figure('Position', [100 100 1050 430]);

subplot(1, 2, 1);
scatter(A1(:), A2(:), 28, colorOf(A1, A2), 'filled', 's');
axis square; xlim([0 1]); ylim([0 1]);
xlabel('weight of firm 1 on profit');
ylabel('weight of firm 2 on profit');
title('All possible weights');

subplot(1, 2, 2);
h = plot_game(G, [-0.5 10], [-0.5 10]);
scatter(Xw(1, :), Xw(2, :), 14, colorOf(A1, A2), 'filled');
plot(corner(1, :), corner(2, :), 'ko', 'MarkerFaceColor', 'k');
axis square;
xlabel('x^1 (production of firm 1)'); ylabel('x^2 (production of firm 2)');
title('Equilibrium region (purple) and weighted solutions (dots)');
legend(h, {'best response of firm 1, profit', 'best response of firm 1, environment', ...
           'best response of firm 2, profit', 'best response of firm 2, environment'}, ...
       'Location', 'northeast');
sgtitle('Each choice of weights gives one equilibrium; together they fill the region');
save_figure(fig, 'equilibrium_region');
