function [F, branch] = pseudo_gradient_n(G, X)
%PSEUDO_GRADIENT_N  The movement rule of functions/pseudo_gradient.m for N players.
%   A player whose two own gradients have opposite signs (or one is zero)
%   cannot raise both payoffs and stays put.  Otherwise it follows the
%   payoff whose best response is closer:  F^i = alpha^i_j * dJ^i_j/dx^i.
%   branch(i, n) = 0 (not moving), 1 or 2 (payoff followed).

N = size(G.A, 1);
D = signed_distance(G, X);
F = zeros(size(X));
branch = zeros(size(X));
for i = 1:N
    d1 = reshape(D(i, 1, :), 1, []);
    d2 = reshape(D(i, 2, :), 1, []);
    moving = d1 .* d2 > 0;                 % same sign: both payoffs improve together
    useFirst = moving & abs(d1) <= abs(d2);
    useSecond = moving & abs(d1) > abs(d2);
    % dJ^i_j/dx^i = A^{ij}_{ii} d^i_j
    F(i, useFirst) = G.alpha(i, 1) * G.A{i, 1}(i, i) * d1(useFirst);
    F(i, useSecond) = G.alpha(i, 2) * G.A{i, 2}(i, i) * d2(useSecond);
    branch(i, useFirst) = 1;
    branch(i, useSecond) = 2;
end
end
