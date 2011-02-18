#!/usr/bin/perl -w
use warnings;
use strict;
use 5.010;
use File::Slurp;

# path to folder with tools - Assembler and Hardware Simulator
my $pathtool = '/home/vk/Desktop/repository/tecs/software';
# path to folder with .asm specifications
my $pathtest = '/home/vk/Desktop/repository/tecs/testjump';
my $base = "CPUnomemory"; # base name for the file

my $asm = "$pathtest/$base.asm"; # assembler file
my $hack = "$pathtest/$base.hack"; # hack file
my $tst = "$pathtest/$base.tst"; # tst file
my $out = "$pathtest/$base.out"; # output file
my $cmp = "$pathtest/$base.out"; # compare file

my $tool = "$pathtool/Assembler.sh"; # Assembler tool
my $toolH = "$pathtool/HardwareSimulator.sh"; # Hardware Simulator tool

# get rid of old files if they exist
if (-e $hack) { unlink ($hack); } 
if (-e $tst) { unlink ($tst); } 
if (-e $out) { unlink ($out); } 
if (-e $cmp) { unlink ($cmp); }

# produce a new .hack fie
system ("$tool $asm");

# create a header for a test script without 'compare-to option'
my $header1 = "load CPU.hdl,\noutput-file $base.out,";
my $header2 = "output-list time%S0.4.0 instruction%B0.16.0 pc%D0.4.0 DRegister[]%D1.2.1;\n\n";
my $header = $header1."\n".$header2;
my $addcmp = "\ncompare-to $base.cmp,", # compare-to option

# read hack file and create scalar with 'set instruction' test spaecification
my @hack = read_file ($hack);  
my $text;
for (@hack) {
    $_ =~ s/\n//;    
    $text .= 'set instruction %B'.$_.", tick, tock, output;\n";
}

# write a test script and execute it
write_file ($tst, $header.$text); 
`$toolH $tst`;

# read the output and print it to STDOUT
my $output = read_file($out);
say $output;

# write the output to compare file and regenarate
# test script with compare-to option
write_file($cmp,$output);
write_file($tst,$header1.$addcmp."\n".$header2.$text);