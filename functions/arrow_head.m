function arrow_head(at, direction, color)
%ARROW_HEAD  Draw a small filled arrow head at point "at", pointing along
%   "direction".  Its size is fixed on screen, whatever the axis scales are.

ax = gca;
pos = getpixelposition(ax);
sx = pos(3) / diff(xlim(ax));          % pixels per data unit, x
sy = pos(4) / diff(ylim(ax));          % pixels per data unit, y
d = [direction(1) * sx, direction(2) * sy];
if norm(d) == 0, return; end
d = d / norm(d);
n = [-d(2), d(1)];
L = 11; W = 4.5;                        % head length and half width in pixels
pts = [0 0; -L * d + W * n; -L * d - W * n];
patch(at(1) + pts(:, 1) / sx, at(2) + pts(:, 2) / sy, color, ...
      'EdgeColor', color, 'HandleVisibility', 'off');
end
