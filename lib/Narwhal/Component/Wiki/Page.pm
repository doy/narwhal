package Narwhal::Component::Wiki::Page;
use Moose;

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

sub BUILD {
    my $self = shift;
    $self->scope;
}

sub get {
    my $self = shift;
    my ($req, $page) = @_;

    my $page_obj = $self->lookup("page:$page");
    return $req->new_response(404)
        unless $page_obj;

    my $out;
    $self->process(
        'page.tt',
        {
            uri_for => sub { $req->uri_for({@_}) },
            text    => $page_obj->text,
            page    => $page
        },
        \$out
    );

    return $req->new_response(200, [], $out);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
