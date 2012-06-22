module eval;

import env;
import expr;

Expr eval(Expr expr, Enviroment env) {
    while (true) {
        assert(expr !is null);
        if (expr.classinfo is SymbolExpr.classinfo) {
            auto symbol = cast(SymbolExpr)(expr);
            return env.get(symbol.symbol);
        }
        else if (expr.classinfo is ListExpr.classinfo) {
            auto list = cast(ListExpr)(expr);
            Expr first = eval(list.arr[0], env);
            if (first.classinfo is FunctionExpr.classinfo) {
                auto fun = cast(FunctionExpr)(first);
                return fun.fn(env, list.arr[1 .. $]);
            }
            else {
                auto lambda = cast(LambdaExpr)(first);
                Enviroment newenv = new Enviroment(lambda.env);
                foreach (i, ref param; lambda.params) {
                    newenv.env[param] = eval(list.arr[i+1], env);
                }
                expr = lambda.body_;
                env = newenv;
            }
        }
        else if (expr.classinfo is NumberExpr.classinfo) {
            return expr;
        }
        else if (expr.classinfo is BodyExpr.classinfo) {
            auto body_ = cast(BodyExpr)(expr);
            foreach (ref e; body_.body_[0 .. $ - 1]) {
                eval(e, env);
            }
            expr = body_.body_[$-1];
        }
        else {
            writeln(expr.classinfo);
            assert(false, "wut");
        }
    }
}
