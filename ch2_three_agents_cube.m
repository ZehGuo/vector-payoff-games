%% Chapter 2 - Three agents: the weight cube is mapped face-to-face onto X*(J)
% Thesis: Example 2.9 and Fig. 2.3 (Proposition 2.1, Lemma 2.2, Theorem 2.4).
%
% Three agents, each with a scalar state x^i and two payoffs.  Each agent's
% weights lambda^i = [w_i, 1 - w_i] live on a segment, so all weights together
% form the cube [0,1]^3.  Theorem 2.4 says: when Lambda(lambda)A is always
% invertible AND each agent's own-gradient matrix has rank s_i - 1 on X*(J),
% the map  weights -> Nash point  (eq. (2.11)) is a diffeomorphism.  In
% particular every face of the cube is sent onto a face of X*(J)
% ("the NESCP is simplicial"): the face w_i = 1 is the Nash set of the
% smaller game in which agent i keeps only payoff 1, and so on.

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'functions'));
fprintf('\n== Chapter 2: three agents, cube of weights (Example 2.9, Fig. 2.3) ==\n');

%% 1. The game, given by its own gradients dJ^i_j/dx^i = M x + v (thesis Example 2.9)
grad{1}{1} = struct('M', [-1 0 0.4],  'v', 0);
grad{1}{2} = struct('M', [-1 0 -0.6], 'v', 5);
grad{2}{1} = struct('M', [1 -2 0.4],  'v', 0);
grad{2}{2} = struct('M', [1 -2 -0.5], 'v', 6);
grad{3}{1} = struct('M', [0 0 -1.5],  'v', 0);
grad{3}{2} = struct('M', [0 0 -1],    'v', -10);

%% 2. Lemma 2.2: all 8 matrices A_{j1j2j3} have determinants of the same sign
d = zeros(1, 8); k = 0;
for j1 = 1:2
    for j2 = 1:2
        for j3 = 1:2
            k = k + 1;
            d(k) = det([grad{1}{j1}.M; grad{2}{j2}.M; grad{3}{j3}.M]);
        end
    end
end
check('Lemma 2.2: det(A_{j1j2j3}) all have the same sign', all(d > 0) || all(d < 0), ...
      sprintf('dets = %s', mat2str(d, 3)));

%% 3. Sample the whole cube and map it to the Nash set
w = linspace(0, 1, 21);
[W1, W2, W3] = ndgrid(w, w, w);
W = [W1(:)'; W2(:)'; W3(:)'];
X = zeros(3, size(W, 2));
for k = 1:size(W, 2)
    X(:, k) = weighted_nash_point(grad, weights_of(W(:, k)));
end

% Rank condition of Theorem 2.4 (here s_i - 1 = 1): an agent's two own
% gradients must never vanish together on X*(J).
minNorm = inf;
for i = 1:3
    g = [own_grad(grad, i, 1, X); own_grad(grad, i, 2, X)];
    minNorm = min(minNorm, min(vecnorm(g, 2, 1)));
end
check('Theorem 2.4 rank condition: own gradients never both zero on X*(J)', minNorm > 1e-6, ...
      sprintf('smallest gradient norm = %.3f', minNorm));

% One-to-one: from a Nash point x, eq. (2.15) gives back a unique weight,
% here w_i = g_2 / (g_2 - g_1).  It must equal the weight we started from.
Wback = zeros(size(W));
for i = 1:3
    g1 = own_grad(grad, i, 1, X);
    g2 = own_grad(grad, i, 2, X);
    Wback(i, :) = g2 ./ (g2 - g1);
end
check('weights recovered from Nash points (map is one-to-one)', max(abs(Wback(:) - W(:))) < 1e-9, ...
      sprintf('max error %.1e', max(abs(Wback(:) - W(:)))));

% Face-to-face: on the face w_1 = 1 agent 1 uses only payoff 1, so the point
% must lie on its best-response plane BR^1_1 (dJ^1_1/dx^1 = 0).
onFace = W(1, :) == 1;
check('face w_1 = 1 lies on the best-response plane BR^1_1', ...
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
        agent = ceil(f / 2);              % which weight is fixed on this face
        value = mod(f + 1, 2);            % fixed at 0 or 1
        others = setdiff(1:3, agent);
        P = zeros(3, numel(S));
        P(agent, :) = value;
        P(others(1), :) = S(:)';
        P(others(2), :) = T(:)';
        if panel == 2                     % map each weight to its Nash point
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
        title('Weights: cube \Delta^1\times\Delta^1\times\Delta^1');
        legend('Location', 'southoutside', 'NumColumns', 3);
    else
        xlabel('x^1'); ylabel('x^2'); zlabel('x^3');
        title('Nash set X^*(J): each face maps to a face');
    end
end
sgtitle('Chapter 2 (Example 2.9): same colour = same face');
save_figure(fig, 'ch2_three_agents_cube');

%% Local helper functions
function lam = weights_of(w)
% Turn the cube coordinates (w_1, w_2, w_3) into the three weight vectors.
lam = {[w(1), 1 - w(1)], [w(2), 1 - w(2)], [w(3), 1 - w(3)]};
end

function g = own_grad(grad, i, j, X)
% Own gradient dJ^i_j/dx^i evaluated at the columns of X.
g = grad{i}{j}.M * X + grad{i}{j}.v;
end
