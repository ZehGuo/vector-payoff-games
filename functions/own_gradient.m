function g = own_gradient(G, i, j, X)
%OWN_GRADIENT  dJ^i_j / dx^i : how payoff j of agent i changes when agent i
%   moves its OWN state x^i (the other agent's state is held fixed).
%
%   G  : 2-agent game struct (see GUIDE.md, "Notation")
%   X  : 2-by-N matrix of states, each column is x = [x^1; x^2]
%
%   For J^i_j(x) = 1/2 x'A x + b'x + c, the own gradient is the i-th row of
%   (A x + b)  (thesis eq. (3.9): row_i(A^{ij}) x + b^{ij}_i).

A = G.A{i, j};
b = G.b{i, j};
g = A(i, :) * X + b(i);
end
