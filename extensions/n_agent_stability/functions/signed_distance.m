function D = signed_distance(G, X)
%SIGNED_DISTANCE  How far each player is from each of its best responses.
%   D(i, j, n) = x^i - BR^i_j(x^{-i}) at the state X(:, n), the signed
%   distance of player i to the best response of its payoff j, measured
%   along its own axis.  Since dJ^i_j/dx^i = A^{ij}_{ii} (x^i - BR^i_j),
%   it is the own gradient divided by A^{ij}_{ii}.
%   Works for any number N of players (G.A{i,j} is N-by-N, X is N-by-M).

N = size(G.A, 1);
D = zeros(N, 2, size(X, 2));
for i = 1:N
    for j = 1:2
        A = G.A{i, j};
        D(i, j, :) = (A(i, :) * X + G.b{i, j}(i)) / A(i, i);
    end
end
end
