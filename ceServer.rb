
require "sinatra/base"
require "net/http"
require "json"
require "yaml"
require "base16"
require "base64"

#### 120 characters ###########################################################################################

class CEexcept < StandardError
   def initialize( payload = { } )
      @payload = {
         status:  false,
         message: @message   # this should be in the superclass
      }
      @payload.merge( payload )
      @payload = @payload.to_json
   end
end

#### 120 characters ###########################################################################################

class CasperExplorer < Sinatra::Base

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# the following (outside any sinatra-specific block) should be accessible to all sinatra-specific blocks

$\ = "\n"   # appended to output of print()
DEFAULT_CONFIG_FILE = "casperExplorerConfig.yaml"
@@mutex = Mutex.new
@@debug = false
@@store = {
   keys: [
      { keyPairId: "keyId1", accountCreated: true  },
      { keyPairId: "keyId2", accountCreated: false }
   ],
   payment: [
      { name: "pay1", wasm: "lots o' pay wasm 1" },
      { name: "pay2", wasm: "lots o' pay wasm 2" }
   ],
   session: [
      { name: "session1", wasm: "lots o' session wasm 1" },
      { name: "session2", wasm: "lots o' session wasm 2" },
      { name: "session3", wasm: "lots o' session wasm 3" }
   ]
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# run once at sinatra startup before any http requests are processed
# command line options: optional single argument specifying config.yaml file name

configure {
   # the following override defaults for modular sinatra apps, i.e. those that subclass Sinatra::Base
   set( :bind,    "0.0.0.0" )
   set( :app_file, __FILE__ )    # specifies root directory for the website (the directory containing this file)
   set( :run,      true     )    # start the default/internal web server after loading this sinatra app (webrick for ruby1.9)
   set( :logging,  true     )    # enable logging to stderr

   config = YAML.load_file( ARGV[ 0 ] || DEFAULT_CONFIG_FILE )

   set( :port,       config[ "serverPort"  ]  )   # default port for sinatra is 4567
   set( :root,       config[ "projectRoot" ]  )   # root directory for project files (for production mode; for development it's "root/public")
   set( :account,    Base64.strict_encode64( Base16.decode16( config[ "account" ] ) ) )

   %i[ createSession voteSession payment ].each { | contract |
      wasm = File.binread( config[ "wasmRoot" ] + "/" + config[ contract.to_s ] )
      set( contract, Base64.strict_encode64( wasm ) )
   }

   deploy = {
      user:      "",
      address:   settings.account,
      timestamp: ( Time.now.to_f * 1000.0 ).round,
      session: {
         code: settings.createSession,
         args: "",
      },
      payment: {
         code: settings.payment,
         args: "",
      },
      gasLimit:      0,
      gasPrice:      0,
      nonce:         0,
      sigAlgorithm: "",
      signature:    ""
   }

   # need http create above here if line below is un-commented
   #self.deployPropose( "create", http, deploy, config[ "nodeCount" ] )
if false
   Thread.new( config[ "account" ], settings.nodeCnt, settings.candidates.length ) { | account, nodeCnt, candidateCnt |

      http = Net::HTTP.new( config[ "envoyIP" ], config[ "envoyPort" ] )
      sleep( 10 )
      query = {
         keyVariant: "address",
         keyBytes:   account
      }

      loop {                                                                               # loop until process terminates
         0.upto( nodeCnt - 1 ) { | nodeId |
            response  = http.send_request( "POST", "/block", "{}", { "X-node" => nodeId.to_s } )                              # propose any pending deploys
            print( ">> propose to node #{ nodeId }: ", response.body ) if @@debug
            next unless nodeId == 0                                                       # always query node 0 for monotonicity
            response  = http.send_request( "PUT", "/show/blocks", { depth: 1 }.to_json, { "X-node" => nodeId.to_s } )   # query
            print( ">> showBlocks response: ", response.body ) if @@debug
            blockHash = response.body.match( /"blockHash": *"([^"]+)"/ )   # returns an array of objects; this should match the first

            unless blockHash.nil?
               print( ">> showBlocks response: ", response.body ) if @@debug
               query[ :blockHash ] = blockHash[ 1 ]

               0.upto( candidateCnt - 1 ) { | candidateIndex |
                  query[ :path ] = "vote/" + candidateIndex.to_s
                  req = query.to_json
                  print( ">> query request to node #{ nodeId }: ", req ) if @@debug
                  response = http.send_request( "PUT", "/query", req, { "X-node" => nodeId.to_s } )
                  print( ">> query response: ", response.body ) if @@debug
                  votes = response.body.match( /"result":[^\d]+([\d]+)/ )

                  if votes.nil?
                     print( "**** did not find result in query response: ", response.body ) if @@debug
                     next
                  end

                  @@mutex.synchronize {
                     @@resultsCache[ candidateIndex ] = votes[ 1 ].to_i
                  }
               }

            else
               print( "**** did not find block hash in put /show/blocks response: ", response.body )
            end
         }

         sleep( 3 )
      }      # loop
   }         # Thread.new
end
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# methods available to all route bodies (define methods using standard def-end block)

helpers {

   #--- 120 characters ------------------------------------------------------------------------------------------------------------------------------------------------------------------

   def deploy( name, http, deploy, count )
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
         exit
      end
   end

   #--- 120 characters ------------------------------------------------------------------------------------------------------------------------------------------------------------------

   def createKeyPair()
   end

   #--- 120 characters ------------------------------------------------------------------------------------------------------------------------------------------------------------------
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

get( "/" ) {
   send_file( settings.root + "/index.html" )
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# support files at project level

get( %r[(/(assets|images)/.+)] ) { | path, dir |
   fname = settings.root + path
   send_file( fname )
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# called onload to get long-lived data

get( "/data" ) {
   # read file (which file?) to get most recent persistent state of CE
   # have config param specifying location of wasm library
   out = settings.store.read( username )
   raise( CEexcept.new, "username does not exist: #{ username }" ) unless out.status
   {
      keys:    out.keys,
      payment: out.payment,
      session: out.session
   }.to_json

rescue CEexcept => except
   print( "\n**** #{ except.message }: #{ req }\n" )   # print error message to console
   [ 400, [ except.payload ] ]   # rack-compatible return value; the body (second) element must respond to each()
end
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

post( "/key" ) {
   begin
      req   = JSON.parse( request.body.read )
      valid = req.has_key?( "keyPairId" )
      raise( CEexcept.new( { publicKey: "" } ), "post /key request body missing 'keyPairId'" ) unless valid
      keyPair = createKeyPair()
      settings.store.write( req[ "keyPairId" ], keyPair.public, keyPair.private )   # overwrite existing id
      {
         status:    true,
         message:   "success",
         publicKey: keyPair.public,
      }.to_json

   rescue CEexcept => except
      print( "\n**** #{ except.message }: #{ req }\n" )   # print error message to console
      [ 400, [ except.payload ] ]   # rack-compatible return value; the body (second) element must respond to each()
   end
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

put( "/key" ) {
   begin
      req   = JSON.parse( request.body.read )
      valid = req.has_key?( "keyPairId" ) && req.has_key?( "public" ) && req.has_key?( "private" )
      raise( CEexcept.new, "put /key request body missing one or more of 'keyPairId', 'public', 'private'" ) unless valid
      settings.store.write( req[ "keyPairId" ], req[ "public" ], req[ "private" ] )  # overwrite existing id
      {
         status:  true,
         message: "success",
      }.to_json

   rescue CEexcept => except
      print( "\n**** #{ except.message }: #{ req }\n" )   # print error message to console
      [ 400, [ except.payload ] ]   # rack-compatible return value; the body (second) element must respond to each()
   end
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

delete( "/key" ) {
   begin
      req = JSON.parse( request.body.read )
      raise( CEexcept.new, "post /key request body missing 'keyPairId'" ) unless req.has_key?( "keyPairId" )
      out = settings.store.delete( req[ "keyPairId" ] )
      raise( CEexcept.new, "key does not exist: #{ req[ "keyPairId" ] }" ) unless out.status
      {
         status:  true,
         message: "success",
      }.to_json

   rescue CEexcept => except
      print( "\n**** #{ except.message }: #{ req }\n" )   # print error message to console
      [ 400, [ except.payload ] ]   # rack-compatible return value; the body (second) element must respond to each()
   end
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

post( "/account" ) {
   begin
      req   = JSON.parse( request.body.read )
      valid = req.has_key?( "keyPairId" ) && req.has_key?( "balance" )
      raise( CEexcept.new, "post /account request body missing one or more of 'keyPairId', 'balance'" ) unless valid
      out = settings.store.read( req[ "keyPairId" ] )
      raise( CEexcept.new, "keyPairId '#{ req[ "keyPairId" ] }' does not exist" ) unless out.status
      out = deploy( out.public, :payment, [ ], :createAccount, [ req[ "balance" ] ] )
      raise( CEexcept.new, out.msg ) unless out.status
      {
         status:    true,
         message:   "account create deploy accepted"
      }.to_json

   rescue CEexcept => except
      print( "\n**** #{ except.message }: #{ req }\n" )   # print error message to console
      [ 400, [ except.payload ] ]   # rack-compatible return value; the body (second) element must respond to each()
   end
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

put( "/contract" ) {
   req = JSON.parse( request.body.read )

   if req.has_key?( "name" ) && req.has_key?( "type" ) && req.has_key?( "wasm" )
      settings.store.write( req[ "keyPairId" ], req[ "public" ], req[ "private" ] )  # overwrite existing id
      {
         status:  true,
         message: "success",
      }.to_json

   else
      errMsg = "put /key request body missing one or more of 'keyPairId', 'public', 'private'"
      resp   = {
         status:  false,
         message: errMsg
      }
      print( "\n**** #{ errMsg }: #{ req }\n" )   # print error message to console
      [ 400, [ resp.to_json ] ]   # rack-compatible return value; the body (second) element must respond to each()
   end
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

delete( "/contract" ) {
   begin
      req = JSON.parse( request.body.read )
      raise( CEexcept.new, "post /key request body missing 'keyPairId'" ) unless req.has_key?( "keyPairId" )
      out = settings.store.delete( req[ "keyPairId" ] )
      raise( CEexcept.new, "key does not exist: #{ req[ "keyPairId" ] }" ) unless out.status
      {
         status:  true,
         message: "success",
      }.to_json

   rescue CEexcept => except
      print( "\n**** #{ except.message }: #{ req }\n" )   # print error message to console
      [ 400, [ except.payload ] ]   # rack-compatible return value; the body (second) element must respond to each()
   end
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

post( "/contract" ) {
   begin
      req   = JSON.parse( request.body.read )
      valid = req.has_key?( "keyPairId" ) && req.has_key?( "balance" )
      raise( CEexcept.new, "post /account request body missing one or more of 'keyPairId', 'balance'" ) unless valid
      out = settings.store.read( req[ "keyPairId" ] )
      raise( CEexcept.new, "keyPairId '#{ req[ "keyPairId" ] }' does not exist" ) unless out.status
      out = deploy( out.public, :payment, [ ], :createAccount, [ req[ "balance" ] ] )
      raise( CEexcept.new, out.msg ) unless out.status
      {
         status:    true,
         message:   "account create deploy accepted"
      }.to_json

   rescue CEexcept => except
      print( "\n**** #{ except.message }: #{ req }\n" )   # print error message to console
      [ 400, [ except.payload ] ]   # rack-compatible return value; the body (second) element must respond to each()
   end
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

get( "/query" ) {
   begin
      req   = JSON.parse( request.body.read )
      valid = req.has_key?( "keyPairId" ) && req.has_key?( "balance" )
      raise( CEexcept.new, "post /account request body missing one or more of 'keyPairId', 'balance'" ) unless valid
      out = settings.store.read( req[ "keyPairId" ] )
      raise( CEexcept.new, "keyPairId '#{ req[ "keyPairId" ] }' does not exist" ) unless out.status
      out = query( )
      raise( CEexcept.new, out.msg ) unless out.status
      {
         result: out.result,
      }.to_json

   rescue CEexcept => except
      print( "\n**** #{ except.message }: #{ req }\n" )   # print error message to console
      [ 400, [ except.payload ] ]   # rack-compatible return value; the body (second) element must respond to each()
   end
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

get( "/favicon.ico" ) {
   send_file( settings.root + "/images/favicon.ico" )
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# invalid routes

%i[ get put post delete patch options ].each { | method |
   send( method, "*" ) { | invalidRoute |
      errMsg = "**** invalid route: #{ method.upcase } #{ invalidRoute }"
      printf( "\n%s\n", errMsg )   # print error message to console
      [ 400, [ errMsg ] ]          # rack-compatible return value; the body (second) element must respond to each()
   }
}

#### 120 characters ###########################################################################################

run!   # runs the web server (required for modular sinatra apps, i.e. those that subclass Sinatra::Base OR when using the built-in server?)

end    # class CasperExplorer
