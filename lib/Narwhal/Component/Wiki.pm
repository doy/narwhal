package Narwhal::Component::Wiki;
use Moose;

with 'Narwhal::Component::Role::Wiki';

sub page {
    my $self = shift;
    my ($req, $page) = @_;

    my $page_obj = $self->lookup("page:$page");
    return $req->new_response(404)
        unless $page_obj;

    $self->render(
        $req,
        'page.tt',
        {
            text => $page_obj->text,
            page => $page,
        },
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
