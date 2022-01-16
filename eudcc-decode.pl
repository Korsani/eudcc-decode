#!/usr/bin/env perl
use strict;
use warnings;
use QRCode::Base45;
use MIME::Base64;
use Compress::Raw::Zlib;
use CBOR::XS;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;

use vars qw($HCERT $DUMP $HELP);
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
my %DGC;
$DGC{'EU/1/20/1528'}='Comirnaty';
$DGC{'EU/1/20/1507'}='Spikevax';
$DGC{'EU/1/21/1529'}='Vaxzevria';
$DGC{'EU/1/20/1525'}='COVID-19 Vaccine Janssen';
$DGC{'ORG-100001699'}='AstraZeneca AB';
$DGC{'ORG-100030215'}='Biontech Manufacturing GmbH';
$DGC{'ORG-100001417'}='Janssen-Cilag International';
$DGC{'ORG-100031184'}='Moderna Biotech Spain S.L.';
$DGC{'840539006'}='COVID-19';
$DGC{'LP6464-4'}='Nucleic acid amplification with probe detection';
$DGC{'LP217198-3'}='Rapid immunoassay';
$DGC{'1119349007'}='SARS-CoV2 mRNA vaccine';
$DGC{'1119305005'}='SARS-CoV2 antigen vaccine';
$DGC{'J07BX03'}='covid-19 vaccines';
my %V;
$V{"ci"}="UVCI";
$V{"is"}="Issuer";
$V{"co"}="Country";
$V{"sd"}="Number of doses";
$V{"dn"}="Doses needed";
$V{"dt"}="Last dose";
$V{"ma"}="Vax manufacturer";
$V{"mp"}="Vax product";
$V{"vp"}="Vaccine or prophylaxis";
$V{"tg"}="Agent targeted";
# Useless pour l'instant
my %T;
$T{"tt"}="Test type";
$T{"nm"}="Test name";
$T{"ma"}="Test device identifier";
$T{"sc"}="Sample collection date";
$T{"tr"}="Test result";
$T{"tc"}="Test center";
my %NAM;
$NAM{"fn"}="Surname(s)";
$NAM{"fnt"}="Standardized surname(s)";
$NAM{"gn"}="Forename(s)";
$NAM{"gnt"}="Standardized forename(s)";
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
GetOptions (
	"dump"	=>	\$DUMP,
	"hc1=s"	=>	\$HCERT,
	"help"	=>	\$HELP
);
if (defined $HELP) {
	pod2usage(-verbose => 3);
	exit;
}

#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
$HCERT=~s/^HC1://;
my $d=new Compress::Raw::Zlib::Inflate();
my $decoded=decode_base45($HCERT);
$d->inflate(\$decoded,my $o);
my $cbor=decode_cbor($o);
my $protected=decode_cbor(@{$cbor}[1]->[0]);
${$cbor}[1]->[0]=$protected;
my $payload=decode_cbor(@{$cbor}[1]->[2]);
${$cbor}[1]->[2]=$payload;
my $signature=@{$cbor}[1]->[3];
${$cbor}[1]->[3]=encode_base64($signature);
# Pas utilisé
my $unprotected=@{$cbor}[1]->[1];
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
if ($DUMP) {
	print Dumper($cbor);
	exit,
}
my $prefix_format='[%3s:%-3s] ';
my $display_format='%-30s: %s';
# Decode first level
sub decode_payload_1 {
	my $payload=shift;
	printf "[hcert:1] Issuer: %s\n",${$payload}{1};
	printf "[hcert:6] Issue: %s\n",scalar localtime(${$payload}{6});
	printf "[hcert:4] Expire: %s\n",scalar localtime(${$payload}{4});
}
# Decode 'v' section
sub decode_payload_v {
	my $r=shift;
	my @v=@{ $r };
	foreach my $k (sort keys %{$v[0]}) {
		printf "$prefix_format",'v',$k;
		if (exists $V{$k}) {
			printf "$display_format",$V{$k},$v[0]{$k};
			if (exists $DGC{$v[0]{$k}}) {
				printf " (%s)",$DGC{$v[0]{$k}};
			}
			print "\n";
		} else {
			print "??\n";
		}
	}
}
# Decode 'nam' section
sub decode_payload_nam {
	my $nam=shift;
	foreach my $k (sort keys %{$nam}) {
		printf "$prefix_format",'nam',$k;
		if (exists $NAM{$k}) {
			printf "$display_format\n",$NAM{$k},${$nam}{$k};
		} else {
			print "??\n";
		}
	}
}
# Decode 't' section
sub decode_payload_t {
	my $t=shift;
	foreach my $k (sort keys %{$t}) {
		printf "$prefix_format",'t',$k;
		if (exists $T{$k}) {
			printf "$display_format\n",$T{$k},${$t}{$k};
		} else {
			print "??\n";
		}
	}
}
decode_payload_1($payload);
if (exists ${$payload}{-260}{1}{'nam'}) {
	decode_payload_nam ${$payload}{-260}{1}{'nam'};
}
if (exists ${$payload}{-260}{1}{'v'}) {
	decode_payload_v ${$payload}{-260}{1}{'v'};
}
if (exists ${$payload}{-260}{1}{'t'}) {
	decode_payload_t ${$payload}{-260}{1}{'t'};
}
if (exists ${$payload}{-260}{1}{'dob'}) {
	printf "$prefix_format",'dob','';
	printf "$display_format\n",'Date of birth',${$payload}{-260}{1}{'dob'};
}
=pod

=head1 NAME

EUDCC decoder

=head1 SYNOPSIS

	eudcc-decode --hc1 '<string>' [ --dump ]
	eudcc-decode --help


=head1 DESCRIPTION

EUDCC (health pass) decoder


=head1 OPTIONS

=over

=item --hc1

EUDCC string to decode

=back

=cut
