# API specification

Our API contract is published as OpenAPI v3 specification. The simplest way to check it out is to visit our
Swagger UI, which is available at:

<https://api.cast.ai>

This will bring your to our current specification, where you'll be able to familiarize yourself with available APIs,
as well as try functionality directly in the browser.

!!! note
    Trying out APIs in the browser requires setting up the UI with an API Key.
    See [Authentication](authentication.md) for more details.

We don't maintain any public SDKs, but it is sufficiently trivial to generate an API client for your programming
 language using many of the [OpenAPI generators](https://openapi.tools/#sdk). Use below json as a spec:

<https://api.cast.ai/v1/spec/openapi.json>

!!! note
    OpenAPI is widely supported. Many tools, e.g. Postman, allow importing OpenAPI definitions as well. See
    documentation for your REST tooling to find out more.
