Build and deploy tools for the Ding project
===========================================

Installing Ding
===============

To get your own installation of the Ding project you should use the ding_build tool, which is a part of the ding-deploy package

Prerequisites
-------------

The required server software for running Ding:

* Apache 2.x with mod_rewrite
* PHP 5.2.X and APC or XCache
* MySQL 5.X

The configuration must adhere to [the default system requirements for Drupal](http://drupal.org/requirements).

In addition the default configuration the following settings must be configured as follows:

* PHP `memory_limit` must be at least `128M` (128MB)
* PHP `max_execution_time` must be at least `60` (1 minute)

If the installation is to integrate with the library systems access to [Open Search](http://oss.dbc.dk/plone/services), [ADDI](http://www.danbib.dk/index.php?doc=forsideservice) and Alma services from [Axiell](http://www.axiell.dk/) is a must.

Building a local installation
-----------------------------

NB: The following guide has been tested on Linux and OSX machines. [Ewan Andreasen has a writeup about how to do this on Windows XP (in Danish)](http://netnote.vejlebib.dk/et-ding-ting-udviklingsmiljoe-pa-windows).

The following utilities should be accessible from the command line:

*  A working version of [Python](http://www.python.org/download/)
*  The latest version of [Drush](http://drupal.org/project/drush_make) and [Drush Make](http://drupal.org/project/drush_make). v2.0-beta7 or later is required for git repository revision support.
*  A working version of Git ([Installation guide](http://book.git-scm.com/2_installing_git.html)). v1.7 or later is required for https suppport.

Go through the following steps:

1. Get a version of the ding-deploy package by either
    *  Cloning the repository from GitHub
    *  Downloading a tagged version which corresponds to a Ding release and unpack it
2. Open a console and navigate to the `ding-deploy` directory
3. Run `python ding_build.py [options] [installation path]`.

   If you run `python ding_build.py` without additional parameters, a full
   site will be built for you in the `ding-deploy/build/ding` folder.

   The options include
    *  `-d`: **Debug**. Required if you want to track the build progress
    *  `-D`: **Developer copy**. Build developer copy, using authenticated Git repositories.
    *  `-m MODE`: **Build mode**. Use 'site' for full Drupal site, 'profile' for just the installation profile. Default is 'site'.

4. Wait. The build process should take ~5 minutes.
5. *Optional* - download a translation:
    1. Navigate to your installation path
    2. Run `drush dl [language code]`. `drush dl da` downloads the Danish translation
    3. NB: This step should be obsolete once drush make supports translations.
6. Make your ding installation is accessible from your web server and create a corresponding database in MySQL
7. Open a browser and navigate to the web path for your Ding installation. This should display the Drupal installer with the option of using the Ding! installation profile.
8. Follow the installation instructions
    1. Select the Ding! installation profile
    2. Create a copy of `sites/default/default.settings.php` and name it `settings.php`
    3. Enter your database configuration (if needed)
    4. Configure your site
    5. Enter the Ting configuration. The values needed here should be provided by [DBC](http://oss.dbc.dk/plone/services). Ting service settings are required for accessing the Ting database. Additional information settings are required to display cover images.
    6. Enter the Alma configuration. The values needed here should be provided by [Axiell](http://www.axiell.dk/). Alma configuration is required for accessing the library system to enable user login through CPR/PIN, check material availability, make reservations etc.
9. Access your new Ding site!

Downloading a local installation
--------------------------------

If you want to get a local installation up and running quickly or do not have access to the developer tools mentioned above you can [download a build of Ding from GitHub](http://github.com/dingproject/ding-deploy/downloads).

If you choose to download a release you can skip straight to step 6 in the walkthrough above.

The list of downloads should contain builds of all our releases since 1.1.1.

Simple developer site
---------------------

It is also possible to use this Git repository as a standard Drupal
install profile without our special Python build script.

If you want to take this approach, simply check out this folder in your
`drupal/profiles` folder and run
`drush make --no-core --contrib-destination=. ding.make` within it.

