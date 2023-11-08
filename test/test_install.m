% cd test/
% result = runtests('test_install')
% table(result)
clear
warning('off','backtrace')

GITHUB_SEARCH_RATELIMIT = 6;

pim_dir = fileparts(pwd);
cd(pim_dir)
addpath(pim_dir)

%% Test API Install - using GitHub api (no url)

%%% Test install api latest
pim install export_fig --force
export_fig_dir = fullfile(pim_dir, 'pim-packages', 'export_fig');
assert(exist(fullfile(export_fig_dir, 'export_fig.m'), 'file')==2)
assert(~isempty(which('export_fig')))

pause(GITHUB_SEARCH_RATELIMIT);

%%% Test install api tag
pim install matlab2tikz -t 0.4.7 --force
matlab2tikz_dir = fullfile(pim_dir, 'pim-packages', 'matlab2tikz');
assert(exist(fullfile(matlab2tikz_dir, 'version-0.4.7'), 'file')==2)
assert(~isempty(which('matlab2tikz')))

pause(GITHUB_SEARCH_RATELIMIT);

%%% Test install api branch
pim install matlab2tikz -t develop --force
matlab2tikz_dir = fullfile(pim_dir, 'pim-packages', 'matlab2tikz');
assert(exist(fullfile(matlab2tikz_dir, 'test/suites/ACID.Octave.4.2.0.md5'), 'file')==2)
assert(~isempty(which('matlab2tikz')))

pause(GITHUB_SEARCH_RATELIMIT);

%%% Test install api commit hash
pim install matlab2tikz -t ca56d9f --force
matlab2tikz_dir = fullfile(pim_dir, 'pim-packages', 'matlab2tikz');
assert(exist(fullfile(matlab2tikz_dir, 'version-0.3.3'), 'file')==2)
assert(~isempty(which('matlab2tikz')))

pause(GITHUB_SEARCH_RATELIMIT);

%% Test URL Install - using URL with .git file extension

%%% Test install url default branch
pim install matlab2tikz -u https://github.com/matlab2tikz/matlab2tikz.git --force
matlab2tikz_dir = fullfile(pim_dir, 'pim-packages', 'matlab2tikz');
assert(exist(fullfile(matlab2tikz_dir, 'src/matlab2tikz.m'), 'file')==2)
assert(~isempty(which('matlab2tikz')))

pause(GITHUB_SEARCH_RATELIMIT);

%%% Test install url tag
pim install matlab2tikz -t 0.4.7 -u https://github.com/matlab2tikz/matlab2tikz.git --force
matlab2tikz_dir = fullfile(pim_dir, 'pim-packages', 'matlab2tikz');
assert(exist(fullfile(matlab2tikz_dir, 'version-0.4.7'), 'file')==2)
assert(~isempty(which('matlab2tikz')))

pause(GITHUB_SEARCH_RATELIMIT);

%%% Test install url branch
pim install matlab2tikz -t develop -u https://github.com/matlab2tikz/matlab2tikz.git --force
matlab2tikz_dir = fullfile(pim_dir, 'pim-packages', 'matlab2tikz');
assert(exist(fullfile(matlab2tikz_dir, 'test/suites/ACID.Octave.4.2.0.md5'), 'file')==2)
assert(~isempty(which('matlab2tikz')))

pause(GITHUB_SEARCH_RATELIMIT);

%%% Test install url commit hash
pim install matlab2tikz -t ca56d9f -u https://github.com/matlab2tikz/matlab2tikz.git --force
matlab2tikz_dir = fullfile(pim_dir, 'pim-packages', 'matlab2tikz');
assert(exist(fullfile(matlab2tikz_dir, 'version-0.3.3'), 'file')==2)
assert(~isempty(which('matlab2tikz')))

pause(GITHUB_SEARCH_RATELIMIT);



%% Test Git Clone Install - using non-GitHub URL with .git file extension

%%% Test install git clone default branch
pim install hello -u https://bitbucket.org/dhoer/mpm_test.git --force
pim_test_dir = fullfile(pim_dir, 'pim-packages', 'hello');
assert(exist(fullfile(pim_test_dir, 'hello.m'), 'file')==2)
assert(~isempty(which('hello')))

pause(GITHUB_SEARCH_RATELIMIT);

%%% Test install git clone tag
pim install hello -t v1.0.0 -u https://bitbucket.org/dhoer/mpm_test.git --force
pim_test_dir = fullfile(pim_dir, 'pim-packages', 'hello');
assert(exist(fullfile(pim_test_dir, 'v1.0.0'), 'file')==2)
assert(~isempty(which('hello')))

pause(GITHUB_SEARCH_RATELIMIT);

%%% Test install git clone branch
pim install hello -t develop -u https://bitbucket.org/dhoer/mpm_test.git --force
pim_test_dir = fullfile(pim_dir, 'pim-packages', 'hello');
assert(exist(fullfile(pim_test_dir, 'v2.0.0'), 'file')==2)
assert(~isempty(which('hello')))

pause(GITHUB_SEARCH_RATELIMIT);



%%% Test install FileExchange
pim install covidx -u https://www.mathworks.com/matlabcentral/fileexchange/76213-covidx --force
covidx_dir = fullfile(pim_dir, 'pim-packages', 'covidx');
assert(exist(fullfile(covidx_dir, 'covidx.m'), 'file')==2)
assert(~isempty(which('covidx')))

pause(GITHUB_SEARCH_RATELIMIT);



%%% Test uninstall
pim install colorbrewer --force
pim uninstall colorbrewer --force
colorbrewer_dir = fullfile(pim_dir, 'pim-packages', 'colorbrewer');
assert(exist(colorbrewer_dir, 'dir')==0)
assert(exist(fullfile(colorbrewer_dir, 'brewermap.m'), 'file')==0)
assert(isempty(which('brewermap')))



%%% Test freeze
if ~exist('contains', 'builtin')
    contains = @(x,y) ~isempty(strfind(x,y));
end
results = evalc('pim freeze');
assert(contains(results,'export_fig'))
assert(contains(results,'matlab2tikz==ca56d9f'))
assert(contains(results,'covidx'))



%%% Test search
results = evalc('pim search export_fig');
assert(contains(results, ...
    'Found url: https://www.mathworks.com/matlabcentral/fileexchange/23629-export_fig?download=true'))

pause(GITHUB_SEARCH_RATELIMIT);

%%% Test infile
pim install --approve --force -i requirements-example.txt
assert(~isempty(which('export_fig')))
assert(~isempty(which('matlab2tikz')))
assert(~isempty(which('brewermap')))
pim uninstall colorbrewer --force
pim uninstall covidx --force
pim uninstall export_fig --force
pim uninstall hello --force
pim uninstall matlab2tikz --force
