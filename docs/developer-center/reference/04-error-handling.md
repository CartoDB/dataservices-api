## Error handling

Most of the errors fired by the API are handled by the API itself. It triggers a `CartoError` every time an error happens.

A cartoError is an object containing a single `message` field with a string explaining the error.
