function Z = eta_n(G, X)
%ETA_N  The coordinate change of the ECC paper, for N players.
%   eta_i(x) = signed distance of player i to the best response it follows,
%   and eta_i(x) = 0 when player i does not move.  The whole equilibrium
%   set is mapped to the origin.

[~, branch] = pseudo_gradient_n(G, X);
D = signed_distance(G, X);
Z = zeros(size(X));
for i = 1:size(X, 1)
    for j = 1:2
        k = branch(i, :) == j;
        Z(i, k) = reshape(D(i, j, k), 1, []);
    end
end
end
