function isOk = checkoutFromUrl(package)
% git checkout from url to installDir
    isOk = true;
    if ispc, quote = '"'; else, quote = ''''; end
    if ~(package.releaseTag == "")
        flag = system(['git clone --depth 1 --branch ', package.releaseTag, ' ', package.url, ' ', quote, package.installDir, quote]);
    else
        flag = system(['git clone --depth 1 ', package.url, ' ', quote, package.installDir, quote]);
    end
    if (flag ~= 0)
        isOk = false;
        warning(i18n('checkout_error', package.url));
    end
end