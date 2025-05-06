function url = findUrl(package, opts)
arguments
    package PimPackage
    opts PimOpts
end
% find url by searching matlab fileexchange and github given opts.name

if ~(package.releaseTag == "") % tag set, so search github only
    url = findUrlOnGithub(package);
elseif opts.searchGithubFirst
    url = findUrlOnGithub(package);
    if url == "" % if nothing found, try file exchange
        url = findUrlOnFileExchange(package);
    end
else
    url = findUrlOnFileExchange(package);
    if url == "" % if nothing found, try github
        url = findUrlOnGithub(package);
    end
end
if url == ""
    disp(i18n('url_404'));
else
    disp(i18n('url_found', url));
end
end