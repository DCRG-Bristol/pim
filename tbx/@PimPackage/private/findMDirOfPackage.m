function mdir = findMDirOfPackage(package)
% find mdir (folder containing .m files that we will add to path)
mdir = "";
    if ~package.addPath
        return;
    end
    if ~(package.internalDir == "")
        if exist(fullfile(package.installDir, package.internalDir), 'dir')
        mdir = string(package.internalDir);
            return;
        else
            warning(i18n('internal_nosuchdir'));
            dispTree(package.installDir);
        end
    end
% check if pathlist file exist if so use this to define mdirs
pathfile = fullfile(package.installDir, 'pathList.txt');
if exist(pathfile,'file')
    local_paths = readlines(pathfile);
    idx = 1;
    for i = 1:length(local_paths)
        path2add = fullfile(package.installDir,local_paths(i));
        file=java.io.File(path2add);
        if file.exists && file.isDirectory
            mdir(idx) = local_paths(i);
            idx = idx+1;
        end
    end
    return
end
	folderNames = dir(fullfile(package.installDir, '*.m'));
    if ~isempty(folderNames)
    % all is well; *.m files exist in base directory
        return;
    else
    M_DIR_ORDER = {'bin', 'src', 'lib', 'code','tbx'};
        for ii = 1:numel(M_DIR_ORDER)
            folderNames = dir(fullfile(package.installDir, M_DIR_ORDER{ii}, '*.m'));
            if ~isempty(folderNames)
            mdir = string(M_DIR_ORDER{ii});
                return;
            end
        end
    end
    warning(i18n('mdir_404'));
    disp(i18n('mdir_help', package.name));
    dispTree(package.installDir);
    tree
end

