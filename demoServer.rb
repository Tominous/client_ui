
require "sinatra/base"
require "net/http"
require "monitor"
require "json"
require "yaml"
require "base16"
require "base64"

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

class VotingDemo < Sinatra::Base

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# the following (outside any sinatra-specific block) should be accessible to all sinatra-specific blocks

$\ = "\n"   # appended to output of print()
DEFAULT_CONFIG_FILE = "demoConfig.yaml"
@@nodeId = 0
@@resultsCache = [ ]
@@mutex = Mutex.new
@@debug = false

def self.deployPropose( name, http, deploy, count )
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
   raise( "candidate count exceeds maxCandidates" ) if config[ "candidates" ].length > config[ "maxCandidates" ]
   set( :nodeCnt,    config[ "nodeCount" ].to_i )
   set( :port,       config[ "serverPort"  ]  )   # default port for sinatra is 4567
   set( :root,       config[ "projectRoot" ]  )   # root directory for project files (for production mode; for development it's "root/public")
   set( :account,    Base64.strict_encode64( Base16.decode16( config[ "account" ] ) ) )
   set( :candidates, config[ "candidates"  ]  )
   @@resultsCache = [ 0 ] * config[ "candidates" ].length

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
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# methods available to all route bodies (define methods using standard def-end block)

helpers {

}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# called every 2 seconds by javascript

get( "/results" ) {
   @@mutex.synchronize {
      @@resultsCache.to_json
   }
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# for testing purposes

#put( "/deploy" ) {
#   File.write( "browserDeployObject.txt", request.body.read )
#   { status: "ok" }.to_json
#}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# support files at project level

get( %r[(/(assets|images)/.+)] ) { | path, dir |
   fname = settings.root + path
   send_file( fname )
}

#--- 120 characters ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
# called onload to get long-lived data

get( "/data" ) {
   @@nodeId += 1
   @@nodeId = 0 if @@nodeId == settings.nodeCnt
   {
      voteSession: settings.voteSession,
      payment:     settings.payment,
      account:     settings.account,
      candidates:  settings.candidates,
      nodeId:      @@nodeId
   }.to_json
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

get( "/favicon.ico" ) {
   send_file( settings.root + "/images/favicon.ico" )
}

#--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

get( "/" ) {
   send_file( settings.root + "/index.html" )
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

#################################################################################

run!   # runs the web server (required for modular sinatra apps, i.e. those that subclass Sinatra::Base OR when using the built-in server?)

end    # class CasperExplorer
