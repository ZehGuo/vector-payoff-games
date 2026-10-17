function V = vertex_data(G, sigma)
%VERTEX_DATA  Everything about one vertex of the equilibrium set.
%   sigma = [j^1 ... j^N] picks one payoff per player (1 = the payoff whose
%   best response is the LOWER end of the player's interval, 2 = the upper end).
%   Returns a struct with
%     R, beta : the selected signed distances are  d = R x + beta
%     xstar   : vertex point, where every player is at its selected best response
%     E       : diag(s), s_i = -1 (lower end) or +1 (upper end)
%     K       : diag(kappa^i_{j^i}),  kappa = -alpha * A_ii > 0
%     B       : matrix of the vertex model  w' = B [w]_+,  B = -E R K E
%     C       : outward coupling matrix (positive part of the off-diagonal
%               entries of -E R E, i.e. B without the speeds)
%   Vertex coordinates of a state x:  w = E (R x + beta).

N = numel(sigma);
V.R = zeros(N); V.beta = zeros(N, 1); kappa = zeros(N, 1);
for i = 1:N
    A = G.A{i, sigma(i)};
    V.R(i, :) = A(i, :) / A(i, i);
    V.beta(i) = G.b{i, sigma(i)}(i) / A(i, i);
    kappa(i) = -G.alpha(i, sigma(i)) * A(i, i);
end
s = 2 * sigma(:) - 3;                       % 1 -> -1, 2 -> +1
V.E = diag(s);
V.K = diag(kappa);
V.xstar = -V.R \ V.beta;
V.B = -V.E * V.R * V.K * V.E;
V.C = max(-V.E * V.R * V.E, 0);
V.C(1:N + 1:end) = 0;
V.w = @(X) V.E * (V.R * X + V.beta);        % vertex coordinates
V.x = @(W) V.R \ (V.E * W - V.beta);        % back to the original state
end
