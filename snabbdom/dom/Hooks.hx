package snabbdom.dom;

import snabbdom.dom.PatchDom.*;
import snabbdom.dom.plugins.*;
using snabbdom.VirtualNodeDataTools;

import snabbdom.dom.VirtualNodeDom as VNode;

typedef PreHook = Void -> Any;
typedef InitHook = VNode -> Void;
typedef CreateHook = VNode -> VNode -> Void;
typedef InsertHook = VNode -> Void;
typedef PrePatchHook = VNode -> VNode -> Void;
typedef UpdateHook = VNode -> VNode -> Void;
typedef PostPatchHook = VNode -> VNode -> Void;
typedef DestroyHook = VNode -> Void;
typedef Closure = Void -> Void;
typedef RemoveHook = VNode -> Closure -> Void;
typedef PostHook = Void -> Void;

class HookApi {

    public var pre:PreHook;
    public var init:InitHook;
    public var create:CreateHook;
    public var insert:InsertHook;
    public var prepatch:PrePatchHook;
    public var update:UpdateHook;
    public var postpatch:PostPatchHook;
    public var destroy:DestroyHook;
    public var remove:RemoveHook;
    public var post:PostHook;

    public function new():Void {
        
    }
}


class Hooks {
    inline public static function create(oldVnode:VirtualNodeDom, vnode:VirtualNodeDom) {

        var elm:VirtualNodeData = cast vnode.elm;
        var apply_hooks = if (vnode.data.___cache.contains(CacheDom.cacheAll) == false) {
            true;
        } else {
            if (elm.___cache == null) {
                elm.___cache = 1;
                true;
            } else {
                if (elm.___cache == 1) {
                    false;
                } else {
                    true;
                }
            }
        };

        if (apply_hooks) {
            Attributes.create(oldVnode, vnode);
            Props.create(oldVnode, vnode);
            CssClasses.create(oldVnode, vnode);
            Styles.create(oldVnode, vnode);
            Events.create(oldVnode, vnode);
        }
    }

    inline public static function update(oldVnode:VirtualNodeDom, vnode:VirtualNodeDom) {

        var elm:VirtualNodeData = cast vnode.elm;
        var apply_hooks = if (vnode.data.___cache.contains(CacheDom.cacheAll) == false) {
            true;
        } else {
            if (elm.___cache == null) {
                elm.___cache = 1;
                true;
            } else {
                if (elm.___cache == 1) {
                    false;
                } else {
                    true;
                }
            }
        };

        if (apply_hooks) {
            Attributes.update(oldVnode, vnode);
            Props.update(oldVnode, vnode);
            CssClasses.update(oldVnode, vnode);
            Styles.update(oldVnode, vnode);
            Events.update(oldVnode, vnode);
        }
    }


    inline public static function destroy(vnode:VirtualNodeDom) {
        Styles.destroy(vnode);
    }


    inline public static function remove(vnode, rm) {

        Styles.remove(vnode, rm);

    }

}
