#!/usr/bin/env python
"""
Build script for Ding.

Utilises Drush make to build a site or install profile based on Ding.
"""

from optparse import OptionParser
from subprocess import Popen, PIPE, STDOUT
import logging
import os.path
import shutil
import sys

def parse_args():
    """ Configure and run optparse to parse commandline parameters """
    parser = OptionParser(usage='usage: %prog [-dDhlqv -L prefix -m MODE] [MAKE_PATH]')
    parser.add_option("-d", "--debug",
                      action="store_true", dest="debug", default=False,
                      help="run script in debug mode, very verbose output.")
    parser.add_option("-D", "--developer",
                      action="store_true", dest="developer", default=False,
                      help="build developer copy, using authenticated Git repositories.")
    parser.add_option("-l", "--create_symlinks",
                      action="store_true", dest="create_symlinks", default=False,
                      help="create symlinks - latest pointing to the build performing to, and previous pointing to whatever latest was pointing to before.")
    parser.add_option("-L", "--symlink-prefix",
                      action="store", dest="symlink_prefix", default='',
                      help="prefix the symlinks provided by -l with this string")
    parser.add_option("-m", "--mode",
                      action="store", dest="mode", default='site',
                      help="what build mode to use. 'site' for full Drupal site, 'profile' for just the installation profile. Default is 'site'.")
    parser.add_option("-v", "--verbose",
                      action="store_true", dest="verbose", default=True,
                      help="make lots of noise [default]")
    parser.add_option("-q", "--quiet",
                      action="store_false", dest="verbose", default=True,
                      help="don't print status messages to stdout")

    return parser.parse_args()


def configure_logging(options):
    """
    Set up a an instance of Python's standard logging utility.
    """
    if options.debug:
        level = logging.DEBUG
    elif options.verbose:
        level = logging.INFO
    else:
        level = logging.WARNING

    logging.basicConfig(level=level, datefmt="%H:%M:%S",
                        format='%(levelname)s: %(message)s (%(asctime)s)')

def make_command(options, make_path):
    """ Generate the make command based on current options. """
    # Set command based on mode.
    if options.mode == 'site':
        command = ['drush.php', 'make', '--contrib-destination=profiles/ding', 'ding.make', make_path]
    elif options.mode == 'profile':
        command = ['drush.php', 'make', '--no-core', '--contrib-destination=.', 'ding.make', make_path]
    else:
        sys.exit('Unknown mode "%s", aborting.' % options.mode)

    # Add debug or quiet flag based on our debug setting.
    if options.debug:
        command.insert(1, '-d')
    elif options.verbose:
        command.insert(1, '-v')
    else:
        command.insert(1, '-q')

    # For developers, keep SCM checkouts.
    if options.developer:
        command.insert(3, '--working-copy')

    return command

def start_make(command):
    """ Run make command as generated by make_command() """
    try:
        proc = Popen(command)
    except OSError:
        sys.exit('Could not run %s - is it available in your path?' % command[0])

    proc.wait()

    if proc.returncode == 0:
        logging.info('Finished Drush make sucessfully')
        return True

def setup_profile(options, make_path):
    """
    Setup the make product as a Drupal install profile.

    Handles copying the profile file into the correct folder.
    """
    if options.mode == 'site':
        path = os.path.join(make_path, 'profiles', 'ding')
    else:
        path = make_path

    shutil.copy('ding.profile', path)

def create_symlinks(options, make_path):
    """
    Set up symlinks to latest and previous build.
    """
    if options.symlink_prefix:
        latest = '%s-latest' % options.symlink_prefix
        previous = '%s-previous' % options.symlink_prefix
    else:
        latest = 'latest'
        previous = 'previous'

    # Revome previous symlink, if it exists.
    if os.path.lexists(previous):
        os.unlink(previous)

    # If there is already a latest symlink, rename it to previous.
    if os.path.lexists(latest):
        os.rename(latest, previous)

    # Set up a link from our completed build to the new one.
    os.symlink(make_path, latest)

def main():
    """ Main function, run when the script is run stand-alone. """
    (options, args) = parse_args()
    configure_logging(options)

    if args:
        make_path = args[-1]
    else:
        make_path = 'ding'

    logging.info('Starting make for mode "%s" in folder "%s"' % (options.mode, make_path))
    success = start_make(make_command(options, make_path))

    if success:
        setup_profile(options, make_path)
        if options.create_symlinks:
            create_symlinks(options, make_path)
    else:
        logging.error('Build FAILED for mode "%s" in folder "%s"' % (options.mode, make_path))

if __name__ == '__main__':
    main()

