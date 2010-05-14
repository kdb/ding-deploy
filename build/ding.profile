<?php
// $Id: ding.profile,v 1.1 2010/05/14 08:28:32 mikl Exp $

/**
 * Implementation of hook_profile_details().
 */
function ding_profile_details() {
  return array(
    'name' => 'Ding!',
    'description' => 'Drupal for libraries',
  );
}

/**
 * Implementation of hook_profile_modules().
 */
function ding_profile_modules() {
  $modules = array(
    // Drupal core
    'block', 'comment', 'contact', 'dblog', 'filter', 'locale', 'menu',
    'node', 'path', 'search', 'system', 'taxonomy', 'user',

    // Bucketloads of contrib modules.
    'admin', 'admin_language', 'admin_theme', 'advanced_help',
    'ahah_response', 'atom_api', 'auto_nodetitle', 'backup_migrate',
    'better_formats', 'content', 'content_copy', 'content_permissions',
    'fieldgroup', 'nodereference', 'number', 'optionwidgets', 'text',
    'userreference', 'comment_notify', 'content_profile', 'ctm',
    'bulk_export', 'ctools', 'page_manager', 'views_content', 'date_api',
    'date_timezone', 'date_locale', 'date_popup', 'date', 'dibs', 'email',
    'filefield', 'filefield_insert', 'flexifield', 'globalredirect', 'gmap',
    'gmap_location', 'google404', 'googleanalytics', 'htmLawed', 'imageapi',
    'imageapi_gd', 'imagecache', 'imagecache_ui', 'imagecache_canvasactions',
    'imagefield', 'image_resize_filter', 'jquery_ui', 'jquery_ui_theme',
    'jquery_update', 'keys_api', 'link', 'location_fax', 'location_phone',
    'location', 'location_node', 'markdown', 'masquerade', 'oembed',
    'oembedcore', 'office_hours', 'panels', 'pathauto', 'path_redirect',
    'potx', 'remember_me', 'scheduler', 'similarterms',
    'similarterms_preview', 'spamspan', 'suggestedterms', 'tagadelic',
    'term_node_count', 'token', 'token_actions', 'transliteration',
    'vertical_tabs', 'views', 'actions_permissions',
    'views_bulk_operations', 'wysiwyg', 'environment_indicator',

    // Misc custom modules.
    'd7backports', 'draggable_checkboxes',

    // Axiell Alma.
    'alma', 'alma_cart', 'alma_dibs', 'alma_periodical', 'alma_user',

    // Ting integration.
    'ting_covers', 'ting_recommendation_panes', 'ting_reference',
    'ting_search', 'ting_search_autocomplete', 'ting_search_carousel',
    'ting',

    // Ding specific functionality.
    'ding_admin', 'ding_breadcrumbs', 'ding_campaign', 'ding_content',
    'ding_event', 'ding_feature_ref', 'ding_library', 'ding_library_map',
    'ding_page', 'ding_panels', 'ding_slug', 'ding_user',
  );

  return $modules;
}

/**
 * Implementation of hook_profile_task_list().
 */
function ding_profile_task_list() {
  $tasks = array();
  return $tasks;
}

/**
 * Implementation of hook_profile_tasks().
 */
function ding_profile_tasks(&$task, $url) {
  global $profile, $install_locale;
  
  // Just in case some of the future tasks adds some output
  $output = '';

  switch ($task) {
    case 'profile':
      global $theme_key;
      $theme_key = 'dynamo';
    
      // Disable all DB blocks
      db_query("UPDATE {blocks} SET status = 0, region = ''"); 

      // Reload blocks from modules.
      _block_rehash();

      // Set theme to Dynamo.
      db_query("UPDATE {system} SET status = 0 WHERE type = 'theme' and name ='%s'", 'garland');
      db_query("UPDATE {system} SET status = 1 WHERE type = 'theme' and name ='%s'", 'dynamo');
      variable_set('theme_default', 'dynamo');

      // Set the front page.
      variable_set('site_frontpage', 'front_panel');


      // Rebuild key tables/caches
      drupal_flush_all_caches();
      break;
  }

  return $output;
}

