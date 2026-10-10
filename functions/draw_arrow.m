function draw_arrow(p, q, color, lineWidth)
%DRAW_ARROW  Straight arrow from point p to point q (data coordinates).
%   Call it after the axis limits are set, so the head has the right shape.

if nargin < 4, lineWidth = 1.5; end
plot([p(1) q(1)], [p(2) q(2)], '-', 'Color', color, 'LineWidth', lineWidth, 'HandleVisibility', 'off');
arrow_head(q, q - p, color);
end
