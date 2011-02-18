package Narwhal::Component::Wiki::Page;
use Moose;

with 'Narwhal::Component::Role::Wiki';

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
