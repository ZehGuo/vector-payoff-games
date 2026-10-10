function plot_goal_changes(G, t, X, players, scale)
%PLOT_GOAL_CHANGES  How each goal changes along a path, compared with the start.
%   Same styles as the maps: player 1 red, player 2 blue, goal 1 solid,
%   goal 2 dashed.  Moments when a player loses BOTH goals are shaded in
%   that player's light colour.  players: which players to show (default
%   [1 2]); scale: divide goal (i,j) by scale(i,j) (default 1).

if nargin < 4 || isempty(players), players = [1 2]; end
if nargin < 5 || isempty(scale), scale = ones(2); end
s = style();
colors = {s.red, s.blue};
styles = {'-', '--'};
hold on
for i = players
    for j = 1:2
        J = payoff_value(G, i, j, X);
        plot(t, (J - J(1)) / scale(i, j), styles{j}, 'Color', colors{i}, 'LineWidth', 1.8);
    end
end
lose = loss_moments(G, X);
yline(0, 'k:', 'HandleVisibility', 'off');
xlim([t(1) t(end)]);
for i = players
    shade_times(t, lose(i, :), colors{i});
end
xlabel('time t'); ylabel('change since the start');
box on
end
