package snabbdom.dom;

abstract NativeNode(js.html.Element) from js.html.Element to js.html.Element {

    public static inline function createElement(tag) {

        return  js.Browser.document.createElement(tag);

    }

    public static inline function createTextElement(text) {
        return js.Browser.document.createTextNode(text);
    }

    public static inline function createElementNS(ns, element) {
        return js.Browser.document.createElementNS(ns, element);
    }

    @:from
    public static inline function fromNode(nd:js.html.Node)
    return new NativeNode(untyped nd);

    public inline function new(el) this = el;

    public var id(get, set):String;
    public var parentElm(get, never):NativeNode;
    public var parentElement(get, never):NativeNode;
    public var textContent(get, set):String;
    public var nextSibling(get, never):NativeNode;

    public inline function get_id() return this.id;

    public inline function set_id(value) return this.id = value;

    public inline function get_parentElement() return new NativeNode(this.parentElement);

    public inline function get_parentElm() return new NativeNode(this.parentElement);

    public inline function get_nextSibling() return new NativeNode(untyped this.nextSibling);
    //public inline function set_parentElm(node) return this.parentElement = node;

    public inline function get_textContent() return this.textContent;

    public inline function set_textContent(value) {
        (this.textContent = value);
        return value;
    }

    public inline function addEventListener(name:String, cb:Dynamic -> Void) this.addEventListener(name, cb);

    public inline function appendChild(element) {
        this.appendChild(element);
    }

    public inline function removeAttribute(attr) {
        this.removeAttribute(attr);
    }

    public inline function setAttribute(key, value) {
        this.setAttribute(key, value);
    }

    public inline function insertBefore(new_node, ref_node) {
        this.insertBefore(new_node, ref_node);
    }


    public inline function removeChild(element) {
        trace('remove-child');

        this.removeChild(element);
    }

    public inline function replaceChild(e1, e2) {
        this.replaceChild(e1, e2);
    }


}
