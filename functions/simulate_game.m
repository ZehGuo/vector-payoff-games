function [t, X] = simulate_game(G, x0, tEnd, nSamples, maxDistance)
%SIMULATE_GAME  Follow the players from x0 using the movement rule
%   in pseudo_gradient.m.  Returns times t (N-by-1) and states X (2-by-N).
%   Optional maxDistance: stop early once ||x(t) - x0|| exceeds it (useful
%   when trajectories run off to infinity).

if nargin < 4 || isempty(nSamples), nSamples = 2000; end
tspan = linspace(0, tEnd, nSamples);
% The velocity jumps when a player switches payoff, so use tight tolerances
% and small steps.
opts = odeset('RelTol', 1e-8, 'AbsTol', 1e-10, 'MaxStep', tEnd / 1000);
if nargin >= 5
    opts = odeset(opts, 'Events', @(~, x) far_away(x, x0(:), maxDistance));
end
[t, Y] = ode45(@(~, x) pseudo_gradient(G, x), tspan, x0(:), opts);
X = Y';
end

function [value, isTerminal, direction] = far_away(x, x0, maxDistance)
% Event: becomes zero when x is maxDistance away from the start; then stop.
value = norm(x - x0) - maxDistance;
isTerminal = 1;
direction = 0;
end
