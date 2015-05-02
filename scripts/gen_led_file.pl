#!/usr/bin/perl -w 

use strict;

use Getopt::Std;
use Bit::Fast qw(popcount popcountl);

my %opts;
getopts('?hf:p:c:m:x:', \%opts);

if ($opts{h} || $opts{'?'}) {
  print usage();
  exit;
}

my $outfile = $opts{f} || 'rokid.led';
my $fps = $opts{p} || 60;
my $milliseconds = $opts{m} || 1;
my $channelMask = $opts{c} || 0xfff;
my $totalFrames = $opts{x} || 2;

my $magic = "LED";
my $version = 1;
my $adler32 = 0;
my $channelCount = popcount($channelMask);


my $totalSize = $totalFrames * $channelCount * 3;
my $frameSize = $channelCount * 3;

my $buf = pack "A3C1I1I1C1I1", $magic, $version, $adler32, $channelMask, $fps, $totalFrames;

print "=="x20 . "\n";
printf "totalSize=%d, totalFrames=%d\n", $totalSize, $totalFrames;
printf "channelCount=%d, channelMask=0x%x\n", $channelCount, $channelMask;
printf "frameSize=%d\n", $frameSize;
print "=="x20 . "\n";

open(OUTPUT, ">", $outfile) or die "Unable to open $outfile !";
binmode(OUTPUT);
print OUTPUT $buf;

my ($R, $G, $B) = (0, 0, 0);
for(my $f = 0; $f < $totalFrames; ++$f) {
        ++$R;
	for (my $i = 0; $i < $channelCount; ++$i) {
		print OUTPUT pack "C3", $R, $G, $B;
	}
}

sub usage {
  return <<EOT;
$0 - create rokid light system data file.

 USAGE:
  # a 3 second 60fps LED called 'rokid.led'
  $0 -f 'rokid.led' -t 3 

 OPTIONS:
  ?       Print this screen
  h       Print this screen
  v <num> format version (0~255)
  f <str> name of the outfile (defaults to 'out.led') 
  p <num> render fps to play (defaults to 60 fps)
  t <num> number of seconds to make the file (default is 2)
  c <num> number of frames 

EOT
}

