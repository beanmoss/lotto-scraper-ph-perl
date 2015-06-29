#!/usr/bin/perl
use strict;
use warnings;
use LWP::Simple;
use lib "HTML";
use HTML::TableExtract;
use threads;
use Config;
use threads;
use FileHandle;
use LWP::UserAgent;
use LWP::ConnCache;
require HTTP::Request;
    
$Config{usethreads} or die "Recompile Perl with threads to run this program.";

#Scrapes the content of the webpage of the given url.
sub scrape() 
{
	my $url = $_[0];
	my $file = $_[1];
	my $te = $_[2];
	my $ua = $_[3];

	$ua->default_header('Accept-Encoding' => 'gzip');
	my $data = $ua->get($url)->decoded_content;

	writeToFile($file, $data, $te);
}

#Writes data to the file in csv format (semicolon separator since money figures are involved)
sub writeToFile()
{
	my $file = $_[0];
	my $data = $_[1];
	my $te = $_[2];
	my $stream = '';
	# $te = HTML::TableExtract->new();
	$te->parse($data);
	foreach my $ts ($te->tables) {
	  foreach my $row ($ts->rows) {
		my $values = join(';', @$row);
		$stream = "${stream}${values}\n";
	  }
	}
	print $file $stream;
	close $file;
}



my $ua = new LWP::UserAgent;

#Stores the result
my $resultDir = 'results/';

#The draw types, also used as filenames
my @drawTypes = ("6-55results", "6-49results", "6-45results", "6-42results", "6-dresults", "4-dresults", "3-dresults", "2-dresults");

#Base Url of the target website
my $url = 'http://pcso-lotto-results-and-statistics.webnatin.com/';

my @threads;

my $i = 0;

my @files;

my $te = HTML::TableExtract->new();

my @fh;

#Here we go!
foreach my $type (@drawTypes){
	$fh[$i] = FileHandle->new("> ${resultDir}${type}${i}.csv");
	$threads[$i] = threads->create(\&scrape, "${url}${type}.asp", $fh[$i], $te, $ua);
	$i++;
}

foreach my $thread (@threads)
{
	$thread->join();
}

print "Complete...\n";
exit 0;