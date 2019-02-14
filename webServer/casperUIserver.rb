
# the order in which files are required may be significant - or maybe not (e.g. classUpdates before classPstore, serverSmtp before classEmail)

require "sinatra/base"
require "haml"
#require "json"
#require "yaml"

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

class RchainUI < Sinatra::Base

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# the following (outside any sinatra-specific block) should be accessible to all sinatra-specific blocks

$\ = "\n"   # appended to output of print()
#DEFAULT_CONFIG_FILE = ""

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# run once at sinatra startup before any http requests are processed
# command line options: optional single argument specifying config.yaml file name

configure {
   # the following override defaults for modular sinatra apps, i.e. those that subclass Sinatra::Base
   set( :app_file, __FILE__ )    # specifies root directory for the website (the directory containing this file)
   set( :run,      true     )    # start the default web server after loading this sinatra app (webrick for ruby1.9.2)
   set( :logging,  true     )    # enable logging to stderr

   #config = YAML.load_file( ARGV[ 0 ] || DEFAULT_CONFIG_FILE )
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# methods available to all route bodies (define methods using standard def-end block)

helpers {
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# request body: empty
# reply body: full screen html+css+js

get( "/" ) {
   rchainE = Haml::Engine.new( File.read( "rchainUI.haml" ), { format: :xhtml } )
   html = rchainE.render()   # other options needed if passing ruby variables to the haml template
   print( html )
   html
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# secondary files at the top level

get( %r{^/(.+\.(css|js|png))$} ) { | filename, extension |   # second set of parens is grouping for file extension alternatives
   send_file( filename )
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# invalid routes

%i[ get put post delete patch options ].each { | method |
   send( method, "*" ) { | invalidRoute |
      errMsg = "invalid route: #{ method.upcase } #{ invalidRoute }"
      print( "\n%s\n", errMsg )   # print error message to console
      [ 400, [ errMsg ] ]         # rack-compatible return value; the body (second) element must respond to each()
   }
}

#################################################################################

run!   # runs the web server (required for modular sinatra apps, i.e. those that subclass Sinatra::Base)

end    # class RchainUI
