
# command line: optional single argument specifying yaml config file name
# TODO: make rescue clauses capture all exception classes
# TODO: create class to manage contract libraries?

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
@@debug = true

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
   set( :storeRoot, config[ "storeRoot" ] )                      # root directory for store file and contract libraries
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

   %w[ payment session ].each { | type |          # load current contents of contract libraries (which are saved in directories)
      dir2 = settings.storeRoot + "/#{ type }Lib"

      if Dir.exists?( dir2 )
         @@store[ type ] = ( Dir.entries( dir2 ) - [ ".", ".." ] ).map { | file |
            base = file.match( /^(.+)\.wasmBase64$/ )
            ( base.nil? ) ? file : base[ 1 ]
         }
      else
         Dir.mkdir( dir2 )                       # create the directory if it doesn't exist
         @@store[ type ] = [ ]
         print( "\n>>> creating directory ", dir2 )
      end
   }
}

#--- 120 characters ----------------------------------------------------------------------------------------------------
# methods available to all route bodies (define methods using standard def-end block)

helpers {

   #--- 120 characters -------------------------------------------------------------------------------------------------

   def deploy( account, payment, paymentArgs, session, sessionArgs )   # deal with .wasmBas64 in filenames

      session = settings.storeRoot + "/sessionLib/#{ session }.wasmBase64"
      raise( CEexcept.new( "session contract does not exist: '#{ session }'" ) ) unless File.exist?( session )
      payment = settings.storeRoot + "/paymentLib/#{ payment }.wasmBase64"
      raise( CEexcept.new( "payment contract does not exist: '#{ payment }'" ) ) unless File.exist?( payment )

      unless sessionArgs.empty?      # this is a special case for single integer arguments
         map = %w[ A B C D E F G ]
         sessionArgs = "AQAAAAQAAAA" + map[ sessionArgs.to_i ] + "AAAA"
      end

      deploy = {
         user:      "",
         address:   settings.account64,                 # use hardwired account for now
         timestamp: ( Time.now.to_f * 1000.0 ).round,
         session: {
            code: File.read( session ),
            args: sessionArgs,
         },
         payment: {
            code: File.read( payment ),
            args: "",
         },
         gasLimit:      1000000000,
         gasPrice:      0,
         nonce:         0,
         sigAlgorithm: "",
         signature:    ""
      }

      response = settings.http.send_request( "PUT", "/deploy", deploy.to_json )   # deploy
      print( ">> deploy response: ", response.body ) if @@debug
      raise( CEexcept.new( "deploy failed: " + response.body ) ) unless response.body.match( /"success": *true/ )
      response = settings.http.send_request( "POST", "/block" )                # propose
      print( ">> propose response: ", response.body ) if @@debug
      raise( CEexcept.new( "propose failed: " + response.body ) ) unless response.body.match( /"success": *true/ )
      true
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

   %w[ payment session savedDeploys savedQueries ].each { | element |
      payload[ element ] = @@store[ element ]
   }

   payload.to_json
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
         status:  true,
         message: "success"
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

      file = "#{ settings.storeRoot }/#{ req[ "type" ] }Lib/#{ req[ "name" ] }.wasmBase64"
      File.write( file, req[ "wasm" ] )   # overwrites any existing file; TODO: indicate overwrite in message?
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

post( "/contract/save" ) {
   begin
      req   = JSON.parse( request.body.read )
      valid = req.has_key?( "name" ) && req.has_key?( "payment" ) && req.has_key?( "session" )
      raise( CEexcept.new( "post /contract/save request missing one or more of 'name', 'payment', 'session'" ) ) unless valid

      %w[ paymentArgs sessionArgs ].each { | element |        # initialize these optional elements if not present
         req[ element ] = "" unless req.has_key?( element )
      }

      @@store[ "savedDeploys" ].delete_if { | element |       # delete any existing saved deploy with the same name
         element[ "name" ] == req[ "name" ]
      }

      @@store[ "savedDeploys" ] << req

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
post( "/contract/deploy" ) {
   begin
      req   = JSON.parse( request.body.read )
      valid = req.has_key?( "account" ) && req.has_key?( "payment" ) && req.has_key?( "session" )
      raise( CEexcept.new( "post /contract request missing one or more of 'account', 'payment', 'session'" ) ) unless valid

      %w[ paymentArgs sessionArgs ].each { | element |        # initialize these optional elements if not present
         req[ element ] = "" unless req.has_key?( element )
      }

      deploy( req[ "account" ], req[ "payment" ], req[ "paymentArgs" ], req[ "session" ], req[ "sessionArgs" ] )

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
# i think you can figure this one out on your own

delete( "/contract" ) {
   begin
      req   = JSON.parse( request.body.read )
      valid = req.has_key?( "name" ) && req.has_key?( "type" )
      raise( CEexcept.new( "delete /contract request missing one or more of 'name', 'type'" ) ) unless valid

      if %w[ payment session ].include?( req[ "type" ] )
         file = "#{ settings.storeRoot }/#{ req[ "type" ] }Lib/#{ req[ "name" ] }.wasmBase64"
         raise( CEexcept.new( "#{ req[ "type" ] } contract file '#{ file }' does not exist" ) ) unless File.exist?( file )
         File.delete( file )
         found = @@store[ req[ "type" ] ].delete( req[ "name" ] )
         raise( CEexcept.new( "#{ req[ "type" ] } contract '#{ req[ "name" ] }' does not exist" ) ) if found.nil?
      elsif req[ "type" ] == "saved"
         index = @@store[ "savedDeploys" ].find_index { | hash |
            hash[ "name" ] == req[ "name" ]
         }
         raise( CEexcept.new( "saved deploy '#{ req[ "name" ] }' does not exist" ) ) if index.nil?
         @@store[ "savedDeploys" ].delete_at( index )
      else
         raise( CEexcept.new( "delete /contract request 'type' property must be one of 'payment', 'session', 'saved'" ) )
      end

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

get( "/query" ) {
   begin
      variant = params[ "keyVariant" ]   # these access the query string in the URL
      key     = params[ "keyBytes"   ]
      path    = params[ "path"       ]
      invalid = variant.empty? || key.empty? || path.empty?
      raise( CEexcept.new( "get /query missing one or more of 'keyVariant', 'keyBytes', 'path'", { result: "" } ) ) if invalid
      response = settings.http.send_request( "PUT", "/show/blocks", { depth: 1 }.to_json )   # get most recent block
      print( ">> showBlocks response: ", response.body ) if @@debug
      blockHash = response.body.match( /"blockHash": *"([^"]+)"/ )   # returns an array of objects; this should match the first
      raise( CEexcept.new( "did not find block hash in put /show/blocks response", { result: "" } ) ) if blockHash.nil?

      query = {
         blockHash:  blockHash[ 1 ],
         keyVariant: variant,
         keyBytes:   key,
         path:       path
      }
      print( ">> query request: ", query.to_json ) if @@debug
      response = settings.http.send_request( "PUT", "/query", query.to_json )
      print( ">> query response: ", response.body ) if @@debug
      state    = response.body.match( /"result": *"(.+)"/ )
      state    = ( state.nil? ) ? response.body : state[ 1 ]

      {
         status:  true,
         message: "success",
         result:  state
      }.to_json

   rescue CEexcept => except
      print( "\n**** #{ except.message }: #{ variant }; #{ key }; #{ path }\n" )   # print error message to console
      [ 400, [ except.payload ] ]   # rack-compatible return value; the body (second) element must respond to each()
   end
}

#--- 120 characters ----------------------------------------------------------------------------------------------------

post( "/query/save" ) {
   begin
      req   = JSON.parse( request.body.read )
      valid = req.has_key?( "name" ) && req.has_key?( "variant" ) && req.has_key?( "key" )&& req.has_key?( "path" )
      raise( CEexcept.new( "post /query/save request missing one or more of 'name', 'variant', 'key', 'path'" ) ) unless valid

      @@store[ "savedQueries" ].delete_if { | element |       # delete any existing saved query with the same name
         element[ "name" ] == req[ "name" ]
      }

      @@store[ "savedQueries" ] << req

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

get( "/favicon.ico" ) {
   send_file( settings.assetRoot + "/images/favicon.ico" )
}

#--- 120 characters ----------------------------------------------------------------------------------------------------
# assets: css, js, images, etc.

get( %r[(/.+)] ) { | path |                 # get anything other than / or /data
   send_file( settings.assetRoot + path )   # path includes leading /
}

#--- 120 characters ----------------------------------------------------------------------------------------------------
# invalid routes

%i[ get put post delete patch options ].each { | method |
   send( method, "*" ) { | invalidRoute |
      errMsg = "invalid route: #{ method.upcase } #{ invalidRoute }"
      printf( "\n**** %s\n", errMsg )   # print error message to console
      except = CEexcept.new( errMsg )
      [ 400, [ except.payload ] ]       # rack-compatible return value; the body (second) element must respond to each()
   }
}

#### 120 characters ####################################################################################################

run!   # runs the web server (required for modular sinatra apps, i.e. those that subclass Sinatra::Base OR when using the built-in server?)

end    # class CasperExplorer
