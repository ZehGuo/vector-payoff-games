function G = orient_payoffs(G)
%ORIENT_PAYOFFS  Number the two payoffs of every player so that payoff 1
%   gives the LOWER end of its interval near the equilibrium set and
%   payoff 2 the upper end (the convention X* = D^1_{-1,1} n D^2_{-1,1} of
%   the ECC paper).  The width d^i_1 - d^i_2 is tested at the vertex point
%   of the selection (1,...,1); under the assumptions it has one sign on
%   the whole equilibrium set.

N = size(G.A, 1);
x = vertex_data(G, ones(1, N)).xstar;
D = signed_distance(G, x);
for i = 1:N
    if D(i, 1) - D(i, 2) < 0
        G.A(i, :) = G.A(i, [2 1]);
        G.b(i, :) = G.b(i, [2 1]);
        G.alpha(i, :) = G.alpha(i, [2 1]);
    end
end
end
