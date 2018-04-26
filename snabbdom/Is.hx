package snabbdom;
import haxe.macro.Expr.ExprOf;
import haxe.macro.Expr;
class Is {

    public macro  static function is_array(obj:ExprOf<Any>) {
        return macro untyped Array.isArray($obj);
    }

    public macro static function is_primitive(obj:ExprOf<Any>) {
        return macro untyped __js__('typeof {0} == "string" || typeof {0} == "number"', $obj);
    }


    public macro static function isUndef(obj:ExprOf<Any>) { return macro untyped $obj == undefined; }

    public macro static function isDef(obj:ExprOf<Any>) { return macro untyped $obj != undefined; }


}
