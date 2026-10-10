function [F, branch] = pseudo_gradient(G, X)
%PSEUDO_GRADIENT  How the players move: the velocity x' = F(x).
%
%   Each player i looks at how its two payoffs change when it moves itself
%   (its two "own gradients" g1 and g2):
%     * opposite signs (or one is zero): moving cannot improve both payoffs,
%       so the player stays put, F^i = 0;
%     * same sign: both payoffs improve in the same direction.  The player
%       follows the payoff whose best-response line is CLOSER to its current
%       state:  F^i = alpha^i_j * g_j.
%
%   X is 2-by-N; F is 2-by-N.  branch(i,n) = 0, 1 or 2 tells which payoff
%   player i follows at X(:,n) (0 = not moving).

F = zeros(size(X));
branch = zeros(size(X));
for i = 1:2
    g1 = own_gradient(G, i, 1, X);
    g2 = own_gradient(G, i, 2, X);

    % Distance from x^i to the best-response line of payoff j, measured
    % along player i's own axis:  g_j = A^{ij}_{ii} * (x^i - best response).
    d1 = abs(g1 / G.A{i, 1}(i, i));
    d2 = abs(g2 / G.A{i, 2}(i, i));

    moving = g1 .* g2 > 0;          % both payoffs can improve together
    useFirst = moving & (d1 <= d2);
    useSecond = moving & (d1 > d2);

    F(i, useFirst) = G.alpha(i, 1) * g1(useFirst);
    F(i, useSecond) = G.alpha(i, 2) * g2(useSecond);
    branch(i, useFirst) = 1;
    branch(i, useSecond) = 2;
end
end
