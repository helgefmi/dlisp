module expr;

import std.string : format, to;
import std.array : join;

import env;

abstract class Expr {
    abstract string toString();
}

class NumberExpr : Expr {
    int i;
    this(int i) {
        this.i = i;
    }

    override final string toString() {
        return to!string(i);
    }
}

class SymbolExpr : Expr {
    string symbol;
    this(string symbol) {
        this.symbol = symbol;
    }

    override final string toString() {
        return "#" ~ symbol;
    }
}

class ListExpr : Expr {
    Expr[] arr;
    this(Expr[] arr) {
        this.arr = arr;
    }

    override final string toString() {
        string ret[];
        foreach (ref e; arr) {
            ret ~= e.toString();
        }
        return "(" ~ join(ret, " ") ~ ")";
    }
}

class BodyExpr : Expr {
    Expr[] body_;
    this(Expr[] body_) {
        this.body_ = body_;
    }

    override final string toString() {
        string[] ret;
        foreach (ref e; body_) {
            ret ~=  e.toString();
        }
        return "(" ~ join(ret, ", ") ~ ")";
    }
}

class FunctionExpr : Expr {
    Expr function(Enviroment, Expr[]) fn;
    this(Expr function(Enviroment, Expr[]) fn) {
        this.fn = fn;
    }

    override final string toString() {
        return "builtin function@%X".format(&this);
    }
}

class LambdaExpr : Expr {
    string[] params;
    BodyExpr body_;
    Enviroment env;
    this(string[] params, BodyExpr body_, Enviroment env) {
        this.params = params;
        this.body_ = body_;
        this.env = env;
    }

    override final string toString() {
        return "lambda function@%X".format(&this);
    }
}
