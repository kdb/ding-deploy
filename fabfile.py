"""
Ding deploy script.

It uses the Fabric deploying tool. Documentation for Fabric can be found here:
http://docs.fabfile.org/0.9/
"""

def kkb_dev():
  'Initialize development environment'
  config.env = 'dev'
  config.fab_user = 'kkbdeploy'
  config.fab_hosts = ['halla.dbc.dk']
  config.webroot = '/data/www/kkb.dev.gnit.dk'

def aakb_dev():
  'Initialize development environment'
  config.env = 'dev'
  config.fab_user = 'kkbdeploy'
  config.fab_hosts = ['halla.dbc.dk']
  config.webroot = '/data/www/aakb.dev.gnit.dk'

def kolding_dev():
  'Initialize development environment'
  config.env = 'dev'
  config.fab_user = 'kkbdeploy'
  config.fab_hosts = ['halla.dbc.dk']
  config.webroot = '/data/www/kolding.dev.gnit.dk'

def kkb_stg():
  'Initialize staging environment'
  config.env = 'kkb_stg'
  config.fab_user = 'kkbdeploy'
  config.fab_hosts = ['hiri.dbc.dk']
  config.webroot = '/data/www/kkb.stg.gnit.dk'

def aakb_stg():
  'Initialize staging environment'
  config.env = 'aakb_stg'
  config.fab_user = 'kkbdeploy'
  config.fab_hosts = ['hiri.dbc.dk']
  config.webroot = '/data/www/aakb.stg.gnit.dk'

def kolding_stg():
  'Initialize staging environment'
  config.env = 'kolding_stg'
  config.fab_user = 'kkbdeploy'
  config.fab_hosts = ['hiri.dbc.dk']
  config.webroot = '/data/www/kolding.stg.gnit.dk'

def kkb_prod():
  'Initialize production environment'
  config.env = 'kkb_prod'
  config.fab_user = 'kkbdeploy'
  config.fab_hosts = ['hiri.dbc.dk']
  config.webroot = '/data/www/kkb.prod.gnit.dk'

def aakb_prod():
  'Initialize production environment'
  config.env = 'aakb_prod'
  config.fab_user = 'kkbdeploy'
  config.fab_hosts = ['hiri.dbc.dk']
  config.webroot = '/data/www/aakb.prod.gnit.dk'

def kolding_prod():
  'Initialize production environment'
  config.env = 'kolding_prod'
  config.fab_user = 'kkbdeploy'
  config.fab_hosts = ['hiri.dbc.dk']
  config.webroot = '/data/www/kolding.prod.gnit.dk'

def version():
  'Get the current version'
  require('fab_hosts', 'fab_user', 'webroot',
    used_for='finding the target deployment environment.',
  )
  run('cd $(webroot); git show | head -5')

def reload_apache():
  'Reload Apache on the remote machine'
  run('sudo /usr/sbin/apache2ctl graceful')

def deploy():
  'Push a specific version to the specified environment'
  invoke('version')
  prompt('commit', 'Enter commit to deploy (40 character SHA1)',
      validate=r'^[0-9a-fA-F]{40}$')
  run('cd $(webroot); git fetch ; git checkout $(commit) ; git submodule init ; git submodule update')
  run('curl -s http://localhost/apc_clear_cache.php')
  local("echo `date` $(env) $USER $(commit) >> /var/log/deploy.log")


