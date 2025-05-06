classdef PimOpts
    %PACKAGEMETA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        installDir string = "";
        metadir string = ""
        searchGithubFirst logical = false;
        updatePimPaths logical = false
        updateAllPaths logical = true;
        localInstall logical = false
        localInstallUseLocal logical = false
        addAllDirsToPath logical = false
        installDirOverride string = "default"
        inFile string = ""
        force logical = false;
        approve logical = true
        debug logical = true
        noPaths  logical = true
        collection string = "";

        meta PimPackage

        action string
    end

    methods 
        function [pkg,opts] = Parse(opts,pkg,action,varargin)
        arguments
            opts PimOpts
            pkg PimPackage
            action string {mustBeMember(action,["init","search","install","uninstall","freeze","set","clear"])}
        end
        arguments (Repeating)
            varargin
        end
        opts.action = action;

        %% parse additional arguments
        if numel(varargin) == 0
            switch opts.action
                case {"freeze","init","clear"}
                    pkg.query = '';
                    return;
                otherwise
                    error(i18n('parseargs_noargin'));
            end
        end
        % check for parameters, passed as name-value pairs
        usedNextArg = false;
        function nextArg = getNextArg(remainingArgs, ii, curArg)
            if numel(remainingArgs) <= ii
                error(i18n('getnextarg_noargin', curArg));
            end
            nextArg = remainingArgs{ii+1};
        end
        for ii = 1:numel(varargin)
            curArg = varargin{ii};
            if usedNextArg
                usedNextArg = false;
                continue;
            end
            usedNextArg = false;
            if strcmpi(curArg, 'url') || strcmpi(curArg, '-u')
                nextArg = getNextArg(varargin, ii, curArg);
                pkg.url = nextArg;
                usedNextArg = true;
            elseif strcmpi(curArg, 'query') || strcmpi(curArg, '-q')
                nextArg = getNextArg(varargin, ii, curArg);
                pkg.query = nextArg;
                usedNextArg = true;
            elseif strcmpi(curArg, 'infile') || strcmpi(curArg, '-i')
                nextArg = getNextArg(varargin, ii, curArg);
                opts.inFile = nextArg;
                usedNextArg = true;
            elseif strcmpi(curArg, 'install-dir') || strcmpi(curArg, '-d')
                nextArg = getNextArg(varargin, ii, curArg);
                opts.installDir = nextArg;
                opts.installDirOverride = true;
                usedNextArg = true;
            elseif strcmpi(curArg, 'collection') || strcmpi(curArg, '-c')
                nextArg = getNextArg(varargin, ii, curArg);
                opts.collection = nextArg;
                pkg.collection = nextArg;
                usedNextArg = true;
            elseif strcmpi(curArg, 'internal-dir') || strcmpi(curArg, '-n')
                nextArg = getNextArg(varargin, ii, curArg);
                pkg.internalDir = nextArg;
                usedNextArg = true;
            elseif strcmpi(curArg, 'release-tag') || strcmpi(curArg, '-t')
                nextArg = getNextArg(varargin, ii, curArg);
                pkg.releaseTag = nextArg;
                usedNextArg = true;
            elseif strcmpi(curArg, '--github-first') || ...
                strcmpi(curArg, '-g')
                opts.searchGithubFirst = true;
            elseif strcmpi(curArg, '--force') || strcmpi(curArg, '-f')
                opts.force = true;
            elseif strcmpi(curArg, '--approve')
                opts.approve = true;
            elseif strcmpi(curArg, '--debug')
                opts.debug = true;
            elseif strcmpi(curArg, '--no-paths')
                pkg.addPath = false;
                opts.noPaths = true;
            elseif strcmpi(curArg, '--all-paths')
                pkg.addAllDirsToPath = true;
                opts.addAllDirsToPath = true;
            elseif strcmpi(curArg, '--local')
                opts.localInstall = true;
                pkg.localInstall = true;
            elseif strcmpi(curArg, '--use-local') || strcmpi(curArg, '-e')
                opts.localInstallUseLocal = true;
                pkg.noRmdirOnUninstall = true;
            else
                if ii == 1
                    % assume package name if first argument
                    pkg.name = curArg;
                    pkg.query = pkg.name;
                else
                    error(['Did not recognize argument ''' curArg '''.']);
                end
            end
        end

        end
    end

    methods(Static)
        function [pkg,opts] = Default()
            pkg = PimPackage();
            % set default directory to install packages
            curdir = fileparts(mfilename('fullpath'));
            DEFAULT_INSTALL_DIR = fullfile(curdir, 'pim-packages');

            % search github before searching Matlab File Exchange?
            DEFAULT_CHECK_GITHUB_FIRST = false;

            % create instacne
            opts = PimOpts();
            opts.installDir = DEFAULT_INSTALL_DIR;
            opts.metadir = DEFAULT_INSTALL_DIR;
            opts.searchGithubFirst = DEFAULT_CHECK_GITHUB_FIRST;
            opts.updatePimPaths = false;
            opts.updateAllPaths = false;
            opts.localInstall = false;
            opts.localInstallUseLocal = false;
            opts.addAllDirsToPath = false;
            opts.installDirOverride = false; % true if user sets using -d
        
            opts.inFile = '';
            opts.force = false;
            opts.approve = false;
            opts.debug = false;
            opts.noPaths = false;
            opts.collection = pkg.collection;
        end
    end
end

