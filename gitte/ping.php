<?php
// $Id$

/**
 * @file
 * Script that Github pings when a new commit is available.
 */

if (isset($_REQUEST['site']) && !empty($_REQUEST['site'])) {
  $site = preg_replace('/[^A-Za-z0-9]/', '', $_REQUEST['site']);

  $errno = $errstr = NULL;
  $socket = fsockopen('unix:///tmp/gitte.sock', NULL, $errno, $errstr);

  if ($socket) {
    if (fwrite($socket, $site . "\r\n")) {
      $reply = fread($socket, 256);

      if (strpos($reply, 'OK') === 0) {
        printf('Marked %s as updated on %s.', $site, date('c', $_SERVER['REQUEST_TIME']));
      }
      else {
        print 'Invalid reply from server: ' . $reply;
      }
    }
    else {
      print 'Could not write to socket.';
    }
  }
  else {
    print 'Could not connect to socket: ' . $errstr;
  }
}

