# For writers

## Contributing

### Setting up a local editing environment

1. Start a local documentation server:

    ```
    make server
    ```

    If everything is fine, you should see output similar to:

    ```
    [I 201112 11:16:39 server:335] Serving on http://0.0.0.0:8000
    INFO    -  Serving on http://0.0.0.0:8000
    [I 201112 11:16:39 handlers:62] Start watching changes
    INFO    -  Start watching changes
    [I 201112 11:16:39 handlers:64] Start detecting changes
    INFO    -  Start detecting changes
    ```

2. Open the browser at <!-- markdown-link-check-disable-line --> <http://127.0.0.1:8000>

Place your text editor side-by-side with the browser window if you want to have preview of your edits - the browser will
keep refreshing every time you update documents.

Useful links:

* [MkDocs Basics](https://www.mkdocs.org/user-guide/writing-your-docs/)

### Quick fixes directly from web

For quick edits/suggestions, edit links ("edit this page" at the top right corner) and create text suggestions directly
from web. See <!-- markdown-link-check-disable-line --> [GitHub documentation](https://docs.github.com/en/repositories/working-with-files/managing-files/editing-files)
if you're unfamiliar with the workflow.

### Linter

Required tools:

* Docker

To run the markdown linter which also fixes small issues automatically:

```shell
make lint
```
