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

from os import chdir
from sys import stdout, stderr
import logging
import logging.handlers
from subprocess import Popen, PIPE, STDOUT
from pyinotify import WatchManager, Notifier, ProcessEvent, IN_ATTRIB

# Configure a little bit of logging so we can see what's going on.
LOG_FILENAME = '/home/kkbdeploy/logs/gitte.log'

def get_logger():
    """
    Set up a an instance of Python's standard logging utility.
    """
    logger = logging.getLogger('logger')
    logger.setLevel(logging.INFO)
    trfh = logging.handlers.TimedRotatingFileHandler(LOG_FILENAME, 'D', 1, 5)
    trfh.setFormatter(logging.Formatter("%(asctime)s | %(levelname)s | %(message)s"))
    logger.addHandler(trfh)
    return logger

logger = get_logger()

class ProcessGitUpdates(ProcessEvent):
    """
    Processor of Git updates.
    """
    def process_IN_ATTRIB(self, event):
        logger.info('%s was touched.' % event.name)
        update_git_checkout(event.name.split('-')[0])


def update_git_checkout(name):
    """
    Update the Git checkouts.
    """
    dirnames = {
        'kkb': '/home/kkbdeploy/sites/kkb.dev.gnit.dk',
        'aakb': '/home/kkbdeploy/sites/aakb.dev.gnit.dk',
        'kolding': '/home/kkbdeploy/sites/kolding.dev.gnit.dk',
        'kbhlyd': '/home/kkbdeploy/sites/kbhlyd.dev.gnit.dk',
        'ding': '/data/www/code.ting.dk/repos/ding6',
    }

    if dirnames.has_key(name):
        messages = ''
        p = Popen(['git', 'pull'], cwd=dirnames[name], stdout=PIPE, stderr=STDOUT)
        logger.info('Git command output: %s' % p.communicate()[0])
        p = Popen(['git', 'submodule', 'init'], cwd=dirnames[name], stdout=PIPE, stderr=STDOUT)
        logger.info('Git command output: %s' % p.communicate()[0])
        p = Popen(['git', 'submodule', 'update'], cwd=dirnames[name], stdout=PIPE, stderr=STDOUT)
        logger.info('Git command output: %s' % p.communicate()[0])


wm = WatchManager()
notifier = Notifier(wm, ProcessGitUpdates())

# Watch for when writable file is closed.
wm.add_watch('/data/www/default/github', IN_ATTRIB)

notifier.loop(daemonize=True, pid_file='/tmp/gitte.pid', force_kill=True)

