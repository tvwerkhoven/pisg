package Pisg::Parser::Format::mIRC;

# Documentation for the Pisg::Parser::Format modules is found in Template.pm

use strict;
$^W = 1;

sub new
{
    my ($type, %args) = @_;
    my $self = {
        cfg => $args{cfg},
        normalline => '^\[(\d+):\d+[^ ]+ <([^>]+)> (.*)',
        actionline => '^\[(\d+):\d+[^ ]+ \* (\S+) (.*)',
        thirdline  => '^\[(\d+):(\d+)[^ ]+ \*\*\* (.+)'
    };

    bless($self, $type);
    return $self;
}

sub normalline
{
    my ($self, $line, $lines) = @_;
    my %hash;

    if ($line =~ /$self->{normalline}/o) {

        $hash{hour}   = $1;
        $hash{nick}   = remove_prefix($2);
        $hash{saying} = $3;

        return \%hash;
    } else {
        return;
    }
}

sub actionline
{
    my ($self, $line, $lines) = @_;
    my %hash;

    if ($line =~ /$self->{actionline}/o) {

        $hash{hour}   = $1;
        $hash{nick}   = remove_prefix($2);
        $hash{saying} = $3;

        return \%hash;
    } else {
        return;
    }
}

sub thirdline
{
    my ($self, $line, $lines) = @_;
    my %hash;

    if ($line =~ /$self->{thirdline}/o) {

        my @line = split(/\s/, $3);

        $hash{hour} = $1;
        $hash{min}  = $2;
        $hash{nick} = remove_prefix($line[0]);

        if ($#line >= 4 && ($line[1].$line[2]) eq 'waskicked') {
            $hash{kicker} = $line[4];

        } elsif ($#line >= 4 && ($line[1] eq 'changes')) {
            $hash{newtopic} = join(' ', @line[4..$#line]);
            $hash{newtopic} =~ s/^'//;
            $hash{newtopic} =~ s/'$//;

        } elsif ($#line >= 3 && ($line[1].$line[2]) eq 'setsmode:') {
            $hash{newmode} = join(' ', @line[3..$#line]);

        } elsif ($#line >= 3 && ($line[2].$line[3]) eq 'hasjoined') {
            $hash{newjoin} = $line[0];

        } elsif ($#line >= 5 && ($line[2].$line[3]) eq 'nowknown') {
            $hash{newnick} = $line[5];
        }

        return \%hash;

    } else {
        return;
    }
}

sub remove_prefix
{
    my $str = shift;

    $str =~ s/^@//;
    $str =~ s/^\+//;

    return $str;

}

1;
