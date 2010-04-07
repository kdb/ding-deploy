<?php
// $Id$

/**
 * Script that Github pings when a new commit is available.
 */
if (isset($_REQUEST['site']) && in_array($_REQUEST['site'], array('kkb', 'aakb', 'kolding', 'kbhlyd', 'ding'))) {
  touch($_REQUEST['site'] . '-lastmod');
  printf('Marked %s as updated on %s.', $_REQUEST['site'], date('c', $_SERVER['REQUEST_TIME']));
}

