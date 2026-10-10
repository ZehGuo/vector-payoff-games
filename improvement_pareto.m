%% Does everybody get better off along the way?
% Paper: Z. Guo, T. Hayakawa, "Pareto improvement for noncooperative systems
%        with vector-valued payoff functions", IEEE CDC 2024,
%        https://doi.org/10.1109/CDC56724.2024.10886420
%
% Along a trajectory of the players' movement:
%   * Pareto improving       : no payoff of any player ever decreases;
%   * weakly Pareto improving: at every moment, each player has AT LEAST ONE
%                              payoff that does not decrease.
% A player's own move never hurts itself (it only moves to improve), so only
% the OTHER player's move can hurt it.  Gamma^i_j is the region where the
% other player's move does not decrease payoff J^i_j.  This region does not
% depend on how fast the players move (alpha), so an outside observer who
% knows only the payoffs can compute it.
%   * Gamma^i_1 and Gamma^i_2 both cover the whole plane, for both players
%       -> every trajectory is Pareto improving;
%   * Gamma^i_1 and Gamma^i_2 together cover the whole plane, for both players
%       -> every trajectory is weakly Pareto improving;
%   * otherwise a trajectory that enters the uncovered region makes that
%     player lose on both payoffs at once.

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'functions'));
fprintf('\n== Does everybody get better off along the way? ==\n');

%% Three examples.  J^i_j(x) = 1/2 x'A^{ij}x + b^{ij}'x
% (a) NOT weakly Pareto improving
ex(1).name = '(a) not weakly Pareto improving';
ex(1).A = {[-4 -1; -1 -3], [-2 -1; -1 -10]; [-2 1; 1 -2], [-5 1; 1 -1]};
ex(1).b = {[10; 22], [10; 78]; [8; 0], [5; 0]};
ex(1).x0 = [7; 13];
% Speeds: player 2 adjusts its second payoff at half speed.
ex(1).alpha = [1 1; 1 0.5];
ex(1).window = [-3 11 -1 14];
ex(1).expect = 'none';

% (b) Pareto improving.  Built so that, for each payoff J^i_j, the line where
% the other player's move has no effect on J^i_j passes through the point
% where the other player's two best-response lines cross.  Then the other
% player can never hurt J^i_j.
A = {[-2 1; 1 -3], [-4 -4; -4 -12]; [-7 1; 1 -2], [-3 -1; -1 -2]};
xp1 = [A{1,1}(1,:); A{1,2}(1,:)] \ -[15; 30];    % BR^1_1 cross BR^1_2
xp2 = [A{2,1}(2,:); A{2,2}(2,:)] \ -[-5; 0];     % BR^2_1 cross BR^2_2
ex(2).name = '(b) Pareto improving';
ex(2).A = A;
ex(2).b = {[15; -A{1,1}(2,:) * xp2], [30; -A{1,2}(2,:) * xp2];
           [-A{2,1}(1,:) * xp1; -5], [-A{2,2}(1,:) * xp1; 0]};
ex(2).x0 = [0; 0];
ex(2).alpha = [];          % [] = default choice explained below
ex(2).window = [-2 12 -6 6];
ex(2).expect = 'pareto';

% (c) weakly Pareto improving
ex(3).name = '(c) weakly Pareto improving';
ex(3).A = A;
ex(3).b = {[5; 12], [30; 0]; [-20; 0], [20; 0]};
ex(3).x0 = [0; 3];
ex(3).alpha = [];
ex(3).window = [-8 12 -4 8];
ex(3).expect = 'weak';

fig = figure('Position', [50 50 1350 720]);
for k = 1:3
    G.A = ex(k).A;
    G.b = ex(k).b;
    % Default speeds: alpha^i_1 = 1 and alpha^i_2 chosen so both payoffs pull
    % equally hard at equal distance from their best-response lines.
    % The results of (b) and (c) hold for ANY speeds alpha > 0.
    G.alpha = [1, G.A{1,1}(1,1) / G.A{1,2}(1,1); 1, G.A{2,1}(2,2) / G.A{2,2}(2,2)];
    if ~isempty(ex(k).alpha), G.alpha = ex(k).alpha; end
    fprintf('\n-- %s --\n', ex(k).name);

    %% 1. Regions Gamma^i_j (other player's move does not hurt J^i_j) on a large grid
    w = ex(k).window;
    [X1, X2] = meshgrid(linspace(-60, 60, 401));
    Xg = [X1(:)'; X2(:)'];
    gam = externality_regions(G, Xg);
    full = squeeze(all(gam, 3));                               % Gamma^i_j = R^2 ?
    unionFull = [all(gam(1,1,:) | gam(1,2,:)), all(gam(2,1,:) | gam(2,2,:))];
    fprintf('   Gamma^i_j = R^2 on the grid: [i=1: %d %d; i=2: %d %d]\n', full(1,:), full(2,:));

    %% 2. Simulate and look at how the four payoffs change in time
    [t, Xt] = simulate_game(G, ex(k).x0, 8, 4000);
    Ft = pseudo_gradient(G, Xt);
    dJ = zeros(4, numel(t));    J = zeros(4, numel(t));    r = 0;
    for i = 1:2
        for j = 1:2
            r = r + 1;
            dJ(r, :) = sum((G.A{i,j} * Xt + G.b{i,j}) .* Ft, 1);   % d/dt J^i_j = grad J . f
            J(r, :) = payoff_value(G, i, j, Xt);
        end
    end
    tol = -1e-6 * max(abs(dJ(:)));
    isPareto = all(dJ(:) >= tol);
    isWeak = all(max(dJ(1:2, :)) >= tol) && all(max(dJ(3:4, :)) >= tol);

    switch ex(k).expect
        case 'none'
            check('Gamma^i_1 and Gamma^i_2 together do NOT cover the plane (both players)', ~any(unionFull));
            lose1 = t(max(dJ(1:2, :)) < tol);     % moments when player 1 loses on both payoffs
            lose2 = t(max(dJ(3:4, :)) < tol);
            check('trajectory is NOT weakly Pareto improving: each player loses on both payoffs at some time', ...
                  ~isempty(lose1) && ~isempty(lose2), ...
                  sprintf('player 2 first at t = %.2f, player 1 from t = %.2f', min(lose2), min(lose1)));
        case 'pareto'
            check('every Gamma^i_j covers the whole plane', all(full(:)));
            check('trajectory is Pareto improving (all four payoffs rise)', isPareto);
        case 'weak'
            check('Gamma^i_1 and Gamma^i_2 together cover the plane (both players)', all(unionFull));
            check('trajectory is weakly Pareto improving', isWeak);
            check('... but not Pareto improving (some payoff falls)', ~isPareto);
    end

    %% 3. Plot: state space (top) and payoff values (bottom)
    subplot(2, 3, k);
    [P1, P2] = meshgrid(linspace(w(1), w(2), 400), linspace(w(3), w(4), 400));
    gw = externality_regions(G, [P1(:)'; P2(:)']);
    bad1 = reshape(~(gw(1,1,:) | gw(1,2,:)), size(P1));   % player 1 can be hurt on both payoffs
    bad2 = reshape(~(gw(2,1,:) | gw(2,2,:)), size(P1));
    hold on
    image(P1(1,:), P2(:,1), repmat(reshape([0.45 0.45 0.45], 1, 1, 3), size(P1)), 'AlphaData', 0.55 * bad1);
    image(P1(1,:), P2(:,1), repmat(reshape([0.75 0.75 0.75], 1, 1, 3), size(P1)), 'AlphaData', 0.55 * bad2);
    plot_game(G, w(1:2), w(3:4));
    plot(Xt(1, :), Xt(2, :), 'k-', 'LineWidth', 2);
    plot(ex(k).x0(1), ex(k).x0(2), 'ko', 'MarkerFaceColor', 'k');
    title(ex(k).name);

    subplot(2, 3, 3 + k); hold on
    styles = {'-', '--', '-', '--'};
    colors = {[0.85 0.15 0.15], [0.85 0.15 0.15], [0.10 0.45 0.85], [0.10 0.45 0.85]};
    for r = 1:4
        plot(t, J(r, :) - J(r, 1), styles{r}, 'Color', colors{r}, 'LineWidth', 1.5);
    end
    yline(0, 'k:');
    xlabel('time t'); ylabel('J^i_j(x(t)) - J^i_j(x_0)');
    legend({'J^1_1', 'J^1_2', 'J^2_1', 'J^2_2'}, 'Location', 'best');
    box on
end
sgtitle({'Does everybody get better off along the trajectory?', ...
         ['\fontsize{9}dark grey: player 1 can lose on both payoffs, light grey: same for player 2, ' ...
          'purple: equilibrium set, black: trajectory from x_0']});
save_figure(fig, 'improvement_pareto');

%% ------------------------------------------------------------------------
function gam = externality_regions(G, X)
% gam(i,j,n) is true when x = X(:,n) is in Gamma^i_j, i.e. the other player's
% move does not decrease J^i_j:  dJ^i_j/dx^{-i} * f^{-i}(x) >= 0.
F = pseudo_gradient(G, X);
gam = false(2, 2, size(X, 2));
for i = 1:2
    o = 3 - i;                                     % the other player
    for j = 1:2
        cross = G.A{i,j}(o, :) * X + G.b{i,j}(o);  % dJ^i_j / dx^{-i}
        gam(i, j, :) = cross .* F(o, :) >= -1e-9;
    end
end
end
