function lgd = standard_legend(items, nColumns)
%STANDARD_LEGEND  One legend with the shared meaning of styles and colours.
%   items is a cell array of keys:
%     'goals'   player 1/2, goal 1/2 (best-response line on maps, change in time plots)
%     'goals2'  only player 2's two goals
%     'set'     equilibrium set          'path'    simulated path
%     'loss1'   player 1 loses both      'loss2'   player 2 loses both
%     'flow'    direction of motion      'energy'  energy levels
%     'target'  manager's target         'budget'  budget region
%     'payment' manager's net payment
%   In a tiledlayout, put it below the panels with lgd.Layout.Tile = 'south'.

s = style();
h = gobjects(0); names = {};
    function add(obj, name)
        h(end + 1) = obj; names{end + 1} = name;
    end
for k = 1:numel(items)
    switch items{k}
        case {'goals', 'goals2'}
            pl = 1:2; if strcmp(items{k}, 'goals2'), pl = 2; end
            c = {s.red, s.blue};
            for i = pl
                add(plot(NaN, NaN, '-', 'Color', c{i}, 'LineWidth', 1.8), sprintf('player %d, goal 1', i));
                add(plot(NaN, NaN, '--', 'Color', c{i}, 'LineWidth', 1.8), sprintf('player %d, goal 2', i));
            end
        case 'set',    add(patch(NaN, NaN, s.purple, 'FaceAlpha', 0.75, 'EdgeColor', 'none'), 'equilibrium set');
        case 'path',   add(plot(NaN, NaN, 'k-', 'LineWidth', 2, 'Marker', 'o', 'MarkerFaceColor', 'k', 'MarkerIndices', 1), 'path (from the dot)');
        case 'loss1',  add(patch(NaN, NaN, s.red, 'FaceAlpha', s.shadeAlpha, 'EdgeColor', 'none'), 'player 1 loses both goals');
        case 'loss2',  add(patch(NaN, NaN, s.blue, 'FaceAlpha', s.shadeAlpha, 'EdgeColor', 'none'), 'player 2 loses both goals');
        case 'flow',   add(plot(NaN, NaN, '-', 'Color', s.flow, 'LineWidth', 1.2), 'direction of motion');
        case 'energy', add(plot(NaN, NaN, 'k:', 'LineWidth', 1.2), 'energy levels');
        case 'target', add(plot(NaN, NaN, 'kp', 'MarkerFaceColor', 'y', 'MarkerSize', 12), 'target of the manager');
        case 'budget', add(patch(NaN, NaN, s.orange, 'FaceAlpha', 0.6, 'EdgeColor', 'none'), 'budget region');
        case 'payment', add(plot(NaN, NaN, ':', 'Color', [0.4 0.4 0.4], 'LineWidth', 2), 'manager''s net payment p^1 + p^2');
    end
end
if nargin < 2, nColumns = min(numel(h), 4); end
lgd = legend(h, names, 'NumColumns', nColumns, 'FontSize', 9);
end
