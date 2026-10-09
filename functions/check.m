function nFail = check(description, passed, detail)
%CHECK  Print one PASS/FAIL line comparing a computed result with the thesis.
%
%   check('text', condition, 'optional detail')  prints and records a check.
%   check('reset')    clears the record.
%   check('summary')  prints the totals and returns the number of failures.

persistent nPass nFailed
if isempty(nPass), nPass = 0; nFailed = 0; end

if strcmp(description, 'reset')
    nPass = 0; nFailed = 0;
    nFail = 0;
    return
end
if strcmp(description, 'summary')
    fprintf('\n==== %d checks passed, %d failed ====\n', nPass, nFailed);
    nFail = nFailed;
    return
end

if nargin < 3, detail = ''; end
if passed
    nPass = nPass + 1;
    tag = 'PASS';
else
    nFailed = nFailed + 1;
    tag = 'FAIL';
end
fprintf('  [%s] %s', tag, description);
if ~isempty(detail), fprintf('  (%s)', detail); end
fprintf('\n');
nFail = nFailed;
end
