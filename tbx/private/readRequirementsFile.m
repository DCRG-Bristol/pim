function readRequirementsFile(fileName, opts)
    txt = fileread(fileName);
    lines = strsplit(txt, '\n');

    % build list of commands to run
    % and check for illegal params (note spaces)
    illegalParams = {' -i ', ' infile '};
    cmds = {};
    for ii = 1:numel(lines)
        line = lines{ii};
        cmd = strtrim(string(line));

        if isempty(strrep(cmd, ' ', ''))
            % ignore empty line
            continue;
        end
        if startsWith(cmd, '%')
            % ignore comments
            continue;
        end

        for jj = 1:numel(illegalParams)
            if ~isempty(strfind(line, illegalParams{jj}))
                error(i18n('', num2str(ii), illegalParams{jj}));
            end
        end

        % if args are specified inside file, don't allow specifying w/ opts
        % if (                                                                ...
        %     opts.force                                                      ...
        %     && (...
        %         ~isempty(strfind(line, ' --force'))                         ...
        %         || ~isempty(strfind(line, ' -f'))                           ...
        %     )                                                               ...
        % )
        %     error(i18n('requirements_infile_conflict', 'force'));
        % end
        if opts.noPaths && ~isempty(strfind(line, ' --no-paths'))
            error(i18n('requirements_infile_conflict', 'no-paths'));
        end
        if opts.addAllDirsToPath && ~isempty(strfind(line, ' --all-paths'))
            error(i18n('requirements_infile_conflict', 'all-paths'));
        end
        if opts.localInstall && ~isempty(strfind(line, ' --local'))
            error(i18n('requirements_infile_conflict', 'local'));
        end
        if (                                                                ...
            opts.localInstallUseLocal ...
            && (                                                            ...
                ~isempty(strfind(line, '--use-local'))                      ...
                || ~isempty(strfind(line, ' -e'))                           ...
            )                                                               ...
        )
            error(i18n('requirements_infile_conflict', 'use-local'));
        end

        % check if installDir set on line
        if ~isempty(strfind(line, ' -d')) || ~isempty(strfind(line, ' InstallDir '))
            % warn if user also provided this line globally
            if opts.installDirOverride
                warning(i18n('requirements_installdir_override', num2str(ii)));
            end
        elseif ~isempty(line)
            cmd = cmd + " -d " + """" + opts.installDir + """";
        end

        % check if collection set on line
        if ~isempty(strfind(line, ' -c')) || ~isempty(strfind(line, ' Collection '))
            % warn if user also provided this line globally
            if ~strcmpi(opts.collection, 'default')
                warning(i18n(                                               ...
                    'requirements_collection_global',                       ...
                    opts.collection, num2str(ii)                            ...
                ));
            end
        elseif ~isempty(line)
            cmd = cmd + " -c " + opts.collection;
        end

        % now append opts as globals for each line in file
        if ~isempty(line)
            if opts.force
                cmd = cmd + " --force";
            end
            if opts.noPaths
                cmd = cmd + " --no-paths";
            end
            if opts.addAllDirsToPath
                cmd = cmd + " --all-paths";
            end
            if opts.localInstall
                cmd = cmd + " --local";
            end
            if opts.localInstallUseLocal
                cmd = cmd + " --use-local";
            end
            cmds = [cmds cmd];
        end
    end

    % verify
    disp(i18n('requirements_command_list'));
    for ii = 1:numel(cmds)
        disp(i18n('requirements_command', opts.action, cmds(ii)));
    end
    if ~opts.force % otherwise, auto-approve the below
        reply = input(i18n('confirm'), 's');
        if isempty(reply)
            reply = i18n('confirm_yes');
        end
        if ~strcmpi(reply(1), i18n('confirm_yes'))
            disp(i18n('confirm_nvm'));
            return;
        end
    end

    % run all
    for ii = 1:numel(cmds)
        % deal with "strings"
        cmd = strsplit(cmds{ii});
        jj = 1;
        while jj<length(cmd)
            if startsWith(cmd{jj},'"')
                for k = 1:length(cmd)
                    if endsWith(cmd{k},'"')
                        cmd{jj} = strjoin(cmd(jj:k),' ');
                        cmd = cmd([1:jj,k+1:end]);
                        break
                    end
                    if k == length(cmd)
                        error('I am confused')
                    end
                end
            end
            jj = jj + 1;
        end
        % run
        pim(opts.action, cmd{:});
    end
end

