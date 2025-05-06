function url = handleCustomUrl(url)

% if .git url, must remove and add /zipball/master
inds = strfind(url, '.git'); % want to match this
inds = setdiff(inds, strfind(url, '.github')); % ignore matches to '.github'
if isempty(inds)
    inds = strfind(url, '?download=true');
    if isempty(inds) %#ok<*STREMP>
        url = url +"?download=true";
    end
    return
else
    error('Address should not end in .git...')
end

end

