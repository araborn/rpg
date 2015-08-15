xquery version "3.0";

module namespace armada="http://localhost:8080/exist/apps/rpg/sw_armada";


declare function armada:test ($node as node(), $model as map(*)) {
    "Im Alive"
};


declare function armada:get-factions($node as node(), $model as map(*)) {
    let $list := doc("/db/apps/rpg/data/sw_armada/list_armada.xml")
    return map {
        "factions" : $list//list[@type="namespaces"]/list[@type="faction"]/term/data(.)
    }
};

declare function armada:test_map($node as node(), $model as map(*), $type as xs:string) {
    $model($type)
};