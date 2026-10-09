%% Chapter 5 - Designing taxes/subsidies that guarantee weak Pareto improvement
% Thesis: Section 5.3-5.4, eqs. (5.27)-(5.28), Theorem 5.4, Figs. 5.5 and 5.6.
%
% The manager picks priorities eta^i_j, which define a social welfare
% U(x) = sum eta^i_j J^i_j(x) and a target state x_hat = argmax U (5.7)-(5.8).
% Incentives can only be added to the money-type payoff J^i_1 of each agent.
% With the design (5.27) and the simplest parameter choice of the thesis
% (omega^i = 0, Q_i = 0), the incentivized money payoff becomes
%   tilde J^i_1(x) = zeta_i * sigma * (U(x) - U(x0)) + J^i_1(x0),        (5.28)
% i.e. agent i receives the share zeta_i of the (scaled) social welfare gain.
% The incentive itself is p^i(x) = tilde J^i_1(x) - J^i_1(x).
% Theorem 5.4: if the conditions (5.29) hold, the incentivized trajectory is
% weakly Pareto improving, nobody falls into the trap, the budget
% p^1 + p^2 <= 0 holds, and the Nash set of the new game is stable.

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'functions'));
fprintf('\n== Chapter 5: incentive design (Figs. 5.5, 5.6) ==\n');

%% 1. Original game (Section 5.4) and the manager's choices
G.A = {[-4 1; 1 -10],   [-4 -1; -1 -3];
       [-16 8; 8 -16],  [-5 -1; -1 -2]};
G.b = {[5; -440], [30; -20];
       [360; 0],  [58.5; 0]};
G.alpha = ones(2);              % agents' sensitivities (Theorem 5.4: any alpha > 0)
eta = [0.7 4; 1 2];             % manager's priorities eta^i_j
x0 = [16; -15];
sigma = 0.05;                   % incentive scale
zeta = [0.3; 0.7];              % shares of the welfare gain, zeta_1 + zeta_2 = 1

% Social welfare U(x) = 1/2 x'HU x + gU'x and the target state x_hat (5.8)
HU = 0; gU = 0;
for i = 1:2
    for j = 1:2
        HU = HU + eta(i,j) * G.A{i,j};
        gU = gU + eta(i,j) * G.b{i,j};
    end
end
xhat = -HU \ gU;
Ufun = @(X) 0.5 * sum(X .* (HU * X), 1) + gU' * X;
fprintf('   target state x_hat = (%.4f, %.4f)\n', xhat);

%% 2. Incentivized game: replace J^i_1 by tilde J^i_1 of eq. (5.28)
Gt = G;
Gt.c = zeros(2);               % constants c^i_j (zero in the original game)
for i = 1:2
    Gt.A{i,1} = zeta(i) * sigma * HU;
    Gt.b{i,1} = zeta(i) * sigma * gU;
    Gt.c(i,1) = payoff_value(G, i, 1, x0) - zeta(i) * sigma * Ufun(x0);
end
incentive = @(i, X) payoff_value(Gt, i, 1, X) - payoff_value(G, i, 1, X);   % p^i(x)

%% 3. Conditions of Theorem 5.4
% Assumption 6: unincentivized payoffs concave in own state, det(A_22) > 0.
% (5.29a): det(tilde A_{j1j2}) > 0 for (1,1), (1,2), (2,1).
dt = zeros(2);
for j1 = 1:2
    for j2 = 1:2
        dt(j1, j2) = det([Gt.A{1,j1}(1,:); Gt.A{2,j2}(2,:)]);
    end
end
check('Assumption 6 and (5.29a): all det(tilde A_{j1j2}) > 0, own concavity', ...
      all(dt(:) > 0) && G.A{1,2}(1,1) < 0 && G.A{2,2}(2,2) < 0 && Gt.A{1,1}(1,1) < 0 && Gt.A{2,1}(2,2) < 0, ...
      sprintf('dets = %s', mat2str(dt(:)', 3)));
% With omega = 0 the new best-response lines of payoff 1 pass through x_hat,
% so the target is a Nash equilibrium of the incentivized game (Remark 5.3).
check('x_hat is a Nash equilibrium of the incentivized game', ...
      abs(own_gradient(Gt, 1, 1, xhat)) < 1e-9 && abs(own_gradient(Gt, 2, 1, xhat)) < 1e-9 && in_nash_set(Gt, xhat, 1e-9));
check('budget rule (5.5): p^1(x0) = p^2(x0) = 0', abs(incentive(1, x0)) < 1e-9 && abs(incentive(2, x0)) < 1e-9);

%% 4. Simulate without and with the incentive
tEnd = 10;                      % slow at the end: the incentive is scaled by sigma
[t0, X0] = simulate_game(G, x0, tEnd, 3000);
[t1, X1] = simulate_game(Gt, x0, tEnd, 3000);

% Payoffs along both trajectories (incentivized money payoff for the new game)
[J0, dJ0] = payoff_history(G, X0);
[J1, dJ1] = payoff_history(Gt, X1);
tol = -1e-6 * max(abs(dJ1(:)));
weak = @(dJ) all(max(dJ(1:2, :)) >= tol) && all(max(dJ(3:4, :)) >= tol);
budgetTotal = incentive(1, X1) + incentive(2, X1);

loser = find([any(max(dJ0(1:2, :)) < tol), any(max(dJ0(3:4, :)) < tol)]);
check('without incentive the trajectory is NOT weakly Pareto improving', ~weak(dJ0), ...
      sprintf('agent(s) %s lose on both payoffs at some time', mat2str(loser)));
check('with incentive the trajectory is weakly Pareto improving', weak(dJ1));
% With omega = 0, tilde J^i_1 itself never decreases, so no payoff vector can
% become worse in both components later (Lemma 5.1): nobody is trapped.
check('with incentive tilde J^i_1 never decreases (no trap, Lemma 5.1)', ...
      all(dJ1(1, :) >= tol) && all(dJ1(3, :) >= tol));
check('budget rule (5.6): p^1 + p^2 <= 0 along the whole trajectory', all(budgetTotal <= 1e-9), ...
      sprintf('max p^1+p^2 = %.2e', max(budgetTotal)));
check('incentivized trajectory converges to the target x_hat', norm(X1(:, end) - xhat) < 0.05, ...
      sprintf('end (%.2f, %.2f), distance to x_hat %.2f', X1(:, end), norm(X1(:, end) - xhat)));

%% 5. Fig. 5.5(a): Pareto set of the four payoffs (maximizers of weighted sums)
P = [];
for a = 0:0.05:1
    for b = 0:0.05:1 - a
        for c = 0:0.05:1 - a - b
            wts = [a b; c 1 - a - b - c];
            H = 0; g = 0;
            for i = 1:2
                for j = 1:2
                    H = H + wts(i,j) * G.A{i,j};
                    g = g + wts(i,j) * G.b{i,j};
                end
            end
            P(:, end + 1) = -H \ g; %#ok<SAGROW>
        end
    end
end

%% 6. Figure
fig = figure('Position', [50 50 1400 820]);
subplot(2, 2, 1); hold on
plot(P(1, :), P(2, :), '.', 'Color', [0.45 0.65 0.25], 'MarkerSize', 6);
h = plot_game(G, [-10 40], [-50 50]);
legend([h, findobj(gca, 'Type', 'line', 'Marker', '.')'], ...
       {'BR^1_1', 'BR^1_2', 'BR^2_1', 'BR^2_2', 'Pareto set'}, 'Location', 'southeast');
title('(a) Pareto set of the four payoffs (Fig. 5.5a)');

subplot(2, 2, 2); hold on
win = [-5 32 -18 12];
[Y1, Y2] = meshgrid(linspace(win(1), win(2), 400), linspace(win(3), win(4), 400));
Y = [Y1(:)'; Y2(:)'];
inBud = incentive(1, Y) + incentive(2, Y) <= 0;
image(Y1(1, :), Y2(:, 1), repmat(reshape([0.98 0.75 0.45], 1, 1, 3), size(Y1)), 'AlphaData', 0.6 * reshape(inBud, size(Y1)));
set(gca, 'YDir', 'normal');
Jsum = payoff_value(G, 1, 1, Y) + payoff_value(G, 2, 1, Y);    % omega = 0
contour(Y1, Y2, reshape(Ufun(Y) - Ufun(x0), size(Y1)), [0 0], 'm--', 'LineWidth', 1.5);
contour(Y1, Y2, reshape(Jsum - (payoff_value(G, 1, 1, x0) + payoff_value(G, 2, 1, x0)), size(Y1)), ...
        [0 0], 'm-', 'LineWidth', 1.5);
plot_game(Gt, win(1:2), win(3:4));
h1 = plot(X0(1, :), X0(2, :), 'k--', 'LineWidth', 1.8);
h2 = plot(X1(1, :), X1(2, :), 'k-', 'LineWidth', 2.2);
plot(x0(1), x0(2), 'ko', 'MarkerFaceColor', 'k');
plot(xhat(1), xhat(2), 'g*', 'MarkerSize', 10, 'LineWidth', 1.5);
legend([h1 h2], {'original trajectory', 'incentivized trajectory'}, 'Location', 'northeast');
title({'(b) orange: D_{bud}(\sigma);  magenta dashed: \partialD(U,x_0);  solid: \partialD(J_{sum},x_0)', ...
       'lines and purple set: incentivized game;  green star: target state'});

% Without incentive the money payoffs change ~50 times more than the others,
% so they are shown divided by 10 (as in the thesis figure).
labels = {{'J^1_1 / 10', 'J^1_2', 'J^2_1 / 10', 'J^2_2'}, {'J^1_1 + p^1', 'J^1_2', 'J^2_1 + p^2', 'J^2_2'}};
scale = {[10 1 10 1], [1 1 1 1]};
data = {{t0, J0}, {t1, J1}};
names = {'(c) payoffs WITHOUT incentive: not weakly Pareto improving', ...
         '(d) payoffs WITH incentive: every agent always gains on one payoff'};
for p = 1:2
    subplot(2, 2, 2 + p); hold on
    tt = data{p}{1}; JJ = data{p}{2};
    styles = {'-', '--', '-', '--'};
    colors = {[0.85 0.15 0.15], [0.85 0.15 0.15], [0.10 0.45 0.85], [0.10 0.45 0.85]};
    for r = 1:4
        plot(tt, (JJ(r, :) - JJ(r, 1)) / scale{p}(r), styles{r}, 'Color', colors{r}, 'LineWidth', 1.6);
    end
    if p == 2
        plot(tt, budgetTotal, ':', 'Color', [0.4 0.4 0.4], 'LineWidth', 2);
        labels{2}{end + 1} = 'p^1 + p^2 (manager''s net payment)';
    end
    yline(0, 'k:', 'HandleVisibility', 'off');
    xlabel('time t'); ylabel('change since t = 0');
    legend(labels{p}, 'Location', 'southoutside', 'NumColumns', 3); box on
    title(names{p});
end
sgtitle('Chapter 5: incentive design with a budget constraint (\eta = (0.7, 4, 1, 2), \sigma = 0.05, \zeta = (0.3, 0.7))');
save_figure(fig, 'ch5_incentive_design');

%% ------------------------------------------------------------------------
function [J, dJ] = payoff_history(G, X)
% Values and time derivatives of the four payoffs along a trajectory X.
F = pseudo_gradient(G, X);
J = zeros(4, size(X, 2)); dJ = J; r = 0;
for i = 1:2
    for j = 1:2
        r = r + 1;
        J(r, :) = payoff_value(G, i, j, X);
        dJ(r, :) = sum((G.A{i,j} * X + G.b{i,j}) .* F, 1);
    end
end
end
