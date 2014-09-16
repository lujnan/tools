#!/usr/bin/perl -w
use strict;
use Config::Simple;
use Date::Parse;
use Net::POP3;
use Net::SMTP;
use Data::Dumper;
use LWP::Simple;

use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP ();
use Email::Simple ();
use Email::Simple::Creator ();
use List::Util;
			

my $pop3_server = "pop.ym.163.com";
my $smtp_server = "smtp.ym.163.com";
my $username = 'xxxx@rokid.com';
my $password = 'xxxx';

my $cfg = new Config::Simple('/home/lujnan/etc/mail_filter.conf');

my $timestamp = $cfg->param('timestamp');

my @email_whitelist=load_whitelist();

# Constructors
my $pop = Net::POP3->new($pop3_server, Timeout => 30, Debug => 0);	

my $max_time = $timestamp;
my $num_messages = $pop->login($username, $password);
if ($num_messages > 0 ) {
	my $count = $num_messages;
	for ($count; $count > 0; $count--) {
		my $header = $pop->top($count, 0);
		my ($subject, $from, $status, $date) = analyze_header($header);

		my $time = str2time($date);
		if ($time > $timestamp) {
			if ($time > $max_time) {
				$max_time = $time;
			}		
			
			my ($email_addr) = $from =~ /<(.*)>/m;
			if (not List::Util::first { $_ eq $email_addr } @email_whitelist) {
				print "$from is not in whitelist.\n";
				next;
			}

			if ($subject eq 'getip') {
				print "try to send mail to $from.\n";
				my $reply = get("http://20140507.ip138.com/ic.asp");
				
				my $transport = Email::Sender::Transport::SMTP->new({
						host => $smtp_server,
						port => 25,
						sasl_username => $username,
						sasl_password => $password,
						});	

				my $email = Email::Simple->create(
						header => [
							To      => $from,
							From    => $username,
							Subject => 'Re: getip',
							replyto => '',
							],
						body => $reply,
						);

				sendmail($email, { transport => $transport });
			}
		} 
		else {
			last;	
		}	
	}
}

if ($timestamp < $max_time) {
	$cfg->param('timestamp', $max_time);
	$cfg->save();
}

$pop->quit;


sub load_whitelist {
	my $filename = '/home/lujnan/etc/mail_whitelist.conf';
	open(FH, '<', $filename) or die $!;
	chomp(my @lines = <FH>);
	close(FH);	
	return @lines;
}

sub analyze_header {
	my $header_array_ref = shift;

	my $header = join "", @$header_array_ref;

	my ($subject) = $header =~ /Subject: (.*)/m;
	my ($from   ) = $header =~ /From: (.*)/m;
	my ($status ) = $header =~ /Status: (.*)/m;
	my ($date) = $header =~ /Date: (.*)/m;

	if (defined $status) {
		$status = "Unread" if $status eq 'O';
		$status = "Read"   if $status eq 'R';
		$status = "Read"   if $status eq 'RO';
		$status = "Ne    $status = "-";w"    if $status eq 'NEW';
		$status = "New"    if $status eq 'U';
	}
	else {
		$status = "-";
	}

	return ($subject, $from, $status, $date);
}

