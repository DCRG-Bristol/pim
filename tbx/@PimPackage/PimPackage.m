classdef PimPackage < handle
    %PACKAGEMETA Summary of this class goes here
    %   Detailed explanation goes here

    properties
        name string = "";
        url string = ""
        internalDir string = "";
        releaseTag string = ""
        addPath logical = true;
        localInstall logical = false
        noRmdirOnUninstall logical = false
        addAllDirsToPath logical = false
        collection string = "default"
        installDir string = ""
        mdir string = ""
        downloadDate

        query string
    end

    methods
        function remove(pkg,opts)
            arguments
                pkg PimPackage
                opts PimOpts
            end

            % delete package directories if they exist
            disp(i18n('remove_start', '1', pkg.name));
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
            % remove from path
            pkg.UpdatePath(opts.debug,isRemove=true);

            % check for uninstall file
            checkForFileAndRun(pkg.installDir, 'uninstall.m', opts);

            if exist(pkg.installDir, 'dir')
                % remove old directory
                if ~pkg.noRmdirOnUninstall
                    rmdir(pkg.installDir, 's');
                else
                    disp(i18n('remove_preexist', pkg.installDir));
                end
            end
        end

        function success = UpdatePath(pkg,debug,fopts)
            arguments
                pkg
                debug = false;
                fopts.isRemove = false;
            end
            success = false;
            if ~pkg.addPath
                return;
            end
            for i = 1:length(pkg.mdir)
                dirPath = fullfile(pkg.installDir, pkg.mdir(i));
                if exist(dirPath, 'dir')
                    success = true;
                    if ~debug
                        if  fopts.isRemove
                            disp(i18n('updatepath_rm', dirPath));
                            rmpath(dirPath);
                        else
                            disp(i18n('updatepath_op', dirPath));
                            addpath(dirPath);
                        end
                    end

                    % add all folders to path
                    if pkg.addAllDirsToPath
                        disp(i18n('updatepath_all'));
                        if  fopts.isRemove
                            rmpath(genpath(dirPath));
                        else
                            addpath(genpath(dirPath));
                        end
                    end
                else
                    warning(i18n('updatepath_404', dirPath));
                end
            end
        end

        function isOk = install(pkg,opts)
            arguments
                pkg PimPackage
                opts
            end
            % install package by downloading url, unzipping, and finding paths to add
            isOk = true;

            % check for previous package
            if exist(pkg.installDir, 'dir') && ~opts.force
                warning(i18n('install_conflict'));
                isOk = false;
                return;
            elseif exist(pkg.installDir, 'dir')
                % remove old directory
                disp(i18n('install_remove_previous'));
                rmdir(pkg.installDir, 's');
            end

            if (                                                                    ...
                    ~opts.localInstall                                                  ...
                    && ~contains(pkg.url, '.git')                         ...
                    && contains(pkg.url, 'github.com')                    ...
                    )
                % install with git clone because not on github
                isOk = checkoutFromUrl(pkg);
                if ~isOk
                    warning(i18n('install_git_error'));
                end
            elseif ~opts.localInstall
                % download zip
                pkg.url = handleCustomUrl(pkg.url);
                [isOk, pkg] = unzipFromUrl(pkg);
                if (                                                                ...
                        ~isOk                                                           ...
                        && ~contains(pkg.url, 'github.com')                 ...
                        && contains(pkg.url, '.git')                        ...
                        )
                    warning(i18n('install_add_git_ext'));
                elseif ~isOk
                    warning(i18n('install_download_error'));
                end
            else % local install (using pre-existing local directory)
                % make sure path exists
                if ~exist(pkg.url, 'dir')
                    warning(i18n('install_nosuchdir', pkg.url));
                    isOk = false; return;
                end

                % copy directory to installDir
                if ~opts.localInstallUseLocal
                    if ~exist(pkg.url, 'dir')
                        warning(i18n('install_404', pkg.url));
                        isOk = false; return;
                    end
                    mkdir(pkg.installDir);
                    isOk = copyfile(pkg.url, pkg.installDir);
                    if ~isOk
                        warning(i18n('install_error_local'));
                    end
                else % no copy; just track the provided path
                    % make sure we have absolute path
                    file=java.io.File(pkg.url);
                    if file.isAbsolute()
                        absPath = pkg.url;
                    else
                        absPath = char(file.getCanonicalPath());
                    end
                    if ~file.isDirectory
                        warning(i18n('install_404', absPath));
                        isOk = false; return;
                    else
                        pkg.installDir = absPath;
                    end
                end
            end
            if ~isOk
                warning(i18n('install_error', pkg.name));
                return;
            end
            pkg.downloadDate = datestr(datetime);
            pkg.mdir = findMDirOfPackage(pkg);

            if isOk
                % check for install.m and run after confirming
                checkForFileAndRun(pkg.installDir, 'install.m', opts);
            end

        end


    end
end

