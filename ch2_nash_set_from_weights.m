%% Chapter 2 - The Nash equilibrium set is the image of a square of weights
% Thesis: Example 2.11 and Fig. 2.5 (production-pollution game), illustrating
% the weighted-game characterization (2.7)-(2.11) and the explicit formula (2.28).
%
% Two firms choose production quantities x^1, x^2 >= 0.  Each firm has TWO
% goals it wants to maximize and no fixed preference between them:
%   payoff 1 = profit,   payoff 2 = environmental score.
% Because a firm does not rank its goals, "best" means "cannot improve both
% goals at once", and the Nash equilibrium becomes a whole REGION of states.
%
% This script computes that region in two independent ways and checks they agree:
%   (A) weights: fix weights (lambda^1, lambda^2), solve the ordinary scalar
%       game, collect the equilibria for all weights  (eqs. (2.7), (2.11));
%   (B) signs:   keep x if, for each firm, its two own gradients have opposite
%       signs  (eq. (2.28)).

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'functions'));
fprintf('\n== Chapter 2: production-pollution game (Example 2.11, Fig. 2.5) ==\n');

%% 1. The game.  J^i_j(x) = 1/2 x'A x + b'x + c, with x = [x^1; x^2].
% Market price P = 100 - 2(x^1 + x^2).
% Firm 1: profit P*x^1 - 5(x^1)^2,   environment 150 - 3(x^1)^2
% Firm 2: profit P*x^2 - 4(x^2)^2,   environment 140 - 2.5(x^2)^2
G.A = {[-14 -2; -2 0],  [-6 0; 0 0];      % firm 1: profit, environment
       [0 -2; -2 -12],  [0 0; 0 -5]};     % firm 2: profit, environment
G.b = {[100; 0], [0; 0];
       [0; 100], [0; 0]};
G.c = [0 150; 0 140];
G.alpha = ones(2);       % not used here (no dynamics in this chapter)

% Own gradients dJ^i_j/dx^i written as  M x + v  (needed by eq. (2.11)).
grad = cell(1, 2);
for i = 1:2
    for j = 1:2
        grad{i}{j}.M = G.A{i, j}(i, :);
        grad{i}{j}.v = G.b{i, j}(i);
    end
end

%% 2. Condition of Lemma 2.2: det(A_{j1 j2}) has the same sign for all choices.
% A_{j1 j2} stacks firm 1's gradient row of payoff j1 and firm 2's of payoff j2.
% Same sign => Lambda(lambda)A is invertible for every weight => the Nash set
% is compact and connected (Proposition 2.1).
d = zeros(2);
for j1 = 1:2
    for j2 = 1:2
        d(j1, j2) = det([grad{1}{j1}.M; grad{2}{j2}.M]);
    end
end
check('Lemma 2.2: det(A_{j1j2}) all have the same sign', all(d(:) > 0) || all(d(:) < 0), ...
      sprintf('dets = %s', mat2str(d(:)', 4)));

%% 3. Way (A): sweep the weights and solve the weighted game for each.
% lambda^i = [a_i, 1 - a_i]: a_i is how much firm i cares about profit.
n = 41;
a = linspace(0, 1, n);
[A1, A2] = meshgrid(a, a);
Xw = zeros(2, numel(A1));
for k = 1:numel(A1)
    Xw(:, k) = weighted_nash_point(grad, {[A1(k), 1 - A1(k)], [A2(k), 1 - A2(k)]});
end

% Corners of the weight square = Nash points of the four scalar games.
cornerTarget = [0, 0;                 % both firms care only about environment
                100/14, 0;            % firm 1 profit, firm 2 environment
                0, 100/12;            % firm 1 environment, firm 2 profit
                500/82, 50 - 7*500/82]';  % both care only about profit
corner = [weighted_nash_point(grad, {[0 1], [0 1]}), weighted_nash_point(grad, {[1 0], [0 1]}), ...
          weighted_nash_point(grad, {[0 1], [1 0]}), weighted_nash_point(grad, {[1 0], [1 0]})];
check('corner equilibria match hand calculation', max(abs(corner(:) - cornerTarget(:))) < 1e-9, ...
      sprintf('profit-only equilibrium = (%.4f, %.4f)', corner(1, 4), corner(2, 4)));

%% 4. Way (B): the sign test (2.28) on a grid.  Compare with way (A).
check('every weighted equilibrium passes the sign test (2.28)', all(in_nash_set(G, Xw, 1e-9)), ...
      sprintf('%d weight pairs', size(Xw, 2)));

% Conversely, for any x passing the sign test, eq. (2.26) gives weights that
% reproduce x exactly: lambda^i_1 = |g2| / (|g1| + |g2|).
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
check('every sign-test point is reproduced by some weights (eq. 2.26)', err < 1e-9, ...
      sprintf('%d points, max error %.1e', size(Y, 2), err));

% Proposition 2.7: if BR^i_1 and BR^i_2 meet OUTSIDE the other agent's Pareto
% region, the map weights -> Nash set is one-to-one (Theorem 2.4).
p1 = [0; 50];   % firm 1's two best-response lines meet here (x^1 = 0, 14x^1+2x^2 = 100)
p2 = [50; 0];   % firm 2's two best-response lines meet here
in2 = own_gradient(G, 2, 1, p1) * own_gradient(G, 2, 2, p1) <= 0;
in1 = own_gradient(G, 1, 1, p2) * own_gradient(G, 1, 2, p2) <= 0;
check('Prop. 2.7 rank condition holds, so weights <-> Nash set is one-to-one', ~in1 && ~in2);

%% 5. Figure: same colour = same weights.
colorOf = @(a1, a2) [0.25 + 0.7 * a1(:), 0.35 * ones(numel(a1), 1), 0.25 + 0.7 * a2(:)];
fig = figure('Position', [100 100 1050 430]);

subplot(1, 2, 1);
scatter(A1(:), A2(:), 28, colorOf(A1, A2), 'filled', 's');
axis square; xlim([0 1]); ylim([0 1]);
xlabel('\lambda^1_1  (weight of firm 1 on profit)');
ylabel('\lambda^2_1  (weight of firm 2 on profit)');
title('Weights  \Delta^1 \times \Delta^1');

subplot(1, 2, 2);
h = plot_game(G, [-0.5 10], [-0.5 10]);
scatter(Xw(1, :), Xw(2, :), 14, colorOf(A1, A2), 'filled');
plot(corner(1, :), corner(2, :), 'ko', 'MarkerFaceColor', 'k');
axis square;
title('Nash set X^*(J): purple = sign test, dots = weighted games');
legend(h, {'BR^1_1 (firm 1, profit)', 'BR^1_2 (firm 1, environment)', ...
           'BR^2_1 (firm 2, profit)', 'BR^2_2 (firm 2, environment)'}, ...
       'Location', 'northeast');
sgtitle('Chapter 2: each weight choice gives one Nash point; together they fill X^*(J)');
save_figure(fig, 'ch2_production_pollution');
