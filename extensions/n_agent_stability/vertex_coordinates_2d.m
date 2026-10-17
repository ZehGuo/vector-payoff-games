%% Two players: the new coordinates (vertex coordinates) and the determinant test
% Builds on (published):
%   Z. Guo, T. Hayakawa, "A coordinate transformation method for stability
%     analysis of Nash equilibria with vector payoff functions", ECC:
%     the coordinate change eta, eqs. (20)-(21), the transformed system (25)
%     with the matrices (27), Theorem 1 and Proposition 2
%     (main repository: stability_lyapunov.m).
%   Z. Guo, T. Hayakawa, Y. Yan, IFAC World Congress 2023 and IEEE CDC 2023:
%     the determinant test and its five arrangements
%     (main repository: stability_cases.m).
% New in this extension (not yet peer reviewed): vertex coordinates, the
% vertex model w' = B [w]_+, and the vertex test.  See README.md, Sections 3-5.
%
% Part 1 uses the game of the ECC paper and shows what the new coordinates
% record that eta does not: how deep a player that does not move lies inside
% its interval, and how this depth shrinks when another player pushes it out.  Part 2 applies the vertex test to the five arrangements of
% stability_cases.m and checks that it gives the same answer as the
% determinant test.

clear; close all;
here = fileparts(mfilename('fullpath'));
root = fileparts(fileparts(here));
addpath(fullfile(root, 'functions'));            % helpers of the main repository
addpath(fullfile(here, 'functions'));            % helpers of this extension
fprintf('\n== Extension: vertex coordinates for two players ==\n');
st = style();

%% Part 1. The game of the ECC paper (same numbers as stability_lyapunov.m)
G.A = {[-2 -1; -1 -3], [-1 -1; -1 -3];
       [-7 -1; -1 -4], [-3 1; 1 -4]};
G.b = {[8; 0], [8; 0];
       [0; 0], [0; 0]};
G.alpha = [0.25 2; 0.25 0.25];
Go = orient_payoffs(G);
check('payoff 1 already gives the lower end for both players (convention (8) of the ECC paper)', ...
      isequal(Go.A, G.A));

% Vertex x*21: player 1 at its upper end, player 2 at its lower end.  Here
% both couplings are outward (C has two positive entries), but rho(C) < 1.
V21 = vertex_data(G, [2 1]);
check('at x*21 both couplings are outward and rho(C) < 1 (Theorem 2: stable for any speeds)', ...
      all(V21.C(~eye(2)) > 0) && max(abs(eig(V21.C))) < 1, sprintf('rho(C) = %.2f', max(abs(eig(V21.C)))));
% Start: player 1 inside its interval at depth 1.2 (w_1 = -1.2), player 2
% 2.5 below its lower end (w_2 = 2.5).
w0 = [-1.2; 2.5];
x0 = V21.x(w0);
[t, X] = simulate_n(G, x0, 20, 4000);
Z = eta_n(G, X);                       % the coordinates of the ECC paper
W = V21.w(X);                          % the vertex coordinates of x*21
D = signed_distance(G, X);
d1 = squeeze(D(:, 1, :)); d2 = squeeze(D(:, 2, :));

% Side region U^(2,1): player 1 is not below its lower end, player 2 not
% above its upper end, and all widths are positive.
inU = d1(1, :) >= -1e-9 & d2(2, :) <= 1e-9 & all(d1 - d2 > 0, 1);
check('the path stays in the side region U^(2,1) of the vertex x*21', all(inU));
check('in U^(2,1) the two coordinates agree where a player moves: eta = E [w]_+', ...
      max(abs(Z - V21.E * max(W, 0)), [], 'all') < 1e-8);

% The vertex model w' = B [w]_+ reproduces the vertex coordinates exactly.
opts = odeset('RelTol', 1e-8, 'AbsTol', 1e-10, 'MaxStep', t(end) / 1000);
[~, Wm] = ode45(@(~, w) V21.B * max(w, 0), t, W(:, 1), opts);
check('the vertex model w'' = B[w]_+ reproduces w(x(t)) along the whole path', ...
      max(abs(Wm' - W), [], 'all') < 1e-5, sprintf('max error %.1e', max(abs(Wm' - W), [], 'all')));

% Player 1 starts inactive; player 2's correction pushes it out.  eta_1 = 0
% gives no warning, while w_1 = -(depth) rises to 0.
[~, branch] = pseudo_gradient_n(G, X);
rest1 = branch(1, :) == 0;
kOut = find(~rest1, 1);                % first time player 1 moves
check('player 1 starts inactive and is pushed out later; before that eta_1 = 0 while w_1 rises from -1.2 to 0', ...
      rest1(1) && ~isempty(kOut) && all(Z(1, 1:kOut - 1) == 0) && all(diff(W(1, 1:kOut)) > 0) && W(1, kOut) > 0, ...
      sprintf('pushed out at t = %.2f', t(kOut)));
check('the path converges to the equilibrium set', norm(Z(:, end)) < 1e-4);

%% Figure 1: the same path in three coordinate systems
win = [4 14 -6 4];
fig = figure('Position', [50 50 1500 900]);
tl = tiledlayout(2, 3, 'TileSpacing', 'compact');

% (a) original coordinates, with the grid of the vertex coordinates of x*21
nexttile([2 1]); hold on
plot_game(G, win(1:2), win(3:4));
[Y1, Y2] = meshgrid(linspace(win(1), win(2), 400), linspace(win(3), win(4), 400));
Wy = V21.w([Y1(:)'; Y2(:)']);
contour(Y1, Y2, reshape(Wy(1, :), size(Y1)), -12:2:12, 'Color', st.light(st.red), 'HandleVisibility', 'off');
contour(Y1, Y2, reshape(Wy(2, :), size(Y1)), -12:2:12, 'Color', st.light(st.blue), 'HandleVisibility', 'off');
axis equal; axis(win);
draw_path(X, [0.2 0.6]);
plot(V21.xstar(1), V21.xstar(2), 'kd', 'MarkerFaceColor', 'y', 'MarkerSize', 9);
text(V21.xstar(1) + 0.3, V21.xstar(2) + 0.5, 'x^{*21}', 'FontSize', 11);
title({'(a) the path in the original coordinates', ...
       'thin lines: w_1 = const (red), w_2 = const (blue)'});

% (b) the coordinates eta of the ECC paper
nexttile; hold on; box on; grid on
plot(Z(1, :), Z(2, :), 'k-', 'LineWidth', 2);
plot(Z(1, 1), Z(2, 1), 'ko', 'MarkerFaceColor', 'k');
plot(0, 0, 'o', 'MarkerFaceColor', st.purple, 'MarkerEdgeColor', st.purple, 'MarkerSize', 9);
xline(0, 'k:'); yline(0, 'k:');
xlabel('\eta_1'); ylabel('\eta_2');
title({'(b) coordinates \eta of the ECC paper', 'the equilibrium set is the point 0 (purple)'});

% (c) the vertex coordinates of x*21
nexttile; hold on; box on; grid on
% Image of the equilibrium set: the polygon with the four vertex points as corners.
P = zeros(2, 4); sel = [1 1; 1 2; 2 2; 2 1];
for q = 1:4, P(:, q) = V21.w(vertex_data(G, sel(q, :)).xstar); end
patch(P(1, :), P(2, :), st.purple, 'FaceAlpha', 0.75, 'EdgeColor', 'none', 'HandleVisibility', 'off');
plot(W(1, :), W(2, :), 'k-', 'LineWidth', 2);
plot(W(1, 1), W(2, 1), 'ko', 'MarkerFaceColor', 'k');
xline(0, 'k:'); yline(0, 'k:');
xlabel('w_1'); ylabel('w_2');
title({'(c) vertex coordinates of x^{*21}', 'w_i \leq 0: player i does not move, -w_i is its depth'});

% (d) player 1: eta_1 and w_1 over time
nexttile([1 2]); hold on; box on; grid on
yl = [min([Z(1, :) W(1, :)]) - 0.5, max([Z(1, :) W(1, :)]) + 0.5];
ylim(yl); xlim([0 8]);
shade_times(t, rest1, [0.5 0.5 0.5]);            % grey: player 1 does not move
plot(t, Z(1, :), '-', 'Color', st.red, 'LineWidth', 2);
plot(t, W(1, :), '--', 'Color', st.red, 'LineWidth', 2);
yline(0, 'k:', 'HandleVisibility', 'off');
xlabel('time t');
legend({'\eta_1(x(t))', 'w_1(x(t))'}, 'Location', 'northeast');
title('(d) player 1: \eta_1 = 0 until it is pushed out; w_1 shows its depth shrinking beforehand');
save_extension_figure(fig, 'vertex_coordinates');

%% Part 2. The five arrangements of stability_cases.m
% Same games as the figure stability_one_piece.png of the main repository.
cases = {
    {[-3 -1], 25,   [-2 1], 0,         [-1/2 -1], 6,   [1/2 -1], 5,      0.01 * ones(2),      [0.5 10 0 11]}
    {[-3 1], 5,     [-4 1], 10,        [1/2 -1], 5,    [1/4 -1], 21/4,   [1/3 1/4; 2 2],      [0.5 10 0 11]}
    {[-2 -1], 20,   [-3 -1], 25,       [1/2 -1], 5,    [1/4 -1], 21/4,   [1/2 1/3; 2 2],      [0.5 10 0 11]}
    {[-3 -1], 25,   [-2 1], 0,         [1/2 -1], 5,    [1/4 -1], 21/4,   [1 1; 2 2],          [0.5 10 0 11]}
    {[-1/4 1], -35/4, [-1/2 1], -15/2, [4 -1], 3/2,    [3 -1], 5/2,      [4 2; 1 1],          [0.5 6 2 11]}
};
% Marker and fill colour for the four kinds of vertex (see the legend panel).
mk = {'o', [1 1 1]; 's', [0.6 0.6 0.6]; '^', [1 0.85 0.2]; 'p', [0 0 0]};
fig = figure('Position', [50 50 1200 820]);
tl = tiledlayout(2, 3, 'TileSpacing', 'compact');
for k = 1:numel(cases)
    c = cases{k};
    G = orient_payoffs(game_from_rows(c{1:8}, c{9}));
    win = c{10};
    nexttile; hold on
    plot_game(G, win(1:2), win(3:4));
    axis(win);
    dets = zeros(2); allES = true; bad = [];
    for j1 = 1:2
        for j2 = 1:2
            dets(j1, j2) = det([G.A{1, j1}(1, :); G.A{2, j2}(2, :)]);
            V = vertex_data(G, [j1 j2]);
            out12 = V.C(1, 2) > 0; out21 = V.C(2, 1) > 0;
            isES = max(abs(eig(V.C))) < 1;              % Theorem 2 (exact for two players)
            allES = allES && isES;
            if ~out12 && ~out21, kind = 1;          % both couplings inward
            elseif out12 ~= out21, kind = 2;        % one inward, one outward
            elseif isES, kind = 3;                  % both outward, test passed
            else, kind = 4; bad = V;                % both outward, test failed
            end
            plot(V.xstar(1), V.xstar(2), mk{kind, 1}, 'MarkerSize', 11, 'MarkerFaceColor', mk{kind, 2}, ...
                 'MarkerEdgeColor', 'k', 'LineWidth', 1.2, 'HandleVisibility', 'off');
        end
    end
    detPositive = all(dets(:) > 0);
    check(sprintf('(%c) vertex test (all four vertex models ES) agrees with the determinant test', 'a' + k - 1), ...
          allES == detPositive, sprintf('determinants %s', mat2str(dets(:)', 3)));
    if detPositive
        verdict = 'det > 0: every vertex passes, stable';
    else
        verdict = 'det < 0: one vertex fails, unstable';
        % Start next to the failing vertex along the direction in which both
        % players push each other out (positive eigenvector of B).
        [vec, val] = eig(bad.B);
        [lam, q] = max(diag(val));
        v = vec(:, q) * sign(sum(vec(:, q)));
        xStart = bad.x(0.02 * v / norm(v));
        [~, Xb] = simulate_n(G, xStart, 6, 1500);
        Xb = Xb(:, all(Xb >= [win(1); win(3)] & Xb <= [win(2); win(4)], 1));
        draw_path(Xb, 0.5);
        grow = norm(eta_n(G, Xb(:, end))) / norm(eta_n(G, xStart));
        check(sprintf('(%c) a path that starts next to the failing vertex moves away', 'a' + k - 1), ...
              lam > 0 && grow > 10, sprintf('positive eigenvalue %.2f, distance grows %.0f-fold', lam, grow));
    end
    title(sprintf('(%c) %s', 'a' + k - 1, verdict));
end
nexttile; axis off; hold on
h = gobjects(4, 1);
for kind = 1:4
    h(kind) = plot(NaN, NaN, mk{kind, 1}, 'MarkerSize', 11, 'MarkerFaceColor', mk{kind, 2}, 'MarkerEdgeColor', 'k');
end
legend(h, {'vertex: both couplings inward', 'vertex: one inward, one outward', ...
           'vertex: both outward, test passed', 'vertex: both outward, test failed'}, ...
       'Location', 'north', 'FontSize', 10);
lgd = standard_legend({'goals', 'set', 'path'});
lgd.Layout.Tile = 'south';
title(tl, 'The vertex test on the five arrangements of stability\_cases.m', 'FontSize', 14);
save_extension_figure(fig, 'vertex_test_2d');


%% ------------------------------------------------------------------------
function G = game_from_rows(r11, b11, r12, b12, r21, b21, r22, b22, alpha)
% Same construction as in stability_cases.m of the main repository.
G.A = {[r11; r11(2) -1], [r12; r12(2) -1];
       [-1 r21(1); r21], [-1 r22(1); r22]};
G.b = {[b11; 0], [b12; 0];
       [0; b21], [0; b22]};
G.alpha = alpha;
end
