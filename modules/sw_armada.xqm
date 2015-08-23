xquery version "3.0";

module namespace armada="http://localhost:8080/exist/apps/rpg/sw_armada";
import module namespace templates="http://exist-db.org/xquery/templates" ;

import module namespace helpers="http://localhost:8080/exist/apps/rpg/helpers" at "helpers.xqm";

declare function armada:test ($node as node(), $model as map(*)) {
    "Im Alive"
};


declare function armada:get-factions($node as node(), $model as map(*)) {
    let $list := doc("/db/apps/rpg/data/sw_armada/list_armada.xml")
    return map {
        "factions" : $list//list[@type="namespaces"]/list[@type="faction"]/item,
        "CardsAll" : $list//list[@type="cards"]/list
    }
};

declare function armada:set-faction($node as node(), $model as map(*)) {
   let $res :=  $model("faction")
   return map {
    "id" : $res/attribute()/data(.),
    "name" : $res/term/data(.),
    "BGimg" : $res/img[@url]/attribute()
   }
};

declare function armada:print-data($node as node(), $model as map(*), $type as xs:string) {
    $model($type)
};

declare function armada:test_map($node as node(), $model as map(*), $type as xs:string) {
    $model($type)
};

declare  function armada:set-bg-image($node as node(), $model as map(*),$source as xs:string,  $class as xs:string) {
     <div style="background-image:url({$helpers:app-root}/resources/img/sw_armada/{$model($source)})" class="{$class}" title="{$model("id")}" id="flag_{$model("id")}"></div>
};

declare  function armada:set-armada-image($node as node(), $model as map(*),$source as xs:string,  $class as xs:string) {
    let $res := $model($source)
   return if($source = "SHimg") then 
        <div style="background-image:url({$helpers:app-root}/data/sw_armada/img/{$res})" class="{$class}" title="{$model("name")}">
        <div class="data">
            <div class="data-faction">{$model("faction")}</div>
            <div class="data-cost">{$model("cost")}</div>
            <div class="data-upgrade">{armada:build-upgrades($model("upgrades"))}</div>
            </div>
        </div>
     else <div style="background-image:url({$helpers:app-root}/data/sw_armada/img/{$res})" class="{$class}" title="{$model("name")}"></div>
};

declare function armada:collect-armada($node as node(), $model as map(*)) {
    let $faction := $model("id")
    let $list := doc("/db/apps/rpg/data/sw_armada/list_armada.xml")
    return map {
    "ships" : $list//list[@type="ships"]/item[@faction=$faction],
    "swarms" : $list//list[@type="swarms"]/item[@faction=$faction]
    }
    
};

declare function armada:set-ships($node as node(), $model as map(*), $type as xs:string) {
    let $ship := $model($type)
    return map {
        "shipId" : $ship/attribute()[1]/data(.),
        "shipType" : $ship/attribute()[2]/data(.),
        "name" : $ship/term/data(.),
        "SHimg" : $ship/img[@url]/attribute(),
        "cost" : $ship/cost/data(.),
        "upgrades" : $ship/upgrades/list/term/attribute(),
        "faction" : $ship/attribute()[3]/data(.)
    }
};



declare function armada:build-upgrades($res as node()*) {
for $item in $res
return <div>{$item/data(.)}</div>
    
    
};

declare function armada:printChoosenShips($node as node(), $model as map(*)) {
<div class="ChoosenShips" id="Choosen_{$model("id")}"/>
};

declare %templates:wrap function armada:SortCards($node as node(), $model as map(*)) {
let $res := $model("CardsCat")
return map {
    "CardsDeck" : $res/item
    "CardsTyoe" : $res/attribute()/data(.)
}
};

declare function armada:SortCards2($node as node(), $model as map(*)) {
    let $res := $model("Card")
    return map {
    "CardName" : $res/term/data(.),
    "CardImg" : $res/img[@url]/attribute()
    
    }
};
