function x = weighted_nash_point(grad, lambda)
%WEIGHTED_NASH_POINT  Equilibrium of the game in which every player adds up
%   its payoffs with fixed weights.
%
%   Player i maximizes  sum_j lambda{i}(j) * J^i_j(x).  Its best state
%   satisfies  sum_j lambda{i}(j) * (M^i_j x + v^i_j) = 0,  where
%   M^i_j x + v^i_j is the own gradient dJ^i_j/dx^i.  Stacking the
%   conditions of all players gives one linear system, solved here.
%
%   grad{i}{j}.M : r_i-by-r matrix,  grad{i}{j}.v : r_i-by-1 vector
%   lambda{i}    : weights of player i (nonnegative, summing to 1)

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
