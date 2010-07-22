backend default {
.host = "127.0.0.1";
.port = "8080";
}

sub vcl_recv {
  // added by johsw (http://drupal.org/user/58666) june 23rd 2010
  
  // js
  if (req.url ~ "\.(js)") {
    lookup;
  }
  // images
  if (req.url ~ "\.(gif|jpg|jpeg|bmp|png|tiff|tif|ico|img|tga|wmf)$") {
    unset req.http.cookie;
    lookup;
  }

  // ajax-callback (does not work due to timestamp)
  if (req.url ~ "^/ting/autocomplete") {
    unset req.http.cookie;
    lookup;
  }

  if (req.url ~ "^/ting_search_carousel/results") {
    unset req.http.cookie;
    lookup;
  }
  //if (req.request != "GET" && req.request != "HEAD"){
    //unset req.http.cookie;
    //lookup;
  //}

  // end added by johsw

  // Remove has_js and Google Analytics __* cookies.
  set req.http.Cookie = regsuball(req.http.Cookie, "(^|;\s*)(__[a-z]+|has_js)=[^;]*", "");
  // Remove a ";" prefix, if present.
  set req.http.Cookie = regsub(req.http.Cookie, "^;\s*", "");

   // Remove Webtrends cookies.
  set req.http.Cookie = regsub(req.http.Cookie, "(^|;\s*)(WT_FPC)[^;]*", "");
    // Remove NO_CACHE cookies.
  set req.http.Cookie = regsub(req.http.Cookie, "(^|;\s*)(NO_CACHE)[^;]*", "");



  // Remove empty cookies.
  if (req.http.Cookie ~ "^\s*$") {
    unset req.http.Cookie;
  }
  // Cache all requests by default, overriding the
  // standard Varnish behavior.
  // if (req.request == "GET" || req.request == "HEAD") {
  //   return (lookup);
  // }
}
//sub vcl_hash {
//  if (req.http.Cookie) {
//    set req.hash += req.http.Cookie;
//  }
//}


sub vcl_fetch {  
  // added by johsw (http://drupal.org/user/58666) june 23rd 2010
  if (req.url ~ "\.(gif|jpg|jpeg|bmp|png|tiff|tif|ico|img|tga|wmf)$") {
    set obj.ttl = 600s; 
    set obj.http.type = "fetch image"; 
    unset obj.http.set-cookie;   
  }
  // ajax-callback
  if (req.url ~ "^/ting/autocomplete") {
    set obj.ttl = 600s;
    unset obj.http.set-cookie;
  }
  if (req.url ~ "^/ting_search_carousel/results") {
    set obj.ttl = 600s;
    unset obj.http.set-cookie;
  }


  // end added by johsw
}
