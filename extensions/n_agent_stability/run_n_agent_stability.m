function run_n_agent_stability()
%RUN_N_AGENT_STABILITY  Reproduce every result of this extension.
%   Figures are written to extensions/n_agent_stability/figures/.  Each
%   script prints [PASS] / [FAIL] lines, and a summary is printed at the end.
%   The main repository (run_all.m) is not affected.

here = fileparts(mfilename('fullpath'));
root = fileparts(fileparts(here));
addpath(fullfile(root, 'functions'));
addpath(fullfile(here, 'functions'));

scripts = {
    'vertex_coordinates_2d'      % two players: the new coordinates and the vertex test
    'face_counterexample_3d'     % three players: why eta is not enough
};
check('reset');
for k = 1:numel(scripts)
    run_script(fullfile(here, [scripts{k} '.m']));
    close all
end
nFail = check('summary');
if nFail > 0
    warning('%d check(s) failed. See the [FAIL] lines above.', nFail);
end
end

function run_script(file)
% Run one script in its own workspace (the scripts start with "clear").
run(file);
end
