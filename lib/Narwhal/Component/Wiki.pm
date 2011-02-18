package Narwhal::Component::Wiki;
use Moose;

with 'Narwhal::Component::Role::Wiki';

sub page {
    my $self = shift;
    my ($req, $page_name) = @_;

    my $page = $self->lookup("page:$page_name");
    if (!$page) {
        my $res = $req->new_response(303);
        $res->location(
            $req->uri_for({
                action     => 'edit',
                page_name  => $page_name,
            })
        );
        return $res;
    }

    $self->render(
        $req,
        'page.tt',
        {
            page     => $page_name,
            text     => $page->text,
            author   => $page->author,
            modified => $page->modification_date,
        },
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
