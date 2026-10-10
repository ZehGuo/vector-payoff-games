%% Where can the manager afford the incentive?  The budget region
% Paper: Z. Guo, T. Hayakawa, "Two-agent noncooperative dynamical systems with
%        quadratic vector-valued payoff functions and weak Pareto improvement",
%        IEEE Control Systems Letters, 2024, https://doi.org/10.1109/LCSYS.2024.3522596
%
% A manager adds an incentive p^i(x) (tax if negative, subsidy if positive)
% to the money-type payoff J^i_1 of each player.  Two budget rules:
%   p^1(x0) = p^2(x0) = 0      (nobody gains or loses at the start)
%   p^1(x) + p^2(x) <= 0       (the manager never pays out net money).
% With the design used in incentive_design.m, the total incentive is
%   p^1 + p^2 = sigma (U(x) - U(x0)) - (J_sum(x) - J_sum(x0)),
% where U = sum eta^i_j J^i_j is the manager's measure of social welfare
% (priorities eta), J_sum = J^1_1 + w^1 J^1_2 + J^2_1 + w^2 J^2_2, and
% sigma > 0 sets how strong the incentive is.  The trajectory must stay in
%   D_bud(sigma) = { x : p^1(x) + p^2(x) <= 0 }   (the budget region).
% Its boundary is a conic whose type changes with sigma: ellipse (inside),
% hyperbola, then ellipse again (outside).  This script finds the two
% values of sigma where the type changes (reported values: 0.4097 and 0.5266).

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'functions'));
fprintf('\n== Budget region D_bud(sigma) ==\n');

%% 1. Same game as improvement_trap.m, manager priorities eta, and w^1 = w^2 = 1
A = {[-2 1; 1 -3], [-2 -1; -1 -10]; [-4 1; 1 -4], [-5 -1; -1 -2]};
b = {[5; -5], [20; 124]; [90; 0], [72; 0]};
eta = [1 3; 1 3];             % eta^i_j: priority of payoff J^i_j for the manager
w = [1; 1];                   % weights w^i inside J_sum
x0 = [18.5; -8.71];

% Quadratic data of U and J_sum:  f(x) = 1/2 x'H x + g'x
HU = 0; gU = 0;
for i = 1:2
    for j = 1:2
        HU = HU + eta(i,j) * A{i,j};
        gU = gU + eta(i,j) * b{i,j};
    end
end
HJ = A{1,1} + w(1) * A{1,2} + A{2,1} + w(2) * A{2,2};
gJ = b{1,1} + w(1) * b{1,2} + b{2,1} + w(2) * b{2,2};
quad = @(H, g, X) 0.5 * sum(X .* (H * X), 1) + g' * X;
U = @(X) quad(HU, gU, X) - quad(HU, gU, x0);          % U(x) - U(x0)
Jsum = @(X) quad(HJ, gJ, X) - quad(HJ, gJ, x0);       % J_sum(x) - J_sum(x0)
budget = @(X, sigma) sigma * U(X) - Jsum(X);          % p^1 + p^2

xhat = -HU \ gU;              % target state: where U is largest
fprintf('   target state x_hat = (%.4f, %.4f)\n', xhat);

%% 2. The conic type of the boundary changes where det(sigma*HU - HJ) = 0
% det(sigma*HU - HJ) = 0  <=>  sigma is an eigenvalue of HU^{-1} HJ.
sigmaSwitch = sort(eig(HU \ HJ))';
check('sigma where the boundary changes type matches the reported values (0.4097, 0.5266)', ...
      max(abs(sigmaSwitch - [0.4097 0.5266])) < 5e-5, sprintf('computed %s', mat2str(sigmaSwitch, 6)));

% Below the first value the region is the INSIDE of an ellipse (budget function
% convex), above the second it is the OUTSIDE of an ellipse (concave).
isConvex = @(s) all(eig(s * HU - HJ) > 0);
isConcave = @(s) all(eig(s * HU - HJ) < 0);
check('sigma = 0.3: inside of an ellipse; 0.45: hyperbola; 0.8: outside of an ellipse', ...
      isConvex(0.3) && ~isConvex(0.45) && ~isConcave(0.45) && isConcave(0.8));

%% 3. D(U,x0) \ D(J_sum,x0) never meets D_bud(sigma), whatever sigma is
% (there the manager would have to pay out money).
[X1, X2] = meshgrid(linspace(-15, 45, 500), linspace(-25, 35, 500));
X = [X1(:)'; X2(:)'];
green = U(X) >= 0 & Jsum(X) < 0;          % D(U,x0) minus D(J_sum,x0)
sigmas = [0.1 0.2 0.3 0.4 0.42 0.45 0.5 0.52 0.6 0.8 1 3 10];
clash = false;
for s = sigmas
    clash = clash || any(green & budget(X, s) <= 0);
end
check('D(U,x0) \ D(J_sum,x0) and D_bud(sigma) never overlap', ~clash, ...
      sprintf('%d values of sigma', numel(sigmas)));

%% 4. Figure
groups = {linspace(0.1, 0.4, 7), linspace(0.42, 0.52, 6), linspace(0.6, 1, 5)};
titles = {{'(a) weak incentive', sprintf('\\rm\\fontsize{9}\\sigma < %.4f: edge is an ellipse, region inside', sigmaSwitch(1))}, ...
          {'(b) medium incentive', sprintf('\\rm\\fontsize{9}%.4f \\leq \\sigma \\leq %.4f: edge is a hyperbola', sigmaSwitch)}, ...
          {'(c) strong incentive', sprintf('\\rm\\fontsize{9}\\sigma > %.4f: edge is an ellipse, region outside', sigmaSwitch(2))}};
fig = figure('Position', [50 50 1400 520]);
for p = 1:3
    subplot(1, 3, p); hold on
    image(X1(1, :), X2(:, 1), repmat(reshape([0.55 0.80 0.60], 1, 1, 3), size(X1)), ...
          'AlphaData', 0.7 * reshape(green, size(X1)));
    set(gca, 'YDir', 'normal');
    contour(X1, X2, reshape(U(X), size(X1)), [0 0], 'Color', [0.1 0.2 0.7], 'LineWidth', 2);
    contour(X1, X2, reshape(Jsum(X), size(X1)), [0 0], 'Color', [0.85 0.1 0.1], 'LineWidth', 2);
    cmap = parula(numel(groups{p}) + 2);
    for k = 1:numel(groups{p})
        contour(X1, X2, reshape(budget(X, groups{p}(k)), size(X1)), [0 0], '--', ...
                'Color', cmap(k + 1, :), 'LineWidth', 1);
    end
    plot(xhat(1), xhat(2), 'kp', 'MarkerFaceColor', 'y', 'MarkerSize', 11);
    plot(x0(1), x0(2), 'ko', 'MarkerFaceColor', 'k');
    text(xhat(1) + 1.5, xhat(2) + 2, 'target', 'FontSize', 10);
    text(x0(1) + 1.5, x0(2) - 2.5, 'start', 'FontSize', 10);
    xlabel('x^1'); ylabel('x^2'); axis([-15 45 -25 35]); box on
    title(titles{p});
    colormap(gca, cmap(2:end-1, :));
    cb = colorbar('southoutside');
    clim([groups{p}(1) groups{p}(end)]);
    cb.Label.String = 'incentive strength \sigma of each dashed curve';
end
sgtitle({'Where can the manager afford the incentive?  Dashed: edge of the budget region for several \sigma', ...
         ['\fontsize{9}inside blue: society better off than at the start;  inside red: the players'' goals in total better off;  ' ...
          'green: society better off but players worse off in total, never affordable']});
save_figure(fig, 'incentive_budget');
