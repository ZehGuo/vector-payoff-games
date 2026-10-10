function run_all()
%RUN_ALL  Reproduce every result: regenerate all figures and run all checks.
%   Figures are written to the folder figures/.  Each script prints lines
%   such as "[PASS] ..." comparing a computed number or property with the
%   papers; a summary is printed at the end.  Takes about 2 minutes.

here = fileparts(mfilename('fullpath'));
addpath(fullfile(here, 'functions'));

scripts = {
    'equilibrium_region'           % what the equilibrium set looks like
    'equilibrium_three_players'
    'equilibrium_vector_states'
    'stability_cases'              % do the players settle down?
    'stability_lyapunov'
    'improvement_pareto'           % does everybody get better off?
    'improvement_trap'
    'incentive_budget'             % taxes and subsidies within budget
    'incentive_design'
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
