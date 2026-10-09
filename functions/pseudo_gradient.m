function [F, branch] = pseudo_gradient(G, X)
%PSEUDO_GRADIENT  Vector field of the agents' myopic dynamics, thesis eq. (3.8).
%
%   Each agent i looks at its two own gradients g1 = dJ^i_1/dx^i and
%   g2 = dJ^i_2/dx^i:
%     * if they have opposite signs (or one is zero), agent i cannot improve
%       both payoffs by moving, i.e. it is already Pareto-optimal for itself,
%       so it stays put:  f^i = 0;
%     * otherwise both payoffs improve in the same direction, and agent i
%       follows the payoff whose best-response line BR^i_j is CLOSER to its
%       current state:  f^i = alpha^i_j * g_j.
%
%   X is 2-by-N; F is 2-by-N.  branch(i,n) = 0, 1 or 2 tells which payoff
%   agent i follows at X(:,n) (0 = not moving).

F = zeros(size(X));
branch = zeros(size(X));
for i = 1:2
    g1 = own_gradient(G, i, 1, X);
    g2 = own_gradient(G, i, 2, X);

    % Distance from x^i to BR^i_j, measured along agent i's own axis.
    % Eq. (3.9): g_j = A^{ij}_{ii} (x^i - BR^i_j(x^-i)).
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
