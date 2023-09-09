#!/usr/bin/perl
use autodie;
use warnings;
use strict;
$SIG{INT} = sub { system("stty icanon echo") };
my $t= ' ' x 8;
my $l = `tput lines`; my $o = +`tput cols`; my $O = " " x $o; my $h = ''; my @C = (); $, = $/;    #lines, columns, column spaces, readline hint, clipboard, append separator
system("tput clear");
for my $F (@ARGV) {
	my $f = my $c = my $b = 0; my $v = -1;    # first visible, cursor, background, visual mark
	my $K = '';    # last key (for QQ and ZZ and S)
	open my $H, '<', $F;
	chomp( my @L = <$H> );
	close $H;
	while ( $f > -1 ) {
		my $M = ( $v != -1 and $v < $c ) ? $v : $c; # Min line
		my $X = $v > $c ? $v : $c;                  # maX line
		my $D = $X - $M + 1;                        # line Difference
		system("tput civis; tput cup 0 0");
		for my $x ( $f .. $f + $l - 1 ) {
			my $V =$v != -1 && $x >= $M && $x <= $X;
			$_ = $x > $#L ? '' : $L[$x];
			s/\t/$t/g;
			$_ .= $O;
			print "\033[" . ( $V ? "7" : "" ) . "m" . substr( $_, 0, $o );
		}
		print "\033[m";
		system( "tput cnorm; tput cup "
			  . ( $c - $f )
			  . " 0; stty -icanon -echo min 1" );
		sysread STDIN, my $k, 1;
		system("stty icanon echo");
		$_ = $k;
		if (/j/) {
			$c++ if $c < $#L;
		} elsif(/k/) {
			$c-- if $c > 0;
		} elsif(/v/) {
			$v = $v != -1 ? -1 : $c;
		} elsif( /Q/ && $K eq 'Q' ) {
			$c = -1; # $f will follow
		} elsif( /Z/ && $K eq 'Z' ) {
			$c = -2; # $f will follow
		} elsif( /:/ or ( /@/ and $v != -1 ) ) {
			system( "tput cup " . ( $l - 1 ) . " 0" );
			print $O . "\r";
			my $C =`bash -c "read -rep :; printf '%s' "'"'"\$REPLY"'"'`;
			if (/@/) {
				@_ = @L[ $M .. $X ];
				eval $C;
				splice @L, $M, $D, @_;
			} else {
				for my $x ( $M .. $X ) {
					$_ = $L[$x];
					eval $C;
					$L[$x] = $_;
				}
			}
		} elsif(/J/) {
			if($v == -1) {$X++; $D++}
			$_ = '';
			for my $x ( $M .. $X ) { $_ .= $L[$x] . " "; }
			splice @L, $M, $D, $_;
			$v = -1;
		} elsif(/[dy]/) {
			@C = @L[ $M .. $X ];
			splice @L, $M, $D if /d/;
			$c-- if $c > $#L;
			$v = -1;
		} elsif(/h/) {
			for my $x ( $M .. $X ) { $h .= $L[$x]; }
			$v = -1;
		} elsif( $v == -1 ) {
			$c++ if /[op]/;
			if (/e/) {
				my $C = 'bash -c "';
				if ( $h ne '' ) {
					$h =~ s/'/'"'\\''"'/g;
					$C .= q#read -rei 'HINT: "'# . $h . q#'"'; #;
					$h = '';
				}
				$L[$c] =~ s/'/'"'\\''"'/g;
				$C .= q#read -rei '"'# . $L[$c] . q#'"'; printf '%s' "'"'"\$REPLY"'"'#;
				$_ = `$C`;
				$L[$c] = $_;
			} elsif( /S/ && $K eq 'S' ) {
				$L[ $c + 1 ] =~ s/(.)(.*)/$2/;
				$L[$c] .= $1;
			} elsif(/S/) {
				$L[$c] =~ s/(.)(.*)/$2/;
				splice @L, $c, 0, $1;
			} elsif(/[oO]/) {
				splice @L, $c, 0, '';
			} elsif(/[pP]/) {
				splice @L, $c, 0, @C;
			}
		}
		$K = $k;
		if ( $c < $f ) { $f = $c; }
		if ( $c >= $f + $l ) { $f = $c - $l + 1; }
	}
	if ( $f == -2 ) {
		open $H, '>', $F;
		print $H @L;
		close $H;
	}
}
system("tput reset");
