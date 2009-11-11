"""
Ding deploy script.

It uses the Fabric deploying tool. Documentation for Fabric can be found here:
http://docs.fabfile.org/0.9/
"""
from __future__ import with_statement
import logging
import logging.handlers
from fabric.api import cd, env, prompt, require, run
from fabric.state import _get_system_username

# Hostnames to the different servers.
DEPLOY_HOSTS = {
    'dev': 'kkbdeploy@halla.dbc.dk',
    'stg': 'kkbdeploy@hiri.dbc.dk',
    'prod': 'kkbdeploy@hiri.dbc.dk',
}

# Simple logging for actions. Use the WARNING level to tune out paramiko
# noise which is logged as "INFO".
LOG_FILENAME = '/var/log/deploy.log'
logging.basicConfig(filename=LOG_FILENAME,level=logging.WARNING, format="%(asctime)s - %(levelname)s - %(message)s")

def kkb_dev():
    'Initialize development environment'
    env.hosts = [DEPLOY_HOSTS['dev']]
    env.webroot = '/data/www/kkb.dev.gnit.dk'

def aakb_dev():
    env.hosts = [DEPLOY_HOSTS['dev']]
    env.webroot = '/data/www/aakb.dev.gnit.dk'

def kolding_dev():
    env.hosts = [DEPLOY_HOSTS['dev']]
    env.webroot = '/data/www/kolding.dev.gnit.dk'

def kkb_stg():
    env.hosts = [DEPLOY_HOSTS['stg']]
    env.webroot = '/data/www/kkb.stg.gnit.dk'

def aakb_stg():
    env.hosts = [DEPLOY_HOSTS['stg']]
    env.webroot = '/data/www/aakb.stg.gnit.dk'

def kolding_stg():
    env.hosts = [DEPLOY_HOSTS['stg']]
    env.webroot = '/data/www/kolding.stg.gnit.dk'

def kkb_prod():
    env.hosts = [DEPLOY_HOSTS['prod']]
    env.webroot = '/data/www/kkb.prod.gnit.dk'

def aakb_prod():
    env.hosts = [DEPLOY_HOSTS['prod']]
    env.webroot = '/data/www/aakb.prod.gnit.dk'

def kolding_prod():
    env.hosts = [DEPLOY_HOSTS['prod']]
    env.webroot = '/data/www/kolding.prod.gnit.dk'

def kbhlyd_prod():
    env.hosts = [DEPLOY_HOSTS['prod']]
    env.webroot = '/data/www/kbhlyd.prod.gnit.dk'

def version():
    'Get the currently deployed version'
    require('user', 'hosts', 'webroot',
        used_for='These variables are used for finding the target deployment environment.',
    )
    with (cd(env.webroot)):
        run('git show | head -5')

def reload_apache():
    'Reload Apache on the remote machine'
    run('sudo /usr/sbin/apache2ctl graceful')

def deploy():
    'Push a specific version to the specified environment'
    version()
    commit = prompt('Enter commit to deploy (40 character SHA1)',
        validate=r'^[0-9a-fA-F]{40}$')

    with (cd(env.webroot)):
        run('git fetch')
        run('git checkout %s' % commit)
        run('git submodule init')
        run('git submodule update')

    run('curl -s http://localhost/apc_clear_cache.php')

    logging.warning('%(site)s | %(user)s | %(commit)s' % {
        'site': env.webroot.split('/')[-1],
        'user': _get_system_username(),
        'commit': commit[0:7],
    })

