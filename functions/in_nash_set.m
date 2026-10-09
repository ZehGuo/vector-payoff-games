function tf = in_nash_set(G, X, tol)
%IN_NASH_SET  Test whether states belong to the Nash equilibrium set X*(J).
%
%   Thesis eq. (2.28) / (4.1): x is a Nash equilibrium of the 2-agent,
%   2-payoff game if, for BOTH agents, the two own gradients do not have the
%   same strict sign, i.e. no agent can raise both of its payoffs by moving
%   alone.  X is 2-by-N; tf is a 1-by-N logical.
%   tol (optional, default 0) absorbs round-off for points lying exactly on
%   a best-response line.

if nargin < 3, tol = 0; end
tf = true(1, size(X, 2));
for i = 1:2
    tf = tf & (own_gradient(G, i, 1, X) .* own_gradient(G, i, 2, X) <= tol);
end
end
