#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Git checkout updating script.

Works together with a PHP script to update Git repositories based on pings
from github.com or similar git hosting services.

This is currently accomplished by way of the PHP script touch'ing files
when it receives a ping and this script looking for these pings via
inotify. This will be refactored to use named pipes instead when time permits.
"""

import os.path
import logging
import logging.handlers
from subprocess import Popen, PIPE, STDOUT
from pyinotify import WatchManager, Notifier, ProcessEvent, IN_ATTRIB

# Configure a little bit of logging so we can see what's going on.
LOG_PATH = '~/log'

DIRNAMES = {
    'kkb': '/home/kkbdeploy/sites/kkb.dev.gnit.dk',
    'aakb': '/home/kkbdeploy/sites/aakb.dev.gnit.dk',
    'kolding': '/home/kkbdeploy/sites/kolding.dev.gnit.dk',
    'kbhlyd': '/home/kkbdeploy/sites/kbhlyd.dev.gnit.dk',
    'ding': ('/home/kkbdeploy/sites/ding6_api',
             '/home/kkbdeploy/sites/ding.dev.ting.dk',
             '/home/kkbdeploy/sites/ting012.dev.ting.dk'),
}

GIT_COMMANDS = (
    ('git', 'pull'),
    ('git', 'submodule', 'init'),
    ('git', 'submodule', 'update'),
)

def configure_logging():
    """
    Set up a an instance of Python's standard logging utility.
    """
    log_instance = logging.getLogger('gitte')
    log_instance.setLevel(logging.INFO)

    # The logging handler does not resolve the path, so we do it
    # manually before setting the handler up.
    log_path = os.path.abspath(os.path.expanduser(LOG_PATH))
    if os.path.isdir(log_path):
        log_file = os.path.join(log_path, 'gitte.log')
        trfh = logging.handlers.TimedRotatingFileHandler(log_file, 'D', 1, 5)
        trfh.setFormatter(logging.Formatter(
            "%(asctime)s | %(levelname)s | %(message)s"
        ))
        log_instance.addHandler(trfh)
    else:
        log_instance.error('Log dir does not exist: %s' % log_path)

    return log_instance


class ProcessGitUpdates(ProcessEvent):
    """ pyinotify event processor. """
    def process_IN_ATTRIB(self, event):
        """
        Process when file attributes are changed.

        This happen every time the file is touched.
        """
        logger = logging.getLogger('gitte')
        logger.info('%s was touched.' % event.name)
        name = event.name.split('-')[0]

        if name in DIRNAMES:
            # Single dir for name, value is just a string.
            if isinstance(DIRNAMES[name], basestring):
                update_git_checkout(DIRNAMES[name])
            # If value is iterable, get each dirname and update it.
            elif hasattr(DIRNAMES[name], '__iter__'):
                for dirname in DIRNAMES[name]:
                    update_git_checkout(dirname)


def update_git_checkout(dirname):
    """ Performs git update on given dirname """
    logger = logging.getLogger('gitte')
    for command in GIT_COMMANDS:
        proc = Popen(command, cwd=dirname, stdout=PIPE, stderr=STDOUT)
        message = proc.communicate()[0]

        if message:
            logger.info('%s: %s' % (dirname, message))

def wait_for_change():
    """
    Start watching a dir for changes and process them when they occur.
    """
    wtchmmgr = WatchManager()
    notifier = Notifier(wtchmmgr, ProcessGitUpdates())

    # Watch for when writable file is closed.
    wtchmmgr.add_watch('/data/www/default/github', IN_ATTRIB)

    notifier.loop(daemonize=True, pid_file='/tmp/gitte.pid', force_kill=True)

if __name__ == '__main__':
    configure_logging()
    wait_for_change()

