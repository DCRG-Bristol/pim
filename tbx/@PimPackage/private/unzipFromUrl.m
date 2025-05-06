function [isOk, package] = unzipFromUrl(package)
% download from url to installDir
    isOk = true;

    zipFileName = [tempname '.zip'];
    try
        zipFileName = websave(zipFileName, package.url);
    catch ME
        % handle 404 from File Exchange for getting updated download url
        ps = strsplit(ME.message, 'for URL');
        if numel(ps) < 2
            isOk = false; return;
        end
        ps = strsplit(ps{2}, 'github_repo.zip');
        package.url = ps{1}(2:end);
        zipFileName = websave(zipFileName, package.url);
    end
    try
        unzip(zipFileName, package.installDir);
    catch
        isOk = false; return;
    end

    folderNames = dir(package.installDir);
    numFolderNames = numel(folderNames);
    ndirs = sum([folderNames.isdir]);
    if ...
        ((numFolderNames == 3) && (ndirs == 3)) ...
        || ((numFolderNames == 4) && (ndirs == 3) ...
        && strcmpi(folderNames(~[folderNames.isdir]).name, 'license.txt'))
        % only folders are '.', '..', and package folder (call it dirName)
        %       and then maybe a license file,
        %       so copy the subtree of dirName and place inside installDir
        folderNames = folderNames([folderNames.isdir]);
        fldr = folderNames(end).name;
        dirName = fullfile(package.installDir, fldr);
        try
            movefile(fullfile(dirName, '*'), package.installDir);
        catch % hack for handling packages like cbrewer 34087
            movefile(fullfile(dirName, package.name, '*'), package.installDir);
        end
        rmdir(dirName, 's');
    end
end

