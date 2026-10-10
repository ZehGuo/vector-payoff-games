%% Do the players settle down?  Stability of the equilibrium set
% Papers: Z. Guo, T. Hayakawa, Y. Yan, "Nash equilibrium of 2-agent game with
%         quadratic vector payoff functions and its stability", IFAC World
%         Congress 2023, https://doi.org/10.1016/j.ifacol.2023.10.1395
%         Z. Guo, T. Hayakawa, Y. Yan, "Stability and stabilization of Nash
%         equilibrium for noncooperative systems with vector-valued payoff
%         functions", IEEE CDC 2023, https://doi.org/10.1109/CDC49753.2023.10384265
%
% Two players, one number each, two payoffs each.  A player moves only if it
% can raise both payoffs, and then follows the payoff whose best-response
% line is closer (see functions/pseudo_gradient.m).  The four best-response
% lines cut the plane into regions; inside each region the motion is linear.
%
% Main result.  Pick one payoff per player and stack their gradient rows into
% a 2x2 matrix.  There are four such matrices.
%   * all four determinants > 0  ->  the equilibrium set is bounded and
%                                    nearby trajectories converge to it (stable);
%   * all four determinants < 0  ->  bounded, but trajectories move away (unstable);
%   * mixed signs                ->  the equilibrium set is unbounded.
% The four lines can be arranged in five essentially different ways: four
% are stable, one is unstable.
%
% For every example this script (1) PREDICTS stability from the determinant
% signs and (2) SIMULATES trajectories that start close to the set, then
% checks that the simulation agrees with the prediction.

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'functions'));
fprintf('\n== Stability of the equilibrium set ==\n');

% Each example is given by its four best-response lines, written as
% dJ^i_j/dx^i = row * x + b, and the speeds alpha^i_j of the players.

%% Examples where the equilibrium set is one solid piece
fig35 = {
    % player 1 payoff 1, payoff 2     | player 2 payoff 1, payoff 2       | alpha (2x2)        | window
    {[-3 -1], 25,   [-2 1], 0,         [-1/2 -1], 6,   [1/2 -1], 5,      0.01 * ones(2),      [0.5 10 0 11]}
    {[-3 1], 5,     [-4 1], 10,        [1/2 -1], 5,    [1/4 -1], 21/4,   [1/3 1/4; 2 2],      [0.5 10 0 11]}
    {[-2 -1], 20,   [-3 -1], 25,       [1/2 -1], 5,    [1/4 -1], 21/4,   [1/2 1/3; 2 2],      [0.5 10 0 11]}
    {[-3 -1], 25,   [-2 1], 0,         [1/2 -1], 5,    [1/4 -1], 21/4,   [1 1; 2 2],          [0.5 10 0 11]}
    {[-1/4 1], -35/4, [-1/2 1], -15/2, [4 -1], 3/2,    [3 -1], 5/2,      [4 2; 1 1],          [0.5 6 2 11]}
};
plot_case_family(fig35, 'Equilibrium set in one piece: four stable arrangements and one unstable', 'stability_one_piece');

%% Examples where the equilibrium set is two pieces touching at a point
fig36 = {
    {[-3 -1], 17,    [-2 1], 3,         [-1/2 -1], 6,   [1/2 -1], 5,      0.01 * ones(2),      [0.5 10 0 11]}
    {[-3 1], 11,     [-4 1], 17,        [1/2 -1], 5,    [1/4 -1], 21/4,   [1/3 1/4; 2 2],      [3 8 4 9]}
    {[-2 -1], 19,    [-3 -1], 25,       [1/2 -1], 5,    [1/4 -1], 21/4,   [1/2 1/3; 2 2],      [4 9 5 9]}
    {[-3 -1], 57/2,  [-2 1], 13/2,      [1/2 -1], 5,    [1/4 -1], 21/4,   [1 1; 2 2],          [0.5 10 0 11]}
    {[-1/4 1], -67/4, [-1/2 1], -31/2,  [4 -1], 3/2,    [3 -1], 5/2,      [4 2; 1 1],          [3 6 15 20]}
};
plot_case_family(fig36, 'Equilibrium set in two pieces touching at a point', 'stability_two_pieces');

%% Examples where the determinant signs are mixed: the set is unbounded
fig37 = {
    {[-1 2], 0,     [-1 -0.5], 2,      [1 -1], 1,      [0.2 -1], -3,     ones(2),  [-10 10 -20 20]}
    {[-1 0.5], 1,   [-1 3], -2,        [0.5 -1], 0,    [-1 -1], 4,       ones(2),  [-10 10 -20 20]}
    {[-1 -2], 0,    [-1 1.5], 3,       [-1 -1], -1,    [1 -1], 2,        ones(2),  [-10 10 -20 20]}
};
plot_case_family(fig37, 'Mixed determinant signs: the equilibrium set is unbounded', 'stability_unbounded');


%% ------------------------------------------------------------------------
function plot_case_family(cases, figTitle, fileName)
% Analyse every example of one group and draw them side by side.
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
sgtitle({figTitle, ['\fontsize{9}red = player 1, blue = player 2, solid = goal 1, dashed = goal 2, ' ...
         'green dotted = switching lines, purple = equilibrium set, black = paths starting at the circles']});
save_figure(fig, fileName);
end

function verdict = analyse_case(G, win, label)
% Predict stability from the four determinants, simulate, and draw one panel.

% --- Prediction from the theory ------------------------------------------
d = zeros(2);
for j1 = 1:2
    for j2 = 1:2
        d(j1, j2) = det([G.A{1, j1}(1, :); G.A{2, j2}(2, :)]);
    end
end
if all(d(:) > 0)
    verdict = 'stable';
elseif all(d(:) < 0)
    verdict = 'unstable';
else
    verdict = 'unbounded';
end

% --- Vector field and equilibrium set -------------------------------------
[X1, X2] = meshgrid(linspace(win(1), win(2), 60), linspace(win(3), win(4), 60));
F = pseudo_gradient(G, [X1(:)'; X2(:)']);
plot_game(G, win(1:2), win(3:4), ~strcmp(verdict, 'unbounded'));
hs = streamslice(X1, X2, reshape(F(1, :), size(X1)), reshape(F(2, :), size(X1)), 1.2);
set(hs, 'Color', [0.55 0.6 0.75]);

% Sample the equilibrium set finely (to measure distances to it).
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
        % The set reaches arbitrarily far: test points on a huge circle.
        th = linspace(0, 2 * pi, 3600);
        farHit = any(in_nash_set(G, 1e4 * [cos(th); sin(th)]));
        check([label ' mixed determinant signs and the set reaches ||x|| = 1e4 (unbounded)'], farHit, ...
              sprintf('dets = %s', mat2str(d(:)', 3)));
    otherwise
        % Start 12 points at distance ~ delta from the set, spread around it.
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
        grid = 1.5 * span / 700;    % sampling resolution of the set
        if strcmp(verdict, 'stable')
            ok = all(dEnd < grid) && all(dMax < 3 * delta);
            msg = 'stable: all start near the set and converge to it';
        else
            ok = any(dEnd > 5 * delta);
            msg = 'unstable: some trajectory starting near the set moves away';
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
% Only these rows drive the motion; the remaining matrix entry is
% set to -1 so that each payoff is a valid concave quadratic.
G.A = {[r11; r11(2) -1], [r12; r12(2) -1];
       [-1 r21(1); r21], [-1 r22(1); r22]};
G.b = {[b11; 0], [b12; 0];
       [0; b21], [0; b22]};
G.alpha = alpha;
end
