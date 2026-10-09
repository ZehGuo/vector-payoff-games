function x = weighted_nash_point(grad, lambda)
%WEIGHTED_NASH_POINT  Nash equilibrium of the weighted (scalar) game, eq. (2.11).
%
%   For fixed weights, agent i maximizes  sum_j lambda{i}(j) * J^i_j(x).
%   Its first-order condition is  sum_j lambda{i}(j) * (M^i_j x + v^i_j) = 0,
%   where  M^i_j x + v^i_j  is the own gradient dJ^i_j/dx^i (r_i rows).
%   Stacking all agents gives the linear system  Lambda(lambda)(A x + b) = 0,
%   whose solution is  x*(lambda) = -(Lambda A)^{-1} Lambda b.
%
%   grad{i}{j}.M : r_i-by-r matrix,  grad{i}{j}.v : r_i-by-1 vector
%   lambda{i}    : weight vector of agent i (nonnegative, sums to 1)

M = [];
v = [];
for i = 1:numel(grad)
    Mi = 0;
    vi = 0;
    for j = 1:numel(grad{i})
        Mi = Mi + lambda{i}(j) * grad{i}{j}.M;
        vi = vi + lambda{i}(j) * grad{i}{j}.v;
    end
    M = [M; Mi]; %#ok<AGROW>
    v = [v; vi]; %#ok<AGROW>
end
x = -M \ v;
end
