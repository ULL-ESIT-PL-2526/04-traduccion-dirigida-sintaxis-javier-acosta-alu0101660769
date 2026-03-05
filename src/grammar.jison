/* Lexer */
%lex
%%
\/\/[^\n]*             { /* skip single-line comments */ }
\s+                    { /* skip whitespace */ }
[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?   { return 'NUMBER'; }
"**"                   { return 'OPOW'; }
[*/]                   { return 'OPMU'; }
[+-]                   { return 'OPAD'; }

"("                    { return '('; }
")"                    { return ')'; }

<<EOF>>                { return 'EOF'; }
.                      { return 'INVALID'; }
/lex

/* Parser */
%start L

%token NUMBER OPAD OPMU OPOW EOF

%%

L
    : E EOF
        { return $E; }
    ;

E
    : E OPAD T
        { $$ = operate($OPAD, $E, $T); }
    | T
        { $$ = $T; }
    ;

T
    : T OPMU R
        { $$ = operate($OPMU, $T, $R); }
    | R
        { $$ = $R; }
    ;

R
    : F OPOW R
        { $$ = operate($OPOW, $F, $R); }
    | F
        { $$ = $F; }
    ;

F
    : NUMBER
        { $$ = Number(yytext); }
    | '(' E ')'
        { $$ = $E; }
    ;
%%

function operate(op, left, right) {
    switch (op) {
        case '+': return left + right;
        case '-': return left - right;
        case '*': return left * right;
        case '/': return left / right;
        case '**': return Math.pow(left, right);
    }
}
