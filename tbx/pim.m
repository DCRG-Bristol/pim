function pim(action, varargin)
%pim Matlab Package Manager
% function pim(ACTION, varargin)
%
% ACTION can be any of the following:
%   'init'      add all installed packages in default install directory to path
%   'search'    finds a url for a package by name (searches Github and File Exchange)
%   'install'   installs a package by name
%   'uninstall' installs a package by name
%   'freeze'    list all installed packages (optional: in install-dir)
%   'set'       change options for an already installed package
%
% If ACTION is one of 'search', 'install', or 'uninstall', then you must
% provide a package NAME as the next argument (e.g., 'matlab2tikz')
%
%
% Examples:
%
%   % Add all installed packages to the path (e.g. to be run at startup)
%   pim init
%
%   % Search for a package called 'test' on Matlab File Exchange
%   pim search test
%
%   % Install a package called 'test'
%   pim install test
%
%   % Uninstall a package called 'test'
%   pim uninstall test
%
%   % List all installed packages
%   pim freeze
%
%
% To modify the default behavior of the above commands,
% the following optional arguments are available:
%
% name-value arguments:
%   url (-u): optional; if does not exist, must search
%   infile (-i): if set, will run pim on all packages listed in file
%   install-dir (-d): where to install package
%   query (-q): if name is different than query
%   release-tag (-t): if url is found on github, this lets user set release tag
%   internal-dir (-n): lets user set which directories inside package to add to path
%   collection (-c): override pim's default package collection ("default")
%     by specifying a custom collection name
%
% arguments that are true if passed (otherwise they are false):
%   --github-first (-g): check github for url before matlab fileexchange
%   --force (-f): install package even if name already exists in InstallDir
%   --approve: when using -i, auto-approve the installation without confirming
%   --debug: do not install anything or update paths; just pretend
%   --no-paths: no paths are added after installing (default if -c is specified)
%   --all-paths: add path to all subfolders in package
%   --local: url is a path to a local directory to install (add '-e' to not copy)
%   --use-local (-e): skip copy operation during local install
%
% For more help, or to report an issue, see <a href="matlab:
% web('https://github.com/mobeets/mpm')">the pim Github page</a>.
%

% print help info if no arguments were provided
if nargin < 1
    help pim;
    return;
end

% parse and validate command line args
[pkg, opts] = PimOpts.Default();
[pkg, opts] = opts.Parse(pkg, action, varargin{:});
validateArgs(pkg, opts);
if opts.debug
    warning(i18n('debug_message'));
end

% installing from requirements
if ~(opts.inFile == "")
    % read filename, and call pim for all lines in this file
    readRequirementsFile(opts.inFile, opts);
    return;
end

% load metadata
opts.meta = getMetadata();

% pim init
if strcmpi(opts.action, 'init')
    opts.updatePimPaths = true;
    updatePaths(opts);
    return;
end

% pim freeze
if strcmpi(opts.action, 'freeze')
    listPackages(opts);
    return;
end

% pim uninstall
if strcmpi(opts.action, 'uninstall')
    removePackage(pkg, opts);
    return;
end

if strcmpi(opts.action, 'clear')
    pkgs = [opts.meta];
    names = [pkgs.name];
    disp(i18n('remove_start', string(numel(names)), strjoin(names,', ')));
    if ~opts.force
        reply = input(i18n('confirm'), 's');
        if isempty(reply)
            reply = i18n('confirm_yes');
        end
        if ~strcmpi(reply(1), i18n('confirm_yes'))
            disp(i18n('confirm_nvm'));
            return;
        end
    end
    opts.force = true;
    for i = pkgs
        removePackage(i, opts);
    end
    setpref('pim','meta',PimPackage.empty);
    return;
end

if strcmpi(opts.action, 'install')
    pkg.installDir = fullfile(opts.installDir, pkg.name);
    disp(i18n('setup_start', pkg.name));
    % get url
    if pkg.url == ""
        pkg.url = findUrl(pkg, opts);
    end
    % download package and add to metadata
    if pkg.url ~= ""
        if ~opts.localInstall
            disp(i18n('setup_download', pkg.url));
        else
            disp(i18n('setup_install', pkg.name));
        end
        isOk = pkg.install(opts);
        if isOk
            opts.meta = addToMetadata(pkg, opts.meta);
            if ~opts.noPaths
                disp(i18n('setup_updating'));
                pkg.UpdatePath(opts.debug);
            end
        end
    end
    return
end
end


function removePackage(pkg, opts)
[~, ix] = indexInMetadata(pkg, opts.meta);
if ~any(ix)
    disp(i18n('remove_404', pkg.name));
    return;
end
pkg = opts.meta(ix);
pkg.remove(opts);
% write new metadata to file
opts.meta = opts.meta(~ix);
setpref('pim','meta',opts.meta)
disp(i18n('remove_complete'));
end

function dispTree(name)
folderNames = dir(name);
folderNames = {folderNames([folderNames.isdir] == 1).name};
for i = 1:length(folderNames)
    if i == length(folderNames)
        disp([char(9492) char(9472) char(9472) char(9472) folderNames{i}])
    elseif ~endsWith(folderNames{i}, '.')
        disp([char(9500) char(9472) char(9472) char(9472) folderNames{i}])
    end
end
end

function listPackages(opts)
if isempty(opts.meta)
    disp(i18n('list_404', opts.installDir));
    return;
end
disp(i18n('list_current', opts.installDir));
for ii = 1:numel(opts.meta)
    package = opts.meta(ii);
    packageName = package.name;
    if ~(package.releaseTag == "")
        packageName = packageName + "==" + package.releaseTag; %#ok<*AGROW>
    end
    out = " - " + packageName + " (" + string(package.downloadDate) + ")";
    cdir = fileparts(package.installDir);
    if ~strcmpi(cdir, opts.installDir)
        out = out +  " : " + package.installDir;
    end
    disp(out);
end
end



function [meta] = getMetadata()
if ~ispref('pim','meta')
    try
    addpref('pim','meta',struct.empty)
    catch
    end
    meta = PimPackage.empty;
else
    meta = getpref('pim','meta');
end

cleanPackages = PimPackage.empty;
for ii = 1:numel(meta)
    package = meta(ii);

    dirPaths = fullfile(package.installDir, package.mdir);
    if all(isfolder(dirPaths))
        cleanPackages(end+1) =  package;
    end
end
meta = cleanPackages;
end

function [ind, ix] = indexInMetadata(package, meta)
if isempty(meta)
    ind = []; ix = [];
    return;
end
ix = ismember([meta.name], package.name);
ind = find(ix, 1, 'first');
end

function meta = addToMetadata(package, meta)
% update metadata file to track all packages installed

[~, ix] = indexInMetadata(package, meta);
if any(ix)
    meta = meta(~ix);
    disp(i18n('metadata_replace_op', package.name));
else
    disp(i18n('metadata_add_op', package.name));
end
meta = [meta package];

% write to file
setpref('pim','meta',meta)
end

function updatePaths(opts)
% read metadata file and add all paths listed

% add mdir to path for each package in metadata (optional)
namesAdded = {};
if opts.updatePimPaths
    for ii = 1:numel(opts.meta)
        success = opts.meta(ii).UpdatePath(opts.debug);
        if success
            namesAdded = [namesAdded opts.meta(ii).name];
        end
    end
end
if numel(opts.meta) == 0
    disp(i18n('updatepaths_404'));
else
    disp(i18n('updatepaths_success', num2str(numel(opts.meta))));
end

% also add all folders listed in install-dir (optional)
if opts.updateAllPaths
    c = updateAllPaths(opts, namesAdded);
    disp(i18n('updatepaths_all', num2str(c)));
end
end

function c = updateAllPaths(opts, namesAlreadyAdded)
% adds all directories inside installDir to path
%   ignoring those already added
%
c = 0;
fs = dir(opts.installDir); % get names of everything in install dir
fs = {fs([fs.isdir]).name}; % keep directories only
fs = fs(~strcmp(fs, '.') & ~strcmp(fs, '..')); % ignore '.' and '..'
for ii = 1:numel(fs)
    f = fs{ii};
    if ~ismember(f, namesAlreadyAdded)
        if ~opts.debug
            dirPath = fullfile(opts.installDir, f);
            disp(pim_config('updatepath_op', dirPath));
            addpath(dirPath);
        end
        c = c + 1;
    end
end
end




