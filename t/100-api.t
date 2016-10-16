#! /usr/bin/perl

use strict;
use warnings;

use Test::More;

require_ok('Lingua::Tatoeba');

my $tatoeba = Lingua::Tatoeba->new(
    sentences      => 't/inc/sentences_test.csv',
    links          => 't/inc/links_test.csv',
    languages      => [qw(eng deu)],
);

isa_ok($tatoeba, 'Lingua::Tatoeba');

my @ids = sort $tatoeba->get_ids_by_lang('eng');
is_deeply(\@ids, [1,4]);

is($tatoeba->get(3), undef, "sentence with language NLD filtered out");

my $sentence = $tatoeba->get(1);
isa_ok($sentence, 'Lingua::Tatoeba::Item');
can_ok($sentence, qw(id lang text collection get_related));
is($sentence->id, 1, "->id");
is($sentence->lang, "eng", "->lang");
is($sentence->text, 'test sentence', "->text");
is($sentence->collection, $tatoeba, "refers to parent");

my @ways_to_get_related = (
    sub { $sentence->get_related },
    sub { $tatoeba->get_related(1) },
);

for my $way (@ways_to_get_related) {
    my @related_ids = map {isa_ok($_, 'Lingua::Tatoeba::Item'); $_->id} sort {$a->id <=> $b->id} $way->();
    is_deeply(\@related_ids, [2, 5], "related_ids");
}

done_testing();
