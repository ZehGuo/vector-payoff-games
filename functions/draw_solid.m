function draw_solid(faces, gridSize, colors, labels, viewAngle)
%DRAW_SOLID  Draw a 3-D solid from its faces and name every visible face.
%   faces{f}: 3-by-N points of face f on a grid of size gridSize;
%   colors(f,:): its colour; labels{f}: the name written on it.
%   Faces are opaque, so only the faces turned towards the camera are seen,
%   and only those get a label.

hold on
for f = 1:numel(faces)
    P = faces{f};
    X = reshape(P(1, :), gridSize); Y = reshape(P(2, :), gridSize); Z = reshape(P(3, :), gridSize);
    surf(X, Y, Z, 'FaceColor', colors(f, :), 'EdgeColor', 'none');
    edge = @(M) [M(1, :), M(2:end, end)', M(end, end-1:-1:1), M(end-1:-1:1, 1)'];
    plot3(edge(X), edge(Y), edge(Z), 'k-', 'LineWidth', 0.8);
end
view(viewAngle); grid on; axis equal tight
% Label the faces that face the camera, at their middle.
c = [sind(viewAngle(1)) * cosd(viewAngle(2)); -cosd(viewAngle(1)) * cosd(viewAngle(2)); sind(viewAngle(2))];
n = outward_normals(faces);
allPts = cell2mat(faces);
sizeOfSolid = norm(max(allPts, [], 2) - min(allPts, [], 2));
for f = find(n' * c > 0.05)'
    P = faces{f};
    [~, k] = min(vecnorm(P - mean(P, 2)));       % grid point closest to the middle
    q = P(:, k) + 0.12 * sizeOfSolid * n(:, f);   % slightly in front of the face
    text(q(1), q(2), q(3), labels{f}, 'FontSize', 10, 'FontWeight', 'bold', ...
         'HorizontalAlignment', 'center', 'BackgroundColor', 'w', 'Margin', 1);
end
end
