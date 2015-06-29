#!/usr/bin/perl
# use strict;
use warnings;
use LWP::Simple;
use lib "HTML";
use HTML::TableExtract;
use threads;
use Config;
use threads;
use FileHandle;
use LWP::UserAgent;

my $ua = new LWP::UserAgent;
    
$Config{usethreads} or die "Recompile Perl with threads to run this program.";

#Scrapes the content of the webpage of the given url.
sub scrape() 
{
	$url = $_[0];
	$file = $_[1];

	# $data =  get($url);
	$ua->default_header('Accept-Encoding' => scalar HTTP::Message::decodable());
	$data = $ua->get($url)->decoded_content;
	&writeToFile($file, $data);
}

#Writes data to the file in csv format (semicolon separator since money figures are involved)
sub writeToFile()
{
	$file = $_[0];
	$data = $_[1];
	$stream = '';
	$te = HTML::TableExtract->new( attribs => { border => 1 } );
	$te->parse($data);
	foreach $ts ($te->tables) {
	  foreach $row ($ts->rows) {
		$values = join(';', @$row);
		$stream = "${stream}${values}\n";
	  }
	}
	print $file $stream;
	close $file;
}

#Stores the result
my $resultDir = 'results/';

#The draw types, also used as filenames
my @drawTypes = ("6-55results", "6-49results", "6-45results", "6-42results", "6-dresults", "4-dresults", "3-dresults", "2-dresults");

#Base Url of the target website
my $url = 'http://pcso-lotto-results-and-statistics.webnatin.com/';

my @threads;

my $i = 0;

my @files;

#Here we go!
foreach $type (@drawTypes){
	$fh[$i] = FileHandle->new("> ${resultDir}${type}.csv");
	$threads[$i] = threads->create(\&scrape, "${url}${type}.asp", $fh[$i]);
	$i++;
}
foreach $thread (@threads)
{
	$thread->join();
}
print "Complete...\n";
exit 0;