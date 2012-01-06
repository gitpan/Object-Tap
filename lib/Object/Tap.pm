package Object::Tap;

use 5.006;
use strict;

BEGIN {
	$Object::Tap::AUTHORITY = 'cpan:TOBYINK';
	$Object::Tap::VERSION   = '0.001';
}

use base qw/Object::Role/;
use Carp qw/croak/;
use Scalar::Util qw/blessed/;
use Object::AUTHORITY;
use Object::DOES;

{ my $_eval    = bless \do{my$x='EVAL'};     sub EVAL ()    { $_eval }    }
{ my $_no_eval = bless \do{my$x='NO_EVAL'};  sub NO_EVAL () { $_no_eval } }

sub import
{
	my $class = shift;
	
	my ($caller, %args) = __PACKAGE__->parse_arguments(-method => @_);
	$args{-method} //= ['tap'];
	
	foreach my $method (@{ $args{-method} })
	{
		foreach my $pkg (@{ ref $caller ? $caller : [$caller] })
		{
			__PACKAGE__->install_method($method => \&_tap, $pkg);
		}
	}
}

sub _tap
{
	my $self = shift;
	my %flags;
	
	while (@_)
	{
		my $next = shift;
		
		if (ref $next eq 'SCALAR' or ref $next eq __PACKAGE__)
		{
			if ($$next =~ m{^(no_?)?(.+)$}i)
			{
				$flags{ uc $2 } = $1 ? 0 : 1;
				next;
			}
		}
		
		if (ref $next eq 'CODE'
		or not ref $next
		or (blessed $next and $next->can('(&{}')))
		{
			my $args = (ref $_[0] eq 'ARRAY') ? shift : [];
			my $code = ref $next
				? $next
				: sub { $self->$next(@_) };
			
			if ($flags{ EVAL })
			{
				local $_ = $self;
				eval { $code->(@$args) }
			}
			else
			{
				local $_ = $self;
				do { $code->(@$args) }
			}
			
			next;
		}
		
		croak qq/Unsupported parameter to Object::Tap-provided method: $next/;
	}
	
	return $self;
}

__FILE__
__END__

=head1 NAME

Object::Tap - a ruby-inspired tap method for your objects

=head1 SYNOPSIS

 {
   package My::Class;
   use Object::Tap;
   sub new { ... }
   sub dump { ... ; return $string }
 }
 
 my $obj    = My::Class->new;
 my $return = $obj->tap(sub { warn "here"; return "blah" });
 
 use Test::More;
 is $obj, $return, "tap method returns the invocant";

=head1 DESCRIPTION

This module has nothing to do with the Test Anything Protocol (TAP, see
L<Test::Harness>).

This module is a (non-Moose) role for your class, providing it with a
C<tap> method. The C<tap> method is an aid to chaining. You can do for
example:

 $object
   ->tap( sub{ $_->foo(1) } )
   ->tap( sub{ $_->bar(2) } )
   ->tap( sub{ $_->baz(3) } );

... without worrying about what the C<foo>, C<bar> and C<baz> methods
return, because C<tap> always returns its invocant.

The C<tap> method also provides a few shortcuts, so that the above can
actually be written:

 $object->tap(foo => [1], bar => [2], baz => [3]);

... but more about that later. Anyway, this module provides one
method for your class - C<tap> - which is described below.

=head2 C<< tap(@arguments) >>

This can be called as an object or class method, but is usually used as
an object method.

Each argument is processed in the order given. It is processed differently,
depending on the kind of argument it is.

=head3 Coderef arguments

An argument that is a coderef (or a blessed argument that overloads
C<< &{} >> - see L<overload>) will be executed in a context where
C<< $_ >> has been set to the invocant of the tap method C<tap>. The
return value of the coderef is ignored. For example:

 { package My::Class; use Object::Tap; }
 print My::Class->tap( sub { warn uc $_; return 'X' } );

... will warn "MY::CLASS" and then print "My::Class".

Because each argument to C<tap> is processed in order, you can provide
multiple coderefs:

 print My::Class->tap(
   sub { warn uc $_; return 'X' },
   sub { warn lc $_; return 'Y' },
   );

=head3 String arguments

A non-reference argument (i.e. a string) is treated as a shortcut
for a method call on the invocant. That is, the following two taps
are equivalent:

 $object->tap( sub{$_->foo(@_)} );
 $object->tap( 'foo' );

=head3 Arrayref arguments

An arrayref is dereferenced yielding a list. This list is passed as
an argument list when executing the previous coderef argument (or
string argument). The following three taps are equivalent:

 $object->tap(
   sub { $_->foo('bar', 'baz') },
   );
 $object->tap(
   sub { $_->foo(@_) },
   ['bar', 'baz'],
   );
 $object->tap(
   foo => ['bar', 'baz'],
   );

=head3 Scalar ref arguments

There are a handful of special scalar ref arguments that are supported:

=over

=item C<< \"EVAL" >>, C<< Object::Tap::EVAL >>

This indicates that you wish for all subsequent coderefs to be wrapped in
an C<eval>, making any errors that occur within it non-fatal.

 $object->tap(\"EVAL", sub {...});

In case you dislike weird scalar references in your code, this should
also work:

 $object->tap(Object::Tap::EVAL, sub {...});

=item C<< \"NO_EVAL" >>, C<< Object::Tap::NO_EVAL >>

Switches back to the default behaviour of not wrapping coderefs in
C<eval>.

 $object->tap(
   Object::Tap::EVAL,
   sub {...},   # any fatal errors will be caught and ignored
   Object::Tap::NO_EVAL,
   sub {...},   # fatal errors are properly fatal again.
   );

=back

=head2 Importing from Object::Tap

Object::Tap provides a number of cool import features. Firstly, what if
you like the idea of a C<tap> method but don't like the name "tap"?
Easy, just give the method a different name:

 use Object::Tap 'execute_and_return_self'; # silly long name

You can even create multiple methods:

 use Object::Tap qw/execute_and_return_self exec_return/;

You can quite easily install C<tap> into somebody else's class too:

 use Object::Tap -package => 'LWP::UserAgent';

or multiple classes:

 use Object::Tap -package => [
   qw/LWP::UserAgent HTTP::Response HTTP::Request/
   ];

or even all classes (though this is probably not desirable):

  use Object::Tap -package => 'UNIVERSAL';

And these options can be combined:

 use Object::Tap 'exec_return', -package => 'UNIVERSAL';

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Object-Tap>.

=head1 SEE ALSO

L<http://tea.moertel.com/articles/2007/02/07/ruby-1-9-gets-handy-new-method-object-tap>,
L<http://prepan.org/module/3Yz7PYrBLN>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2012 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

