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
my %DGC=(
	"EU/1/20/1528"	=>	"Comirnaty",
	"EU/1/20/1507"	=>	"Spikevax",
	"EU/1/21/1529"	=>	"Vaxzevria",
	"EU/1/20/1525"	=>	"COVID-19 Vaccine Janssen",
	"ORG-100001699"	=>	"AstraZeneca AB",
	"ORG-100030215"	=>	"Biontech Manufacturing GmbH",
	"ORG-100001417"	=>	"Janssen-Cilag International",
	"ORG-100031184"	=>	"Moderna Biotech Spain S.L.",
	"840539006"		=>	"COVID-19",
	"LP6464-4"		=>	"Nucleic acid amplification with probe detection",
	"LP217198-3"	=>	"Rapid immunoassay",
	"1119349007"	=>	"SARS-CoV2 mRNA vaccine",
	"1119305005"	=>	"SARS-CoV2 antigen vaccine",
	"J07BX03"		=>	"covid-19 vaccines"
);
my %V=(
	"ci"	=>	"UVCI",
	"is"	=>	"Issuer",
	"co"	=>	"Country",
	"sd"	=>	"Number of doses",
	"dn"	=>	"Doses needed",
	"dt"	=>	"Last dose",
	"ma"	=>	"Vax manufacturer",
	"mp"	=>	"Vax product",
	"vp"	=>	"Vaccine or prophylaxis",
	"tg"	=>	"Agent targeted"
);
# Useless pour l'instant
my %T=(
	"tt"	=>	"Test type",
	"nm"	=>	"Test name",
	"ma"	=>	"Test device identifier",
	"sc"	=>	"Sample collection date",
	"tr"	=>	"Test result",
	"tc"	=>	"Test center"
);
my %NAM=(
	"fn"	=>	"Surname(s)",
	"fnt"	=>	"Standardized surname(s)",
	"gn"	=>	"Forename(s)",
	"gnt"	=>	"Standardized forename(s)"
);
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
my $prefix_format='[%3s:%-3s] ';
my $display_format='%-30s: %s';
sub parse_hc1 {
	my $hcert=shift;
	$hcert=~s/^HC1://;
	my $d=new Compress::Raw::Zlib::Inflate();
	my $decoded=decode_base45($hcert);
	$d->inflate(\$decoded,my $o);
	my $cbor=decode_cbor($o);
	my $protected=decode_cbor(@{$cbor}[1]->[0]);
	${$cbor}[1]->[0]=$protected;
	my $payload=decode_cbor(@{$cbor}[1]->[2]);
	${$cbor}[1]->[2]=$payload;
	my $signature=@{$cbor}[1]->[3];
	${$cbor}[1]->[3]=encode_base64($signature);
	# Unused
	my $unprotected=@{$cbor}[1]->[1];
	return $cbor;
}
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
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
my $cbor=parse_hc1($HCERT);
if ($DUMP) {
	print Dumper($cbor);
	exit;
}
decode_payload_1(${$cbor}[1][2]);
if (exists ${$cbor}[1][2]{-260}{1}{'nam'}) {
	decode_payload_nam ${$cbor}[1][2]{-260}{1}{'nam'};
}
if (exists ${$cbor}[1][2]{-260}{1}{'v'}) {
	decode_payload_v ${$cbor}[1][2]{-260}{1}{'v'};
}
if (exists ${$cbor}[1][2]{-260}{1}{'t'}) {
	decode_payload_t ${$cbor}[1][2]{-260}{1}{'t'};
}
if (exists ${$cbor}[1][2]{-260}{1}{'dob'}) {
	printf "$prefix_format",'dob','';
	printf "$display_format\n",'Date of birth',${$cbor}[1][2]{-260}{1}{'dob'};
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

=item --dump

Dump the CBOR object.

=back

=cut
