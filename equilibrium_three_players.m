%% Three players: the cube of weights is copied face-to-face onto the equilibrium set
% Paper: Z. Guo, T. Hayakawa, "Topology of Nash equilibrium set with quadratic
%        vector payoff functions", ACC 2024, https://doi.org/10.23919/ACC60939.2024.10644643
%
% Three players, each with one number to choose (x^i) and two payoffs.
% Player i weighs its payoffs as [w_i, 1 - w_i], so all weights together
% form the cube [0,1]^3.  Each point of the cube gives one equilibrium of
% the weighted game; together they form the equilibrium set.
% Under two simple conditions (checked below) this map is one-to-one and
% smooth, so the equilibrium set has the same shape as the cube: every face
% of the cube becomes a face of the set.  For example, the face w_1 = 1
% ("player 1 only cares about payoff 1") becomes the equilibrium set of the
% smaller game in which player 1 has only payoff 1.

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'functions'));
fprintf('\n== Three players: cube of weights ==\n');

%% 1. The game, given by how each payoff changes when its player moves: M x + v
grad{1}{1} = struct('M', [-1 0 0.4],  'v', 0);
grad{1}{2} = struct('M', [-1 0 -0.6], 'v', 5);
grad{2}{1} = struct('M', [1 -2 0.4],  'v', 0);
grad{2}{2} = struct('M', [1 -2 -0.5], 'v', 6);
grad{3}{1} = struct('M', [0 0 -1.5],  'v', 0);
grad{3}{2} = struct('M', [0 0 -1],    'v', -10);

%% 2. Condition 1: pick one payoff per player and stack the three gradient rows.
% If all 8 such matrices have determinants of the same sign, every weighted
% game has exactly one solution and the set is bounded and connected.
d = zeros(1, 8); k = 0;
for j1 = 1:2
    for j2 = 1:2
        for j3 = 1:2
            k = k + 1;
            d(k) = det([grad{1}{j1}.M; grad{2}{j2}.M; grad{3}{j3}.M]);
        end
    end
end
check('condition 1: all 8 determinants have the same sign', all(d > 0) || all(d < 0), ...
      sprintf('dets = %s', mat2str(d, 3)));

%% 3. Sample the whole cube and map it to the equilibrium set
w = linspace(0, 1, 21);
[W1, W2, W3] = ndgrid(w, w, w);
W = [W1(:)'; W2(:)'; W3(:)'];
X = zeros(3, size(W, 2));
for k = 1:size(W, 2)
    X(:, k) = weighted_nash_point(grad, weights_of(W(:, k)));
end

% Condition 2: a player's two own gradients never vanish at the same
% equilibrium (otherwise several weights could give the same point).
minNorm = inf;
for i = 1:3
    g = [own_grad(grad, i, 1, X); own_grad(grad, i, 2, X)];
    minNorm = min(minNorm, min(vecnorm(g, 2, 1)));
end
check('condition 2: own gradients never both zero on the set', minNorm > 1e-6, ...
      sprintf('smallest gradient norm = %.3f', minNorm));

% One-to-one: from an equilibrium x we can read back a unique weight,
% w_i = g_2 / (g_2 - g_1).  It must equal the weight we started from.
Wback = zeros(size(W));
for i = 1:3
    g1 = own_grad(grad, i, 1, X);
    g2 = own_grad(grad, i, 2, X);
    Wback(i, :) = g2 ./ (g2 - g1);
end
check('weights recovered from equilibria (map is one-to-one)', max(abs(Wback(:) - W(:))) < 1e-9, ...
      sprintf('max error %.1e', max(abs(Wback(:) - W(:)))));

% Face-to-face: on the face w_1 = 1 player 1 uses only payoff 1, so the point
% must lie on its best-response plane for payoff 1 (dJ^1_1/dx^1 = 0).
onFace = W(1, :) == 1;
check('face w_1 = 1 lies on the best-response plane of player 1, payoff 1', ...
      max(abs(own_grad(grad, 1, 1, X(:, onFace)))) < 1e-9);

%% 4. Figure: cube faces (left) and their images in state space (right)
% w_i is player i's weight on its payoff 1, so w_i = 0 means "only payoff 2".
% One clearly different colour per face (the face names are also written on them).
faceColors = [0.93 0.55 0.25; 0.98 0.85 0.35; 0.35 0.55 0.90; ...
              0.60 0.85 0.95; 0.55 0.78 0.40; 0.92 0.60 0.75];
s = linspace(0, 1, 15);
[S, T] = meshgrid(s, s);
faces = cell(2, 6);                       % row 1: cube, row 2: equilibrium set
for f = 1:6
    player = ceil(f / 2);                 % which weight is fixed on this face
    value = mod(f + 1, 2);                % fixed at 0 or 1
    others = setdiff(1:3, player);
    P = zeros(3, numel(S));
    P(player, :) = value;
    P(others(1), :) = S(:)';
    P(others(2), :) = T(:)';
    faces{1, f} = P;
    for k = 1:size(P, 2)                  % map each weight to its equilibrium
        P(:, k) = weighted_nash_point(grad, weights_of(P(:, k)));
    end
    faces{2, f} = P;
end
labels = {'w_1 = 0', 'w_1 = 1', 'w_2 = 0', 'w_2 = 1', 'w_3 = 0', 'w_3 = 1'};
% Top row: seen from the front; bottom row: seen from the opposite side, so
% all six faces appear.  The right picture is turned so that it shows the
% same faces as the left one.
cubeViews = {[-35 25], [145 -25]};
fig = figure('Position', [100 100 1100 950]);
tl = tiledlayout(2, 2, 'TileSpacing', 'compact');
for row = 1:2
    [az, el] = matching_view(faces(1, :), faces(2, :), cubeViews{row});
    nexttile;
    draw_solid(faces(1, :), size(S), faceColors, labels, cubeViews{row});
    xlabel('w_1'); ylabel('w_2'); zlabel('w_3');
    nexttile;
    draw_solid(faces(2, :), size(S), faceColors, labels, [az el]);
    xlabel('x^1'); ylabel('x^2'); zlabel('x^3');
    if row == 1
        nexttile(1); title({'All possible weights (a cube)', '\rmseen from the front'});
        nexttile(2); title({'Equilibrium set', '\rmthe same three faces'});
    else
        nexttile(3); title('\rmseen from the other side');
        nexttile(4); title('\rmthe same three faces');
    end
end
title(tl, {'Three players: each face of the cube of weights becomes a face of the equilibrium set', ...
           '\fontsize{10}w_i = weight of player i on its goal 1 (w_i = 0: player i cares only about goal 2)'}, 'FontSize', 14);
save_figure(fig, 'equilibrium_three_players');

%% Local helper functions
function lam = weights_of(w)
% Turn the cube coordinates (w_1, w_2, w_3) into the three weight vectors.
lam = {[w(1), 1 - w(1)], [w(2), 1 - w(2)], [w(3), 1 - w(3)]};
end

function g = own_grad(grad, i, j, X)
% Own gradient dJ^i_j/dx^i evaluated at the columns of X.
g = grad{i}{j}.M * X + grad{i}{j}.v;
end
