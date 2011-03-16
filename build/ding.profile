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

    // Contrib modules
    'admin',
    'admin_language',
    'admin_theme',
    'adminrole',
    'advanced_help',
    'ahah_response',
    'atom_api',
    'auto_nodetitle',
    'better_formats',
    'content',
    'nodereference',
    'number',
    'optionwidgets',
    'text',
    'userreference',
    'cache_actions',
    'comment_notify',
    'content_profile',
    'ctm',
    'bulk_export',
    'ctools',
    'page_manager',
    'views_content',
    'd7backports',
    'date_api',
    'date_locale',
    'date_popup',
    'date_timezone',
    'date',
    'ding_user',
    'email',
    'environment_indicator',
    'features',
    'filefield',
    'globalredirect',
    'gmap',
    'gmap_location',
    'googleanalytics',
    'htmLawed',
    'imageapi',
    'imageapi_gd',
    'imagecache',
    'imagecache_canvasactions',
    'imagefield',
    'image_resize_filter',
    'insert',
    'jquery_update',
    'keys',
    'link',
    'location',
    'location_fax',
    'location_phone',
    'location_node',
    'markdown',
    'menu_block',
    'oembed',
    'oembedcore',
    'optionwidgets',
    'page_manager',
    'panels',
    'pathauto',
    'path_redirect',
    'potx',
    'purl',
    'similarterms',
    'similarterms_preview',
    'spamspan',
    'strongarm',
    'suggestedterms',
    'tagadelic',
    'term_node_count',
    'token',
    'token_actions',
    'transliteration',
    'vertical_tabs',
    'views',
    'actions_permissions',
    'views_bulk_operations',
    'wysiwyg',
  );

  return $modules;
}

/**
 * Returns an array list of atrium features (and supporting) modules.
 */
function _ding_profile_modules() {
  return array(
    'alma',
    'alma_cart',
    'alma_dibs',
    'alma_user',
    'dibs',
    'ding_admin',
    'ding_base',
    'ding_breadcrumbs',
    'ding_campaign',
    'ding_content',
    'ding_event',
    'ding_feature_ref',
    'ding_library',
    'ding_library_map',
    'ding_library_user',
    'ding_default_permissions',
    'ding_page',
    'ding_panels',
    'draggable_checkboxes',
    'flexifield',
    'jquery_ui',
    'jquery_ui_theme',
    'office_hours',
    'ting',
    'ting_covers',
    'ting_recommendation_panes',
    'ting_reference',
    'ting_search',
    'ting_search_autocomplete',
    'ting_search_carousel',
    'dynamo',
    'trampoline',
  );
}

/**
 * Implementation of hook_profile_task_list().
 */
function ding_profile_task_list() {
  // This is the only profile method that is invoked before the first page is
  // displayed during the install sequence.  Use this opportunity to theme the
  // install experience.
  global $conf;
  $conf['site_name'] = 'Ding.TING';

  return array(
    'ding-ting-config' => st('Ting configuration'),
    'ding-alma-config' => st('Alma configuration'),
    'ding-modules-batch' => st('Feature installation'),
    'ding-configure-batch' => st('Feature configuration'),
  );
}

/**
 * Implementation of hook_profile_tasks().
 */
function ding_profile_tasks(&$task, $url) {
  global $profile, $install_locale;

  // Just in case some of the future tasks adds some output
  $output = '';

  // First time, this function will be called with the 'profile' task.
  // In this case, we advance the pointer to our first custom task, to
  // indicate that this profile needs more runs to complete.
  if ('profile' == $task) {
    $task = 'ding-ting-config';
  }

  // First custom step displays a configuration form for Ting.
  if ('ding-ting-config' == $task) {
    $output = drupal_get_form('ding_profile_ting_form', $url);

    // If the submit function has not run yet, display the form.
    if (!variable_get('ding_profile_ting_form_finished', FALSE)) {
      drupal_set_title(st('Ting configuration'));
      return $output;
    }
    // Otherwise, go to the next task.
    else {
      $task = 'ding-alma-config';
    }
  }

  if ('ding-alma-config' == $task) {
    $output = drupal_get_form('ding_profile_alma_form', $url);

    // If the submit function has not run yet, display the form.
    if (!variable_get('ding_profile_alma_form_finished', FALSE)) {
      drupal_set_title(st('Alma configuration'));
      return $output;
    }
    // Otherwise, go to the next task.
    else {
      drupal_set_message('Going to modules');
      $task = 'ding-modules';
    }
  }

  // We are running a batch task for this profile so basically do nothing and return page
  if (in_array($task, array('ding-modules-batch', 'ding-configure-batch'))) {
    include_once 'includes/batch.inc';
    $output = _batch_page();
  }

  if ('ding-modules' == $task) {
    drupal_set_message('setting up batch');
    $modules = _ding_profile_modules();
    $files = module_rebuild_cache();

    // Create batch
    foreach ($modules as $module) {
      $batch['operations'][] = array('_install_module_batch', array($module, $files[$module]->info['name']));
    }

    $batch['finished'] = '_ding_modules_batch_finished';
    $batch['title'] = st('Installing @drupal', array('@drupal' => drupal_install_profile_name()));
    $batch['error_message'] = st('The installation has encountered an error.');

    // Start a batch, switch to 'ding-modules' task. We need to
    // set the variable here, because batch_process() redirects.
    variable_set('install_task', 'ding-modules-batch');
    batch_set($batch);
    batch_process($url, $url);

    // Just for cli installs. We'll never reach here on interactive installs.
    return;
  }

  // Run additional configuration tasks.
  if ($task == 'ding-configure') {
    $batch['title'] = st('Configuring @drupal',  array('@drupal' => drupal_install_profile_name()));
    $batch['operations'][] = array('_ding_configure_first', array());
    $batch['operations'][] = array('_ding_configure_second', array());
    $batch['finished'] = '_ding_configure_finished';

    variable_set('install_task', 'ding-configure-batch');
    batch_set($batch);
    batch_process($url, $url);

    // Just for cli installs. We'll never reach here on interactive installs.
    return;
  }

  return $output;
}

/**
 * Implementation of hook_form_alter().
 */
function ding_form_alter(&$form, $form_state, $form_id) {
  if ($form_id == 'install_configure') {
    $form['submit']['#submit'] = array('ding_form_install_configure_submit');
  }
}

/**
 * Submit handler for configure form.
 *
 * Takes the entered password and saves it in our own table.
 */
function ding_form_install_configure_submit($form, &$form_state) {
  db_query("INSERT INTO {ding_user} (uid, pass, display_name) VALUES (1, '%s', 'Systemadministrator');", user_hash_password($form_state['values']['account']['pass']));

  // For some reason, adding our own submit handler seems to prevent the
  // standard one from running. To work around this, we run it manually.
  install_configure_form_submit($form, $form_state);
}


/**
 * Ting configuration form.
 */
function ding_profile_ting_form(&$form_state, $url) {
  $form = array();

  $form['explanation'] = array(
    '#prefix' => '<p>',
    '#suffix' => '</p>',
    '#value' => st('If you want the site to integrate with the ting library data well from dbc, please fill in the following details:'),
  );

  $form['ting'] = array(
    '#type' => 'fieldset',
    '#title' => t('Ting service settings'),
    '#tree' => FALSE,
  );

  $form['ting']['ting_agency'] = array(
    '#type' => 'textfield',
    '#title' => t('Library code'),
    '#description' => t('The 6-digit code representing the library organization'),
  );

  $form['ting']['ting_search_url'] = array(
    '#type' => 'textfield',
    '#title' => t('Search service URL'),
    '#description' => t('URL to the Ting search webservice, e.g. http://didicas.dbc.dk/opensearch/'),
  );

  $form['ting']['ting_scan_url'] = array(
    '#type' => 'textfield',
    '#title' => t('Scan service URL'),
    '#description' => t('URL to the Ting scan webservice, e.g. http://didicas.dbc.dk/openscan/'),
  );

  $form['ting']['ting_spell_url'] = array(
    '#type' => 'textfield',
    '#title' => t('Spell service URL'),
    '#description' => t('URL to the Ting spell webservice, e.g. http://didicas.dbc.dk/openspell/'),
  );

  $form['ting']['ting_recommendation_server'] = array(
    '#type' => 'textfield',
    '#title' => t('Recommendation service URL'),
    '#description' => t('URL to the Ting recommendation webservice (Andre der har lånt...) , e.g. http://didicas.dbc.dk/openadhl/'),
  );

  $form['addi'] = array(
    '#type' => 'fieldset',
    '#title' => t('Additional Information settings'),
  	'#description' => t('The Additional Information service is used to retrieve cover images and other information about objects. <a href="http://www.danbib.dk/index.php?doc=forsideservice">More information about the service (in Danish)</a>'),
    '#tree' => FALSE,
  );

  $form['addi']['addi_wdsl_url'] = array(
    '#type' => 'textfield',
    '#title' => t('Service URL'),
    '#description' => t('URL to the Additional Information webservice, e.g. http://forside.addi.dk/addi.wsdl'),
  );

  $form['addi']['addi_username'] = array(
    '#type' => 'textfield',
    '#title' => t('Username'),
    '#description' => t('Username for the Additional information webservice'),
  );

  $form['addi']['addi_group'] = array(
    '#type' => 'textfield',
    '#title' => t('Group'),
    '#description' => t('User group for the Additional information webservice'),
  );

  $form['addi']['addi_password'] = array(
    '#type' => 'textfield',
    '#title' => t('Password'),
    '#description' => t('Password for the Additional information webservice'),
  );

  $form['continue'] = array(
    '#type' => 'submit',
    '#value' => st('Continue'),
  );

  // Note that #action is set to the url passed through from
  // installer, ensuring that it points to the same page, and
  // #redirect is FALSE to avoid broken installer workflow.
  $form['errors'] = array();
  $form['#action'] = $url;
  $form['#redirect'] = FALSE;

  return $form;
}

/**
 * Submit handler for Ting configuration form.
 */
function ding_profile_ting_form_submit($form, &$form_state) {
  system_settings_form_submit($form, &$form_state);
  variable_set('ding_profile_ting_form_finished', TRUE);
}

/**
 * Alma configuration form.
 */
function ding_profile_alma_form(&$form_state, $url) {
  $form = array();

  $form['explanation'] = array(
    '#prefix' => '<p>',
    '#suffix' => '</p>',
    '#value' => st('If you want the site to integrate with the Axiell library system via the Alma API, please fill in the following details:'),
  );

  $form['alma_base_url'] = array(
    '#type' => 'textfield',
    '#title' => t('Alma base URL'),
    '#description' => t('The base URL for constructing request to the Alma REST service, usually something like https://server.example.com:8000/alma/ or http://10.0.0.34:8010/alma/'),
  );

  $form['continue'] = array(
    '#type' => 'submit',
    '#value' => st('Continue'),
  );

  // Note that #action is set to the url passed through from
  // installer, ensuring that it points to the same page, and
  // #redirect is FALSE to avoid broken installer workflow.
  $form['errors'] = array();
  $form['#action'] = $url;
  $form['#redirect'] = FALSE;

  return $form;
}

/**
 * Submit handler for Alma configuration form.
 */
function ding_profile_alma_form_submit($form, &$form_state) {
  system_settings_form_submit($form, &$form_state);
  variable_set('ding_profile_alma_form_finished', TRUE);
  variable_set('install_task', 'ding-modules');
}

/**
 * Finished callback for the modules install batch.
 */
function _ding_modules_batch_finished($success, $results) {
  variable_set('install_task', 'ding-configure');
}

/**
 * Configuration. First stage.
 */
function _ding_configure_first() {
  // Use the Rubik admin theme.
  variable_set('admin_theme', 'rubik');
  variable_set('admin_theme_admin_theme_batch', 1);
  variable_set('admin_theme_admin_theme_devel', 1);
  variable_set('admin_theme_admin_theme_webform_results', 1);
  variable_set('admin_theme_ding_campaign_ding_campaign_rules', 1);
}

/**
 * Configuration. Second stage.
 */
function _ding_configure_second() {
  global $theme_key;

  // Rebuild key tables/caches
  drupal_flush_all_caches();

  db_query("UPDATE {blocks} SET status = 0, region = ''"); // disable all DB blocks
  db_query("UPDATE {system} SET status = 0 WHERE type = 'theme' and name ='%s'", 'garland');
  db_query("UPDATE {system} SET status = 1 WHERE type = 'theme' and name ='%s'", 'dynamo');
  variable_set('theme_default', 'dynamo');

  // Rebuild our blocks and place them at default positions
  // as they may have lost their position during the install
  //
  // _block_rehash() uses the global $theme_key variable which has
  // not been set to dynamo yet so do this manually during the rehash.
  // TODO: Is there a more clean way to achieve this?
  $temp_theme_key = $theme_key;
  $theme_key = 'dynamo';
  _block_rehash();
  $theme_key = $temp_theme_key;

  // In Aegir install processes, we need to init strongarm manually as a
  // separate page load isn't available to do this for us.
  if (function_exists('strongarm_init')) {
    strongarm_init();
  }

  // Revert key components that are overridden by others on install.
  // Note that this comes after all other processes have run, as some cache
  // clears/rebuilds actually set variables or other settings that would count
  // as overrides. See `og_node_type()`.
  $revert = array(
    'ding_campaign' => array('user', 'variable'),
    'ding_content' => array('user', 'variable', 'filter'),
    'ding_page' => array('user', 'variable'),
    'ding_library' => array('user', 'variable'),
  );
  features_revert($revert);

  // Set the front page.
  variable_set('site_frontpage', 'front_panel');

  // Delete our temporary variables
  variable_del('ding_profile_ting_form_finished');
  variable_del('ding_profile_alma_form_finished');

  // Set up our default taxonomy vocabularies.
  db_query("INSERT INTO {vocabulary} (vid, name, help, relations, hierarchy, multiple, required, tags, module, weight) VALUES
    (1, '" . st('Post category') . "', '" . st('Pick a topic for the post') . " . ', 1, 1, 0, 1, 0, 'taxonomy', -9),
    (2, '" . st('Tags') . "', '" . st('A comma-separated list of keywords') . " . ', 1, 0, 1, 0, 1, 'taxonomy', 9),
    (4, '" . st('Event category') . "', '', 1, 0, 0, 0, 0, 'taxonomy', 0),
    (5, '" . st('Event target') . "', '', 1, 1, 0, 0, 0, 'taxonomy', 0)
  ");

  // Bind vocabularies to node types.
  db_query("INSERT INTO {vocabulary_node_types} (vid, type) VALUES
    (1, 'article'),
    (2, 'article'),
    (2, 'campaign'),
    (2, 'event'),
    (2, 'feature'),
    (2, 'library'),
    (2, 'page'),
    (2, 'profile'),
    (2, 'topic'),
    (4, 'event'),
    (5, 'event')
  ");

  // Add a term to the required vocabulary.
  db_query("INSERT INTO {term_data} (tid, vid, name) VALUES (1, 1, 'Test')");
  db_query("INSERT INTO {term_hierarchy} (tid, parent) VALUES (1, 0)");

  // Initialise the carousel with a test search.
  variable_set('ting_search_carousel_searches', array(array(
    'title' => 'Test',
    'subtitle' => 'Lorem ipsum dolor amet',
    'query' => 'test',
  )));

  // Mark all the non-default roles as secure.
  $query = db_query("SELECT rid FROM role WHERE rid > 2");
  $rid_list = array();
  while ($rid = db_result($query)) {
    $rid_list[$rid] = $rid;
  }
  variable_set('ding_user_secure_roles', $rid_list);
}

/**
 * Finish configuration batch.
 */
function _ding_configure_finished($success, $results) {
  variable_set('install_task', 'profile-finished');
}

