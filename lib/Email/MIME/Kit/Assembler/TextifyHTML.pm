package Email::MIME::Kit::Assembler::TextifyHTML;
# ABSTRACT: textify some HTML arguments to assembly

use Moose;
extends 'Email::MIME::Kit::Assembler::Standard';

=head1 SYNOPSIS

In your F<manifest.yaml>:

  alteratives:
  - type: text/plain
    path: body.txt
    assembler:
    - TextifyHTML
    - html_args: [ body ]
  - type: text/html
    path: body.html

Then:

  my $email = $kit->assemble({
    body => '<div><p> ... </p></div>',
  });

The C<body> argument will be rendered intact in the the HTML part, but will
converted to plaintext before the plaintext part is rendered.

This will be done by
L<HTML::FormatText::WithLinks|HTML::FormatText::WithLinks>, using the arguments
provided in the C<formatter_args> assembler attribute.

=head1 BY THE WAY

There will probably exist a TextifyHTML renderer, someday, which will first
render the part with the parent part's renderer, and then convert the produced
HTML to text.  This would allow you to use one template for both HTML and text.

=cut

use HTML::FormatText::WithLinks;

has html_args => (
  is  => 'ro',
  isa => 'ArrayRef',
  default => sub { [] },
);

has formatter_args => (
  is  => 'ro',
  isa => 'HashRef',
  default => sub {
    return {
      before_link => '',
      after_link  => ' [%l]',
      footnote    => '',
      leftmargin  => 0,
    };
  },
);

has formatter => (
  is   => 'ro',
  isa  => 'HTML::FormatText::WithLinks',
  lazy => 1,
  init_arg => undef,
  default  => sub {
    my ($self) = @_;
    HTML::FormatText::WithLinks->new(
      %{ $self->formatter_args },
    );
  }
);

around assemble => sub {
  my ($orig, $self, $arg) = @_;
  my $local_arg = { %$arg };

  for my $key (@{ $self->html_args }) {
    next unless defined $local_arg->{ $key };
    $local_arg->{ $key } = $self->formatter->parse($local_arg->{ $key });
  }

  return $self->$orig($local_arg);
};

no Moose;
1;
