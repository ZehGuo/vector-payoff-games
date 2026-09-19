function publicReport = run_public_reproduction(outputRoot)
%RUN_PUBLIC_REPRODUCTION Safely run the six public reproduction experiments.
%
% PUBLICREPORT = RUN_PUBLIC_REPRODUCTION() must be called from the repository
% root. It writes only beneath results/public, explicitly redirects the T1
% and I1 figures away from tracked audit figures, checks all 18 figure and
% 21 nonfigure experiment artifacts, and writes a human-readable index.
%
% PUBLICREPORT = RUN_PUBLIC_REPRODUCTION(OUTPUTROOT) uses an empty custom
% output root. A custom root inside this repository must be below results/.

repoRoot = fileparts(fileparts(mfilename('fullpath')));
repoRoot = canonicalPath(repoRoot);
assert(strcmp(canonicalPath(pwd),repoRoot), ...
    'public:WrongWorkingDirectory', ...
    'Run run_public_reproduction from the repository root: %s',repoRoot);

if nargin < 1 || isempty(outputRoot)
    outputRoot = fullfile(repoRoot,'results','public');
else
    assert(ischar(outputRoot) || (isstring(outputRoot) && isscalar(outputRoot)), ...
        'public:InvalidOutputRoot','The output root must be a character vector or string scalar.');
    outputRoot = char(outputRoot);
    if ~isAbsolutePath(outputRoot)
        outputRoot = fullfile(repoRoot,outputRoot);
    end
end
outputRoot = canonicalPath(outputRoot);
assert(~strcmp(outputRoot,repoRoot),'public:UnsafeOutputRoot', ...
    'The repository root cannot be used as the public output root.');
if isPathWithin(outputRoot,repoRoot)
    resultsRoot = canonicalPath(fullfile(repoRoot,'results'));
    assert(isPathWithin(outputRoot,resultsRoot), ...
        'public:UnsafeOutputRoot', ...
        'An output root inside the repository must be below the ignored results/ directory.');
end
assertDirectoryEmpty(outputRoot);
if ~exist(outputRoot,'dir'), mkdir(outputRoot); end

experimentsDir = fullfile(repoRoot,'experiments');
% Own the experiment-path lifetime even though the one-line shell command
% bootstraps this function with addpath('experiments').
if contains([path,pathsep],[experimentsDir,pathsep])
    rmpath(experimentsDir);
end
addpath(experimentsDir);
pathCleanup = onCleanup(@()removeExperimentPath(experimentsDir));

[artifactTask,artifactKind,artifactRelativePath] = artifactSchema();
taskIds = {'T1','S1','S2','P1','X1','I1'};
taskDirs = lower(taskIds);
metadata = repmat(struct('task','','outputDirectory','','figureDirectory','', ...
    'elapsedSeconds',0,'reportClass','','reportSize','','reportFieldCount',0), ...
    numel(taskIds),1);
reports = cell(numel(taskIds),1);

fprintf('Public reproduction output root: %s\n',outputRoot);
for k = 1:numel(taskIds)
    task = taskIds{k};
    taskDir = fullfile(outputRoot,taskDirs{k});
    figureDir = taskDir;
    if any(strcmp(task,{'T1','I1'}))
        figureDir = fullfile(taskDir,'figures');
    end
    if ~exist(taskDir,'dir'), mkdir(taskDir); end
    if ~exist(figureDir,'dir'), mkdir(figureDir); end
    fprintf('\n[%s] starting\n',task);
    started = tic;
    try
        switch task
            case 'T1'
                taskReport = run_t1_topology_applications(taskDir,figureDir);
            case 'S1'
                taskReport = run_s1_five_cases(taskDir);
            case 'S2'
                taskReport = run_s2_degenerate_noncompact(taskDir);
            case 'P1'
                taskReport = run_p1_payoff_properties(taskDir);
            case 'X1'
                taskReport = run_x1_transformation_stability(taskDir);
            case 'I1'
                taskReport = run_i1_incentive_budget(taskDir,figureDir);
        end
        verifyTaskArtifacts(outputRoot,task,artifactTask,artifactRelativePath);
    catch cause
        failure = MException('public:TaskFailed', ...
            'Public reproduction failed in task %s. Its output directory is %s.', ...
            task,taskDir);
        throwAsCaller(addCause(failure,cause));
    end
    reports{k} = taskReport;
    metadata(k).task = task;
    metadata(k).outputDirectory = taskDir;
    metadata(k).figureDirectory = figureDir;
    metadata(k).elapsedSeconds = toc(started);
    metadata(k).reportClass = class(taskReport);
    metadata(k).reportSize = strjoin(string(size(taskReport)),'x');
    if isstruct(taskReport), metadata(k).reportFieldCount = numel(fieldnames(taskReport)); end
    fprintf('[%s] complete (%.2f seconds)\n',task,metadata(k).elapsedSeconds);
end

artifactExists = false(size(artifactRelativePath));
artifactBytes = zeros(size(artifactRelativePath));
for k = 1:numel(artifactRelativePath)
    artifactPath = fullfile(outputRoot,artifactRelativePath{k});
    artifactExists(k) = exist(artifactPath,'file') == 2;
    assert(artifactExists(k),'public:MissingArtifact','Missing expected artifact: %s',artifactPath);
    info = dir(artifactPath);
    artifactBytes(k) = info.bytes;
    assert(artifactBytes(k) > 0,'public:EmptyArtifact','Expected artifact is empty: %s',artifactPath);
end

publicReport = struct();
publicReport.generatedAt = char(datetime('now','TimeZone','local', ...
    'Format','yyyy-MM-dd''T''HH:mm:ssXXX'));
publicReport.matlabVersion = version;
publicReport.computer = computer;
publicReport.repositoryRoot = repoRoot;
publicReport.outputRoot = outputRoot;
publicReport.taskMetadata = metadata;
publicReport.figureCount = sum(strcmp(artifactKind,'figure'));
publicReport.nonfigureCount = sum(strcmp(artifactKind,'data'));
publicReport.artifactTask = artifactTask;
publicReport.artifactKind = artifactKind;
publicReport.artifactRelativePath = artifactRelativePath;
publicReport.artifactBytes = artifactBytes;
publicReport.scientificBoundary = ['A successful run, trajectory, or finite-grid check ', ...
    'is execution evidence and does not by itself prove a theorem.'];

writeCsvIndex(fullfile(outputRoot,'public_output_index.csv'),artifactTask, ...
    artifactKind,artifactRelativePath,artifactBytes);
writeMarkdownIndex(fullfile(outputRoot,'PUBLIC_OUTPUT_INDEX.md'),publicReport);
save(fullfile(outputRoot,'public_reproduction_report.mat'),'publicReport','reports');

fprintf('\nPublic reproduction complete: %d figures and %d nonfigure experiment artifacts.\n', ...
    publicReport.figureCount,publicReport.nonfigureCount);
fprintf('Human-readable output index: %s\n',fullfile(outputRoot,'PUBLIC_OUTPUT_INDEX.md'));
fprintf('Machine-readable output index: %s\n',fullfile(outputRoot,'public_output_index.csv'));
clear pathCleanup
end

function verifyTaskArtifacts(outputRoot,task,artifactTask,artifactRelativePath)
mask = strcmp(artifactTask,task);
paths = artifactRelativePath(mask);
for k = 1:numel(paths)
    artifactPath = fullfile(outputRoot,paths{k});
    assert(exist(artifactPath,'file')==2,'public:MissingTaskArtifact', ...
        '%s did not produce expected artifact: %s',task,artifactPath);
    info = dir(artifactPath);
    assert(info.bytes>0,'public:EmptyTaskArtifact', ...
        '%s produced an empty artifact: %s',task,artifactPath);
end
end

function writeCsvIndex(pathName,tasks,kinds,relativePaths,bytes)
fid = fopen(pathName,'w');
assert(fid>=0,'public:IndexWriteFailed','Could not write output index: %s',pathName);
cleanup = onCleanup(@()fclose(fid));
fprintf(fid,'task,kind,relative_path,bytes\n');
for k = 1:numel(tasks)
    fprintf(fid,'"%s","%s","%s",%d\n',tasks{k},kinds{k}, ...
        strrep(relativePaths{k},'"','""'),bytes(k));
end
end

function writeMarkdownIndex(pathName,report)
fid = fopen(pathName,'w');
assert(fid>=0,'public:IndexWriteFailed','Could not write output index: %s',pathName);
cleanup = onCleanup(@()fclose(fid));
fprintf(fid,'# Public reproduction output index\n\n');
fprintf(fid,'Generated: `%s`  \nMATLAB: `%s`  \nOutput root: `%s`\n\n', ...
    report.generatedAt,report.matlabVersion,report.outputRoot);
fprintf(fid,'The six experiments produced **%d figures** and **%d nonfigure experiment artifacts**.\n\n', ...
    report.figureCount,report.nonfigureCount);
fprintf(fid,'| Task | Kind | Relative path | Bytes |\n');
fprintf(fid,'|---|---|---|---:|\n');
for k = 1:numel(report.artifactTask)
    fprintf(fid,'| %s | %s | `%s` | %d |\n',report.artifactTask{k}, ...
        report.artifactKind{k},report.artifactRelativePath{k},report.artifactBytes(k));
end
fprintf(fid,'\n## Task metadata\n\n');
fprintf(fid,'| Task | Seconds | Report class | Report size | Report fields |\n');
fprintf(fid,'|---|---:|---|---:|---:|\n');
for k = 1:numel(report.taskMetadata)
    m = report.taskMetadata(k);
    fprintf(fid,'| %s | %.2f | %s | %s | %d |\n',m.task,m.elapsedSeconds, ...
        m.reportClass,m.reportSize,m.reportFieldCount);
end
fprintf(fid,'\n## Evidence boundary\n\n%s\n',report.scientificBoundary);
end

function [tasks,kinds,paths] = artifactSchema()
rows = {
    'T1','figure','t1/figures/T1_cube_face_correspondence.png';
    'T1','figure','t1/figures/T1_prism_face_correspondence.png';
    'T1','figure','t1/figures/T1_production_pollution.png';
    'T1','figure','t1/figures/T1_nonquadratic_schematic.png';
    'S1','figure','s1/s1_five_case_overview.png';
    'S1','figure','s1/s1_eigenvectors_and_transitions.png';
    'S2','figure','s2/S2_rank_degenerate_five_cases.png';
    'S2','figure','s2/S2_noncompact_three_configurations.png';
    'P1','figure','p1/p1_three_payoff_properties.png';
    'P1','figure','p1/p1_rate_decomposition.png';
    'P1','figure','p1/p1_weak_pareto_trap.png';
    'X1','figure','x1/x1_domain_map.png';
    'X1','figure','x1/x1_fiber_collapse.png';
    'X1','figure','x1/x1_trajectories_lyapunov.png';
    'I1','figure','i1/figures/I1_design_geometry.png';
    'I1','figure','i1/figures/I1_sigma_budget.png';
    'I1','figure','i1/figures/I1_before_after.png';
    'I1','figure','i1/figures/I1_INC_omega.png';
    'T1','data','t1/t1_report.mat';
    'T1','data','t1/t1_face_correspondence.csv';
    'T1','data','t1/t1_edge_correspondence.csv';
    'T1','data','t1/t1_vertex_correspondence.csv';
    'T1','data','t1/t1_diagnostics.csv';
    'S1','data','s1/s1_report.mat';
    'S1','data','s1/s1_case_summary.csv';
    'S1','data','s1/s1_branch_diagnostics.csv';
    'S2','data','s2/s2_report.mat';
    'S2','data','s2/s2_case_summary.csv';
    'S2','data','s2/s2_branch_diagnostics.csv';
    'S2','data','s2/s2_noncompact_summary.csv';
    'S2','data','s2/s2_trajectory_summary.csv';
    'P1','data','p1/p1_report.mat';
    'P1','data','p1/p1_samples.csv';
    'P1','data','p1/p1_summary.csv';
    'X1','data','x1/x1_report.mat';
    'X1','data','x1/x1_trajectories.csv';
    'I1','data','i1/i1_report.mat';
    'I1','data','i1/i1_condition_checks.csv';
    'I1','data','i1/i1_trajectory_summary.csv'};
tasks = rows(:,1);
kinds = rows(:,2);
paths = rows(:,3);
end

function assertDirectoryEmpty(pathName)
if exist(pathName,'dir')~=7, return; end
entries = dir(pathName);
names = {entries.name};
names = names(~ismember(names,{'.','..'}));
assert(isempty(names),'public:OutputRootNotEmpty', ...
    'The public output root must be absent or empty: %s',pathName);
end

function tf = isAbsolutePath(pathName)
if ispc
    tf = ~isempty(regexp(pathName,'^[A-Za-z]:[\\/]','once')) || startsWith(pathName,'\\');
else
    tf = startsWith(pathName,filesep);
end
end

function tf = isPathWithin(pathName,parentName)
pathName = canonicalPath(pathName);
parentName = canonicalPath(parentName);
tf = strcmp(pathName,parentName) || startsWith(pathName,[parentName,filesep]);
end

function value = canonicalPath(value)
value = char(java.io.File(value).getCanonicalPath());
end

function removeExperimentPath(experimentsDir)
if contains([path,pathsep],[experimentsDir,pathsep])
    rmpath(experimentsDir);
end
end
