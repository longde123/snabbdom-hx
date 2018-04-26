package snabbdom.dom;
import snabbdom.dom.Hooks.HookApi;
import snabbdom.dom.Hooks.Closure;
import snabbdom.dom.VirtualNodesDom as Vnodes;
import snabbdom.dom.VirtualNodeDom as Vnode;
import snabbdom.dom.NativeNode;
import snabbdom.dom.PatchDom.*;
import snabbdom.Is.*;
using snabbdom.VirtualNodeDataTools;


class PatchDom {


    inline static function vnode(sel:Dynamic, data:Dynamic, children, ?text, ?elm:Dynamic):Vnode {
        var key = data == null ? null : data.key;
        return {sel: sel, data: data, children: children,
            text: text, elm: elm};
    }


    inline static function emptyNodeAt(elm) {
        return vnode(elm.tagName, {}, [], null, elm);
    }

    static var emptyNode = vnode('', {}, [], null, null);

    inline static function sameVnode(vnode1:Vnode, vnode2:Vnode) {
        return vnode1.data.key == vnode2.data.key && vnode1.sel == vnode2.sel;
    }

    inline static function createKeyToOldIdx(children:Vnodes, beginIdx, endIdx) {
        var i, map:haxe.DynamicAccess<Dynamic> = {}, key;
        for (i in beginIdx... endIdx - 1) {
            key = children[i].data.key;
            if (isDef(key)) map[key] = i;
        }
        return map;
    }

    inline static function createRmCb(childElm:NativeNode, listeners) {
        return function() {
            if (--listeners == 0) childElm.parentElement.removeChild(childElm);
        };
    }


    inline static function createElm(vnode:Vnode, insertedVnodeQueue:Vnodes) {
        var i:HookApi, data:VirtualNodeData = vnode.data;
        if (isDef(data)) {
            if (isDef(i = data.hook) && isDef(i.init)) {
                i.init(vnode);
                data = vnode.data;
            }
        }
        var elm:NativeNode, children = vnode.children, sel = vnode.sel;
        if (isDef(sel)) {
            var tag = sel;
            elm = vnode.elm = isDef(data) && isDef(data.ns) ? NativeNode.createElementNS(data.ns + "", tag)
            : NativeNode.createElement(tag);
            if (is_array(children)) {
                for (i in 0...children.length) {
                    var new_node = createElm(children[i], insertedVnodeQueue);
                    elm.appendChild(new_node);
                }
            } else if (is_primitive(vnode.text)) {
                elm.appendChild(NativeNode.createTextElement(vnode.text));
            }

            Hooks.create(emptyNode, vnode);

            i = vnode.data.hook; // Reuse variable
            if (isDef(i)) {
                if (i.create != null) i.create(emptyNode, vnode);
                if (i.insert != null) insertedVnodeQueue.push(vnode);
            }

        } else {
            vnode.elm = NativeNode.createTextElement(vnode.text);
        }
        return vnode.elm;
    }

    inline static function addVnodes(parentElm:NativeNode, before, vnodes, startIdx, endIdx, insertedVnodeQueue) {

        var new_node;
        for (startIdx in startIdx ...endIdx - 1) {
            new_node = createElm(vnodes[startIdx], insertedVnodeQueue);
            parentElm.insertBefore(new_node, before);
        }
    }


    inline static function invokeDestroyHook(vnode:Vnode) {
        var i:HookApi, data:VirtualNodeData = vnode.data;
        if (isDef(data)) {
            if (isDef(i = data.hook) && isDef(i.destroy)) i.destroy(vnode);
            Hooks.destroy(vnode);
            if (isDef(i = vnode.children)) {
                for (j in 0...vnode.children.length) {
                    invokeDestroyHook(vnode.children[j]);
                }
            }
        }
    }


    inline static function removeVnodes(parentElm:NativeNode, vnodes:Vnodes, startIdx, endIdx) {

        for (startIdx in startIdx... endIdx - 1) {
            var listeners, rm:Closure = null, ch:VirtualNode<NativeNode> = vnodes[startIdx];
            if (isDef(ch)) {
                if (isDef(ch.sel)) {
                    invokeDestroyHook(ch);
                    Hooks.remove(ch, rm);
                    var i:HookApi, data:VirtualNodeData = ch.data;
                    if (isDef(data) && isDef(i = data.hook) && isDef(i.remove)) {
                        i.remove(ch, rm);
                    } else {
                        trace('remove');
                        if (rm != null) rm();
                        parentElm.removeChild(ch.elm);
                    }
                } else { // Text node
                    parentElm.removeChild(ch.elm);
                }
            }
        }
    }


    static function updateChildren(parentElm:NativeNode, oldCh:Vnodes, newCh:Vnodes, insertedVnodeQueue:Vnodes) {

        var oldStartIdx = 0;
        var newStartIdx = 0;
        var oldEndIdx = oldCh.length - 1;
        var oldStartVnode:Vnode = oldCh[0];
        var oldEndVnode:Vnode = oldCh[oldEndIdx];
        var newEndIdx = newCh.length - 1;
        var newStartVnode:Vnode = newCh[0];
        var newEndVnode:Vnode = newCh[newEndIdx];
        var oldKeyToIdx = null;
        var idxInOld = null;
        var elmToMove:Vnode = null;
        var before = null;

        while (oldStartIdx <= oldEndIdx && newStartIdx <= newEndIdx) {
            if (isUndef(oldStartVnode)) {
                oldStartVnode = oldCh[++oldStartIdx]; // Vnode has been moved left
            } else if (isUndef(oldEndVnode)) {
                oldEndVnode = oldCh[--oldEndIdx];
            } else if (sameVnode(oldStartVnode, newStartVnode)) {
                patchVnode(oldStartVnode, newStartVnode, insertedVnodeQueue);
                oldStartVnode = oldCh[++oldStartIdx];
                newStartVnode = newCh[++newStartIdx];
            } else if (sameVnode(oldEndVnode, newEndVnode)) {
                patchVnode(oldEndVnode, newEndVnode, insertedVnodeQueue);
                oldEndVnode = oldCh[--oldEndIdx];
                newEndVnode = newCh[--newEndIdx];
            } else if (sameVnode(oldStartVnode, newEndVnode)) { // Vnode moved right
                patchVnode(oldStartVnode, newEndVnode, insertedVnodeQueue);
                parentElm.insertBefore(oldStartVnode.elm, oldEndVnode.elm.nextSibling);
                oldStartVnode = oldCh[++oldStartIdx];
                newEndVnode = newCh[--newEndIdx];
            } else if (sameVnode(oldEndVnode, newStartVnode)) { // Vnode moved left
                patchVnode(oldEndVnode, newStartVnode, insertedVnodeQueue);
                parentElm.insertBefore(oldEndVnode.elm, oldStartVnode.elm);
                oldEndVnode = oldCh[--oldEndIdx];
                newStartVnode = newCh[++newStartIdx];
            } else {
                if (isUndef(oldKeyToIdx)) oldKeyToIdx = untyped createKeyToOldIdx(oldCh, oldStartIdx, oldEndIdx);
                idxInOld = untyped oldKeyToIdx[newStartVnode.data.key];
                if (isUndef(idxInOld)) { // New element
                    var new_node = createElm(newStartVnode, insertedVnodeQueue);
                    parentElm.insertBefore(new_node, oldStartVnode.elm);
                    newStartVnode = newCh[++newStartIdx];
                } else {
                    elmToMove = oldCh[idxInOld];
                    patchVnode(elmToMove, newStartVnode, insertedVnodeQueue);
                    oldCh[idxInOld] = null;
                    parentElm.insertBefore(elmToMove.elm, oldStartVnode.elm);
                    newStartVnode = newCh[++newStartIdx];
                }
            }
        }

        if (oldStartIdx > oldEndIdx) {
            before = isUndef(newCh[newEndIdx + 1]) ? null : newCh[newEndIdx + 1].elm;
            addVnodes(parentElm, before, newCh, newStartIdx, newEndIdx, insertedVnodeQueue);
        } else if (newStartIdx > newEndIdx) {
            removeVnodes(untyped parentElm, oldCh, oldStartIdx, oldEndIdx);
        }


    }


    static function patchVnode(oldVnode:Vnode, vnode:Vnode, insertedVnodeQueue:Vnodes) {
        var i:VirtualNodeData = vnode.data;
        var hook:HookApi = i.hook;

        if (isDef(i = vnode.data) && isDef(hook = i.hook) && isDef(hook.prepatch)) {
            hook.prepatch(oldVnode, vnode);
        }

        var elm:NativeNode = vnode.elm = oldVnode.elm, oldCh = oldVnode.children, ch = vnode.children;
        if (oldVnode == vnode) return;

        Hooks.update(oldVnode, vnode);

        hook = vnode.data.hook;
        if (isDef(hook) && isDef(hook.update)) hook.update(oldVnode, vnode);

        if (isUndef(vnode.text)) {
            if (isDef(oldCh) && isDef(ch)) {
                if (oldCh != ch) updateChildren(elm, oldCh, ch, insertedVnodeQueue);
            } else if (isDef(ch)) {
                addVnodes(elm, null, ch, 0, ch.length - 1, insertedVnodeQueue);
            } else if (isDef(oldCh)) {
                removeVnodes(elm, oldCh, 0, oldCh.length - 1);
            }
        } else if (oldVnode.text != vnode.text) {
            elm.textContent = vnode.text;
        }
        if (isDef(hook) && isDef(hook.postpatch)) {
            hook.postpatch(oldVnode, vnode);
        }


    }

    public static function patchDom(oldVnode:NativeNode, vnode:Vnode) {

        var i = 0;
        var insertedVnodeQueue:Vnodes = [];
        if (untyped oldVnode.parentElement != null) {
            createElm(vnode, insertedVnodeQueue);
            oldVnode.parentElement.replaceChild(vnode.elm, oldVnode);
        } else {
            oldVnode = untyped emptyNodeAt(untyped oldVnode);
            patchVnode(untyped oldVnode, vnode, insertedVnodeQueue);
        }


        for (i in 0... insertedVnodeQueue.length) {
            untyped insertedVnodeQueue[i].data.hook.insert(insertedVnodeQueue[i]);
        }

        return vnode;

    }


    public static function patch(oldVnode:Vnode, vnode:Vnode) {
        var i = 0;
        var insertedVnodeQueue:Vnodes = [];

        patchVnode(oldVnode, vnode, insertedVnodeQueue);

        for (i in 0... insertedVnodeQueue.length) {
            untyped insertedVnodeQueue[i].data.hook.insert(insertedVnodeQueue[i]);
        }


        return vnode;
    };

}
