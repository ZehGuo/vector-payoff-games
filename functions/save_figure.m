function save_figure(fig, name)
%SAVE_FIGURE  Save a figure as figures/<name>.png in the project folder.

root = fileparts(fileparts(mfilename('fullpath')));   % parent of functions/
outDir = fullfile(root, 'figures');
if ~exist(outDir, 'dir'), mkdir(outDir); end
% Hide the interactive axes toolbar so it is not drawn into the image.
for ax = findall(fig, 'Type', 'axes')'
    ax.Toolbar.Visible = 'off';
end
exportgraphics(fig, fullfile(outDir, [name '.png']), 'Resolution', 150);
fprintf('  saved figures/%s.png\n', name);
end
