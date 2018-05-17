package snabbdom;

abstract DynamicObject<T>(Dynamic<T>) from Dynamic<T> {

    public inline function new(t:Dynamic<T>) {
        this = t;
    }

    @:arrayAccess
    public inline function set(key:String, value:T):Void {
        Reflect.setField(this, key, value);
    }

    @:arrayAccess
    public inline function get(key:String):Null<T> {
        #if js
        return untyped this[key];
        #else
        return Reflect.field(this, key);
        #end
    }

    public inline function exists(key:String):Bool {
        return Reflect.hasField(this, key);
    }

    public inline function remove(key:String):Bool {
        return Reflect.deleteField(this, key);
    }
    @from
    public inline function fromDynamic(t:Dynamic<T>) {
        return new DynamicObject(t);
    }
    public inline function keys():Array<String> {
        #if js
          return untyped Object.keys(this);
        #else
        return Reflect.fields(this);
        #end
    }
    public inline function clone():Dynamic<T> {
        var c={};
        for(k in keys()){
            Reflect.setField(   c, k, Reflect.field(this,k));
        }
        return c;
    }
}
