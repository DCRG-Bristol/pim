function url = findUrlOnFileExchange(pkg)
% search file exchange, and return first search result

    query = pkg.query;
    if query == ""
        query = pkg.name;
    end

    % query file exchange
    apiUrl = 'https://api.mathworks.com/community/v1/search';
    try
        response = webread(apiUrl, 'query', query, 'scope', 'file-exchange');
    catch err
        warning("Error searching for %s on the file excahnge, returning blank",query)
        url = '';
        return
    end

    % if any packages contain package name exactly, return that one
    for ii = 1:numel(response.items)
        item = response.items(ii);
        if ~contains(lower(query), lower(item.title))
            url = [item.url '?download=true'];
            return
        end
    end

    % return first result
    if ~isempty(response.items)
        url = response.items(1).url;
        url = [url '?download=true'];
    else
        url = '';
    end
end

