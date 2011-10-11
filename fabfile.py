"""
Ding deploy script.

It uses the Fabric deploying tool. Documentation for Fabric can be found here:
http://docs.fabfile.org/
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
    'metropol:stg': ['deploy@haruna.dbc.dk'],
    'metropol:prod': ['deploy@haruna.dbc.dk'],
    'aabenraa:stg': ['deploy@aabenraa.dbc.dk'],
    'aabenraa:prod': ['deploy@aabenraa.dbc.dk'],
    'kolding:dev': ['deploy@kolding.dbc.dk'],
    'kolding:stg': ['deploy@kolding.dbc.dk'],
    'kolding:prod': ['deploy@kolding.dbc.dk'],
    'billund:stg': ['deploy@billund.dbc.dk'],
    'billund:prod': ['deploy@billund.dbc.dk'],
    'roedovre:dev': ['deploy@roedovre.dbc.dk'],
    'roedovre:stg': ['deploy@roedovre.dbc.dk'],
    'roedovre:prod': ['deploy@roedovre.dbc.dk'],
    'helsbib:stg': ['deploy@helsingoer.dbc.dk'],
    'helsbib:prod': ['deploy@helsingoer.dbc.dk'],
    'albertslund:dev': ['deploy@albertslund.dbc.dk'],
    'albertslund:stg': ['deploy@albertslund.dbc.dk'],
    'albertslund:prod': ['deploy@albertslund.dbc.dk'],
}

env.webroot_patterns = {
    'default': '/data/www/%(project)s.%(role)s',
    'hiri.dbc.dk': '/data/www/%(project)s.%(role)s.ting.dk',
    'halla.dbc.dk': '/data/www/%(project)s.%(role)s.ting.dk',
}

# Simple logging for actions. Use the WARNING level to tune out paramiko
# noise which is logged as "INFO".
LOG_FILENAME = '/tmp/deploy.log'
logging.basicConfig(filename=LOG_FILENAME,level=logging.WARNING, format="%(asctime)s - %(levelname)s - %(message)s")

def _env_settings(project=None):
    """ Set global environment settings base on CLI args. """

    # Get the first role set, defaulting to dev.
    env.role = env.get('roles', ['dev'])[0]

    # If project was not set, extract it from the role.
    if not project:
        try:
            project, env.role = env.role.split(':')
        except ValueError:
            abort('No project in role and no project specified.')

    env.project = project
    env.build_path = os.path.join('/home', env.user, 'build')
    if env.host in env.webroot_patterns:
        env.webroot_pattern = env.webroot_patterns[env.host]
    else:
        env.webroot_pattern = env.webroot_patterns['default']
    env.webroot = env.webroot_pattern % {'project': project, 'role': env.role}

def version(project=None):
    'Get the currently deployed version'
    _env_settings(project)
    require('user', 'hosts', 'webroot',
        used_for='These variables are used for finding the target deployment environment.',
    )
    with cd(os.path.join(env.build_path, env.project, 'build')):
        run('git show | head -10')

def reload_apache():
    'Reload Apache on the remote machine'
    run('sudo /usr/sbin/apache2ctl graceful')

def sync_from_prod(project=None):
    """
    Sync the staging environment from production.

    Copies the production database and files to the staging site
    """
    _env_settings(project)

    if env.role != 'stg':
        abort('sync_from_prod is not supported for non-stg roles.')

    run('mysqldump drupal6_ding_%s_prod | mysql drupal6_ding_%s_stg' % (env.project, env.project))
    prodPath = env.webroot_pattern % {'project': project, 'role': 'prod'}
    stgPath = env.webroot_pattern % {'project': project, 'role': 'stg'}
    run('sudo rsync -avmCF --delete %(prod)s %(stg)s' % {
        'prod': os.path.join(prodPath, 'files'),
        'stg': os.path.join(stgPath, 'files')
    })

def deploy(project=None, commit=None):
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
    profile_path = os.path.join(env.build_path, env.project)
    abs_make_path = os.path.join(profile_path, 'build', make_path)

    with cd(profile_path):
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

