function g = own_gradient(G, i, j, X)
%OWN_GRADIENT  How payoff j of player i changes when player i moves its OWN
%   state x^i (the other player's state held fixed): dJ^i_j / dx^i.
%
%   G : 2-player game (see README / GUIDE for the fields A, b, c, alpha)
%   X : 2-by-N matrix of states, each column is x = [x^1; x^2]
%
%   For J^i_j(x) = 1/2 x'Ax + b'x + c this is the i-th entry of A*x + b.

A = G.A{i, j};
b = G.b{i, j};
g = A(i, :) * X + b(i);
end
