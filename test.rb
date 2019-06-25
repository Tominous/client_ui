
require "base64"

# map = %w[ A B C D E F G ]

# 0.upto( 6 ) { | arg |
#     sessionArgs = "AQAAAAQAAAA" + map[ arg ] + "AAAA"
#     printf( "%d: %s\n", arg, sessionArgs )
# }

# 0.upto( 6 ) { | i |
#     arg = 0x010000000400000000000000 | ( i & 0xFF ) << 24
#     printf( "\n%d: %x\n", i, arg )
#     printf( "%d: %d\n", i, arg )
#     printf( "%d: %s\n", i, [ arg ].pack( "m0" ) )
# }
