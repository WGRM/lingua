class LinguaActions {
    has %!var;

    method TOP($/) {
        dd %!var;
    }

    method scalar-declaration($/) {
        %!var{$<variable-name>} = $<value> ?? $<value>.made !! 0;
    }

    method array-declaration($/) {
        %!var{$<variable-name>} = $[];
    }

    multi method assignment($/ where $<integer>) {
        %!var{~$<variable-name>}[+$<integer>] = $<value>.made;
    }

    multi method assignment($/ where !$<integer>) {
        %!var{~$<variable-name>} = $<value>.made;
    }

    method function-call($/) {
        say $<value>.made;
    }

    multi sub operation('+', $a is rw, $b) {
        $a += $b
    }

    multi sub operation('-', $a is rw, $b) {
        $a -= $b
    }

    multi sub operation('*', $a is rw, $b) {
        $a *= $b
    }

    multi sub operation('/', $a is rw, $b) {
        $a /= $b
    }

    multi sub operation('**', $a is rw, $b) {
        $a **= $b
    }

    multi method value($/ where $<expression>) {
        $/.make($<expression>.made);
    }

    multi method value($/ where $<string>) {
        $/.make($<string>.made);
    }

    method expression($/) {
        $/.make($<expr>.made);
    }

    multi method expr($/ where $<number>) {
        $/.make($<number>.made);
    }

    multi method expr($/ where $<string>) {
        $/.make($<string>.made);
    }

    multi method expr($/ where $<variable-name> && $<integer>) {
        if %!var{$<variable-name>} ~~ Array {
            $/.make(%!var{$<variable-name>}[+$<integer>]);
        }
        else {
            $/.make(%!var{$<variable-name>}.substr(+$<integer>, 1));
        }
    }

    multi method expr($/ where $<variable-name> && !$<integer>) {
        $/.make(%!var{$<variable-name>});
    }

    multi method expr($/ where $<expr>) {
        $/.make(process($<expr>, $<op>));
    }

    multi method expr($/ where $<expression>) {
        $/.make($<expression>.made);
    }

    sub process(@data, @ops) {
        my @nums = @data.map: *.made;
        my $result = @nums.shift;

        operation(~@ops.shift, $result, @nums.shift) while @nums;

        return $result;
    }

    method number($/) {
        $/.make(+$/);
    }

    method string($a) {
        my $s = ~$a[0];

        for $a[0]<variable-name>.reverse -> $var {
            $s.substr-rw($var.from - $a.from - 2, $var.pos - $var.from + 1) = %!var{$var};
        }

        $s ~~ s:g/\\\"/"/;
        $s ~~ s:g/\\\\/\\/;
        $s ~~ s:g/\\\$/\$/;

        $a.make($s);
    }
}
