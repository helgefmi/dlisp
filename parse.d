module parse;

import std.string;
import std.stdio : writeln;

import expr;

int _match_pattern(in string source, in string valid_characters) {
    int i;
    for (; i < source.length && inPattern(source[i], valid_characters); ++i) {}
    return i;
}

Expr parse_body(ref string str) {
    Expr[] exprs;
    while (str.length > 0) {
        Expr expr = parse_expr(str);
        assert(expr !is null, "Couldn't parse. str=%s".format(str));
        exprs ~= expr;
        str = str.stripl();
    }
    return new BodyExpr(exprs);
}

Expr parse_expr(ref string str) {
    foreach(ref fn; [&parse_number, &parse_list, &parse_symbol]) {
        auto ret = fn(str);
        if (ret !is null) {
            return ret;
        }
    }
    return null;
}

Expr parse_symbol(ref string str) {
    const static string valid_symbols = uppercase ~ lowercase ~ "*/+-><=";
    int i = _match_pattern(str, valid_symbols);
    if (i > 0) {
        string symbol = str[0 .. i];
        str = str[i .. $];
        return new SymbolExpr(symbol);
    }
    return null;
}

Expr parse_number(ref string str) {
    int i = _match_pattern(str, digits);
    if (i > 0) {
        string digit = str[0 .. i];
        str = str[i .. $];
        return new NumberExpr(to!int(digit));
    }
    return null;
}

Expr parse_list(ref string str) {
    if (str[0] != '(') {
        return null;
    }

    str = str[1 .. $];
    Expr[] exprs;
    while (str[0] != ')') {
        Expr expr = parse_expr(str);
        assert(expr !is null, "Couldn't parse list. str=%s".format(str));
        exprs ~= expr;
        str = str.stripl();
        assert(str.length > 0, "Got EOF while parsing list");
    }
    str = str[1 .. $];
    return new ListExpr(exprs);
}

BodyExpr parse(string str) {
    str = str.strip();
    return cast(BodyExpr)(parse_body(str));
}
