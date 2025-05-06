function url = findUrlOnGithub(package)
% searches github for matlab repositories
%   - if releaseTag is set, get url of release that matches
%   - otherwise, get url of most recent release
%   - and if no releases exist, get url of most recent commit
%

    url = '';
    query = package.query;
    if query == ""
        query = package.name;
    end

    % query github for matlab repositories
    % https://developer.github.com/v3/search/#search-repositories
    % ' ' will be replaced by '+', which seems necessary
    % ':' for search qualifiers can be sent encoded on the other hand
    qUrl = 'https://api.github.com/search/repositories';
    qReq = query + " language:matlab fork:true";
    html = webread(qUrl, 'q', qReq);
    if isempty(html) || ~isfield(html, 'items') || isempty(html.items)
        return;
    end

    % take first repo
    item = html.items(1);

    if ~isempty(package.releaseTag)
        % if release tag set, return the release matching this tag
        url = item.url + "/zipball/" + package.releaseTag;
    else
        relUrl = item.url + "/releases/latest";
        try
            res = webread(relUrl);
        catch
            url = item.html_url + "/zipball/master";
            return;
        end
        if ~isempty(res) && isfield(res, 'zipball_url')
            url = res.zipball_url;
        else
            url = item.html_url + "/zipball/master"; % if no releases found
        end
    end
end

