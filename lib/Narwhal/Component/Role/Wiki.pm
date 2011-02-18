package Narwhal::Component::Role::Wiki;
use Moose::Role;

has kioku => (
    isa      => 'KiokuX::Model',
    required => 1,
    handles  => 'KiokuDB::Role::API',
);

has tt => (
    isa      => 'Template',
    required => 1,
    handles  => ['process'],
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