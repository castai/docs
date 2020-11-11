# For writers

## Setting up local editing environment

1\. Install python 3 and pipenv:

```
python3 -m pip install pipenv
```

2\. Start local documentation server:

```
./local_server.sh
```

If everything is fine, you should see output similar to:

```
[I 201022 09:01:06 server:335] Serving on http://127.0.0.1:8000
INFO    -  Serving on http://127.0.0.1:8000
[I 201022 09:01:06 handlers:62] Start watching changes
INFO    -  Start watching changes
[I 201022 09:01:06 handlers:64] Start detecting changes
INFO    -  Start detecting changes
```

<!-- markdown-link-check-disable-next-line -->
3\. Open browser at [http://127.0.0.1:8000](http://127.0.0.1:8000)

4\. Place your text editor side-by-side with a browser window if you want to have preview of your edits - browser will
keep refreshing each time you update documents.

Useful links:

* [MkDocs Basics](https://www.mkdocs.org/user-guide/writing-your-docs/)

## Quick fixes directly from web

For quick edits/suggestions, edit links ("edit this page" at the top right corner) and create text suggestions directly
from web. See [GitHub documentation](https://docs.github.com/en/free-pro-team@latest/github/managing-files-in-a-repository/editing-files-in-your-repository)
if you're unfamiliar with the workflow.
