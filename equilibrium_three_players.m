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
faceColors = [0.85 0.33 0.10; 0.93 0.69 0.13; 0.00 0.45 0.74; ...
              0.30 0.75 0.93; 0.47 0.67 0.19; 0.49 0.18 0.56];
faceNames = {'w_1 = 0', 'w_1 = 1', 'w_2 = 0', 'w_2 = 1', 'w_3 = 0', 'w_3 = 1'};
fig = figure('Position', [100 100 1100 480]);
s = linspace(0, 1, 15);
[S, T] = meshgrid(s, s);
for panel = 1:2
    subplot(1, 2, panel); hold on
    for f = 1:6
        player = ceil(f / 2);             % which weight is fixed on this face
        value = mod(f + 1, 2);            % fixed at 0 or 1
        others = setdiff(1:3, player);
        P = zeros(3, numel(S));
        P(player, :) = value;
        P(others(1), :) = S(:)';
        P(others(2), :) = T(:)';
        if panel == 2                     % map each weight to its equilibrium
            for k = 1:size(P, 2)
                P(:, k) = weighted_nash_point(grad, weights_of(P(:, k)));
            end
        end
        surf(reshape(P(1, :), size(S)), reshape(P(2, :), size(S)), reshape(P(3, :), size(S)), ...
             'FaceColor', faceColors(f, :), 'EdgeColor', 'none', 'FaceAlpha', 0.75, ...
             'DisplayName', faceNames{f});
    end
    view(-35, 25); grid on; axis tight
    if panel == 1
        xlabel('w_1'); ylabel('w_2'); zlabel('w_3');
        title('All possible weights (a cube)');
        legend('Location', 'southoutside', 'NumColumns', 3);
    else
        xlabel('x^1'); ylabel('x^2'); zlabel('x^3');
        title('Equilibrium set: each face maps to a face');
    end
end
sgtitle('Three players: same colour = same face');
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
