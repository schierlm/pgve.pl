#!/usr/bin/perl
use autodie;
use warnings;
use strict;

<>;<>;eval<>;my $script=$_; # load script
my $bestwin=0; my $bestpart; my $bestcnt;
for my $offs(0 .. (length $script) - 1) {
	for my $len (2 .. length $script) {
		my $part = substr($script,$offs,$len);
		next if $len != length $part;
		my $pos = $offs;
		my $cnt = 0;
		while (1) {
			$pos = index($script, $part, $pos);
			last if($pos < 0);
			$cnt++;
			$pos++
		}
		my $win = $len * $cnt - (7 + $len + $cnt);
		if ($win > $bestwin) {
			print "Ho $offs $len $part $win\n";
			$bestwin=$win; $bestpart = $part; $bestcnt = $cnt;
		}
	}
}
my $free;
for (ord"A"..ord"Z",ord"a"..ord"z",ord"0"..ord"9",34..127) {
	if (index($script, chr $_) == -1) {
		$free = chr $_;
		last;
	}
}
print "You can save $bestwin characters by using $free instead of $bestcnt occurrences of\n#$bestpart#\n";
