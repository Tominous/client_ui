
$\ = "\n"
out = ""

File.foreach( ARGV.first ) { | line |
   next if line =~ /^\s+$/
   line  = line.chomp
   lineM = line.match( /^\[\d+-\d+-\d+ +\d+:\d+:\d+\.\d+\]\[\d+\](.*)$/ )
   unless lineM.nil?
      print( out )
      out = lineM[ 1 ]
   else
      out << line
   end
}