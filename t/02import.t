use Test::More tests => 6;

{
	package Local::MyClass1;
	use Object::Tap;
	sub new { bless [@_] }
}

{
	package Local::MyClass2;
	use Object::Tap qw/tap2 tap_two/;
	sub new { bless [@_] }
}

{
	package Local::MyClass3;
	sub new { bless [@_] }
}

{
	package Local::MyClass4;
	use Object::Tap -package => 'Local::MyClass3', qw/tap4/;
	sub new { bless [@_] }
}

can_ok Local::MyClass1 => 'tap';
can_ok Local::MyClass2 => 'tap2';
can_ok Local::MyClass2 => 'tap_two';
can_ok Local::MyClass3 => 'tap4';
is(Local::MyClass2->can('tap2'), Local::MyClass2->can('tap_two'));
is(Local::MyClass2->can('tap2'), \&Object::Tap::_tap);
