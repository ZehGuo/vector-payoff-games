%% Three players: why the coordinate change eta is not enough for N >= 3
% Builds on (published): the coordinate change eta, the transformed system
%   (25) and the LMI test (Proposition 2) of the ECC paper,
%   Z. Guo, T. Hayakawa, "A coordinate transformation method for stability
%   analysis of Nash equilibria with vector payoff functions", ECC.
% New in this extension (not yet peer reviewed): this counterexample and the
% vertex test that explains it.  See README.md, Sections 3 and 5.
%
% Three players with the same slopes in both payoffs:
%     J^i_1(x) = -1/2 ((R x)_i + 1)^2,   J^i_2(x) = -1/2 ((R x)_i - 1)^2,
% so that the signed distances are d^i_1 = (Rx)_i + 1 and d^i_2 = (Rx)_i - 1.
% With all speeds alpha = 1, the transformed system of the ECC paper is the
% SAME linear system  x_tilde' = -R x_tilde  in all 8 orthants.  It is stable
% and the LMIs of Proposition 2 (written for 3 players) hold.  Yet the
% equilibrium set is NOT stable: while player 1 does not move, players 2 and 3
% push each other out of their intervals.

clear; close all;
here = fileparts(mfilename('fullpath'));
root = fileparts(fileparts(here));
addpath(fullfile(root, 'functions'));
addpath(fullfile(here, 'functions'));
fprintf('\n== Extension: three players, a counterexample for eta ==\n');
st = style();
green = [0.15 0.60 0.30];                         % colour of player 3

R = [1 1 0; -1 1 1.5; 0.5 1.5 1];
N = 3;
for i = 1:N
    r = R(i, :)';
    G.A{i, 1} = -r * r';  G.b{i, 1} = -r;         % J^i_1 = -1/2 (r'x + 1)^2 (constant dropped)
    G.A{i, 2} = -r * r';  G.b{i, 2} = r;          % J^i_2 = -1/2 (r'x - 1)^2
end
G.alpha = ones(N, 2);
Go = orient_payoffs(G);
check('payoff 1 gives the lower end of every interval (width 2 everywhere)', isequal(Go.b, G.b));
check('all 8 selection matrices equal R, with det R = 0.5 > 0 (Assumption 1)', abs(det(R) - 0.5) < 1e-12);

%% 1. The transformed system of the ECC paper is stable
% In every orthant, x_tilde' = -R K x_tilde with K = I.
check('-R is Hurwitz, so the transformed system x_tilde'' = -R x_tilde is stable', ...
      max(real(eig(-R))) < 0, sprintf('eigenvalues of R: %s', mat2str(eig(R).', 3)));
P = reshape(-(kron(eye(N), -R') + kron(-R', eye(N))) \ reshape(eye(N), [], 1), N, N);
P = (P + P') / 2;                                 % solves (-R)'P + P(-R) = -I
check('V(x_tilde) = x_tilde''P x_tilde satisfies the LMIs of Proposition 2 in all 8 orthants', ...
      min(eig(P)) > 0 && norm((-R)' * P + P * (-R) + eye(N)) < 1e-10);

%% 2. ... but the face "player 1 does not move" is unstable
% With player 1 inactive, only players 2 and 3 move: x_tilde_{23}' = -R_{23,23} x_tilde_{23}.
Rface = R(2:3, 2:3);
check('the 2x2 block of -R for players 2 and 3 has the positive eigenvalue 0.5', ...
      abs(max(eig(-Rface)) - 0.5) < 1e-12);
% Vertex test: at the vertex where player 2 is at its lower end and player 3
% at its upper end, the couplings between 2 and 3 are both outward.
V = vertex_data(G, [1 1 2]);
B23 = V.B(2:3, 2:3);
check('vertex (1,1,2): players 2 and 3 push each other out (outward couplings 1.5 and 1.5)', ...
      all(B23(~eye(2)) > 0) && abs(max(eig(B23)) - 0.5) < 1e-12);

%% 3. Simulation: three starts closer and closer to the equilibrium set
% Player 1 starts inside its interval at depth 1; players 2 and 3 start a
% distance eps outside, along the direction in which they push each other out.
[vec, val] = eig(B23);
[~, q] = max(diag(val));
v = abs(vec(:, q)) / norm(vec(:, q));
epsList = [1e-2 1e-3 1e-4];
tEnd = 30;
runs = cell(1, 3);
maxEta = zeros(1, 3);
for k = 1:3
    w0 = [-1; epsList(k) * v];                    % vertex coordinates of the start
    [t, X] = simulate_n(G, V.x(w0), tEnd, 6000);
    Z = eta_n(G, X);
    runs{k} = struct('t', t, 'X', X, 'Z', Z, 'dist', vecnorm(Z));
    maxEta(k) = max(vecnorm(Z));
end
check('from distances 1e-2, 1e-3, 1e-4 the paths all go out to about the same distance (not stable)', ...
      min(maxEta) > 0.5, sprintf('largest |eta|: %s', mat2str(maxEta, 3)));
check('every path finally returns to the equilibrium set (it is attracting here, but not stable)', ...
      all(cellfun(@(r) r.dist(end) < 1e-3, runs)));

% The energy V along the true image eta(x(t)) and along the transformed system.
r = runs{2};
Vtrue = sum((r.Z' * P) .* r.Z', 2);
Ztr = zeros(N, numel(r.t));
for n = 1:numel(r.t), Ztr(:, n) = expm(-R * r.t(n)) * r.Z(:, 1); end
Vtr = sum((Ztr' * P) .* Ztr', 2);
check('V decreases along the transformed system but increases along the true image eta(x(t))', ...
      all(diff(Vtr) <= 1e-12) && max(Vtrue) > 100 * Vtrue(1));

%% Figure
fig = figure('Position', [50 50 1400 900]);
tl = tiledlayout(2, 2, 'TileSpacing', 'compact');

% (a) mechanism along the middle start
nexttile; hold on; box on; grid on
D = signed_distance(G, r.X);
depth1 = max(min(squeeze(D(1, 1, :)), -squeeze(D(1, 2, :))), 1e-12);   % distance of x^1 to the nearer end
plot(r.t, abs(r.Z(2, :)), '-', 'Color', st.blue, 'LineWidth', 2);
plot(r.t, abs(r.Z(3, :)), '-', 'Color', green, 'LineWidth', 2);
plot(r.t, depth1, '--', 'Color', st.red, 'LineWidth', 2);
set(gca, 'YScale', 'log'); ylim([1e-4 10]); xlim([0 20]);
xlabel('time t');
legend({'|\eta_2| (player 2 outside)', '|\eta_3| (player 3 outside)', 'depth of player 1 inside'}, 'Location', 'southeast');
title({'(a) players 2 and 3 push each other out', 'until player 1 is pushed out too'});

% (b) the largest distance does not shrink with the start
nexttile; hold on; box on; grid on
cl = lines(3);
for k = 1:3
    plot(runs{k}.t, runs{k}.dist, '-', 'Color', cl(k, :), 'LineWidth', 2);
end
set(gca, 'YScale', 'log'); ylim([1e-8 10]); xlim([0 tEnd]);
xlabel('time t'); ylabel('distance |\eta(x(t))|');
legend(arrayfun(@(e) sprintf('start at distance %.0e', e), epsList, 'UniformOutput', false), 'Location', 'southeast');
title({'(b) three starts closer and closer to the set', 'all go out to a distance of about 1'});

% (c) what each player does along the middle start
nexttile; hold on; box on
[~, branch] = pseudo_gradient_n(G, r.X);
imagesc(r.t([1 end]), 1:3, branch);
colormap(gca, [0.88 0.88 0.88; 0.55 0.75 0.95; 0.98 0.75 0.45]); clim([-0.5 2.5]);
set(gca, 'YTick', 1:3, 'YTickLabel', {'player 1', 'player 2', 'player 3'}, 'YDir', 'reverse');
xlim([0 20]); ylim([0.5 3.5]); xlabel('time t');
colorbar('Ticks', 0:2, 'TickLabels', {'does not move', 'below its interval', 'above its interval'});
title('(c) status of each player along the middle start');

% (d) the energy of the ECC LMI test
nexttile; hold on; box on; grid on
plot(r.t, Vtrue, '-', 'Color', 'k', 'LineWidth', 2);
plot(r.t, Vtr, '--', 'Color', st.purple, 'LineWidth', 2);
set(gca, 'YScale', 'log'); xlim([0 20]);
xlabel('time t');
legend({'V(\eta(x(t))): true motion', 'V(x_{tilde}(t)): transformed system (25)'}, 'Location', 'southeast');
title({'(d) the LMI energy V passes all 8 orthant tests,', 'but grows along the true motion'});
title(tl, 'Three players: the transformed system is stable, the equilibrium set is not', 'FontSize', 14);
save_extension_figure(fig, 'face_counterexample_3d');
