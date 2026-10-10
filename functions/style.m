function s = style()
%STYLE  Colours shared by all figures, so every picture reads the same way.
%   red = player 1, blue = player 2, purple = equilibrium set,
%   light red / light blue shading = that player loses both goals,
%   orange = the manager's budget region.

s.red = [0.85 0.15 0.15];
s.blue = [0.10 0.45 0.85];
s.purple = [0.62 0.40 0.75];
s.orange = [0.98 0.75 0.45];
s.flow = [0.80 0.82 0.88];        % light grey-blue: direction of motion
s.shadeAlpha = 0.3;               % strength of the "loses both goals" shading
% The same light colour as an opaque colour (for thick lines).
s.light = @(c) s.shadeAlpha * c + (1 - s.shadeAlpha) * [1 1 1];
end
