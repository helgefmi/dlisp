module env;

import std.stdio : writeln;
import std.array : join;

import eval : eval;
import expr;

string binary_arithmetic_fn(string inner) {
    return "
        new FunctionExpr(function Expr(Enviroment env, Expr[] args) {
            return new NumberExpr((cast(NumberExpr)(eval(args[0], env))).i " ~ inner ~ " (cast(NumberExpr)(eval(args[1], env))).i);
        })
    ";
}

string binary_boolean_fn(string inner) {
    return "
        new FunctionExpr(function Expr(Enviroment env, Expr[] args) {
            bool cond = (cast(NumberExpr)(eval(args[0], env))).i " ~ inner ~ " (cast(NumberExpr)(eval(args[1], env))).i;
            return env.get(cond ? \"true\" : \"false\");
        })
    ";
}

/* Enviroment */
class Enviroment {
    Expr[char[]] env;
    Enviroment parent = null;
    this() {
        env["false"] = new NumberExpr(0);
        env["true"] = new NumberExpr(1);
        env["*"] = mixin(binary_arithmetic_fn("*"));
        env["+"] = mixin(binary_arithmetic_fn("+"));
        env["/"] = mixin(binary_arithmetic_fn("/"));
        env["-"] = mixin(binary_arithmetic_fn("-"));
        env[">"] = mixin(binary_boolean_fn(">"));
        env["<"] = mixin(binary_boolean_fn("<"));
        env["print"] = new FunctionExpr(function Expr(Enviroment env, Expr[] args) {
            string[] new_args;
            foreach(ref arg; args) {
                new_args ~= eval(arg, env).toString();
            }
            writeln(join(new_args, ","));
            return env.get("false");
        });
        env["lambda"] = new FunctionExpr(function Expr(Enviroment env, Expr[] args) {
            auto params = cast(ListExpr)(args[0]);
            string[] params_str;
            foreach (ref expr; params.arr) {
                params_str ~= (cast(SymbolExpr)(expr)).symbol;
            }
            return new LambdaExpr(params_str, new BodyExpr(args[1 .. $]), env);
        });
        env["define"] = new FunctionExpr(function Expr(Enviroment env, Expr[] args) {
            auto key = cast(SymbolExpr)(args[0]);
            auto value = eval(args[1], env);
            env.set(key.symbol, value);
            return value;
        });
        env["if"] = new FunctionExpr(function Expr(Enviroment env, Expr[] args) {
            auto cond = cast(NumberExpr)(eval(args[0], env));
            if (cond is null || cond.i != 0) {
                return eval(args[1], env);
            } else if (args.length > 2) {
                return eval(args[2], env);
            }
            return env.get("false");
        });
    }
    this(Enviroment parent) {
        this.parent = parent;
    }

    void set(in string key, Expr val) {
        auto result = has_key(key);
        if (result !is null) {
            *result = val;
        }
        else {
            env[key] = val;
        }
    }

    Expr get(string key) {
        auto result = key in env;
        return result !is null ? *result : parent.get(key);
    }

    Expr *has_key(string key) {
        auto result = key in env;
        return result ? result : (parent !is null ? parent.has_key(key) : null);
    }
}

