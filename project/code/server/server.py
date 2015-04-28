from twisted.web import server, resource, static
from twisted.internet import reactor, ssl
from twisted.python import log
import os
import tempfile

OUR_DOMAIN = "thedrunken.guru"

HTML = """
<!DOCTYPE html>
<html>
  <head>
    <title>TheDrunkenGuru</title>
    <link href="https://netdna.bootstrapcdn.com/twitter-bootstrap/2.3.1/css/bootstrap-combined.min.css" rel="stylesheet">
    <style>
      body {
        font-family: 'Gabriela', serif;
      }
      form {
        max-width: 650px;
        padding: 19px 29px 29px;
        margin: 15px auto 20px;
        -webkit-border-radius: 5px;
           -moz-border-radius: 5px;
                border-radius: 5px;
        -webkit-box-shadow: 0 1px 2px rgba(0,0,0,.05);
           -moz-box-shadow: 0 1px 2px rgba(0,0,0,.05);
                box-shadow: 0 1px 2px rgba(0,0,0,.05);
      }
      form label {
        margin: 0;
        padding: 0;
      }
      form form-heading,
      form input[type="text"],
      form input[type="password"] {
        font-size: 16px;
        height: auto;
        margin-bottom: 15px;
        padding: 7px 9px;
      }
      form textarea {
          width: 650px;
          height: 180px;
      }
      .title {
          margin: 10px;
          color: #fff;
          text-align: center;
      }
      .alert {
          margin: 75px auto 20px;
          width: 650px;
      }
      .main {
          width: 700px;
          text-align: center;
          margin: 100px auto;
      }
      h2 {
          font-size: 25px;
      }
    </style>

    <link href='https://fonts.googleapis.com/css?family=Bowlby+One' rel='stylesheet' type='text/css'>
    <link href='https://fonts.googleapis.com/css?family=Gabriela' rel='stylesheet' type='text/css'>
  </head>
  <body>
    <div class="main">
    <h1>TheDrunkenGuru</h1>
    <h2>Insights into the mind of a beer snob.</h2>

    <!-- BEER_INFO -->
    <!-- INFO -->

    <br /><br />
    </div>
    <script src="https://netdna.bootstrapcdn.com/twitter-bootstrap/2.3.1/js/bootstrap.min.js"></script>
  </body>
</html>
"""

HTML = HTML.replace("OUR_DOMAIN", OUR_DOMAIN)

BEER_INFO_REPLACE = "<!-- BEER_INFO -->"
ERROR_REPLACE = "<!-- INFO -->"
BEER_INFO_HTML = """ 

    <form name=input method="post">
    <div style="width: 500px; margin: auto; zoom: auto; overflow: auto;">
    <input type="text" name="beer_name" placeholder="Beer Name" style="float: left; ">
    <input type="text" name="brewery_name" placeholder="Brewery Name" style="float: left; margin-left: 25px;"><br>
    </div>
    <br>
    <button class="btn btn-large btn-primary" type="submit">Submit</button>
    </form>
"""

EXCEPTION = "UH OH! THERE WAS AN ERROR :("

REDIRECT = '<meta http-equiv="refresh" content="0; url=http://thedrunken.guru">'

def make_html(beer_info=True, error=None):
    try:
        ret = HTML
        if beer_info:
            ret = ret.replace(BEER_INFO_REPLACE, BEER_INFO_HTML)
    
        if error:
            ret = ret.replace(ERROR_REPLACE,  '<div class="alert alert-info">' + error + '</div>')

        return ret
    except:
        log.msg("EXCEPTION IN MAKE_HTML beer_info %s error %s" % (beer_info, error))
        return EXCEPTION


class Redirect(resource.Resource):
    isLeaf = True
    def render_GET(self, request):
        return REDIRECT

    def render_POST(self, request):
        return REDIRECT

class BeerInfo(resource.Resource):
    isLeaf = False
      
    def getChild(self, name, request):
        #if name == "cert-bg.png" or name == "budget-logo.png":
        #    return resource.Resource.getChild(self, name, request)
        if name == "":
            return self
        else: 
            return Redirect() 

    def render_GET(self, request):
        return make_html(True, None)

    def render_POST(self, request): 
        try:

            if (not "beer_name" in request.args) or (not "brewery_name" in request.args):
                return make_html(True, "ERROR, YOU DID NOT SUPPLY ALL REQUIRED FIELDS"); 

            beer_name = request.args["beer_name"][0]
            brewery_name = request.args["brewery_name"][0]

            return make_html(False, "You entered the beer: %s, from the brewery: %s"%(beer_name, brewery_name))

        except Exception as e:
            return make_html(False, EXCEPTION)


root = BeerInfo()
#root.putChild("cert-bg.png", static.File("/home/ubuntu/svcs/beer_infog_ca/cert-bg.png"))

nonSSLSite = server.Site(root)

reactor.listenTCP(80, nonSSLSite, interface="172.31.24.236")
reactor.run()
