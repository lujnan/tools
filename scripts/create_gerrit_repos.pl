#!/usr/bin/perl

## used for gerrit repo init.

use strict;
use warnings;

use XML::Simple qw(XMLin);
use Git::Repository;
use File::Path qw(make_path);
use File::Basename;
use Cwd 'abs_path';

my $xml = XMLin("rokid.xml", KeyAttr => { project => 'path' }, ForceArray => 1);
my $distout="friendly-arm_4412";
my $abs_path = abs_path(".");
foreach my $path (keys %{$xml->{project}}) {

    if (-d $path) {
	make_path("$distout/$path.git");
        my($filename, $dirs, $suffix) = fileparse($path); 
	printf "abs=%s, %s, %s\n", $abs_path, $filename, $dirs;
	Git::Repository->run( init => $path );
	my $r = Git::Repository->new( work_tree => $path );
	#$r->run(init => $path);
	$r->run(add => '.');
	$r->run('commit', '-m', 'first commit', {   env => { GIT_COMMITTER_NAME  => 'lujnan', GIT_COMMITTER_EMAIL => 'lujnan@rokid.com', }, });
	my $clone_dir = "$abs_path/$distout/$path.git";
	$r->run('clone', '--bare', '-c', 'core.logallrefupdates=true', $filename, $clone_dir, { cwd => $dirs });

	$r = Git::Repository->new( git_dir => $clone_dir );
	my $session_name = "remote.origin";
	$r->run('config', '--local', '--remove-section', $session_name); 
    } else {

    }
}
