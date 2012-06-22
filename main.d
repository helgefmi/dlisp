module main;

import std.stdio : writeln;

import env;
import eval : eval;
import expr;
import parse : parse;

void main() {
    BodyExpr body_ = parse("
        (define rec (lambda (n)
            (print n)
            (if (> n 0)
                (rec (- n 1)))))
        (rec 10)

        (define a
            (lambda (a)
                (lambda (b)
                    (* a b))))
        (define b ((a 9) 8))
        (print b)
        (print ((a 10) 8))
        (print b)

        (define nfac (lambda (n)
            (if (< n 2)
                1
                (* n (nfac (- n 1))))))
        (print (nfac 6))

        (define dofn (lambda (fn arg)
            (fn arg)))
        (print (dofn (lambda (x) (* x 9)) 9))

        (define fib
            (lambda (n)
                (if (< n 2)
                    1
                    (+ (fib (- n 1 )) (fib (- n 2))))))
        (print (fib 26))
    ");
    assert(body_ !is null, "Couldn't parse");

    writeln("input: " ~ body_.toString());

    auto env = new Enviroment(new Enviroment());
    auto result = eval(body_, env);

    writeln(result);
}
