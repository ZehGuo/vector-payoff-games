function shade_times(t, mask, color)
%SHADE_TIMES  Shade the time intervals where mask is true, behind the curves.

s = style();
yl = ylim;
edges = diff([false, mask(:)', false]);
starts = find(edges == 1);
stops = find(edges == -1) - 1;
for k = 1:numel(starts)
    p = patch(t([starts(k) stops(k) stops(k) starts(k)]), yl([1 1 2 2]), color, ...
              'EdgeColor', 'none', 'FaceAlpha', s.shadeAlpha, 'HandleVisibility', 'off');
    uistack(p, 'bottom');
end
ylim(yl);
end
