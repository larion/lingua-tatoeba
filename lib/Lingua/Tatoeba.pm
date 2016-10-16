package Lingua::Tatoeba;

use Moose;
use MooseX::HasDefaults::RO;
use MooseX::StrictConstructor;
use namespace::autoclean;
use autodie;

use Lingua::Tatoeba::Item;

has sentences => (
    isa => 'Str',
    is  => 'ro',
    required => 1,
);

has links => (
    isa => 'Str',
    is  => 'ro',
    required => 1,
);

has languages => (
    isa => 'ArrayRef[Str]',
    is  => 'ro',
    required => 1,
);

has _sentences_per_lang => (
    isa => 'HashRef',
    is  => 'ro',
    init_arg => undef,
    default => sub { {} },
);

has _sentences => (
    isa => 'ArrayRef',
    is  => 'ro',
    init_arg => undef,
    default => sub { [] },
);

has _links => (
    isa => 'ArrayRef',
    is  => 'ro',
    init_arg => undef,
    default => sub { [] },
);

sub BUILD {
    my $self = shift;

    open(my $sentences_fh, '<:utf8', $self->sentences);
    while (my $line = <$sentences_fh>) {
        my ($id, $lang, $text) = split("\t", $line);
        chomp $text;
        if (grep {$_ eq $lang} @{$self->languages}) {
            $self->_sentences->[$id] = {
                lang => $lang,
                text => $text,
            };
        }
        $self->_sentences_per_lang->{$lang}->{$id} = 1;
    }

    close($sentences_fh);

    open(my $links_fh, '<:utf8',  $self->links);
    while (my $line = <$links_fh>) {
        my ($from, $to) = split("\t", $line);
        if ($self->_sentences->[$from] && $self->_sentences->[$to]) {
            push @{$self->_links->[$from]}, $to;
        }
    }
    close($links_fh);
}

sub get {
    my ($self, $id) = @_;
    my $sentence = $self->_sentences->[$id];
    if (!$sentence) {
        return;
    }

    my %sentence = %$sentence;
    return Lingua::Tatoeba::Item->new({
        id         => 0+$id,
        collection => $self,
        %$sentence
    });
}

sub get_related {
    my ($self, $id) = @_;
    my $ids = $self->_links->[$id];
    my @ids = $ids ? @$ids : ();
    my @results = map $self->get($_), @ids;
    return wantarray ? @results : [@results];
}

sub get_ids_by_lang {
    my ($self, $lang) = @_;
    my @ids = keys %{$self->_sentences_per_lang->{$lang}};
    return wantarray ? @ids : \@ids;
}

__PACKAGE__->meta->make_immutable();
no Moose;
1;

=pod

=head1 NAME

Lingua::Tatoeba - Tatoeba library

=head1 SYNOPSIS

    use Lingua::Tatoeba;

    my $tatoeba = Lingua::Tatoeba->new(
        languages      => ['eng', 'deu', 'ita', 'cmn'],
        sentences      => 'sentences.csv',
        links          => 'links.csv',
    );

    my ($id) = $tatoeba->get_ids_by_lang('eng'); # pick an arbitrary English sentence
    my $sentence_en = $tatoeba->get($id);
    say $sentence_en->text;
    my ($sentence_de) = grep $_->lang eq 'deu', $sentence_en->get_related;
    say $sentence_de->text;

=head1 DESCRIPTION

Library to access the L<Tatoeba|https://tatoeba.org> CSV dumps programmatically

=head1 FUNCTIONS

=head2 my $tatoeba = Lingua::Tatoeba->new(languages => $languages, sentences => 'sentences.csv', links => 'links.csv')

Initialize a Tatoeba object. Warning: This will load the whole CSV dump into
memory. You should restrict the languages to the ones you will actually use to
lower memory use. Still initialization takes some time and will use a couple
GB's of memory (patches welcome). You can also prepare your own sentences.csv
file if you don't need the 5 million or so sentences (as of Dec.  2016).

=head3 Arguments

=over 4

=item languages

An ArrayRef of language codes to actually store. Sentences in other languages will simply be ignored.

=item sentences

Path to the sentences.csv file.

=item links

Path to the links.csv file. You can get the up-to-date files from here: L<https://tatoeba.org/eng/downloads>.

=back

=head2 my $sentence = get($id)

Fetch a single sentence based on ID.

=head3 Arguments

=over 4

=item id

=back

=head3 Returns

A L<Lingua::Tatoeba::Item> with the following accessors:

=over 4

=item id

=item lang The ISO-639-3 language code for the sentence

=item text The sentence string itself

=back

=head2 my @sentences = get_related($id)

Fetch all the sentences related to one sentence.

=head3 Arguments

=over 4

=item id

=back

=head3 Returns

A list of L<Lingua::Tatoeba::Item> objects (see get)

=head2 get_ids_by_lang

Get the ids for a given language

=head3 Arguments

A language code (ISO-639-3)

=head3 Returns

A list of ids

=head1 AUTHOR

This module is written by Larion Garaczi <larion@cpan.org> (2016)

=head1 SOURCE CODE

The source code for this module is hosted on GitHub L<https://github.com/larion/lingua-tatoeba>.

Feel free to contribute :)

=head1 LICENSE AND COPYRIGHT

MIT License

Copyright (c) 2016 Larion Garaczi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

=begin private

=for pod_coverage

=head2 BUILD

=end private

=cut
