package Narwhal::Component::Role::Wiki;
use Moose::Role;

has kioku => (
    isa      => 'KiokuX::Model',
    required => 1,
    handles  => [
        'get_user',
        'get_page',
        'get_page_rev',
        'create_page_rev',
        'new_scope',
        'txn_do',
    ],
);

has tt => (
    isa      => 'OX::View::TT',
    required => 1,
    handles  => ['render'],
);

has scope => (
    is      => 'ro',
    isa     => 'KiokuDB::LiveObjects::Scope',
    lazy    => 1,
    default => sub { shift->new_scope },
);

sub BUILD { }
after BUILD => sub {
    my $self = shift;
    $self->scope;
};

no Moose::Role;

1;
