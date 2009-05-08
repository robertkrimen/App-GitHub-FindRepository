#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More;

plan skip_all => "Only go out to the Internet for author" unless -e 'inc/.author';

plan qw/no_plan/;

use App::GitHub::FindRepository;

is( App::GitHub::FindRepository->find( 'robertkrimen,DBIx-Deploy' ), 'git://github.com/robertkrimen/dbix-deploy.git' );
is( App::GitHub::FindRepository->find( 'git://github.com/robertkrimen/Algorithm-BestChoice.git' ), 'git://github.com/robertkrimen/Algorithm-BestChoice.git' );
is( App::GitHub::FindRepository->find( 'git://github.com/robertkrimen/Algorithm-bestChoice.git' ), undef );
is( App::GitHub::FindRepository->find( 'robertkrimen/Algorithm-BestChoice.git' ), 'git://github.com/robertkrimen/Algorithm-BestChoice.git' );
is( App::GitHub::FindRepository->find( 'robertkrimen/Algorithm-BestChoice' ), 'git://github.com/robertkrimen/Algorithm-BestChoice.git' );
is( App::GitHub::FindRepository->find( 'github.com/robertkrimen/Algorithm-BestChoice' ), 'git://github.com/robertkrimen/Algorithm-BestChoice.git' );
