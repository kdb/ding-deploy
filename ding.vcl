# This is the ding.vcl varnish configuration file created for Varnish 2.0.x versions

backend default {
  .host = "127.0.0.1";
  .port = "8042";
  .probe = {
    .timeout = 2 s;
    .interval = 10 s;
    .window = 10;
    .threshold = 2;
    .request =
      "GET /index.php HTTP/1.1"
      "Host: YOURHOST.COM"
      "Connection: close"
      "Accept-Encoding: text/html";
  }
}

sub vcl_recv {
  # Reduce the number of User Agent variants so caching will work better
  if (req.http.user-agent ~ "MSIE") {
    set req.http.user-agent = "MSIE";
  } else {
    set req.http.user-agent = "Mozilla";
  }

  # Allow a grace period for offering "stale" data in case backend lags
  set req.grace = 5m;

  remove req.http.X-Forwarded-For;
  set req.http.X-Forwarded-For = client.ip;

  # Deal with GET and HEAD  requests only, everything else gets through
  if (req.request != "GET" &&
      req.request != "HEAD") {
    return (pass);
  }

  // Skip the Varnish cache for install, update, and cron, 
  // Also skip server-status, and some APC pages
  if (req.url ~ "install\.php|update\.php|cron\.php|server-status|apc_info\.php|apc_clear_cache\.php") {
    return (pass);
  }

  if (req.http.Accept-Encoding) {
    if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg)$") {
      # No point in compressing these
      remove req.http.Accept-Encoding;
    } elsif (req.http.Accept-Encoding ~ "gzip") {
      set req.http.Accept-Encoding = "gzip";
    } elsif (req.http.Accept-Encoding ~ "deflate") {
      set req.http.Accept-Encoding = "deflate";
    } else {
      # unkown algorithm
      remove req.http.Accept-Encoding;
    }
  }
  
  // unset cookies for static files, and remove any dynamic ?123123213 timestamps
  if (req.url ~ "\.(css|html|js)") {
    unset req.http.cookie;
    set req.url = regsub(req.url, "\?.*$", "");
    return(lookup);
  }

  // images
  if (req.url ~ "\.(gif|jpg|jpeg|bmp|png|tiff|tif|ico|img|tga|wmf)$") {
    unset req.http.cookie;
    return(lookup);
  }

  // ajax-callback (clears the timestamp)
  if (req.url ~ "(/|q=)ting/autocomplete") {
    unset req.http.cookie;
    set req.url = regsub(req.url, "\&timestamp=[0-9]+", "");
    return(lookup);
  }

  // always cache these urls
  if (req.url ~ "/ting_search_carousel/results" || 
      req.url ~ "/office_hours/" ||
      req.url ~ "(/|q=)ting/search/js" ||
      req.url ~ "(/|q=)/ting/search/content/js" ||
      req.url ~ "(/|q=)/ting/availability/"
      ) {
    unset req.http.cookie;
    return(lookup);
  }

  // Remove a ";" prefix, if present.
  set req.http.Cookie = regsub(req.http.Cookie, "^;\s*", "");

  // Remove empty cookies.
  if (req.http.Cookie ~ "^\s*$") {
    unset req.http.Cookie;
  }

  if (req.http.Cookie ~ "(VARNISH|DRUPAL_UID|NO_CACHE|SESS.*?)") {
    return(pass);
  }

  unset req.http.Cookie;
  return(lookup);
}

sub vcl_fetch {  
  
  # for debugging purposes
  # set obj.http.X-Varnish-Debug = req.url;
  
  # Special handling for application specific AJAX callbacks
  if (req.url ~ "/ting/autocomplete" ||
      req.url ~ "/ting_search_carousel/results" || 
      req.url ~ "/ting/search/" ||
      req.url ~ "/ting/availability/" ||
      req.url ~ "/office_hours/"
      ) {
    #set obj.ttl = 10m;
    unset obj.http.set-cookie;
  }

  # These status codes should always pass through and never cache.
  if (obj.status == 404 || obj.status == 503 || obj.status == 500) {
    set obj.http.X-Cacheable = "NO: obj.status";
    set obj.http.X-Cacheable-status = obj.status;
    return(pass);
  }

  # Grace to allow varnish to serve content if backend is lagged
  set obj.grace = 5m;

  # Remove Expires from backend, it's not long enough
  unset obj.http.expires;

  # Cache for this time by default, change it if necessary
  set obj.ttl = 15m;

  # Static files are cached for an hour
  if (req.url ~ "\.(gif|jpg|jpeg|bmp|png|tiff|tif|ico|img|tga|wmf|js|css|bz2|tgz|gz|mp3|ogg|swf)") {
    set obj.ttl = 60m;
    remove req.http.Accept-Encoding;
    unset req.http.set-cookie;
    unset obj.http.set-cookie;
  }

  # Static files served from the default directory also have cookies unset
  if (req.url ~ "^/sites/default/") {
    unset req.http.set-cookie;
    unset obj.http.set-cookie;
  }

  # marker for vcl_deliver to reset Age:
  set obj.http.magicmarker = "1";

  # All tests passed, therefore item is cacheable
  set obj.http.X-Cacheable = "YES";

  return(deliver);
}

sub vcl_deliver {
  # Remove the magic marker
  if (resp.http.magicmarker) {
    unset resp.http.magicmarker;

    # By definition we have a fresh object
    set resp.http.age = "0";
  }

  # Add cache hit data
  if (obj.hits > 0) {
    # If hit add hit count
    set resp.http.X-Cache = "HIT";
    set resp.http.X-Cache-Hits = obj.hits;
  } else {
    set resp.http.X-Cache = "MISS";
  }
}

sub vcl_error {
  if (obj.status == 503 && req.restarts < 5) {
    set obj.http.X-Restarts = req.restarts;
    restart;
  }
}

sub vcl_hit {
  # Allow users force refresh
  if (!obj.cacheable) {
    return(pass);
  }
}
