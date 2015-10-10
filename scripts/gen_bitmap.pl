#!/usr/bin/perl

use strict;

my $width = 640;
my $height = 480;

my $row_padding = (3 * $width) % 4;
$row_padding = $row_padding ? (4 - $row_padding) : 0;
my $row_size = 3 * $width + $row_padding;
my $data_size = $height * $row_size;

my $header_size = 54;
my $file_size = $header_size + $data_size;
my $fh = "/tmp/newImage.bmp";
open(OUTPUT, ">", $fh) or die "Unable to open $fh !";
binmode(OUTPUT);

print OUTPUT "\x42\x4D";               # BMP magic number
print OUTPUT pack("V", $file_size);
print OUTPUT "\0\0\0\0";               # Reserved
print OUTPUT pack("V", $header_size);  # Offset to the image data

print OUTPUT "\x28\0\0\0";          # Header size (40 bytes)
print OUTPUT pack("V", $width);     # Bitmap width
print OUTPUT pack("V", $height);    # Bitmap height
print OUTPUT "\1\0";                # Number of color planes
print OUTPUT "\x18\0";              # Bits per pixel (24-bits)
print OUTPUT "\0\0\0\0";            # Compression method
print OUTPUT pack("V", $data_size); # Image data size
print OUTPUT "\x13\x0B\0\0";        # Horizontal resolution (px/m)
print OUTPUT "\x13\x0B\0\0";        # Vertical resolution (px/m)
print OUTPUT "\0\0\0\0";            # Number of colors in palette
print OUTPUT "\0\0\0\0";            # Number of important colors

open(DATA, "<", "raw.rgb888.2th") or die "Couldn't open file file.txt, $!";
binmode(DATA);

my $buffer="";
my $encoded;
while((read(DATA, $buffer, 2))!=0) {
	#my ($R, $G, $B) = unpack('CCC', $buffer);
	#print OUTPUT pack('CCC', $R, $G, $B);
	$encoded = unpack('S', $buffer);

	#print OUTPUT pack('C C C', (($encoded >> 11) & 0x1F) * 255 / 31, (($encoded >> 5) & 0x3F) * 255 / 63, ($encoded & 0x1F) * 255 / 31);
	print OUTPUT pack('C C C', (($encoded & 0x1f)) * 255 / 31, (($encoded >> 5) & 0x3F) * 255 / 63, (($encoded >>11) & 0x1F) * 255 / 31);
}

close(OUTPUT);
close(DATA);

