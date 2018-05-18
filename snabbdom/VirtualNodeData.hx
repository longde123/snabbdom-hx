package snabbdom;

import snabbdom.dom.Hooks.HookApi;
typedef VirtualNodeData = {
attrs:DynamicObject<Dynamic>,
props:DynamicObject<Dynamic>,
classes:DynamicObject<Dynamic>,
style:DynamicObject<Dynamic>,
on:DynamicObject<Dynamic>,
hook:HookApi,
skip_styles:Bool,
skip_attributes:Bool,
key:Null<String>,
ns:DynamicObject<Dynamic>
}
