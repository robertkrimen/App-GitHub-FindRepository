package App::GitHub::FindRepository;

use warnings;
use strict;

=head1 NAME

App::GitHub::FindRepository - Determine the right case (mixed or lower) for a GitHub repository

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

    github-find-repository git://github.com/robertkrimen/Doc-Simply.git
    # git://github.com/robertkrimen/doc-simply.git

    github-find-repository robertkrimen,Doc-Simply
    # git://github.com/robertkrimen/doc-simply.git

    github-find-repository --pinger=./bin/git-ls-remote ...

    # ... or ...

    use App::GitHub::FindRepository

    my $url = App::GitHub::FindRepository->find( robertkrimen/Doc-Simply )
    # git://github.com/robertkrimen/doc-simply.git

=head1 DESCRIPTION

GitHub recently made a change that now allows mixed-case repository names. Unfortunately, their git daemon
will not find the right repository given the wrong case.

L<App::GitHub::FindRepository> (C<github-find-repository>) will first attempt to ping the mixed-case version, and,
failing that, will attempt to ping the lowercase version. It will return/print the valid repository url, if any

=head1 CAVEAT

Given a mixed-case repository, the find routine will try the mixed-case once, then the lowercase. It will not find anything
else

    github-find-repository robertkrimen/Doc-Simply

...will work, as long as the real repository is C<robertkrimen/Doc-Simply.git> or C<robertkrimen/doc-simply.git>

If the real repository is C<robertkrimen/dOc-sImPlY.git> then the finder will NOT see it

...that being said, let me know if you want/need something that is more findy

=head1 INSTALL

    cpan -i App::GitHub::FindRepository

You can also try using the bash script below if you need a quick-fix

=head1 USAGE

=head2 github-find-repository

A commandline application that will print out the the repository with the right casing

    Usage: github-find-repository [--pinger <pinger>] <repository>

        --pinger        The pinger to use (default is either git-ls-remote or git-peek-remote)

        <repository>    The repository to test, can be like:

                        git://github.com/robertkrimen/App-GitHub-FindRepository.git
                        robertkrimen/App-GitHub-FindRepository.git
                        robertkrimen,App-GitHub-FindRepository

=head2 $repository = AppGitHub::FindRepository->find( <repository> [, <pinger>] )

Given a mixed-case repository URI, it will return the version with the right case

=head2 A bash function as an alternative

If you do not want to install App::GitHub::FindRepository, here is a bash equivalent:

    #!/bin/bash

    function github-find-repository() {
        local pinger=`which git-ls-remote`
        if [ "$pinger" == "" ]; then pinger=`which git-peek-remote`; fi
        if [ "$pinger" == "" ]; then echo "Couldn't find pinger (git-ls-remote or git-peek-remote)"; return -1; fi
        local repository=$1
        if [ "`$pinger $repository 2>/dev/null`" ]; then echo $repository; return 0; fi
        repository=`echo $repository | tr "[:upper:]" "[:lower:]" `
        if [ "`$pinger $repository 2>/dev/null`" ]; then echo $repository; return 0; fi
        return -1
    }

    github-find-repository $*

=cut

use Getopt::Long;
use Env::Path qw/PATH/;

if (Env::Path->MSWIN) {
    require Cwd;
    (my $cwd = Cwd::getcwd()) =~ s{/}{\\}g;
    PATH->Remove($cwd);
    PATH->Prepend($cwd);
}

sub _find_in_path($) {

    for ( PATH->Whence( shift ) ) {
        return $_ if -f && -r _ && -x _;
    }

    return undef;
}

sub do_usage(;$) {
    my $error = shift;
    warn $error if $error;
    warn <<_END_;

Usage: github-find-repository [--pinger <pinger>] <repository>

    --pinger        The pinger to use (default is either git-ls-remote or git-peek-remote)

    <repository>    The repository to test, can be like:

                    git://github.com/robertkrimen/App-GitHub-FindRepository.git
                    robertkrimen/App-GitHub-FindRepository.git
                    robertkrimen,App-GitHub-FindRepository

_END_

    exit -1 if $error;
}

sub do_found($) {
    my $repository = shift;
    print "$repository\n";
    exit 0;
}

sub do_not_found($) {
    my $repository = shift;
    warn <<_END_;
$0: Repository \"$repository\" not found
_END_
    exit -1;
}

sub pinger {
    my $self = shift;
    return $ENV{GH_FR_PINGER} || _find_in_path 'git-ls-remote' || _find_in_path 'git-peek-remote';
}

sub find {
    my $self = shift;
    my $repository = shift;
    my $pinger = shift || $self->pinger;

    $repository =~ s/ //g;
    $repository =~ s/,/\//g;
    $repository = "$repository.git" unless $repository =~ m/\.git$/;
    $repository = "github.com/$repository" unless $repository =~ m/github\.com/;
    $repository = "git://$repository" unless $repository =~ m/git:\/\//;

    return $repository if !system( "$pinger $repository 1>/dev/null 2>/dev/null" );
    
    if ($repository =~ m/[A-Z]/) {
        my $repository = lc $repository;
        return $repository if !system( "$pinger $repository 1>/dev/null 2>/dev/null" );
    }

    return undef;
}

sub run {
    my $self = shift;
    
    my $pinger;
    GetOptions(
        'pinger=s' => \$pinger,
    );

    $pinger = $self->pinger unless $pinger;

    do_usage <<_END_ unless defined $pinger;
$0: No pinger given and couldn't find git-ls-remote or git-peek-remote in \$PATH
_END_

    my $repository = join '', @ARGV;

    do_usage <<_END_ unless $repository;
$0: You need to specify a repository
_END_

    {
        my $repository = $self->find( $repository, $pinger );

        do_found $repository if $repository;
    }

    do_not_found $repository;
}

=head1 AUTHOR

Robert Krimen, C<< <rkrimen at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-app-github-findrepository at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-GitHub-FindRepository>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::GitHub::FindRepository


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-GitHub-FindRepository>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-GitHub-FindRepository>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-GitHub-FindRepository>

=item * Search CPAN

L<http://search.cpan.org/dist/App-GitHub-FindRepository/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Robert Krimen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

__PACKAGE__; # End of App::GitHub::FindRepository
