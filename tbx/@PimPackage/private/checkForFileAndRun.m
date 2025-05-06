function checkForFileAndRun(installDir, fileName, opts)
fpath = fullfile(installDir, fileName);

% check for install file and read comments at top
fid = fopen(fpath);
if fid == -1
    return;
end
lines = {};
line = '%';
while ~isnumeric(line) && numel(line) > 0 && strcmpi(line(1), '%')
    line = fgetl(fid);
    if ~isnumeric(line) && numel(line) > 0 && strcmpi(line(1), '%')
        lines = [lines line];
    end
end
if fid ~= -1
    fclose(fid);
end

% verify
disp(i18n('checkfilerun_200', fileName, fpath));
if numel(lines) > 0
    disp(i18n('checkfilerun_help'));
    disp(strjoin(lines, '\n'));
end
if ~opts.force
    reply = input(['Run ' fileName ' (Y/N)? '], 's');
    if isempty(reply)
        reply = i18n('confirm_yes');
    end
    if ~strcmpi(reply(1), i18n('confirm_yes'))
        disp(i18n('checkfilerun_skip', fileName));
        return;
    end
    disp(i18n('checkfilerun_running', fileName));
else
    disp(i18n('checkfilerun_run_force', fileName));
end

% run
run(fpath);
end

