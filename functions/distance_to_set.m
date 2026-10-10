function d = distance_to_set(P, S)
%DISTANCE_TO_SET  Distance from each point P(:,n) to a sampled set S (2-by-M),
%   i.e. the distance to the nearest point of S.  Used to measure how far a
%   trajectory is from the equilibrium set.  Accuracy = sampling of S.

d = zeros(1, size(P, 2));
for n = 1:size(P, 2)
    d(n) = sqrt(min((S(1, :) - P(1, n)).^2 + (S(2, :) - P(2, n)).^2));
end
end
