function [n, center] = outward_normals(faces)
%OUTWARD_NORMALS  Normal of the best-fitting plane of each face of a solid,
%   pointing away from the solid.  faces{f} is a 3-by-N set of points.

allPts = cell2mat(faces);
center = mean(allPts, 2);
n = zeros(3, numel(faces));
for f = 1:numel(faces)
    P = faces{f};
    m = mean(P, 2);
    [~, ~, V] = svd((P - m)', 'econ');
    n(:, f) = V(:, 3);
    if n(:, f)' * (m - center) < 0, n(:, f) = -n(:, f); end
end
end
