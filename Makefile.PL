use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Lingua::Tatoeba',
    AUTHOR        => 'Larion Garaczi <larion@cpan.org>',
    VERSION_FROM  => 'lib/Lingua/Tatoeba.pm',
    ABSTRACT_FROM => 'lib/Lingua/Tatoeba.pm',
    PREREQ_PM => {
        'Moose'                     => 0,
        'MooseX::HasDefaults::RO'   => 0,
        'MooseX::StrictConstructor' => 0,
        'namespace::autoclean'      => 0,
        'Carp'                      => 0,
        'Test::More'                => 0,
    },
);
