"""
Helper functions to set-up storage plugins for remote inputs/outputs.
See the docstring of `path_or_url` for usage instructions.

<https://snakemake.readthedocs.io/en/stable/snakefiles/storage.html>
"""

from urllib.parse import urlparse

PUBLIC_BUCKETS = set(['nextstrain-data']) # TODO XXX

_storage_registry = {} # keeps track of registered storage plugins to enable reuse

def _storage_s3(*, bucket, keep_local, force_signed):
    """
    Returns a Snakemake storage plugin for S3 endpoints
    """
    retries=2 # num S3 retries attempted

    # If the bucket is public then we make an unsigned request (i.e. no AWS credentials
    # need to be set). Note that this won't work for uploads.
    if not force_signed and bucket in PUBLIC_BUCKETS:
        if provider:=_storage_registry.get('s3_unsigned', None):
            return provider

        from botocore import UNSIGNED
        storage s3_unsigned:
            provider="s3",
            signature_version=UNSIGNED,
            retries=retries, 
            keep_local=keep_local,

        _storage_registry['s3_unsigned'] = storage.s3_unsigned
        return _storage_registry['s3_unsigned']

    # Default: resource fetched via a signed request, which will require AWS credentials
    if provider:=_storage_registry.get('s3_signed', None):
        return provider

    # the tag appears in the local file path, so reference 'signed' to give a hint about credential errors
    storage s3_signed:
        provider="s3",
        retries=retries, 
        keep_local=keep_local,

    _storage_registry['s3_signed'] = storage.s3_signed
    return _storage_registry['s3_signed']

def _storage_http(*, keep_local):
    if provider:=_storage_registry.get('http', None):
        return provider

    storage:
        provider="http",
        allow_redirects=True,
        supports_head=True,
        keep_local=keep_local,

    _storage_registry['http'] = storage.http
    return _storage_registry['http']

def path_or_url(uri, *, keep_local=True, force_signed=False):
    """
    Returns the URI wrapped by an applicable storage plugin.
    Local filepaths will be returned unchanged.

    TODO XXX - document usage more thoroughly
    """
    info = urlparse(uri)

    if info.scheme=='': # local
        return uri      # no storage wrapper

    if info.scheme=='s3':
        return _storage_s3(bucket=info.netloc, keep_local=keep_local, force_signed=force_signed)(uri)

    if info.scheme in ['http', 'https']:
        return _storage_http(keep_local=keep_local)(uri)
    
    # TODO XXX - Google? We allowed this in ncov <https://github.com/nextstrain/ncov/blob/41cf6470d3140963ff3e02c29241f80ae8ed9c33/workflow/snakemake_rules/remote_files.smk#L62>

    raise Exception(f"Input address {uri!r} (scheme={info.scheme!r}) is from a non-supported remote")
