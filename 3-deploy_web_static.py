#!/usr/bin/python3
"""
Fabric script based on the file 2-do_deploy_web_static.py that creates and
distributes an archive to the web servers
"""

from fabric.api import *
import os

env.hosts = ['xx-web-01', 'xx-web-02']

def do_pack():
    local("tar -cvzf versions/web_static_%s.tgz web_static" % (time.strftime("%Y%m%d%H%M%S")))
    return "versions/web_static_%s.tgz" % (time.strftime("%Y%m%d%H%M%S"))

def do_deploy(archive_path):
    if not os.path.exists(archive_path):
        return False
    put(archive_path, '/tmp/')
    filename = archive_path.split("/")[1]
    dirname = filename.split(".")[0]
    run("mkdir -p /data/web_static/releases/%s" % (dirname))
    run("tar -xzf /tmp/%s -C /data/web_static/releases/%s" % (filename, dirname))
    run("rm /tmp/%s" % (filename))
    run("mv /data/web_static/releases/%s/web_static/* /data/web_static/releases/%s" % (dirname, dirname))
    run("rm -rf /data/web_static/releases/%s/web_static" % (dirname))
    run("rm -rf /data/web_static/current")
    run("ln -s /data/web_static/releases/%s/ /data/web_static/current" % (dirname))
    return True

def deploy():
    archive_path = do_pack()
    if archive_path is None:
        return False
    return do_deploy(archive_path)
