function [t, X] = simulate_n(G, x0, tEnd, nSamples)
%SIMULATE_N  Follow N players from x0 with the rule of pseudo_gradient_n.m.
%   Same solver settings as functions/simulate_game.m.

if nargin < 4, nSamples = 3000; end
tspan = linspace(0, tEnd, nSamples);
opts = odeset('RelTol', 1e-8, 'AbsTol', 1e-10, 'MaxStep', tEnd / 1000);
[t, Y] = ode45(@(~, x) pseudo_gradient_n(G, x), tspan, x0(:), opts);
X = Y';
end
