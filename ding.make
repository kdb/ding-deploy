api = 2
core = 6.x

; Install pressflow v6.x

projects[pressflow][type] = "core"
projects[pressflow][download][type] = "get"
projects[pressflow][download][url] = "http://files.pressflow.org/pressflow-6-current.tar.gz"

; Contrib projects

projects[admin][subdir] = "contrib"
projects[admin][version] = "2.0"
projects[admin][patch][] = "http://drupal.org/files/0001-Issue-969916-by-Agileware-Breadcrumb-error-in-jquery.patch"

projects[admin_language][subdir] = "contrib"
projects[admin_language][version] = "1.4"

projects[admin_theme][subdir] = "contrib"
projects[admin_theme][version] = "1.3"

projects[adminrole][subdir] = "contrib"
projects[adminrole][version] = "1.3"

projects[advanced_help][subdir] = "contrib"
projects[advanced_help][version] = "1.2"

projects[ahah_response][subdir] = "contrib"
projects[ahah_response][version] = "1.2"

projects[auto_nodetitle][subdir] = "contrib"
projects[auto_nodetitle][version] = "1.2"

projects[autoload][subdir] = contrib
projects[autoload][version] = 2.1

projects[better_formats][subdir] = "contrib"
projects[better_formats][version] = "1.2"

projects[cache_actions][subdir] = "contrib"
projects[cache_actions][version] = "1.0"

projects[cck][subdir] = "contrib"
projects[cck][version] = "2.9"

projects[comment_notify][subdir] = "contrib"
projects[comment_notify][version] = "1.6"

projects[content_profile][subdir] = "contrib"
projects[content_profile][version] = "1.0"
;projects[content_profile][patch][] = http://drupal.org/files/content_profile-776384-2.patch

projects[ctm][subdir] = contrib
projects[ctm][version] = 2.1

projects[ctools][subdir] = "contrib"
projects[ctools][version] = "1.8"

projects[date][subdir] = "contrib"
projects[date][version] = "2.9"

projects[dibs][subdir] = "contrib"
projects[dibs][type] = "module"
projects[dibs][download][type] = "git"
projects[dibs][download][url] = http://git.drupal.org/project/dibs.git
projects[dibs][download][revision] = 1898dd0f

projects[diff][subdir] = "contrib"
projects[diff][version] = "2.3"

projects[email][subdir] = "contrib"
projects[email][version] = "1.4"

projects[environment_indicator][subdir] = contrib
projects[environment_indicator][version] = 1.1

projects[features][subdir] = "contrib"
projects[features][version] = "1.2"
; Patch to fix reverting menu links http://drupal.org/node/860974
projects[features][patch][] = "http://drupal.org/files/issues/features.860974.patch"

projects[filefield][subdir] = contrib
projects[filefield][version] = 3.10

projects[flexifield][subdir] = "contrib"
projects[flexifield][version] = "1.0-alpha5"
projects[flexifield][patch][] = "http://drupal.org/files/issues/flexifield-390480-22.patch"

projects[globalredirect][subdir] = "contrib"
projects[globalredirect][version] = "1.5"

projects[google_analytics][subdir] = "contrib"
projects[google_analytics][version] = "3.4"

projects[htmLawed][subdir] = "contrib"
projects[htmLawed][version] = "2.12"

projects[image_resize_filter][subdir] = "contrib"
projects[image_resize_filter][version] = "1.13"

projects[imageapi][subdir] = contrib
projects[imageapi][version] = 1.10

projects[imagecache][subdir] = contrib
projects[imagecache][version] = 2.0-rc1

projects[imagecache_actions][subdir] = "contrib"
projects[imagecache_actions][version] = "1.9"

projects[imagefield][subdir] = contrib
projects[imagefield][version] = 3.10

projects[insert][subdir] = contrib
projects[insert][version] = 1.2

projects[jquery_ui][subdir] = "contrib"
projects[jquery_ui][version] = "1.5"

projects[jquery_update][subdir] = "contrib"
projects[jquery_update][version] = "1.1"

projects[link][subdir] = "contrib"
projects[link][version] = "2.10"

projects[location][subdir] = "contrib"
projects[location][version] = "3.2"

projects[markdown][subdir] = "contrib"
projects[markdown][version] = "1.3"

projects[masquerade][subdir] = "contrib"
projects[masquerade][version] = "1.4"

projects[menu_breadcrumb][subdir] = "contrib"
projects[menu_breadcrumb][version] = "1.3"

projects[menu_block][subdir] = "contrib"
projects[menu_block][version] = "2.4"
projects[menu_block][patch][] = http://drupal.org/files/menu_block_illegal_choice_in_parent-1203646-6.patch
projects[menu_block][patch][] = http://revealit.dk/static/2012-08-31-menu_block-default-fallback.patch

projects[nanosoap][subdir] = contrib
projects[nanosoap][version] = "1.0"

projects[oembed][subdir] = "contrib"
projects[oembed][version] = "0.8"

projects[office_hours][type] = "module"
projects[office_hours][subdir] = "contrib"
projects[office_hours][download][type] = "git"
projects[office_hours][download][url] = "https://github.com/dingproject/drupal-office_hours.git"
projects[office_hours][download][revision] = "6.x-2.0-unofficial10"

projects[opening_hours][subdir] = contrib
projects[opening_hours][download][type] = "git"
projects[opening_hours][download][url] = http://git.drupal.org/project/opening_hours.git
projects[opening_hours][download][revision] = 6.x-1.3-beta1

projects[openlayers][subdir] = contrib
projects[openlayers][version] = 2.0-beta1

projects[panels][subdir] = "contrib"
projects[panels][version] = "3.10"
projects[panels][patch][] = "https://github.com/downloads/dingproject/ding-deploy/panels_legacy_mode_disabling.patch"

projects[panels_subsites][subdir] = "contrib"
projects[panels_subsites][version] = 1.3

projects[path_redirect][subdir] = "contrib"
projects[path_redirect][version] = "1.0-rc2"

projects[pathauto][subdir] = contrib
projects[pathauto][version] = 2.0

projects[potx][subdir] = "contrib"
projects[potx][version] = "3.3"

projects[purl][subdir] = "contrib"
projects[purl][version] = "1.0-beta13"

projects[rules][subdir] = "contrib"
projects[rules][version] = "1.5"
projects[rules][patch][] = "https://github.com/downloads/dingproject/ding-deploy/rules_dont_clear_cache_on_form_alter.patch"

projects[securepages][subdir] = "contrib"
projects[securepages][version] = "1.9"

projects[similarterms][subdir] = "contrib"
projects[similarterms][version] = "1.18"

projects[spamspan][subdir] = "contrib"
projects[spamspan][version] = "1.6"

projects[strongarm][subdir] = "contrib"
projects[strongarm][version] = "2.2"

projects[suggestedterms][subdir] = "contrib"
projects[suggestedterms][version] = "1.4"

projects[tagadelic][subdir] = "contrib"
projects[tagadelic][version] = "1.3"

projects[term_node_count][subdir] = "contrib"
projects[term_node_count][version] = "1.3"

projects[tipsy][subdir] = contrib
projects[tipsy][version] = 1.1

projects[token][subdir] = contrib
projects[token][version] = 1.19

projects[transliteration][subdir] = "contrib"
projects[transliteration][version] = "3.1"

projects[vertical_tabs][subdir] = "contrib"
projects[vertical_tabs][version] = "1.0-rc2"

projects[views][subdir] = "contrib"
projects[views][version] = "2.16"
projects[views][patch][] = http://drupal.org/files/views_cache_key-1802056-1.patch

projects[views_bulk_operations][subdir] = "contrib"
projects[views_bulk_operations][version] = "1.14"

projects[webform][subdir] = contrib
projects[webform][version] = 3.18

projects[wysiwyg][subdir] = "contrib"
projects[wysiwyg][version] = "2.4"

; Themes
projects[tao][version] = "3.2"

projects[rubik][version] = "3.0-beta2"

projects[mothership][version] = "1.1"

; Ding theme

projects[dynamo][type] = "theme"
projects[dynamo][download][type] = "git"
projects[dynamo][download][url] = "https://github.com/dingproject/dynamo.git"
projects[dynamo][download][revision] = "v2.4.0-rc2"
projects[dynamo][patch][] = https://github.com/dingproject/dynamo/pull/15.patch

; Ding modules

projects[alma][type] = "module"
projects[alma][download][type] = "git"
projects[alma][download][url] = "https://github.com/dingproject/alma.git"
projects[alma][download][revision] = "6b05c09"
projects[alma][patch][] = https://github.com/dingproject/alma/pull/11.patch

projects[openruth][type] = "module"
projects[openruth][download][type] = "git"
projects[openruth][download][url] = "https://github.com/dingproject/openruth.git"
projects[openruth][download][revision] = "v1.0.9"

projects[ding][type] = "module"
projects[ding][download][type] = "git"
projects[ding][download][url] = "https://github.com/dingproject/ding.git"
projects[ding][download][revision] = "8c89e6e"
projects[ding][patch][] = "https://github.com/dingproject/ding/pull/31.patch"
projects[ding][patch][] = "https://github.com/dingproject/ding/pull/38.patch"

projects[ding_campaign][type] = "module"
projects[ding_campaign][download][type] = "git"
projects[ding_campaign][download][url] = "https://github.com/dingproject/ding-campaign.git"
projects[ding_campaign][download][revision] = "v1.5.0-rc2"

projects[ding_mobile][type] = "module"
projects[ding_mobile][download][type] = "git"
projects[ding_mobile][download][url] = "https://github.com/dingproject/ding-mobile.git"
projects[ding_mobile][download][revision] = "v1.1.0-rc1"

projects[ding_redia_feed][type] = "module"
projects[ding_redia_feed][download][type] = "git"
projects[ding_redia_feed][download][url] = "https://github.com/dingproject/ding_redia_feed.git"
projects[ding_redia_feed][download][revision] = "v1.1.0-rc1"

projects[ding_tema_sites][type] = module
projects[ding_tema_sites][download][type] = git
projects[ding_tema_sites][download][url] = https://github.com/kdb/ding_tema_sites.git
projects[ding_tema_sites][download][revision] = 366ed34

projects[ting][type] = "module"
projects[ting][download][type] = "git"
projects[ting][download][url] = "https://github.com/dingproject/ting.git"
projects[ting][download][revision] = cb2a6ec
projects[ting][patch][] = https://github.com/dingproject/ting/pull/52.patch

projects[trampoline][type] = "module"
projects[trampoline][download][type] = "git"
projects[trampoline][download][url] = "https://github.com/dingproject/trampoline.git"
projects[trampoline][download][revision] = "v1.3.1"

projects[webtrends][type] = "module"
projects[webtrends][download][type] = "git"
projects[webtrends][download][url] = "https://github.com/dingproject/webtrends.git"
projects[webtrends][download][revision] = "v1.1.2"

; Libraries
libraries[ting-client][destination] = "modules/ting/lib"
libraries[ting-client][download][type] = "git"
libraries[ting-client][download][url] = "https://github.com/dingproject/ting-client.git"
libraries[ting-client][download][revision] = 74933be

libraries[jquery_ui][download][type] = "get"
libraries[jquery_ui][download][url] = "http://jquery-ui.googlecode.com/files/jquery.ui-1.6.zip"
libraries[jquery_ui][directory_name] = "jquery.ui"
libraries[jquery_ui][destination] = "modules/contrib/jquery_ui"

libraries[tinymce][download][type] = "get"
libraries[tinymce][download][url] = "https://github.com/downloads/tinymce/tinymce/tinymce_3.4.2.zip"
libraries[tinymce][directory_name] = "tinymce"
libraries[tinymce][destination] = "libraries"

; Additions and tweaks for bibliotek.kk.dk

projects[kdb][type] = module
projects[kdb][download][type] = git
projects[kdb][download][url] = https://github.com/kdb/kdb.git
projects[kdb][download][revision] = 450ff95
