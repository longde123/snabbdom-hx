package snabbdom;

import haxe.macro.Expr;
import haxe.macro.Context;
#if !macro
import snabbdom.dom.VirtualNodeDom;
#end
using haxe.macro.ComplexTypeTools;
using haxe.macro.MacroStringTools;
using haxe.macro.ExprTools;
using Lambda;
using StringTools;

class H {


    inline static function get_key_value(expr, ?key, ?value) {

        return switch(expr.expr) {
            case EObjectDecl(fields):[for (field in fields) [field.field, field.expr.toString()] ];
            case _:[];
        }

    }

    inline static function style_to_property(style:String) {
        var els = style.split("-");
        return els[0] + els.slice(1).map(function(s:String) { return s.toLowerCase(); }).join("");
    }


    inline static function parse_style_string(s:String, context) {

        var styles = s.replace('\"', "").split(";");

        var json = [for (style in styles) {
            var pair = style.split(":");

            pair[0] = style_to_property(pair[0]);
            [pair[0], pair[1]];

        }];

        var props = [];
        for (el in json) {
            var key = el[0];
            var value = if (el[1].indexOf("{") == 0) el[1].replace("{", "").replace("}", "");
            else '"${el[1]}"';
            props.push('$key:$value');
        }

        var style = '{' + props.join(",") + '}';


        //var expr = context.parse(style,context.currentPos());
        return style;

    }

    public macro static function h(exprs:Array<Expr>):ExprOf<VirtualNodeDom> {


        var sel = exprs[0];
        var data = exprs[1];

        var s = data.toString();


        var y = haxe.macro.Context.parse(s, haxe.macro.Context.currentPos());
        var fields = get_key_value(data);

        var keys = [for (field in fields) field[0]];


        var structure = 'attrs:untyped {' + [
            for (field in fields) if (
            field[0] != 'skip_styles' &&
            field[0] != 'skip_attributes' &&
            field[0] != 'style' &&
            field[0].indexOf('on') != 0) '${field[0]}:${field[1]}'
        ].join(",") + '}';

        var events = [];
        var key:String = null;

        for (field in fields) {
            //trace(fields);
            if (field[0] == 'style') {
                var style = parse_style_string(field[1], Context);
                structure = structure + ',style:untyped ${style}';
            }

            if (field[0] == 'key') {
                var value = field[1];
                structure = structure + ',key: ${value}';
            }


            if (field[0] == '___cache') {
                var value = field[1].replace('"', "");
                structure = structure + ',___cache: ${value}';
            }


            if (field[0] == 'skip_styles') {
                var value = field[1];
                structure = structure + ',skip_styles: ${value}';
            }

            if (field[0] == 'skip_attributes') {
                var value = field[1];
                structure = structure + ',skip_attributes: ${value}';
            }


            if (field[0].indexOf('on') == 0) {
                events.push([field[0].substr(2), field[1]]);
            }
        }

        if (keys.indexOf('props') == -1) structure += ',props:null';
        if (keys.indexOf('classes') == -1) structure += ',classes:null';
        if (keys.indexOf('style') == -1) structure += ',style:null';
        if (keys.indexOf('hook') == -1) structure += ',hook:null';


        if (events.length > 0) {
            var props = "{" + [for (event in events) '"${event[0]}":${event[1]}' ].join(",") + "}";
            structure = structure + ',on:untyped ${props}';

        }


        var data = Context.parse('{' + structure + '}', Context.currentPos());
        var rest = exprs.slice(2);

        var text = null;
        var str = rest[0].toString();
        text = if (str.indexOf('H.h') != -1) {
            null;
        } else {
            rest[0];
        }
        var rt_expr = null;

        rt_expr = if (text == null) {
            macro {
                {sel:$sel, data:$data, children:untyped $a{rest}, elm:null, text:null};
            }
        } else {
            macro {
                {sel:$sel, data:$data, children:null,elm:null, text:$e{text}};
            }
        };

        if (rest[0].toString().indexOf('"#') == 0) {
            rest[0] = Context.parse(rest[0].toString().replace("#", "").replace('\"', ""), Context.currentPos());
            var element = rest[0];
            rt_expr = macro {
                {sel:$sel, data:$data, children:untyped $e{element}, elm:null, text:null};
            }
        }


        return rt_expr;

    }

}
