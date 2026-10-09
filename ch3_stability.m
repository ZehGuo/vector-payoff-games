%% Chapter 3 - Is the Nash equilibrium set stable under myopic dynamics?
% Thesis: Section 3.4, Figs. 3.5, 3.6, 3.7 (Proposition 3.1, Theorems 3.10, 3.11).
%
% Two agents, scalar states, two payoffs each.  Each agent moves along the
% pseudo-gradient (3.8): it moves only if it can raise both payoffs, and then
% follows the payoff whose best-response line is closer.  The four lines
% BR^i_j cut the plane into regions; in each region the motion is linear.
%
% Main result (Theorems 3.10 and 3.11).  Let A_{j1j2} = [row_1(A^{1 j1}); row_2(A^{2 j2})].
%   * all four det(A_{j1j2}) > 0  ->  X*(J) is compact and asymptotically stable;
%   * all four det(A_{j1j2}) < 0  ->  X*(J) is compact but unstable;
%   * mixed signs                 ->  X*(J) is not compact (Proposition 3.1).
% Remark 3.9 lists five slope orderings of the lines: four stable, one unstable.
%
% For every example this script (1) PREDICTS stability from the determinant
% signs and (2) SIMULATES trajectories that start close to X*(J), then checks
% that the simulation agrees with the prediction.

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'functions'));
fprintf('\n== Chapter 3: stability of the Nash set (Figs. 3.5-3.7) ==\n');

% Each example is given by its four best-response lines, written as own
% gradients  dJ^i_j/dx^i = row * x + b  (rows and offsets from the original
% simulation scripts), and the sensitivities alpha^i_j.

%% Fig. 3.5: interior of X*(J) connected (Assumption 3)
fig35 = {
    % agent 1 payoff 1, payoff 2      | agent 2 payoff 1, payoff 2        | alpha (2x2)        | window
    {[-3 -1], 25,   [-2 1], 0,         [-1/2 -1], 6,   [1/2 -1], 5,      0.01 * ones(2),      [0.5 10 0 11]}
    {[-3 1], 5,     [-4 1], 10,        [1/2 -1], 5,    [1/4 -1], 21/4,   [1/3 1/4; 2 2],      [0.5 10 0 11]}
    {[-2 -1], 20,   [-3 -1], 25,       [1/2 -1], 5,    [1/4 -1], 21/4,   [1/2 1/3; 2 2],      [0.5 10 0 11]}
    {[-3 -1], 25,   [-2 1], 0,         [1/2 -1], 5,    [1/4 -1], 21/4,   [1 1; 2 2],          [0.5 10 0 11]}
    {[-1/4 1], -35/4, [-1/2 1], -15/2, [4 -1], 3/2,    [3 -1], 5/2,      [4 2; 1 1],          [0.5 6 2 11]}
};
plot_case_family(fig35, 'Fig. 3.5 (Assumption 3: X* has a connected interior)', 'ch3_stability_five_cases');

%% Fig. 3.6: interior of X*(J) NOT connected (Assumption 4)
fig36 = {
    {[-3 -1], 17,    [-2 1], 3,         [-1/2 -1], 6,   [1/2 -1], 5,      0.01 * ones(2),      [0.5 10 0 11]}
    {[-3 1], 11,     [-4 1], 17,        [1/2 -1], 5,    [1/4 -1], 21/4,   [1/3 1/4; 2 2],      [3 8 4 9]}
    {[-2 -1], 19,    [-3 -1], 25,       [1/2 -1], 5,    [1/4 -1], 21/4,   [1/2 1/3; 2 2],      [4 9 5 9]}
    {[-3 -1], 57/2,  [-2 1], 13/2,      [1/2 -1], 5,    [1/4 -1], 21/4,   [1 1; 2 2],          [0.5 10 0 11]}
    {[-1/4 1], -67/4, [-1/2 1], -31/2,  [4 -1], 3/2,    [3 -1], 5/2,      [4 2; 1 1],          [3 6 15 20]}
};
plot_case_family(fig36, 'Fig. 3.6 (Assumption 4: X* is two pieces touching at a point)', 'ch3_stability_assumption4');

%% Fig. 3.7: X*(J) unbounded (determinant signs mixed)
% The original scripts for Fig. 3.7 are not available; these three examples
% are NEW constructions with mixed determinant signs (see NOTES.md).
fig37 = {
    {[-1 2], 0,     [-1 -0.5], 2,      [1 -1], 1,      [0.2 -1], -3,     ones(2),  [-10 10 -20 20]}
    {[-1 0.5], 1,   [-1 3], -2,        [0.5 -1], 0,    [-1 -1], 4,       ones(2),  [-10 10 -20 20]}
    {[-1 -2], 0,    [-1 1.5], 3,       [-1 -1], -1,    [1 -1], 2,        ones(2),  [-10 10 -20 20]}
};
plot_case_family(fig37, 'Fig. 3.7 (new examples: X* is unbounded)', 'ch3_unbounded_cases');


%% ------------------------------------------------------------------------
function plot_case_family(cases, figTitle, fileName)
% Analyse every case of one thesis figure and draw them side by side.
fprintf('\n-- %s --\n', figTitle);
nCases = numel(cases);
fig = figure('Position', [50 50 380 * min(nCases, 3) 360 * ceil(nCases / 3)]);
for k = 1:nCases
    c = cases{k};
    G = game_from_rows(c{1:8}, c{9});
    win = c{10};
    subplot(ceil(nCases / 3), min(nCases, 3), k);
    verdict = analyse_case(G, win, sprintf('(%c)', 'a' + k - 1));
    title(sprintf('(%c) %s', 'a' + k - 1, verdict));
end
sgtitle({figTitle, ['\fontsize{9}red = agent 1, blue = agent 2, solid = payoff 1, dashed = payoff 2, ' ...
         'green dotted = switching lines, purple = X^*(J), black = simulated trajectories']});
save_figure(fig, fileName);
end

function verdict = analyse_case(G, win, label)
% Predict stability from det(A_{j1j2}), simulate, and draw one panel.

% --- Prediction from the theory ------------------------------------------
d = zeros(2);
for j1 = 1:2
    for j2 = 1:2
        d(j1, j2) = det([G.A{1, j1}(1, :); G.A{2, j2}(2, :)]);
    end
end
if all(d(:) > 0)
    verdict = 'stable';            % Theorems 3.10 / 3.11
elseif all(d(:) < 0)
    verdict = 'unstable';
else
    verdict = 'unbounded';         % Proposition 3.1: X* not compact
end

% --- Vector field and Nash set -------------------------------------------
[X1, X2] = meshgrid(linspace(win(1), win(2), 60), linspace(win(3), win(4), 60));
F = pseudo_gradient(G, [X1(:)'; X2(:)']);
plot_game(G, win(1:2), win(3:4), ~strcmp(verdict, 'unbounded'));
hs = streamslice(X1, X2, reshape(F(1, :), size(X1)), reshape(F(2, :), size(X1)), 1.2);
set(hs, 'Color', [0.55 0.6 0.75]);

% Sample X*(J) finely (used for the distance d_H(x, X*)).
[S1, S2] = meshgrid(linspace(win(1), win(2), 700), linspace(win(3), win(4), 700));
S = [S1(:)'; S2(:)'];
S = S(:, in_nash_set(G, S));
span = max(win(2) - win(1), win(4) - win(3));

% --- Simulation -----------------------------------------------------------
% Speed of the slowest linear piece sets the time horizon.
rate = min(abs(G.alpha(:)' .* [G.A{1, 1}(1, 1), G.A{1, 2}(1, 1), G.A{2, 1}(2, 2), G.A{2, 2}(2, 2)]));
tEnd = 40 / rate;
switch verdict
    case 'unbounded'
        % Only illustrate: a few trajectories from the window corners region.
        starts = [win(1) + 0.15 * (win(2) - win(1)) * [1 1 6 6]; win(3) + 0.15 * (win(4) - win(3)) * [1 6 1 6]];
        for n = 1:size(starts, 2)
            [~, Xt] = simulate_game(G, starts(:, n), tEnd / 4, 800);
            plot(Xt(1, :), Xt(2, :), 'k-', 'LineWidth', 1.3);
            plot(starts(1, n), starts(2, n), 'ko', 'MarkerFaceColor', 'w');
        end
        % Proposition 3.1 check: X* reaches arbitrarily far (sample a huge circle).
        th = linspace(0, 2 * pi, 3600);
        farHit = any(in_nash_set(G, 1e4 * [cos(th); sin(th)]));
        check([label ' mixed det signs and X* reaches ||x|| = 1e4 (not compact)'], farHit, ...
              sprintf('dets = %s', mat2str(d(:)', 3)));
    otherwise
        % Start 12 points at distance ~ delta from X*, spread around the set.
        delta = 0.03 * span;
        starts = ring_points(S, delta, 12);
        dEnd = zeros(1, 12); dMax = zeros(1, 12);
        for n = 1:12
            [~, Xt] = simulate_game(G, starts(:, n), tEnd, 1500, span);   % stop if it leaves the window
            dist = distance_to_set(Xt(:, 1:10:end), S);
            dEnd(n) = dist(end); dMax(n) = max(dist);
            plot(Xt(1, :), Xt(2, :), 'k-', 'LineWidth', 1.3);
            plot(starts(1, n), starts(2, n), 'ko', 'MarkerFaceColor', 'w', 'MarkerSize', 4);
        end
        grid = 1.5 * span / 700;    % sampling resolution of X*
        if strcmp(verdict, 'stable')
            ok = all(dEnd < grid) && all(dMax < 3 * delta);
            msg = 'stable: all start near X* and converge to it';
        else
            ok = any(dEnd > 5 * delta);
            msg = 'unstable: some trajectory starting near X* moves away';
        end
        check(sprintf('%s dets %s -> predicted %s; simulation agrees', label, mat2str(d(:)', 3), msg), ok, ...
              sprintf('start dist %.2f, end dist max %.3f, worst excursion %.2f', delta, max(dEnd), max(dMax)));
end
axis(win);
end

function P = ring_points(S, delta, n)
% Pick n points at distance about delta outside the sampled set S,
% spread evenly by angle around the set's centre.
c = mean(S, 2);
P = zeros(2, n);
for k = 1:n
    dirv = [cos(2 * pi * k / n); sin(2 * pi * k / n)];
    % walk outward from the centre until we are delta away from S
    r = 0;
    while distance_to_set(c + r * dirv, S) < delta
        r = r + delta / 10;
    end
    P(:, k) = c + r * dirv;
end
end

function G = game_from_rows(r11, b11, r12, b12, r21, b21, r22, b22, alpha)
% Build a game whose own gradients are dJ^i_j/dx^i = r^i_j * x + b^i_j.
% Only these rows drive the dynamics (3.8); the remaining Hessian entry is
% set to -1 so that each payoff is a valid concave quadratic.
G.A = {[r11; r11(2) -1], [r12; r12(2) -1];
       [-1 r21(1); r21], [-1 r22(1); r22]};
G.b = {[b11; 0], [b12; 0];
       [0; b21], [0; b22]};
G.alpha = alpha;
end
