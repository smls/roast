use v6;
use Test;

plan 20;

# L<S04/The Relationship of Blocks and Declarations/"our $foo" introduces a lexically scoped alias>
our $a = 1;
{ # create a new lexical scope
    is($a, 1, '$a is still the outer $a');
    { # create another new lexical scope
        my $a = 2;
        is($a, 2, '$a is now the lexical (inner) $a');
    }
}
is($a, 1, '$a has not changed');

# should it be allowed to declare our-scoped vars more than once?
{
    our $a = 3;
    is($a, 3, '$a is now another lexical (inner) $a');
}
is($a, 3, '$a has changed'); # XXX is that right?

# test that our (@array, @otherarray) correctly declares
# and initializes both arrays
{
    our (@a, @b);
    lives_ok { @a.push(2) }, 'Can use @a';
    lives_ok { @b.push(3) }, 'Can use @b';
    is ~@a, '2', 'push actually worked on @a';
    is ~@b, '3', 'push actually worked on @b';
}

our $c = 42; #OK not used
{
    my $c = $c;
    nok( $c.defined, 'my $c = $c; can not see the value of the outer $c');
}

# check that our-scoped variables really belong to the package
{
    package D1 {
        our $d1 = 7;
        is($d1, 7, "we can of course see the variable from its own package");
        
        package D2 {
            our $d2 = 8;
            {
                our $d3 = 9;
            }
            {
                eval_dies_ok('$d3', "variables aren't seen within other lexical child blocks");
                is($D2::d3, 9, "variables are seen within other lexical child blocks via package");
                
                package D3 {
                    eval_dies_ok('$d3', " ... and not from within child packages");
                    is($D2::d3, 9, " ... and from within child packages via package");
                }
            }
            eval_dies_ok('d3', "variables do not leak from lexical blocks");
            is($D2::d3, 9, "variables are seen from lexical blocks via pacakage");
        }
        eval_dies_ok('$d2', 'our() variable not yet visible outside its package');
        eval_dies_ok('$d3', 'our() variable not yet visible outside its package');
        
    }
    eval_dies_ok('$d1', 'our() variable not yet visible outside its package');
}

# vim: ft=perl6
