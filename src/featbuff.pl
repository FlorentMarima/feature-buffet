#!/usr/bin/perl
#
# The MIT License (MIT)
# Copyright (c) <2014> <Alkemics>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# @author : florent.marima@gmail.com

use strict;
use warnings;
use Getopt::Long;
use utf8;
use lib qw(..);
use JSON qw( );
no utf8;

my $version 	= "0.1a";

my $opt_add 	= "";
my $opt_del 	= "";
my $opt_init	= 0;
my @opt_load 	= ();
my @opt_set 	= ();
my $opt_help 	= 0;
my $opt_version = 0;

Getopt::Long::GetOptions("add=s" 	=> \$opt_add,
			"del=s"		=> \$opt_del,
			"load=s{2}"	=> \@opt_load,
			"set=s{2}"	=> \@opt_set,
			"version"	=> \$opt_version,
			"init"		=> \$opt_init,
			"help"		=> \$opt_help,
			"info"		=> \$opt_help)
	or die("Bad params. Try --help !\n");

my $configuration = undef;
sub handleArgs {
	if ($opt_help) 		{ &usage(); }
	if ($opt_version) 	{ &displayVersion(); }
	if ($opt_init) 		{ &createFeatBuffetFile(); }
	
	$configuration = &getFeatBufferFile();
	
	if ($opt_load[0]) 	{ &addSource($configuration, $opt_load[0], $opt_load[1]); }
	if ($opt_set[0]) 	{ &setFeature($configuration, $opt_set[0], $opt_set[1]); }
	if ($opt_add) 		{ &activateFeature($configuration, $opt_add); } 
	if ($opt_del) 		{ &desactivateFeature($configuration, $opt_del) }
	
	updateFeatBuffetFile($configuration);
	
	if (!$opt_del && !$opt_add && !$opt_set[0] && !$opt_load[0] && !$opt_init) { 
		&run($configuration); 
	}
}

sub updateFeatBuffetFile {
	my ($configuration) = @_;

	open (my $fd, ">", "FeatBuffetFile")
		or die "trying";

	my $json = JSON->new;
	my $content = $json->encode($configuration);
	print $fd $content;
}

sub addSource {
	my ($configuration, $input, $output) = @_;

	for ( @{ $configuration->{FeatBuffet}->{files} } ) {
		if ($_->{src} eq $input) {
			$_->{dest} = $output;
			return 1;
		}
	}
	my %row = ( src => $input, dest => $output);
	push ( @{ $configuration->{FeatBuffet}->{files}} , \%row);
}

sub setFeature {
	my ($configuration, $featureName, $featureLabel) = @_;

	$configuration->{FeatBuffet}->{features}->{$featureName} = $featureLabel;
}

sub activateFeature {
	my ($configuration, $featureName) = @_;

	if (!exists $configuration->{FeatBuffet}->{features}->{$featureName}) {
		&error("Set the feature first");
	}

	for ( @{ $configuration->{FeatBuffet}->{buffet} } ) {
		if ($_ eq $featureName) {
			return 0;
		}
	}
	push ( @{ $configuration->{FeatBuffet}->{buffet} }, $featureName );
	return 1;
}

sub desactivateFeature {
	my ($configuration, $featureName) = @_;

	my $index = 0;
	for ( @{ $configuration->{FeatBuffet}->{buffet} } ) {
		if ($_ eq $featureName) {
			splice(@{ $configuration->{FeatBuffet}->{buffet} }, $index, 1);
			return 1;
		}
		$index++;
	}
	return 0;
}

sub fileExists {
	my ($filename) = @_;

	if (-e $filename) {
		return 1;
	}
	return 0;
}

sub getFeatBufferFile {
	if (!&fileExists("./FeatBuffetFile")) {
		&error("File FeatBuffetFile does not exist. featbuffet --init; ftw");
	}

	my $json_text = do {
   		open(my $json_fh, "<:encoding(UTF-8)", './FeatBuffetFile')
      		or die("Can't open ./FeatBuffetFile: $!\n");
   		local $/;
   		<$json_fh>
	};

	my $json = JSON->new;
	my $data = $json->decode($json_text);
	return $data;
}


sub createFeatBuffetFile {
	open(my $fd, ">", "FeatBuffetFile")
		or die "Cannot open FeatBuffetFile";
	my $content = "{\n";
	$content .= "\t\"FeatBuffet\" : {\n";
	$content .= "\t\t\"files\" : [\n";
	$content .= "\t\t],\n";
	$content .= "\t\t\"features\" : {\n";
	$content .= "\t\t},\n";
	$content .= "\t\t\"buffet\" : [\n";
	$content .= "\t\t]\n";
	$content .= "\t}\n}";

	print $fd $content;
}

sub error {
	my ($msg) = @_;
	die("Error : " . $msg . "\n");
}

sub displayVersion {
	die ("FeatBuff tool version $version proudly bought to you by Alkemics\n");
}

sub usage {
	my $use = "";
	$use .= "Usage: \n\n";
	$use .= "\tfeatbuff [opt]\n\n";
	$use .= "\tNO ARGS\tfeatbuff generates the outputs according to the FeatBuffetFile.\n";
	$use .= "\t\tShould be used after --init, some --set and --add, and at least one --load :-)\n";
	$use .= "\n Options : \n";
	$use .= "\t--init             \tCreate a first FeatBuffetFile\n";
	$use .= "\t--load input output\toutput will be generated by featbuff by parsing input\n";
	$use .= "\t--set \”feature=label\"\tAdd the feature designed by label in the FeatBuffetFile\n";
	$use .= "\t--add featureX    \tActivate the featureX. featureX should have been 'loaded' with --set before\n";
	$use .= "\t--del featureX    \tDesactivate the featureX\n";
	$use .= "\t --help           \tDisplay this usage";
	$use .= "\n\n Classic UseCase: \n";
	$use .= " <pro>\n";
	$use .= "   mv featbuff.pl featbuff\n";
	$use .= "   chmod +x featbuff\n";
	$use .= "   sudo cp featbuff /usr/bin/featbuff\n";
	$use .= " </pro>\n";
	$use .= "\tfeatbuff --init\n";
	$use .= "\tfeatbuff --load myfile myfile.out\n";
	$use .= "\tfeatbuff --load myotherfile myotherfile.out\n";
	$use .= "\tfeatbuff --set \"myFeature=myFeaturelabel\"\n";
	$use .= "\tfeatbuff --set \"myFeature2=mySecondFeatureLabel\"\n";
	$use .= "\tfeatbuff --add myFeature2\n";
	$use .= "\tfeatbuff /* Will parse the myfile and myotherfile files,\n"; 
	$use .= "\t            and only keep the lines between \@start mySecondFeatureLabel && \@end\n";
	$use .= "\t            to genererate the outputs files */\n";
	$use .= "\tfeatbuff --del myFeature2 --add myFeature\n";
	$use .= "\tfeatbuff /* ... */\n";
	die($use);
}

sub run {
	my ($configuration) = @_;

	my @labels = ();

	for ( @{ $configuration->{FeatBuffet}->{buffet} } ) {
		push( @labels, $configuration->{FeatBuffet}->{features}->{$_} );
	}

	for ( @{ $configuration->{FeatBuffet}->{files} } ) {
		parse($_->{src} , $_->{dest}, @labels);
	}
}

sub parse {
	my ($src, $dest, @labels) = @_;
	my %hashParams = map { $_ => 1 } @labels;
	my $cpy = 0;

	print "dest = $dest\n";
	print "src = $src\n";
	open(my $output, ">", $dest) or die ("Can't open $dest");
	open(my $input, "<", $src) or die ("Can't open $src");
	
	while ( my $line = <$input>) {
		if ($line =~/( )*\@end( )*$/) {
			$cpy = 0;
		}
		if ($cpy == 1) {
			print $output $line;
		}
		if ($line =~ /( )*\@start( )+(\w+)$/) {
			if (exists($hashParams{$3})) {
				$cpy = 1;
			}			
		}
	}
}

&handleArgs();

