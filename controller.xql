xquery version "3.0";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://localhost:8080/exist/apps/rpg/config" at "modules/config.xqm";
import module namespace helpers="http://localhost:8080/exist/apps/rpg/helpers" at "modules/helpers.xqm";
(:
import module namespace register="http://localhost:8080/exist/apps/coerp_new/register" at "modules/registration.xqm";
:)
declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;




if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/index.html" />
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
                <set-attribute name="index" value="index" />           
            </forward>
        </view>
    </dispatch>
else if (ends-with($exist:resource, "index.html")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/index.html" />
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
                <set-attribute name="index" value="index" />           
            </forward>
        </view>
    </dispatch>
    else if (contains($exist:path,"/page/")) then 
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/page/{$exist:resource}.html" />
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
                <set-attribute name="index" value="index" />           
            </forward>
        </view>
    </dispatch>
(: Resource paths starting with $shared are loaded from the shared-resources app :)
else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>   
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
