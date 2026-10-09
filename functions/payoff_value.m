function J = payoff_value(G, i, j, X)
%PAYOFF_VALUE  Value of payoff j of agent i:  J^i_j(x) = 1/2 x'Ax + b'x + c.
%   X is 2-by-N (one state per column); J is 1-by-N.

A = G.A{i, j};
b = G.b{i, j};
c = 0;
if isfield(G, 'c'), c = G.c(i, j); end
J = 0.5 * sum(X .* (A * X), 1) + b' * X + c;
end
