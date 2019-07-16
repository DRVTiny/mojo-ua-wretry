Mojo::UserAgent::WithRetry is a "patch" class providing additional methods
(get|post|push|patch|delete)_with_retry for Mojo::UserAgent. This methods
is absolutely equal to ones without "with_retry" suffix except it tries to
handle connection problems like "Premature connection close". 
