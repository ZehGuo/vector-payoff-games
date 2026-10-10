function shade_losses(G, xlims, ylims, players)
%SHADE_LOSSES  Shade the places where a player would lose BOTH goals at once
%   if the players moved from there (light red: player 1, light blue: player 2).
%   The same colours mark the matching moments in the time plots.
%   players: which players to shade (default [1 2]).

if nargin < 4, players = [1 2]; end

s = style();
[X1, X2] = meshgrid(linspace(xlims(1), xlims(2), 400), linspace(ylims(1), ylims(2), 400));
X = [X1(:)'; X2(:)'];
F = pseudo_gradient(G, X);
colors = {s.red, s.blue};
hold on
for i = players
    d1 = sum((G.A{i, 1} * X + G.b{i, 1}) .* F, 1);    % rate of change of goal 1
    d2 = sum((G.A{i, 2} * X + G.b{i, 2}) .* F, 1);    % rate of change of goal 2
    tol = 1e-9 * max(abs([d1 d2]));
    lose = reshape(d1 < -tol & d2 < -tol, size(X1));
    image(X1(1, :), X2(:, 1), repmat(reshape(colors{i}, 1, 1, 3), size(X1)), ...
          'AlphaData', s.shadeAlpha * lose);
end
set(gca, 'YDir', 'normal');
end
