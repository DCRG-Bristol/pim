function isOk = validateArgs(pkg, opts)
    isOk = true;
    if strcmpi(opts.action, 'init')
        return;
    end
    if pkg.name == "" && opts.inFile == ""
        if ~strcmpi(opts.action, 'freeze') && ~strcmpi(opts.action, 'clear')
            error(i18n('parseargs_noargin'));
        end
    end
    if ~(opts.inFile == "")
        assert(pkg.name == "", i18n('validateargs_infile_name'));
        assert(pkg.url == "", i18n('validateargs_infile_url'));
        assert(pkg.internalDir == "", i18n('validateargs_infile_internal_dir'));
        assert(pkg.releaseTag == "", i18n('validateargs_infile_release_tag'));
        assert(~opts.searchGithubFirst, i18n('validateargs_infile_github_first'));
    else
        assert(~opts.approve, i18n('validateargs_infile_approve'));
    end
    if strcmpi(opts.action, 'uninstall')
        assert(pkg.url == "", i18n('validateargs_url', 'uninstall'));
        % assert(pkg.query == "", i18n('validateargs_query', 'uninstall'));
        assert(pkg.internalDir == "", i18n('validateargs_internal_dir', 'uninstall'));
        assert(pkg.releaseTag == "", i18n('validateargs_release_tag', 'uninstall'));
        assert(~opts.searchGithubFirst, i18n('validateargs_github_first', 'uninstall'));
    end
    if strcmpi(opts.action, 'search')
        assert(~opts.force, i18n('validateargs_force_conflict', 'search'));
    end
    if strcmpi(opts.action, 'freeze')
        assert(~opts.force, i18n('validateargs_force_conflict', 'freeze'));
        assert(pkg.url == "", i18n('validateargs_url', 'freeze'));
        assert(pkg.query == "", i18n('validateargs_query', 'freeze'));
        assert(pkg.internalDir == "", i18n('validateargs_internal_dir', 'freeze'));
        assert(pkg.releaseTag == "", i18n('validateargs_release_tag', 'freeze'));
        assert(~opts.searchGithubFirst, i18n('validateargs_github_first', 'freeze'));
    end
    if strcmpi(opts.action, 'set')
        assert(~opts.force, i18n('validateargs_force_conflict', 'set'));
        assert(pkg.url == "", i18n('validateargs_url', 'set'));
        assert(pkg.query == "", i18n('validateargs_query', 'set'));
        assert(pkg.releaseTag == "", i18n('validateargs_release_tag', 'set'));
        assert(~opts.searchGithubFirst, i18n('validateargs_github_first', 'set'));
    end
    if opts.localInstall
        assert(~(pkg.url == ""), i18n('validateargs_localinstall_nourl'));
    end
    if opts.localInstallUseLocal
        assert(opts.localInstall, i18n('validateargs_uselocal_local'));
    end
end