# EUDCC Decode

`PERL(1)` script to decode EUDCC. EUDCC is used in actual health pass in France.

Made for educational purpose. You will NOT be able to build fake health pass with this script.

## Starting

Have `PERL(1)` installed.

### Pre-requisite

- [QRCode::Base45](https://metacpan.org/pod/QRCode::Base45)
- [MIME::Base64](https://metacpan.org/pod/MIME::Base64)
- [Compress::Raw::Zlib](https://metacpan.org/pod/Compress::Raw::Zlib)
- [CBOR::XS](https://metacpan.org/pod/CBOR::XS)
- perl-doc

### Installation

```
$ git clone https://github.com/Korsani/eudcc-decode
```

## Use

You can use un [barcode decoder](https://play.google.com/store/apps/details?id=com.google.zxing.client.android&hl=fr&gl=US) to read an EUDCC qrcode.

To decode EUDCC in human readable manner:

```
$ ./eudcc-decode --hc1 'HC1:6BFOXN%TSMAHN-H/N8KMQ8/8.:91 P1V8.9BXG4.YES25TSJ+NOHB692PXATAN9I6T5XH4PIQJAZGA+1V2:U:PI/E2W-2Y/K:*K57TKR2 6T+*431TDYKFVV*Q0AUV%*45O88L25SI:TU+MM0W5OV1AT1YEGYKMXEE5IAXMFU*GSHGRKMXGG6DBYCB-1JMJKR.KSHGXGG7EDA.D90I/EL6KKYHIL4O GLXCI.EJJ14B2MT6DXP07*435T.A5:S9S-O:S9395*CBVZ0*48$/P.T1NTICZUH%56PP9:9C4VB69X5QPDQFY1OSMNV1L8V1D1O M$1I8LEBE6 ZE+Y1GQU9OUPGUOL1M MKO1KWELS6+H18BH1EPRQ2*19:VO%4AW18HK8:QNC/BY5VDLF%L7V7NC$9T8E*YO$DUJRCJGKQ%7T.NUDJ4 RC7HE.TMFBCMO-7QC:9O6OPMQ-28O+3FGT3H0GD4SEE'
[hcert:1] Issuer: CY
[hcert:6] Issue: Fri Jul  9 11:25:27 2021
[hcert:4] Expire: Sat Jul  9 02:00:00 2022
[nam:fn ] Surname(s)                    : Andreou
[nam:fnt] Standardized surname(s)       : ANDREOU
[nam:gn ] Forename(s)                   : Andreas
[  v:ci ] UVCI                          : URN:UVCI:V1:CY:GD7MDSVTHLOXO6R98AU1BA7FSP
[  v:co ] Country                       : CY
[  v:dn ] Doses needed                  : 2
[  v:dt ] Last dose                     : 2021-07-09
[  v:is ] Issuer                        : MOH
[  v:ma ] Vax manufacturer              : ORG-100001417 (Janssen-Cilag International)
[  v:mp ] Vax product                   : EU/1/20/1525 (COVID-19 Vaccine Janssen)
[  v:sd ] Number of doses               : 2
[  v:tg ] Agent targeted                : 840539006 (COVID-19)
[  v:vp ] Vaccine or prophylaxis        : 1119305005 (SARS-CoV2 antigen vaccine)
[dob:   ] Date of birth                 : 1990-01-01

```

Or dump raw data:

```
$ ./eudcc-decode --dump --hc1 'HC1:6BFOXN%TSMAHN-H/N8KMQ8/8.:91 P1V8.9BXG4.YES25TSJ+NOHB692PXATAN9I6T5XH4PIQJAZGA+1V2:U:PI/E2W-2Y/K:*K57TKR2 6T+*431TDYKFVV*Q0AUV%*45O88L25SI:TU+MM0W5OV1AT1YEGYKMXEE5IAXMFU*GSHGRKMXGG6DBYCB-1JMJKR.KSHGXGG7EDA.D90I/EL6KKYHIL4O GLXCI.EJJ14B2MT6DXP07*435T.A5:S9S-O:S9395*CBVZ0*48$/P.T1NTICZUH%56PP9:9C4VB69X5QPDQFY1OSMNV1L8V1D1O M$1I8LEBE6 ZE+Y1GQU9OUPGUOL1M MKO1KWELS6+H18BH1EPRQ2*19:VO%4AW18HK8:QNC/BY5VDLF%L7V7NC$9T8E*YO$DUJRCJGKQ%7T.NUDJ4 RC7HE.TMFBCMO-7QC:9O6OPMQ-28O+3FGT3H0GD4SEE'
$VAR1 = bless( [                                                                                                                                                                              [0/528]
                 18,
                 [
                   {
                     '1' => -7,
                     '4' => 'M6'
                   },
                   {},
                   {
                     '4' => 1657324800,
                     '1' => 'CY',
                     '-260' => {
                                 '1' => {
                                          'nam' => {
                                                     'fnt' => 'ANDREOU',
                                                     'fn' => 'Andreou',
                                                     'gn' => 'Andreas'
                                                   },
                                          'dob' => '1990-01-01',
                                          'v' => [
                                                   {
                                                     'is' => 'MOH',
                                                     'tg' => '840539006',
                                                     'vp' => '1119305005',
                                                     'ma' => 'ORG-100001417',
                                                     'mp' => 'EU/1/20/1525',
                                                     'dt' => '2021-07-09',
                                                     'ci' => 'URN:UVCI:V1:CY:GD7MDSVTHLOXO6R98AU1BA7FSP',
                                                     'co' => 'CY',
                                                     'dn' => 2,
                                                     'sd' => 2
                                                   }
                                                 ],
                                          'ver' => '1.3.0'
                                        }
                               },
                     '6' => 1625822727
                   },
                   'aMJf3CQITbxb/iRxLX61Skk/LC52uLOGGpPQ2ChD/Z7GTVXQ82LrgJS7SvgQm6tqDVMT5sGU96/i
wvym4zwsWw==
'
                 ]
               ], 'CBOR::XS::Tagged' );
```

## License

GNU GPL v3

## Caveats

- Code is not the cleanest one you'll see
- Implementation is not complete

## See also

https://ec.europa.eu/health/sites/default/files/ehealth/docs/covid-certificate_json_specification_en.pdf

https://ec.europa.eu/health/sites/default/files/ehealth/docs/digital-green-value-sets_en.pdf

https://ec.europa.eu/health/sites/default/files/ehealth/docs/digital-green-certificates_dt-specifications_en.pdf

https://univalence.io/blog/articles/decoder-le-passe-sanitaire/

