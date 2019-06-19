
# TODO: make rescue clauses capture all exception classes

require "sinatra/base"
require "net/http"
require "json"
require "yaml"
require "base16"
require "base64"
require "openssl"

$\ = "\n"   # appended to output of print()

#### 120 characters ####################################################################################################

class CEexcept < StandardError

   attr_reader( :message, :payload )

   def initialize( message, payload = { } )
      @payload = {
         status: false,
         message: message
      }
      @payload.merge( payload )
      @payload = @payload.to_json
   end
end

#### 120 characters ####################################################################################################

class CasperExplorer < Sinatra::Base

#--- 120 characters ----------------------------------------------------------------------------------------------------
# the following (outside any sinatra-specific block) should be accessible to all sinatra-specific blocks

DEFAULT_CONFIG_FILE = "ceConfig.yaml"
@@debug = false

#--- 120 characters ----------------------------------------------------------------------------------------------------
# run once at sinatra startup before any http requests are processed
# command line options: optional single argument specifying config.yaml file name

configure {
   # the following override defaults for modular sinatra apps, i.e. those that subclass Sinatra::Base
   set( :app_file, __FILE__ )   # specifies root directory for the website (the directory containing this file)
   set( :run,      true     )   # start the default/internal web server after loading this sinatra app (webrick for ruby1.9+)
   # set( :logging,  true     )   # enable logging to stderr

   config = YAML.load_file( ARGV[ 0 ] || DEFAULT_CONFIG_FILE )   # TODO: check for valid config file format

   if config[ "mode" ] == "remote"
      set( :bind, "0.0.0.0" )                 # do not set if server is being accessed from localhost
      set( :port, config[ "serverPort"  ] )   # default port for sinatra is 4567
   end

   set( :assetRoot, config[ "assetRoot" ] )   # root directory for project files (for production mode; for development it's "root/public")
   set( :store,     config[ "storeRoot" ] + "/" + config[ "store" ] )
   set( :account,   Base64.strict_encode64( Base16.decode16( config[ "masterAccount" ] ) ) )

   @@store = YAML.load_file( settings.store )   # TODO: check store format correctness

   %w[ payment session ].each { | dir |
      if Dir.exists?( dir )
         @@store[ dir ] = Dir.entries( dir ) - [ ".", ".." ]   # remove trailing ".*" ?
      else
         Dir.mkdir( dir )
         @@store[ dir ] = [ ]
         print( "\n>>> creating #{ dir } directory" )
      end
   }
}

#--- 120 characters ----------------------------------------------------------------------------------------------------
# methods available to all route bodies (define methods using standard def-end block)

helpers {

   #--- 120 characters -------------------------------------------------------------------------------------------------

   def deploy( account, payment, paymentArgs, session, sessionArgs )   # deal with .wasmBas64 in filenames

      deploy = {
         user:      "",
         address:   settings.masterAccount,
         timestamp: ( Time.now.to_f * 1000.0 ).round,
         session: {
            code: settings.createSession,
            args: "",
         },
         payment: {
            code: settings.payment,
            args: "",
         },
         gasLimit:      1000000000,
         gasPrice:      0,
         nonce:         0,
         sigAlgorithm: "",
         signature:    ""
      }

      response = http.send_request( "PUT", "/deploy", deploy.to_json )   # deploy create contract
      print( ">> #{ name } deploy response: ", response.body )

      if response.body.match( /"success": *true/ )

         0.upto( count ) { | attempt |                   # iterate proposes due to round robin load balancer
            if attempt == 2 * count
               print( "**** #{ name } propose attempts exceeded" )
               exit
            end
            response = http.send_request( "POST", "/block" )              # propose create contract
            print( ">> #{ name } propose response (#{ attempt }): ", response.body ) if @@debug
            break if response.body.match( /"success": *true/ )
         }

      else
         print( "**** #{ name } deploy failed: ", response.body )
      end
   end

   #--- 120 characters -------------------------------------------------------------------------------------------------
}

#--- 120 characters ----------------------------------------------------------------------------------------------------

get( "/" ) {
   send_file( settings.assetRoot + "/index.html" )
}

#--- 120 characters ----------------------------------------------------------------------------------------------------
# support files at project level

get( %r[(/(assets|images)/.+)] ) { | path, dir |
   fname = settings.assetRoot + path
   send_file( fname )
}

get( "/store" ) {    # TEMP: for debug
   @@store.to_json
}

#--- 120 characters ----------------------------------------------------------------------------------------------------
# called onload to get app's persistent data

get( "/data" ) {
   payload = { }

   payload[ "accounts" ] = @@store[ "accounts" ].map { | hash |
      {
         name:      hash[ "name"   ],
         publicKey: hash[ "public" ]
      }
   }

   %w[ payment session ].each { | element |
      payload[ element ] = @@store[ element ].map { | hash |
         hash[ "name" ]
      }
   }

   payload.to_json
}

#--- 120 characters ----------------------------------------------------------------------------------------------------

post( "/account" ) {
   begin
      req   = JSON.parse( request.body.read )
      valid = req.has_key?( "name" ) && req.has_key?( "balance" )
      unless valid
         raise( CEexcept.new( "post /account request missing one or more of 'name', 'balance'", { publicKey: "" } ) )
      end

      @@store[ "accounts" ].delete_if { | element |
         element[ "name" ] == req[ "name" ]
      }

      rsaKey  = OpenSSL::PKey::RSA.new( 2048 )   # TODO: change to ed25519
      private = rsaKey.to_pem
      public  = rsaKey.public_key.to_pem

      @@store[ "accounts" ] << {
         "name"    => req[ "name" ],
         "public"  => public,
         "private" => private
      }

      File.open( settings.store, "w" ) { | f |
         YAML.dump( @@store, f )
      }

      {
         status:    true,
         message:   "success",
         publicKey: public
      }.to_json

   rescue CEexcept => except
      print( "\n**** #{ except.message }: #{ req }\n" )   # print error message to console
      [ 400, [ except.payload ] ]   # rack-compatible return value; the body (second) element must respond to each()
   end
}

#--- 120 characters ----------------------------------------------------------------------------------------------------

put( "/contract" ) {
   begin
      req   = JSON.parse( request.body.read )
      valid = req.has_key?( "name" ) && req.has_key?( "type" ) && req.has_key?( "wasm" )
      raise( CEexcept.new( "put /contract request missing one or more of 'name', 'type', 'wasm'" ) ) unless valid
      valid = %w[ payment session ].include?( req[ "type" ] )
      raise( CEexcept.new( "put /contract request 'type' property must be 'payment' or 'session'" ) ) unless valid

      @@store[ req[ "type" ] ].delete_if { | element |
         element == req[ "name" ]
      }

      File.write( req[ "type" ] + "/" + req[ "name" ] + ".wasmBase64", req[ "wasm" ] )   # overwrites any existing file; indicate overwrite in message?
      @@store[ req[ "type" ] ] << req[ "name" ]

      {
         status:  true,
         message: "success"
      }.to_json

   rescue CEexcept => except
      print( "\n**** #{ except.message }: #{ req }\n" )   # print error message to console
      [ 400, [ except.payload ] ]   # rack-compatible return value; the body (second) element must respond to each()
   end
}

#--- 120 characters ----------------------------------------------------------------------------------------------------

post( "/contract" ) {
   begin
      req   = JSON.parse( request.body.read )
      valid = req.has_key?( "payment" ) && req.has_key?( "session" ) && req.has_key?( "account" )
      unless valid
         msg = "post /contract request missing one or more of 'payment', 'paymentArgs', 'session', 'sessionArgs'"
         raise( CEexcept.new( msg ) )
      end
      out = settings.store.read( req[ "keyPairId" ] )
      raise( CEexcept.new( "keyPairId '#{ req[ "keyPairId" ] }' does not exist" ) ) unless out.status
      out = deploy( out.public, :payment, [ ], :createAccount, [ req[ "balance" ] ] )
      raise( CEexcept.new( out.msg ) ) unless out.status
      {
         status:    true,
         message:   "account create deploy accepted"
      }.to_json

   rescue CEexcept => except
      print( "\n**** #{ except.message }: #{ req }\n" )   # print error message to console
      [ 400, [ except.payload ] ]   # rack-compatible return value; the body (second) element must respond to each()
   end
}

#--- 120 characters ----------------------------------------------------------------------------------------------------

get( "/query" ) {
   begin
      req   = JSON.parse( request.body.read )
      valid = req.has_key?( "keyPairId" ) && req.has_key?( "balance" )
      raise( CEexcept.new( "post /account request missing one or more of 'keyPairId', 'balance'" ) ) unless valid
      out = settings.store.read( req[ "keyPairId" ] )
      raise( CEexcept.new( "keyPairId '#{ req[ "keyPairId" ] }' does not exist" ) ) unless out.status
      out = query( )
      raise( CEexcept.new( out.msg ) ) unless out.status
      {
         result: out.result,
      }.to_json

   rescue CEexcept => except
      print( "\n**** #{ except.message }: #{ req }\n" )   # print error message to console
      [ 400, [ except.payload ] ]   # rack-compatible return value; the body (second) element must respond to each()
   end
}

#--- 120 characters ----------------------------------------------------------------------------------------------------

get( "/favicon.ico" ) {
   send_file( settings.root + "/images/favicon.ico" )
}

#--- 120 characters ----------------------------------------------------------------------------------------------------
# invalid routes

%i[ get put post delete patch options ].each { | method |
   send( method, "*" ) { | invalidRoute |
      errMsg = "**** invalid route: #{ method.upcase } #{ invalidRoute }"
      printf( "\n%s\n", errMsg )   # print error message to console
      [ 400, [ errMsg ] ]          # rack-compatible return value; the body (second) element must respond to each()
   }
}

#### 120 characters ####################################################################################################

run!   # runs the web server (required for modular sinatra apps, i.e. those that subclass Sinatra::Base OR when using the built-in server?)

end    # class CasperExplorer
