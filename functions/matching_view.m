function [az, el] = matching_view(faces1, faces2, view1)
%MATCHING_VIEW  Camera angle for a second 3-D plot that shows the same faces.
%   faces1, faces2: cell arrays; faces1{f} and faces2{f} are 3-by-N points
%   of face f of a solid before and after a map.  view1 = [az el] is the
%   camera angle of the first plot.  The returned angle [az, el] makes the
%   faces that face the camera in plot 1 also face the camera in plot 2,
%   so that equal colours can be compared at a glance.
%   Both plots should use "axis equal" so that the angles mean the same.

c1 = camera_direction(view1(1), view1(2));
n1 = outward_normals(faces1);
n2 = outward_normals(faces2);
visible = sign(n1' * c1);                       % +1 seen, -1 hidden in plot 1

% Prefer a usual camera height (looking down 10-50 degrees) and, among those,
% the angle from which the right faces are seen most clearly.
[A, E] = meshgrid(-180:2:178, -70:2:70);
margin = zeros(size(A));
for k = 1:numel(A)
    margin(k) = min(visible .* (n2' * camera_direction(A(k), E(k))));
end
usual = E >= 10 & E <= 50;
if max(margin(usual)) > 0, margin(~usual) = -inf; end
[~, k] = max(margin(:));
az = A(k); el = E(k);
end

function c = camera_direction(az, el)
% Unit vector from the plot towards the camera for view(az, el).
c = [sind(az) * cosd(el); -cosd(az) * cosd(el); sind(el)];
end
