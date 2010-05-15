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

import logging
import logging.handlers
import os
import re
import socket
import stat
from subprocess import Popen, PIPE, STDOUT
from SocketServer import StreamRequestHandler, ThreadingUnixStreamServer

# Configure a little bit of logging so we can see what's going on.
HOME_PATH = os.path.abspath(os.path.expanduser('~'))
LOG_PATH = os.path.join(HOME_PATH, 'log')
BUILD_PATH = os.path.join(HOME_PATH, 'build')
SOCKET_FILENAME = '/tmp/gitte.sock'
INPUT_FILTER = re.compile('[^A-Za-z0-9_-]')

BUILD_PATHS = {
    'kkb': ('kkb',),
    'aakb': ('aakb',),
    'kolding': ('kolding',),
    'kbhlyd': ('kbhlyd',),
    'ding': ('ding.api', 'ding.dev', 'ding.ting012'),
}


class GitPingHandler(StreamRequestHandler):
    """
    Handles requests to the socket server.

    Recieves messages via socket from the PHP script that handles Github
    ping requests.
    """
    def handle(self):
        self.data = INPUT_FILTER.sub('', self.request.recv(256).strip())
        logger.info('Got message: %s' % self.data)
        self.request.send('OK: %s' % self.data)

        if self.data in BUILD_PATHS:
            for name in BUILD_PATHS[self.data]:
                path = os.path.join(BUILD_PATH, name)
                run_command(('git', 'pull'), path)
                run_command(('./ding_build.py', '-q'),
                            os.path.join(path, 'build'))

def configure_logging():
    """
    Set up a an instance of Python's standard logging utility.
    """
    logger = logging.getLogger('gitte')
    logger.setLevel(logging.INFO)

    if os.path.isdir(LOG_PATH):
        log_file = os.path.join(LOG_PATH, 'gitte.log')
        trfh = logging.handlers.TimedRotatingFileHandler(log_file, 'D', 1, 5)
        trfh.setFormatter(logging.Formatter(
            "%(asctime)s | %(levelname)s | %(message)s"
        ))
        logger.addHandler(trfh)
    else:
        logger.error('Log dir does not exist: %s' % log_path)

    return logger

def run_command(command, path):
    """ Runs an arbitrary command in a specific folder. """
    logger = logging.getLogger('gitte')
    proc = Popen(command, cwd=path, stdout=PIPE, stderr=STDOUT)
    message = proc.communicate()[0]

    if message:
        logger.info('%s: %s' % (path, message))

if __name__ == '__main__':
    logger = configure_logging()

    # Socket server creates its own socket file. Delete if it exists already.
    if os.path.exists(SOCKET_FILENAME):
        logger.warning('Unlinking existing socket: %s' % SOCKET_FILENAME)
        os.unlink(SOCKET_FILENAME)

    server = ThreadingUnixStreamServer(SOCKET_FILENAME, GitPingHandler)

    os.chmod(SOCKET_FILENAME, 0777)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        os.unlink(SOCKET_FILENAME)
        print "\nKeyboard interupt recieved, Gitte server stopping..."

