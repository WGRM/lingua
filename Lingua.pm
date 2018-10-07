use CommentableLanguage;
use Number;

grammar Lingua is CommentableLanguage does Number {
    rule TOP {
        [
            | <one-line-comment>
            | <statement> ';'
        ]*
    }

    rule statement {
        | <variable-declaration>
        | <assignment>
        | <function-call>
    }

    rule variable-declaration {
        'my' <variable-name> [ '=' <value> ]?
    }

    rule assignment {
        <variable-name> '=' <value>
    }

    rule function-call {
        <function-name> <value>
    }

    rule value {
        | <expression>
        | <string>
    }

    token variable-name {
        [<:alpha> | '_'] \w*
    }

    token function-name {
        'say' | 'show'
    }

    multi token op(1) {
        '+' | '-'
    }

    multi token op(2) {
        '*' | '/'
    }

    multi token op(3) {
        '**'
    }

    rule expression {
        <expr(1)>
    }

    multi rule expr($n) {
        <expr($n + 1)>+ %% <op($n)>
    }

    multi rule expr(4) {
        | <number>
        | <variable-name> [ '[' <integer> ']' ]?
        | '(' <expression> ')'
    }

    token string {
        '"' ( [
              | <-["\\$]>+
              | '\\"'
              | '\\\\'
              | '\\$'
              | '$' <variable-name>
              ]* )
        '"'
    }
}
