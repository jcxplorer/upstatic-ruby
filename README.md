# Upstatic

Deploy your static sites to S3. Supports Cloudront object invalidation,
file gzipping, and configuration of cache control headers.


## Installation

Until upstatic is released on rubygems, please clone the repository and 
install with:

    rake install

## Usage

Create a file named _Upstatic_ in the directory you want to deploy and 
specify at least the S3 bucket name:

```ruby
bucket "upstatic-site"
```

Upstatic tries to read your AWS credentials from the following 
environment variables: `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

You can also specify them in the _Upstatic_ file as:

```ruby
access_key_id "MY_AWS_KEY_ID"
secret_access_key "MY_AWS_SECRET_ACCESS_KEY"
```

Once the bucket and credentials are setup, you can deploy by running:

    upstatic deploy

For more configuration options, keep reading.

## Configuration

### Gzip

If you want to gzip certain files, just specify which file extensions 
you'd like gzipped. Note that gzipping files means that they'll always 
be served compressed. S3 does not support serving different files based 
on the Accept-Encoding header.

```ruby
gzip_extensions ".html", ".js", ".css"
```

By default no files are gzipped.

### Cache-Control headers

You can also specify Cache-Control headers for specific file extensions.  
For example, you might want Cloudfront (and proxies) to cache HTML files 
for 600 seconds, but tell the browser not to cache them:

```ruby
cache_control ".html", "public, s-maxage=600, max-age=0"
```

You can also specify the default for all other files:

```ruby
default_cache_control "public, max-age=691200"
```

The default is to serve every file with `Cache-Control: public, 
max-age=691200`.

### Cloudfront

If you are serving some or all your files from Cloudfront, you probably 
want to invalidate the newly updated objects. Just specify your 
Cloudfront distribution ID and it will be taken care of when you deploy.

```ruby
distribution_id "E2ADVMBKHEFZJ3"
```

## Notes

This extension keeps track of every deployed file in a `.sha1sums` at 
the root of the bucket. This is a private file that contains a SHA-1 sum 
of the uploaded file, followed by a SHA-1 sum of its upload options and 
finally the filename. This file is used to know if a file needs to be 
uploaded again.

## Testing

Everything is tested by actually deploying to S3 and requesting the 
deployed files.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

MIT License.
