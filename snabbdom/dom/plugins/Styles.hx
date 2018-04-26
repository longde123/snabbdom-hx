package snabbdom.dom.plugins;

import snabbdom.dom.PatchDom.*;
using snabbdom.VirtualNodeDataTools;
class Styles {




    inline static function updateStyle(oldVnode:VirtualNodeDom, vnode:VirtualNodeDom) {
        var cur, name, elm:Dynamic = vnode.elm;

        var apply_styles = if (vnode.data.skip_styles == false) {
            true;
        } else {
            if (elm.cached_styles == null) {
                elm.cached_styles = true;
                true;
            } else {
                if (elm.cached_styles == true) {
                    false;
                } else {
                    true;
                }
            }
        }

        if (apply_styles) {
            var oldStyle = oldVnode.data.get_style_or_empty();
            var style = vnode.data.get_style_or_empty();

            for (_name in oldStyle.keys()) {
                var  name:String=_name;
                if (!style.exists(name)) {
                    if (name.charAt(0) == '-' && name.charAt(1) == '-') {
                        elm.style.removeProperty(name);
                    } else {
                        elm.style.setProperty(name, '');
                    }
                }
            }
            for (name in style.keys()) {
                cur = style[name];
                 if (name != 'remove' && cur != oldStyle[name]) {
                    untyped elm.style[name] = cur;
                }
            }


        }
    }

    inline static function applyDestroyStyle(vnode:VirtualNodeDom) {
        var style:DynamicObject<Dynamic> = null, name, elm = vnode.elm, s:Dynamic = vnode.data.style;
        if (s == null) return;
        style = untyped s.destroy;
        if (style == null) return;
        for (name in style.keys()) {
            untyped elm.style[name] = style[name];
        }
    }

    inline static function applyRemoveStyle(vnode:VirtualNodeDom, rm) {
        var s:Dynamic = vnode.data.style;
        if (!s || !s.remove) {
            if (rm != null) rm() ;
            return;
        }
        var name, elm = vnode.elm, idx, i = 0, maxDur = 0,
        compStyle:DynamicObject<String>, style:DynamicObject<Dynamic> = s.remove, amount = 0, applied = [];
        for (name in style.keys()) {
            applied.push(name);
            untyped elm.style[name] = style[name];
        }
        compStyle = untyped js.Browser.window.getComputedStyle(untyped elm);
        var props = compStyle['transition-property'].split(', ');
        for (i in 0...props.length) {
            if (applied.indexOf(props[i]) != -1) amount++;
        }
        untyped elm.addEventListener('transitionend', function(ev) {
            if (ev.target == elm) --amount;
            if (amount == 0) rm();
        });
    }

    inline public static function create(oldVnode:VirtualNodeDom, vnode:VirtualNodeDom) updateStyle(oldVnode, vnode);

    inline public static function update(oldVnode:VirtualNodeDom, vnode:VirtualNodeDom) updateStyle(oldVnode, vnode);

    inline public static function destroy(vnode:VirtualNodeDom) applyDestroyStyle(vnode);

    inline public static function remove(vnode:VirtualNodeDom, rm) applyRemoveStyle(vnode, rm);


}
