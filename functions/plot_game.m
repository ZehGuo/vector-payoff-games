function h = plot_game(G, xlims, ylims, showDividers)
%PLOT_GAME  Draw the Nash set (purple) and the four best-response lines.
%   Agent 1 = red, agent 2 = blue; payoff 1 solid, payoff 2 dashed.
%   BR^i_j is the line where dJ^i_j/dx^i = 0 (thesis eq. (2.18)).
%   If showDividers is true, also draw (green) the line where each agent
%   switches between following payoff 1 and payoff 2 (thesis eq. (3.10)).
%   h returns the line handles [BR^1_1, BR^1_2, BR^2_1, BR^2_2] for legends.

if nargin < 4, showDividers = false; end
hold on

% Nash set X*(J): shade every grid point that passes the test (2.28).
[X1, X2] = meshgrid(linspace(xlims(1), xlims(2), 500), linspace(ylims(1), ylims(2), 500));
mask = reshape(in_nash_set(G, [X1(:)'; X2(:)']), size(X1));
purple = cat(3, 0.62 * ones(size(X1)), 0.40 * ones(size(X1)), 0.75 * ones(size(X1)));
image(X1(1, :), X2(:, 1), purple, 'AlphaData', 0.75 * mask);
set(gca, 'YDir', 'normal');

styles = {'-', '--'};
colors = {[0.85 0.15 0.15], [0.10 0.45 0.85]};
s = linspace(-1e3, 1e3, 2);   % long enough to cross any plot window
h = gobjects(1, 4);
for j = 1:2
    % Agent 1: row_1(A) x + b_1 = 0  ->  x^1 as a function of x^2
    A = G.A{1, j}; b = G.b{1, j};
    h(j) = plot(-(A(1, 2) * s + b(1)) / A(1, 1), s, styles{j}, 'Color', colors{1}, 'LineWidth', 1.4);
    % Agent 2: row_2(A) x + b_2 = 0  ->  x^2 as a function of x^1
    A = G.A{2, j}; b = G.b{2, j};
    h(2 + j) = plot(s, -(A(2, 1) * s + b(2)) / A(2, 2), styles{j}, 'Color', colors{2}, 'LineWidth', 1.4);
end

if showDividers
    % Agent 1 switches payoff where BR^1_1(x^2) = BR^1_2(x^2): a horizontal line.
    A1 = G.A{1, 1}; A2 = G.A{1, 2}; b1 = G.b{1, 1}; b2 = G.b{1, 2};
    x2s = (A1(1, 1) * b2(1) - A2(1, 1) * b1(1)) / (A2(1, 1) * A1(1, 2) - A1(1, 1) * A2(1, 2));
    plot(xlims, [x2s x2s], ':', 'Color', [0.1 0.6 0.2], 'LineWidth', 1.2);
    % Agent 2 switches where BR^2_1(x^1) = BR^2_2(x^1): a vertical line.
    A1 = G.A{2, 1}; A2 = G.A{2, 2}; b1 = G.b{2, 1}; b2 = G.b{2, 2};
    x1s = (A1(2, 2) * b2(2) - A2(2, 2) * b1(2)) / (A2(2, 2) * A1(2, 1) - A1(2, 2) * A2(2, 1));
    plot([x1s x1s], ylims, ':', 'Color', [0.1 0.6 0.2], 'LineWidth', 1.2);
end

xlim(xlims); ylim(ylims);
xlabel('x^1'); ylabel('x^2');
box on
end
