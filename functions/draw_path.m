function h = draw_path(X, arrowsAt, G)
%DRAW_PATH  Draw a simulated path X (2-by-N): black line, black dot at the
%   start and arrows showing the direction of motion.  arrowsAt lists where
%   to put arrows, as fractions of the path length (default 0.45).
%   If the game G is given, the parts of the path where a player loses BOTH
%   goals are underlaid in that player's light colour (as in the time plots).
%   Call it after the axis limits are set.

if nargin < 2 || isempty(arrowsAt), arrowsAt = 0.45; end
if nargin >= 3
    s = style();
    lose = loss_moments(G, X);
    light = {s.light(s.red), s.light(s.blue)};
    for i = 1:2
        Y = X; Y(:, ~lose(i, :)) = NaN;              % keep only the losing part
        plot(Y(1, :), Y(2, :), '-', 'Color', light{i}, 'LineWidth', 10, 'HandleVisibility', 'off');
    end
end
h = plot(X(1, :), X(2, :), 'k-', 'LineWidth', 2);
plot(X(1, 1), X(2, 1), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 7, 'HandleVisibility', 'off');
len = [0, cumsum(vecnorm(diff(X, 1, 2)))];          % arc length along the path
if len(end) == 0, return; end
for f = arrowsAt
    k = find(len >= f * len(end), 1);
    k2 = find(len >= len(k) + 0.01 * len(end), 1);   % a little further on
    if isempty(k2), k2 = numel(len); end
    if k2 > k
        arrow_head(X(:, k2), X(:, k2) - X(:, k), 'k');
    end
end
end
