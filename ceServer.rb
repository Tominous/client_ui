
# command line: optional single argument specifying yaml config file name
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
# wraps a frequently used error response including creation of the corresponding json

class CEexcept < StandardError

   attr_reader( :message, :payload )

   def initialize( message, payload = { } )
      @message = message
      @payload = {
         status:  false,
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

configure {
   # the following override defaults for modular sinatra apps, i.e. those that subclass Sinatra::Base
   set( :app_file, __FILE__ )   # specifies root directory for the website (the directory containing this file)
   set( :run,      true     )   # start the default/internal web server after loading this sinatra app (webrick for ruby1.9+)

   config = YAML.load_file( ARGV[ 0 ] || DEFAULT_CONFIG_FILE )   # TODO: check for valid config file format

   set( :bind, "0.0.0.0" ) if config[ "mode" ] == "remote"       # do not set if server is being accessed at localhost
   set( :port, config[ "serverPort" ] )                          # fyi: the default port for sinatra is 4567
   set( :http, Net::HTTP.new( config[ "envoyAddress" ], config[ "envoyPort" ] ) )
   set( :assetRoot, config[ "assetRoot" ] )                      # root directory for css, js, images, etc.
   set( :store,     config[ "storeRoot" ] + "/" + config[ "store" ] )
   set( :account16, config[ "masterAccount" ] )
   set( :account64, Base64.strict_encode64( Base16.decode16( config[ "masterAccount" ] ) ) )

   @@store = YAML.load_file( settings.store )

   modified = false   # if store is missing any required elements, initialize them and write them back

   %w[ accounts payment session savedDeploys savedQueries ].each { | element |
      next if @@store.has_key?( element )
      @@store[ element ] = [ ]
      modified = true
   }

   if modified
      File.open( settings.store, "w" ) { | f |
         YAML.dump( @@store, f )
      }
   end

   %w[ payment session ].each { | dir |          # load current contents of contract libraries (which are saved in directories)
      dir2 = config[ "storeRoot" ] + "/" + dir
      set( ( dir + "Lib" ).to_sym, dir2 )

      if Dir.exists?( dir2 )
         @@store[ dir ] = Dir.entries( dir2 ) - [ ".", ".." ]   # TODO: remove trailing ".*" from filenames?
      else
         Dir.mkdir( dir2 )                       # create the directory if it doesn't exist
         @@store[ dir ] = [ ]
         print( "\n>>> creating directory ", dir2 )
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
         address:   settings.account64,
         timestamp: ( Time.now.to_f * 1000.0 ).round,
         session: {
            code: File.read( "session/#{ session }" ),
            args: "",
         },
         payment: {
            code: File.read( "payment/#{ payment }" ),
            args: "",
         },
         gasLimit:      1000000000,
         gasPrice:      0,
         nonce:         0,
         sigAlgorithm: "",
         signature:    ""
      }

      response = settings.http.send_request( "PUT", "/deploy", deploy.to_json )   # deploy
      print( ">> #{ name } deploy response: ", response.body ) if @@debug
      raise( CEexcept.new( "deploy failed: " + response.body ) ) unless response.body.match( /"success": *true/ )
      response = settings.http.send_request( "POST", "/block" )                # propose
      print( ">> #{ name } propose response: ", response.body ) if @@debug
      raise( CEexcept.new( "propose failed: " + response.body ) ) unless response.body.match( /"success": *true/ )
   end

   #--- 120 characters -------------------------------------------------------------------------------------------------
}

#--- 120 characters ----------------------------------------------------------------------------------------------------

get( "/" ) {
   send_file( settings.assetRoot + "/index.html" )
}

#--- 120 characters ----------------------------------------------------------------------------------------------------
# called onload to get app's persistent data

get( "/store" ) {     # TODO: remove when no longer needed for debug
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
      payload[ element ] = @@store[ element ].map { | contractFile |
         contractName = contractFile.match( /(.+)\.wasmBase64/ )
         ( contractName.nil? ) ? contractFile : contractName[ 1 ]
      }
   }

   %w[ savedDeploys savedQueries ].each { | element |
      payload[ element ] = @@store[ element ]
   }

   payload.to_json
}

#--- 120 characters ----------------------------------------------------------------------------------------------------
# assets: css, js, images, etc.

get( %r[(/.+)] ) { | path |                 # get anything other than / or /data
   send_file( settings.assetRoot + path )   # path includes leading /
}

#--- 120 characters ----------------------------------------------------------------------------------------------------
# generate new key pair and create new account (currently does not create accounts on the node)

post( "/account" ) {
   begin
      req   = JSON.parse( request.body.read )
      valid = req.has_key?( "name" ) && req.has_key?( "balance" )   # TODO: check that balance >0?
      raise( CEexcept.new( "post /account request missing one or more of 'name', 'balance'", { publicKey: "" } ) ) unless valid

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
# i think you can figure this one out on your own

delete( "/account" ) {
   begin
      req   = JSON.parse( request.body.read )
      valid = req.has_key?( "name" )
      raise( CEexcept.new( "delete /account request missing 'name'" ) ) unless valid

      index = @@store[ "accounts" ].find_index { | hash |
         hash[ "name" ] == req[ "name" ]
      }

      raise( CEexcept.new( "account '#{ req[ "name" ] }' does not exist" ) ) if index.nil?
      @@store[ "accounts" ].delete_at( index )

      File.open( settings.store, "w" ) { | f |
         YAML.dump( @@store, f )
      }

      {
         status:    true,
         message:   "success"
      }.to_json

   rescue CEexcept => except
      print( "\n**** #{ except.message }: #{ req }\n" )   # print error message to console
      [ 400, [ except.payload ] ]   # rack-compatible return value; the body (second) element must respond to each()
   end
}

#--- 120 characters ----------------------------------------------------------------------------------------------------
# store contract in contract library

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

      File.write( "#{ req[ "type" ] }/#{ req[ "name" ] }.wasmBase64", req[ "wasm" ] )   # overwrites any existing file; indicate overwrite in message?
      @@store[ req[ "type" ] ] << req[ "name" ]

      File.open( settings.store, "w" ) { | f |
         YAML.dump( @@store, f )
      }

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
#
post( "/contract/save" ) {
   begin
      req   = JSON.parse( request.body.read )
      valid = req.has_key?( "name" ) && req.has_key?( "payment" ) && req.has_key?( "session" )
      raise( CEexcept.new( "post /contract/save request missing one or more of 'name', 'payment', 'session'" ) ) unless valid

      %w[ paymentArgs sessionArgs ].each { | element |        # initialize these optional elements if not present
         req[ element ] = "" unless req.has_key?( element )
      }

      @@store[ "savedDeploys" ].delete_if { | element |
         element[ "name" ] == req[ "name" ]
      }

      @@store[ "savedDeploys" ] << req

      File.open( settings.store, "w" ) { | f |
         YAML.dump( @@store, f )
      }

      {
         status:    true,
         message:   "success"
      }.to_json

   rescue CEexcept => except
      print( "\n**** #{ except.message }: #{ req }\n" )   # print error message to console
      [ 400, [ except.payload ] ]   # rack-compatible return value; the body (second) element must respond to each()
   end
}

#--- 120 characters ----------------------------------------------------------------------------------------------------
#
post( "/contract/deploy" ) {
   begin
      req   = JSON.parse( request.body.read )
      valid = req.has_key?( "payment" ) && req.has_key?( "session" ) && req.has_key?( "account" )
      raise( CEexcept.new( "post /contract request missing one or more of 'payment', 'session', 'account'" ) ) unless valid
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
# i think you can figure this one out on your own

delete( "/contract" ) {
   begin
      req   = JSON.parse( request.body.read )
      valid = req.has_key?( "name" ) && req.has_key?( "type" )
      raise( CEexcept.new( "delete /account request missing one or more of 'name', 'type'" ) ) unless valid
      valid = %w[ payment session ].include?( req[ "type" ] )
      raise( CEexcept.new( "put /contract request 'type' property must be 'payment' or 'session'" ) ) unless valid
      found = @@store[ req[ "type" ] ].delete( req[ "name" ] + ".wasmBase64" )
      raise( CEexcept.new( "#{ req[ "type" ] } contract '#{ req[ "name" ] }' does not exist" ) ) if found.nil?

      File.open( settings.store, "w" ) { | f |
         YAML.dump( @@store, f )
      }

      {
         status:    true,
         message:   "success"
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
   send_file( settings.assetRoot + "/images/favicon.ico" )
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
