"""
Ding deploy script.

It uses the Fabric deploying tool. Documentation for Fabric can be found here:
http://docs.fabfile.org/0.9/
"""
from __future__ import with_statement
import logging
import os.path
import time
from fabric.api import cd, env, prompt, require, run, abort
from fabric.state import _get_system_username

# Hostname for each role.
env.roledefs = {
    'dev': ['kkbdeploy@halla.dbc.dk'],
    'stg': ['kkbdeploy@hiri.dbc.dk'],
    'prod': ['kkbdeploy@hiri.dbc.dk'],
}

BUILD_PATH = '/home/kkbdeploy/build'

# Simple logging for actions. Use the WARNING level to tune out paramiko
# noise which is logged as "INFO".
LOG_FILENAME = '/var/log/deploy.log'
logging.basicConfig(filename=LOG_FILENAME,level=logging.WARNING, format="%(asctime)s - %(levelname)s - %(message)s")

def _env_settings(project):
    """ Set global environment settings base on CLI args. """
    env.role = env.get('roles', ['dev'])[0]
    env.project = project
    env.webroot = '/data/www/%s.%s.ting.dk' % (project, env.role)

def version(project):
    'Get the currently deployed version'
    _env_settings(project)
    require('user', 'hosts', 'webroot',
        used_for='These variables are used for finding the target deployment environment.',
    )
    with cd(os.path.join(BUILD_PATH, env.project, 'build')):
        run('git show | head -10')

def reload_apache():
    'Reload Apache on the remote machine'
    run('sudo /usr/sbin/apache2ctl graceful')

def sync_from_prod(project):
    """
    Sync the staging environment from production.

    Copies the production database and files to the staging site
    """
    _env_settings(project)

    if env.get('roles') != ['stg']:
        abort('sync_from_prod is not supported for non-stg roles.')

    run('mysqldump drupal6_ding_%s_prod | mysql drupal6_ding_%s_stg' % (env.project, env.project))
    run('sudo rsync -avmCF --delete /data/www/%(name)s.prod.ting.dk/files/ /data/www/%(name)s.stg.ting.dk/files/' % {'name': env.project})

def deploy(project, commit=None):
    """ Deploy a specific version in the specified environment. """
    version(project)

    # Prompt for the commit ID if not given as a parameter.
    if not commit:
        commit = prompt('Enter commit to deploy (40 character SHA1)',
            validate=r'^[0-9a-fA-F]{6,40}$')

    require('user', 'hosts', 'webroot', 'role',
        used_for='These variables are used for finding the target deployment environment.',
    )

    make_path = time.strftime('ding-%Y%m%d%H%M')[:-1]
    cwd = os.path.join(BUILD_PATH, env.project, 'build')
    abs_make_path = os.path.join(cwd, make_path)

    with cd(cwd):
        # Update git checkout.
        run('git fetch')
        run('git checkout %s' % commit)

        # Run the build process via drush make.
        logging.info('Starting build in %s' % abs_make_path)
        run('./ding_build.py -lL %s -m profile %s' % (env.role, make_path))

    run('curl -s http://localhost/apc_clear_cache.php')

    logging.warning('%(site)s | %(user)s | %(commit)s' % {
        'site': env.webroot.split('/')[-1],
        'user': _get_system_username(),
        'commit': commit[0:7],
    })

