xquery version "3.0";

module namespace page="http://localhost:8080/exist/apps/rpg/page";

import module namespace helpers="http://localhost:8080/exist/apps/rpg/helpers" at "helpers.xqm";


declare function page:createNavigationMain($node as node(), $model as map(*)) {
    let $doc := doc("/db/apps/rpg/data/lists.xml")
    for $item in $doc//list[@type="navigation"]/item
        return <div class="MainTab"><a href="{$helpers:app-root}/page/{$item/term/attribute()}"><div style="background-image:url({$helpers:app-root}/resources/img/{$item/img/attribute()})" class="MainTabImg">{$item/term/data(.)}</div></a></div>
        
};