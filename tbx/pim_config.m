function opts = pim_config()

    opts = struct();
    
    % set default directory to install packages
    curdir = fileparts(mfilename('fullpath'));
    opts.DEFAULT_INSTALL_DIR = fullfile(curdir, 'pim-packages');
    
    % search github before searching Matlab File Exchange?
    opts.DEFAULT_CHECK_GITHUB_FIRST = false;

end
