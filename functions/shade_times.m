function h = shade_times(t, mask, color)
%SHADE_TIMES  Shade the time intervals where mask is true (behind the curves).
%   Used to mark the moments when a player loses on both goals at once.
%   Returns one patch handle for the legend (empty if mask is never true).

h = gobjects(0);
yl = ylim;
edges = diff([false, mask(:)', false]);
starts = find(edges == 1);
stops = find(edges == -1) - 1;
for k = 1:numel(starts)
    t1 = t(starts(k)); t2 = t(stops(k));
    p = patch([t1 t2 t2 t1], yl([1 1 2 2]), color, 'EdgeColor', 'none', 'FaceAlpha', 0.25);
    uistack(p, 'bottom');
    if k == 1, h = p; else, set(p, 'HandleVisibility', 'off'); end
end
ylim(yl);
end
