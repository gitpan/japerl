@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S "%0" %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
exit /b %errorlevel%
goto endofperl
@rem ';
#!perl
#line 15
undef @rem;
######################################################################
#
# japerl - JPerl-again Perl (glocalization scripting environment)
#
# Copyright (c) 2013 INABA Hitoshi <ina@cpan.org>
#
######################################################################
$VERSION =
$VERSION = sprintf '%d.%02d', q$Revision: 0.01 $ =~ /(\d+)/oxmsg;

use strict;
use 5.00503;

# command-line parameter not found
unless (@ARGV) {
    die "@{[__FILE__]}: usage: $0 script.pl argv1 argv2 ...\n";
}

# script not found
if (not -e $ARGV[0]) {
    die "@{[__FILE__]}: $ARGV[0] not found.\n";
}

# load configuration file
%_ = %{ (do "$0.conf") || {} };

# rewrite environment variable PATH
if ($_{PERL5BIN} ne $^X) {
    require Config;
    require File::Basename;
    $ENV{PATH} = join $Config::Config{path_sep},
        File::Basename::dirname($_{PERL5BIN}),
        grep {not -e ("$_/". File::Basename::basename($^X))}
            split $Config::Config{path_sep}, $ENV{PATH};
}

# use source filter
if ($_{ENCODING} and ($ARGV[0] !~ /\.e$/)) {

    # escaped script not found or older than original script
    if ((not -e "$ARGV[0].e") or (-M "$ARGV[0].e" > -M $ARGV[0])) {

        # find source filter
        unless (($_) = grep {-e "$_/$_{ENCODING}.pm"} @{$_{PERL5LIB}}, @INC) {
            die "@{[__FILE__]}: source filter $_{ENCODING}.pm not found.\n";
        }

        # escape script
        if (system join ' ', $_{PERL5BIN}||$^X, "$_/$_{ENCODING}.pm", $ARGV[0], '>', "$ARGV[0].e") {
            die "@{[__FILE__]}: $ARGV[0] had compilation errors.\n";
        }
    }
    $ARGV[0] .= '.e';
}

# execute escaped script
exit system $_{PERL5BIN}||$^X, (map {"-I$_"} @{$_{PERL5LIB}}), @ARGV;

__END__

=pod

=head1 NAME

japerl - JPerl-again Perl (glocalization scripting environment)

=head1 SYNOPSIS

  japerl script.pl argv1 argv2 ...

=head1 DESCRIPTION

japerl provides glocalization script environment on both modern Perl
and traditional Perl by using Sjis software family.

This software is useful also for:

=over 4

=item * if you ain't a system administrator

=item * if you want to use a perl of perls

=item * if you want to manage versions of library

=item * if you want to share library with perls

=back

=head1 INSTALLATION

=over 4

=item 1 Install a member of Sjis software family.

=item 2 Copy japerl.bat and japerl.bat.conf to any directory.

=item 3 Customize japerl.bat.conf.

=back

=head1 BUGS and LIMITATIONS

I have tested and verified this software using the best of my ability.
However, a software containing much regular expression is bound to contain
some bugs. Thus, if you happen to find a bug that's in Sjis software and not
your own program, you can try to reduce it to a minimal test case and then
report it to the following author's address. If you have an idea that could
make this a more useful tool, please let everyone share it.

=head1 AUTHOR

INABA Hitoshi E<lt>ina@cpan.orgE<gt>

This project was originated by INABA Hitoshi.

=head1 LICENSE AND COPYRIGHT

This software is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=head1 SEE ALSO

=over 4

=item * L<Glocalization|http://en.wikipedia.org/wiki/Glocalization> - Wikipedia

=item * L<JPerl|http://www.cpan.org/authors/id/W/WA/WATANABE/> - Japanized Perl or Japanese Perl

=item * L<Sjis software family|http://search.cpan.org/~ina/> - CPAN

=item * L<The BackPAN|http://backpan.perl.org/authors/id/I/IN/INA/> - A Complete History of CPAN

=back

=cut

:endofperl
