%% A player with two numbers and three goals: a prism of weights
% Paper: Z. Guo, T. Hayakawa, "Topology of Nash equilibrium set with quadratic
%        vector payoff functions", ACC 2024, https://doi.org/10.23919/ACC60939.2024.10644643
%
% Player 1 chooses TWO numbers x^1 = [x^1_1; x^1_2] and has THREE payoffs, so
% its weights (three numbers >= 0 summing to 1) live on a triangle.  Player 2
% chooses one number x^2 and has two payoffs (weights on a segment).  All
% weights together form a triangular prism.  As for three players, the map
% weights -> equilibrium is one-to-one, and the prism's 5 faces
% (3 rectangles + 2 triangles) become the 5 faces of the equilibrium set.

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'functions'));
fprintf('\n== Player with two numbers and three goals: prism of weights ==\n');

%% 1. The game: how each payoff changes when its player moves, M x + v, with x = [x^1_1; x^1_2; x^2]
grad{1}{1} = struct('M', [-1 0 0.5; 0 -1 0],  'v', [0; 0]);
grad{1}{2} = struct('M', [-1 0 0.5; 0 -2 0],  'v', [0; 5]);
grad{1}{3} = struct('M', [-1 0 0;   0 -2 0.5], 'v', [6; 0]);
grad{2}{1} = struct('M', [1 0.5 -2], 'v', 0);
grad{2}{2} = struct('M', [1 0.5 -2], 'v', 6);

%% 2. Condition 1: build 3x3 matrices by taking each gradient row from any
% payoff; if all their determinants have the same sign, the set is bounded
% and connected.
d = [];
for a = 1:3
    for b = 1:3
        for c = 1:2
            d(end + 1) = det([grad{1}{a}.M(1, :); grad{1}{b}.M(2, :); grad{2}{c}.M]); %#ok<SAGROW>
        end
    end
end
check('condition 1: all 18 determinants have the same sign', all(d > 0) || all(d < 0), ...
      sprintf('range [%.2f, %.2f]', min(d), max(d)));

%% 3. Sample the prism and map it to the equilibrium set
n = 16;
[U, V, W] = ndgrid(linspace(0, 1, n), linspace(0, 1, n), linspace(0, 1, n));
keep = U + V <= 1 + 1e-12;                         % (u, v, 1-u-v) on the triangle
L = [U(keep)'; V(keep)'; W(keep)'];
X = zeros(3, size(L, 2));
for k = 1:size(L, 2)
    X(:, k) = weighted_nash_point(grad, weights_of(L(:, k)));
end

% Condition 2 (makes the map one-to-one): at every equilibrium, player 1's
% three gradient vectors span a plane (rank 2) and player 2's two own
% gradients are not both zero (rank 1).
ok = true;
Lback = zeros(size(L));
for k = 1:size(X, 2)
    G1 = [own_grad(grad, 1, 1, X(:, k)), own_grad(grad, 1, 2, X(:, k)), own_grad(grad, 1, 3, X(:, k))];  % 2-by-3
    G2 = [own_grad(grad, 2, 1, X(:, k)), own_grad(grad, 2, 2, X(:, k))];                                 % 1-by-2
    ok = ok && rank(G1, 1e-8) == 2 && rank(G2, 1e-8) == 1;
    % Read the weights back: [gradients; 1 1 1] * lambda = [0; 0; 1] has one solution.
    lam1 = [G1; 1 1 1] \ [0; 0; 1];
    Lback(:, k) = [lam1(1); lam1(2); G2(2) / (G2(2) - G2(1))];
end
check('condition 2 holds at every sampled equilibrium', ok);
check('weights recovered from equilibria (map is one-to-one)', max(abs(Lback(:) - L(:))) < 1e-9, ...
      sprintf('max error %.1e', max(abs(Lback(:) - L(:)))));

% Coordinate ranges of the published figure: x^1_1 in [0,6], x^1_2 in [0,3], x^2 in [0,8].
rng = [min(X, [], 2), max(X, [], 2)];
check('equilibrium set lies in the box of the published figure', ...
      all(rng(:, 1) > -1e-9) && all(rng(:, 2) <= [6; 3; 8] + 1e-9), ...
      sprintf('x^1_1 in [%.2f,%.2f], x^1_2 in [%.2f,%.2f], x^2 in [%.2f,%.2f]', rng'));

%% 4. Figure: the 5 faces of the prism and their images
% Player 1's three weights form the triangle at the bottom (each corner means
% "only this goal"); player 2's weight on its goal 2 is the height.
faceColors = [0.85 0.33 0.10; 0.93 0.69 0.13; 0.47 0.67 0.19; 0.00 0.45 0.74; 0.49 0.18 0.56];
faceNames = {'player 1 ignores goal 1', 'player 1 ignores goal 2', 'player 1 ignores goal 3', ...
             'player 2: only goal 2', 'player 2: only goal 1'};
s = linspace(0, 1, 25);
[S, T] = meshgrid(s, s);
faces = cell(2, 5);                        % row 1: prism, row 2: equilibrium set
for f = 1:5
    P = face_points(f, S, T);              % prism coordinates (u, v, w)
    faces{1, f} = prism_to_plot(P);
    Q = zeros(3, size(P, 2));
    for k = 1:size(P, 2)
        Q(:, k) = weighted_nash_point(grad, weights_of(P(:, k)));
    end
    faces{2, f} = Q;
end
view2 = [-40 25];                          % a clear view of the equilibrium set
[az, el] = matching_view(faces(2, :), faces(1, :), view2);   % show the same faces on the left

fig = figure('Position', [100 100 1100 560]);
for panel = 1:2
    subplot(1, 2, panel); hold on
    for f = 1:5
        Q = faces{panel, f};
        X = reshape(Q(1, :), size(S)); Y = reshape(Q(2, :), size(S)); Z = reshape(Q(3, :), size(S));
        surf(X, Y, Z, 'FaceColor', faceColors(f, :), 'EdgeColor', 'none', 'FaceAlpha', 0.85, ...
             'DisplayName', faceNames{f});
        edge = @(M) [M(1, :), M(2:end, end)', M(end, end-1:-1:1), M(end-1:-1:1, 1)'];
        plot3(edge(X), edge(Y), edge(Z), 'k-', 'LineWidth', 0.6, 'HandleVisibility', 'off');
    end
    grid on; axis equal tight
    if panel == 1
        view(az, el);
        set(gca, 'XTick', [], 'YTick', []);
        xlabel('player 1''s three weights (triangle)');
        zlabel('player 2''s weight on goal 2');
        title('All possible weights (a prism)');
        legend('Location', 'southoutside', 'NumColumns', 2);
    else
        view(view2);
        xlabel('x^1_1 (player 1, number 1)'); ylabel('x^1_2 (player 1, number 2)'); zlabel('x^2 (player 2)');
        title('Equilibrium set: each face becomes a face');
    end
end
sgtitle({'Player 1 chooses two numbers and has three goals: same colour = same face', '\fontsize{9}(faces you cannot see are at the back in both pictures)'});
save_figure(fig, 'equilibrium_vector_states');

%% Local helper functions
function lam = weights_of(p)
% Prism coordinates (u, v, w) -> weight vectors of the two players.
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
% Height = player 2's weight on goal 2, so that the picture is not upside
% down compared with the equilibrium set.
Q = [P(1, :) + 0.5 * P(2, :); sqrt(3) / 2 * P(2, :); 1 - P(3, :)];
end
