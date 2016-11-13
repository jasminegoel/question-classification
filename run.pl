use strict;
use warnings;
 
my $trfile= 'train_5500.label.txt';
open(my $tr, $trfile)
  or die "Could not open file '$trfile' $!";
 
my $train= 'train.csv';
open(my $trc,'>', $train)
  or die "Could not open file '$train' $!";
 
my %arr;
my $temp;
while (<$tr>) {
    if (/(.+?):(.+?) (.+)$/) {
    print $trc "$1;$2; $3\n";
}
}

#while (<$te>) {
#    if (/"(.+)"/) {
#    print "$1,$arr{$1}\n";
#}
#}
