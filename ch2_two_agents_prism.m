%% Chapter 2 - Vector states: a triangular prism of weights maps onto X*(J)
% Thesis: Example 2.10 and Fig. 2.4 (Theorem 2.4 with r_1 = 2, s_1 = 3).
%
% Agent 1 controls a 2-dimensional state x^1 = [x^1_1; x^1_2] and has THREE
% payoffs, so its weights live on a triangle (the simplex Delta^2).  Agent 2
% controls a scalar x^2 and has two payoffs (weights on a segment, Delta^1).
% All weights together form the prism Delta^2 x Delta^1.  Theorem 2.4 again
% says the map  weights -> Nash point  is one-to-one and sends each of the
% prism's 5 faces (3 rectangles + 2 triangles) onto a face of X*(J).

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'functions'));
fprintf('\n== Chapter 2: vector states, prism of weights (Example 2.10, Fig. 2.4) ==\n');

%% 1. The game: own gradients dJ^i_j/dx^i = M x + v, with x = [x^1_1; x^1_2; x^2]
grad{1}{1} = struct('M', [-1 0 0.5; 0 -1 0],  'v', [0; 0]);
grad{1}{2} = struct('M', [-1 0 0.5; 0 -2 0],  'v', [0; 5]);
grad{1}{3} = struct('M', [-1 0 0;   0 -2 0.5], 'v', [6; 0]);
% NOTE: the thesis text prints [-1, 0.5, -2] for agent 2.  The thesis figure
% (all coordinates >= 0) is reproduced only with +1, as in the original
% simulation code, so +1 is used here (see NOTES.md).
grad{2}{1} = struct('M', [1 0.5 -2], 'v', 0);
grad{2}{2} = struct('M', [1 0.5 -2], 'v', 6);

%% 2. Lemma 2.2: choose each ROW of the Jacobian from any payoff -> same det sign
d = [];
for a = 1:3
    for b = 1:3
        for c = 1:2
            d(end + 1) = det([grad{1}{a}.M(1, :); grad{1}{b}.M(2, :); grad{2}{c}.M]); %#ok<SAGROW>
        end
    end
end
check('Lemma 2.2: all 18 row-wise determinants have the same sign', all(d > 0) || all(d < 0), ...
      sprintf('range [%.2f, %.2f]', min(d), max(d)));

%% 3. Sample the prism and map it to the Nash set
n = 16;
[U, V, W] = ndgrid(linspace(0, 1, n), linspace(0, 1, n), linspace(0, 1, n));
keep = U + V <= 1 + 1e-12;                         % (u, v, 1-u-v) on the triangle
L = [U(keep)'; V(keep)'; W(keep)'];
X = zeros(3, size(L, 2));
for k = 1:size(L, 2)
    X(:, k) = weighted_nash_point(grad, weights_of(L(:, k)));
end

% Theorem 2.4 rank condition: rank(dJ^1/dx^1) = s_1 - 1 = 2 and
% rank(dJ^2/dx^2) = s_2 - 1 = 1 at every Nash point.
ok = true;
Lback = zeros(size(L));
for k = 1:size(X, 2)
    G1 = [own_grad(grad, 1, 1, X(:, k)), own_grad(grad, 1, 2, X(:, k)), own_grad(grad, 1, 3, X(:, k))];  % 2-by-3
    G2 = [own_grad(grad, 2, 1, X(:, k)), own_grad(grad, 2, 2, X(:, k))];                                 % 1-by-2
    ok = ok && rank(G1, 1e-8) == 2 && rank(G2, 1e-8) == 1;
    % Eq. (2.15): [Jacobian'; 1 1 1] lambda = [0; 0; 1] has a unique solution.
    lam1 = [G1; 1 1 1] \ [0; 0; 1];
    Lback(:, k) = [lam1(1); lam1(2); G2(2) / (G2(2) - G2(1))];
end
check('Theorem 2.4 rank condition holds at every sampled Nash point', ok);
check('weights recovered from Nash points (map is one-to-one)', max(abs(Lback(:) - L(:))) < 1e-9, ...
      sprintf('max error %.1e', max(abs(Lback(:) - L(:)))));

% Coordinate ranges of the thesis figure: x^1_1 in [0,6], x^1_2 in [0,3], x^2 in [0,8].
rng = [min(X, [], 2), max(X, [], 2)];
check('Nash set lies in the box shown in thesis Fig. 2.4', ...
      all(rng(:, 1) > -1e-9) && all(rng(:, 2) <= [6; 3; 8] + 1e-9), ...
      sprintf('x^1_1 in [%.2f,%.2f], x^1_2 in [%.2f,%.2f], x^2 in [%.2f,%.2f]', rng'));

%% 4. Figure: the 5 faces of the prism and their images
faceColors = [0.85 0.33 0.10; 0.93 0.69 0.13; 0.47 0.67 0.19; 0.00 0.45 0.74; 0.49 0.18 0.56];
faceNames = {'\lambda^1_1 = 0', '\lambda^1_2 = 0', '\lambda^1_3 = 0', '\lambda^2_1 = 0', '\lambda^2_1 = 1'};
s = linspace(0, 1, 25);
[S, T] = meshgrid(s, s);
fig = figure('Position', [100 100 1100 480]);
for panel = 1:2
    subplot(1, 2, panel); hold on
    for f = 1:5
        P = face_points(f, S, T);                  % prism coordinates (u, v, w)
        if panel == 1
            Q = prism_to_plot(P);
        else
            Q = zeros(3, size(P, 2));
            for k = 1:size(P, 2)
                Q(:, k) = weighted_nash_point(grad, weights_of(P(:, k)));
            end
        end
        surf(reshape(Q(1, :), size(S)), reshape(Q(2, :), size(S)), reshape(Q(3, :), size(S)), ...
             'FaceColor', faceColors(f, :), 'EdgeColor', 'none', 'FaceAlpha', 0.75, ...
             'DisplayName', faceNames{f});
    end
    view(-40, 25); grid on; axis tight
    if panel == 1
        title('Weights: prism \Delta^2 \times \Delta^1');
        xlabel(''); ylabel(''); zlabel('\lambda^2_1');
        legend('Location', 'southoutside', 'NumColumns', 3);
    else
        title('Nash set X^*(J): 5 faces \leftrightarrow 5 faces');
        xlabel('x^1_1'); ylabel('x^1_2'); zlabel('x^2');
    end
end
sgtitle('Chapter 2 (Example 2.10): same colour = same face');
save_figure(fig, 'ch2_two_agents_prism');

%% Local helper functions
function lam = weights_of(p)
% Prism coordinates (u, v, w) -> weight vectors of the two agents.
lam = {[p(1), p(2), 1 - p(1) - p(2)], [p(3), 1 - p(3)]};
end

function g = own_grad(grad, i, j, x)
g = grad{i}{j}.M * x + grad{i}{j}.v;
end

function P = face_points(f, S, T)
% Parametrize face f of the prism by (S, T) in [0,1]^2.
switch f
    case 1, P = [zeros(1, numel(S)); S(:)'; T(:)'];        % lambda^1_1 = 0
    case 2, P = [S(:)'; zeros(1, numel(S)); T(:)'];        % lambda^1_2 = 0
    case 3, P = [S(:)'; 1 - S(:)'; T(:)'];                 % lambda^1_3 = 0
    case 4, P = [S(:)' .* (1 - T(:)'); T(:)'; zeros(1, numel(S))];  % triangle, lambda^2_1 = 0
    case 5, P = [S(:)' .* (1 - T(:)'); T(:)'; ones(1, numel(S))];   % triangle, lambda^2_1 = 1
end
end

function Q = prism_to_plot(P)
% Draw the triangle (u, v) as an equilateral triangle for a familiar picture.
Q = [P(1, :) + 0.5 * P(2, :); sqrt(3) / 2 * P(2, :); P(3, :)];
end
