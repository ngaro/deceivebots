#!/usr/bin/env perl
use strict; use warnings;
use LWP::Simple;
use JSON;
#use Data::Dumper;
use utf8;

my $url = "https://raw.githubusercontent.com/monperrus/crawler-user-agents/refs/heads/master/crawler-user-agents.json";

#Step 1) Download crawler-user-agents.json and save it to a temporary file
my $jsonAsText = get($url);
die "Couldn't GET $url" unless defined $jsonAsText;
#print Dumper($jsonAsText);

#Step 2) Convert it to arrayref $json (We don't use decode_json because it breaks with the UTF-8 characters in the file)
my $json = JSON->new->decode($jsonAsText);
#print Dumper($json);

#Step 3) Each entry in $json is a hashref that has (among others) the key "pattern". Put these in an arrayref $patterns
my $patterns = [];
foreach my $entry (@$json) {
    push @$patterns, $entry->{pattern};
}
#print Dumper($patterns);

#Step 4) For each pattern in $patterns, convert it to a regexp that can be used in nginx
my @nginxCompatibleRegexps;
foreach my $pattern (@$patterns) {
    $pattern =~ s/(.*)/"~^.*$1.*\$"/;
    push @nginxCompatibleRegexps, $pattern;
}
#print Dumper(\@nginxCompatibleRegexps);

#Step 5) Create a file "is-a-bot.conf" that starts with "default 0;" and is followed by the regexps, each on a new line followed by " 1;"
open(my $fh, '>', 'is-a-bot.conf') or die "Could not open file: $!";
print $fh "default 0;\n";
print $fh "\"\" 1;\n";  #A empty user agent is also bot but not in crawler-user-agents.json
#Add the regexps to the file in a sorted way, each followed by " 1;"
foreach my $regexp (sort @nginxCompatibleRegexps) {
    print $fh "$regexp 1;\n";
}
close($fh);
