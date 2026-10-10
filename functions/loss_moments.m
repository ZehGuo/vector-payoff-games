function lose = loss_moments(G, X)
%LOSS_MOMENTS  lose(i,n) is true when, at state X(:,n), the players' motion
%   lowers BOTH goals of player i at the same time.

F = pseudo_gradient(G, X);
lose = false(2, size(X, 2));
for i = 1:2
    rate = zeros(2, size(X, 2));
    for j = 1:2
        rate(j, :) = sum((G.A{i, j} * X + G.b{i, j}) .* F, 1);   % d/dt of goal j
    end
    tol = 1e-9 * max(abs(rate(:)));   % ignore round-off only
    lose(i, :) = all(rate < -tol, 1);
end
end
