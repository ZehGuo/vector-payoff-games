function save_extension_figure(fig, name)
%SAVE_EXTENSION_FIGURE  Save a figure as figures/<name>.png inside this
%   extension (not in the main figures/ folder of the repository).

root = fileparts(fileparts(mfilename('fullpath')));   % the extension folder
outDir = fullfile(root, 'figures');
if ~exist(outDir, 'dir'), mkdir(outDir); end
for ax = findall(fig, 'Type', 'axes')'
    ax.Toolbar.Visible = 'off';
end
exportgraphics(fig, fullfile(outDir, [name '.png']), 'Resolution', 150);
fprintf('  saved extensions/n_agent_stability/figures/%s.png\n', name);
end
