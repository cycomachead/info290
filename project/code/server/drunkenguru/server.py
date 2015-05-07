from twisted.web.server import Site
from twisted.web.wsgi import WSGIResource
from twisted.internet import reactor
from main import *

if __name__ == '__main__':
    resource = WSGIResource(reactor, reactor.getThreadPool(), app)
    site = Site(resource)
    reactor.listenTCP(80, site, interface="172.31.24.236")
    reactor.run()
