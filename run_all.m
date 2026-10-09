function run_all()
%RUN_ALL  Reproduce every result: regenerate all figures and run all checks.
%   Figures are written to the folder figures/.  Each script prints lines
%   such as "[PASS] ..." comparing a computed number or property with the
%   thesis; a summary is printed at the end.  Takes about 3 minutes.

here = fileparts(mfilename('fullpath'));
addpath(fullfile(here, 'functions'));

scripts = {
    'ch2_nash_set_from_weights'    % Fig. 2.5  (Example 2.11)
    'ch2_three_agents_cube'        % Fig. 2.3  (Example 2.9)
    'ch2_two_agents_prism'         % Fig. 2.4  (Example 2.10)
    'ch3_stability'                % Figs. 3.5, 3.6, 3.7
    'ch4_pareto_improvement'       % Fig. 4.3
    'ch5_trap'                     % Fig. 5.1
    'ch5_budget_region'            % Fig. 5.4
    'ch5_incentive_design'         % Figs. 5.5, 5.6
    'ext_lyapunov_transformation'  % ECC paper, Fig. 4
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
