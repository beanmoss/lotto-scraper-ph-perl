#!/usr/bin/perl
# use strict;
use warnings;
use LWP::Simple;
use lib "HTML";
use HTML::TableExtract;

#Scrapes the content of the webpage of the given url.
sub scrape() 
{
	$url = $_[0];
	print 'scraping....';
	return get($url);
}

#Writes data to the file in csv format (semicolon separator since money figures are involved)
sub writeToFile()
{
	print 'writing.';
	$file = $_[0];
	$data = $_[1];
	$te = HTML::TableExtract->new( attribs => { border => 1 } );
	$te->parse($data);
	foreach $ts ($te->tables) {
	  foreach $row ($ts->rows) {
		print '.';
		print $file join(';', @$row), "\n";
	  }
	}
	close $file;
}

#Stores the result
my $resultDir = 'results/';

#The draw types, also used as filenames
my @drawTypes = ("6-55results", "6-49results", "6-45results", "6-42results", "6-dresults", "4-dresults", "3-dresults", "2-dresults");

#Base Url of the target website
my $url = 'http://pcso-lotto-results-and-statistics.webnatin.com/';

#Here we go!
foreach $type (@drawTypes){
  	open(my $fh, '>:encoding(UTF-8)', "${resultDir}${type}.csv") or die "Could not open file '$type' $!";
	$data = &scrape("${url}${type}.asp");
	&writeToFile($fh, $data);
}

print "Complete...\n";
exit 0;