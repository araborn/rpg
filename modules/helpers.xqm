xquery version "3.0";

(:~
 : Modul, das verschiedene einfache Hilfsfunktionen enthält,
 : speziell zur Erzeugung komplexerer und oft verwendeter HTML-Elemente
 :)
module namespace helpers="http://localhost:8080/exist/apps/rpg/helpers";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://localhost:8080/exist/apps/rpg/config" at "config.xqm";


(:
 : HTML-ELEMENTE VERBERGEN
 : verschiedene Spiegel-Funktionalitäten, die HTML-Elemente verbergen,
 : wo sie bei einfachem AUfruf der Funktionalität angezeigt werden würden.
 :)

(:~
 : Eine each Funktion zur Verwendung in views, identisch mit templates:each, 
 : aber ohne %templates:wrap Annotation, also ohne zusätzliches umschließendes
 : $node - Element
 :)
 declare variable $helpers:app-root := $config:webapp-root;
 declare function helpers:app-root($node as node(), $model as map(*)){
 let $elname := $node/node-name(.)
 
 return if (xs:string($elname) = "link")
        then <link href="{$helpers:app-root}/{$node/@href}">
                {$node/@*[not(xs:string(node-name(.)) = "href") and not(xs:string(node-name(.)) = "class")]}
                {helpers:copy-class-attr($node)}
             </link>
        else if (xs:string($elname) = "script" and $node/@type = "text/javascript")
        then <script type="{$node/@type}" src="{$helpers:app-root}/{$node/@src}" />
        else if (xs:string($elname) = "img")
        then <img src="{$helpers:app-root}/{$node/@src}">
                {$node/@*[not(xs:string(node-name(.)) = "src") and not(xs:string(node-name(.)) = "class")]}
                {helpers:copy-class-attr($node)}
             </img>
        else if (xs:string($elname) = "a")
             then <a href="{$helpers:app-root}/{$node/@href}">
                    {$node/@*[not(xs:string(node-name(.)) = "href") and not(xs:string(node-name(.)) = "class")]}
                    {helpers:copy-class-attr($node)}
                    {templates:process($node/node(), $model)}
                  </a>
        else if (xs:string($elname) = "form")
             then <form action="{$helpers:app-root}/{$node/@action}">
                    {$node/@*[not(xs:string(node-name(.)) = "action") and not(xs:string(node-name(.)) = "class")]}
                    {helpers:copy-class-attr($node)}
                    {templates:process($node/node(), $model)}
                  </form>
        else $node
};
 declare function helpers:copy-class-attr($node as node()){
    attribute class {$node/@class/concat(substring-before(., "helpers:app-root"), substring-after(., "helpers:app-root"))}
};
 
declare function helpers:each($node as node(), $model as map(*), $from as xs:string, $to as xs:string) {
    for $item in $model($from)
    return
        element { node-name($node) } {
            $node/@*, templates:process($node/node(), map:new(($model, map:entry($to, $item))))
        }
};

(:~
 : Identisch zu helpers:each aber ganz ohne irgendein umschließendes Element
 :)
declare function helpers:invisibleEach($node as node(), $model as map(*), $from as xs:string, $to as xs:string) {
    for $item in $model($from)
    return
        templates:process($node/node(), map:new(($model, map:entry($to, $item))))
};

(:~
 : Tut nichts anderes als das HTML-Element von dem aus die Funktion aufgerufen wird,
 : aufzulösen. Krücke, um wohlgeformtes HTML (mit einem einzelnen Elternknoten) 
 : abspeichern zu können, ohne dass dieser Knoten tatsächlich auf der erzeugten Seite
 : auftaucht.
 :)
declare function helpers:invisibleWrapper($node as node(), $model as map(*)) {
    templates:process($node/node(), $model)
};




(:
 : MODEL WERTE ANSTEUERN
 : Verschiedene verallgemeinerte Möglichkeiten, um die Model map zu manipulieren
 : oder Werte direkt auszugeben.
 :)

(:~
 : Enthält das Model eine Map $from, die unter dem key $target eine weitere Map enthält,
 : dann wird der Inhalt von dieser submap unter dem Key $target direkt im Model abgelegt
 :)
 declare function helpers:extractSubmap($node as node(), $model as map(*), $from as xs:string, $target as xs:string) {
    let $from := $model($from)
    return 
        map:entry($target, $from($target))
};

(:~
 : Elemente des Models direkt ansteuern und zurückgeben.
 : Praktische z.B. wenn diese nur aus einem String bestehen, der zurückgegeben werden soll.
 :)
 declare function helpers:get($node as node(), $model as map(*), $key as xs:string) {
    $model($key)
};

(:~
 : Elemente des Models direkt ansteuern und im aufrufenden Element zurückgeben.
 : Praktische z.B. wenn diese nur aus einem String bestehen, der zurückgegeben werden soll.
 :)
declare 
    %templates:wrap
function helpers:getWrapped($node as node(), $model as map(*), $key as xs:string) {
    helpers:get($node, $model, $key)
};




(:
 : STRING FUNKTIONEN
 :)
 
declare function helpers:firstToUpper($str as xs:string) as xs:string {
    upper-case(substring($str, 1, 1)) || substring($str, 2)
};

declare function helpers:prettifyUnderscoreString($str as xs:string) as xs:string {
    let $words := 
        for $word in tokenize($str, '_')
        return helpers:firstToUpper($word)
    return string-join($words, ' ')
};

(:~
 : Zeilenumbrüche in einem String in <br/> Elemente umwandeln und
 : als Sequenz von Teilstrings und br-Elementen zurückgeben
 :)
declare function helpers:linebreaksToHTML($str as xs:string) { 
    for $line at $pos in tokenize($str, '(\r\n?|\n\r?)')
    let $seq :=
        if($pos = 1) then $line
        else (<br/>, $line)
    return $seq
};

declare function helpers:lettersOfTheAlphabet() {
    ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z')
};

(:
 : Wrapper für mögliche url-Kodierungen
 :)
declare function helpers:url-encode($str) {
    xmldb:encode-uri($str)
};

declare function helpers:url-decode($str) {
    xmldb:decode-uri($str)
};






(:
 : ELEMENTE MIT ABSOLUTEN PFADANGABEN
 : Erzeugt dynamisch Elemente, an die der verschiedene Pfadangaben übergenen werden
 : können.
 : TODO config: Funktionen- oder Variablen mit einbeziehen. Dorthin auslagern? Besserer Weg? Vll. exist:controller in controller.xqm??
 : Alle: als Änderungen am Node umsetzen statt direkter Elementrückgabe
 :)
 
 (:~
  : Wurzelpfad für interne Links
    um Dateien aus Unterordnern (zB. resources/img) laden zu können
  :)
 
 
 declare variable $helpers:proxyPath := 
    if (request:get-server-name() eq "coerp.uni-koeln.de")
        then
            ''
        else
            $config:app-root;
 
  (:config:app-root = /db/apps/coerp/:)
 declare variable $helpers:rootPath := replace($helpers:proxyPath, '/db/', '/');
  
 declare variable $helpers:url := 
    if (request:get-server-name() eq "coerp.uni-koeln.de")
        then
         ''
         else 
            $helpers:rootPath;

 declare variable $helpers:emailLink := 
    if (request:get-server-name() eq "coerp.uni-koeln.de")
        then
            "http://coerp.uni-koeln.de"
         else 
            "http://localhost:8080/exist/apps/coerp";
 
 (:declare variable $helpers:rootPath := replace($config:app-root, '/db/', '/');
 
 declare variable $helpers:url := concat('http://projects.cceh.uni-koeln.de:8080', $helpers:rootPath); 


:)
 declare function helpers:stylesheet($node as node(), $model as map(*), $path as xs:string) {
    <link rel="stylesheet" type="text/css" href="http://localhost:8080/exist/apps/rpg/{$path}"/>
 };
 
  declare function helpers:favicon($node as node(), $model as map(*), $path as xs:string) {
    <link rel="shortcut icon" type="image/x-icon" href="{$helpers:rootPath}/{$path}"/>
 };
 
 declare function helpers:script($node as node(), $model as map(*), $path as xs:string) {
    <script type="text/javascript" src="http://localhost:8080/exist/apps/rpg/{$path}"></script>
 };
 
 declare function helpers:internalLink($node as node(), $model as map(*), $path as xs:string, $name as  xs:string, $class as xs:string) {
    <a class="{$class}" href="{$helpers:rootPath}/{helpers:url-encode($path)}">{replace($name, "_", " ")}</a>
 };

 declare function helpers:internalLinkFurtherInfo($node as node(), $model as map(*), $path as xs:string, $name as  xs:string, $class as xs:string) {
    <a class="{$class}" href="{$helpers:rootPath}/{helpers:url-encode($path)}" target="_blank">(Further Information...)</a>
 };

 declare function helpers:image($node as node(), $model as map(*), $path as xs:string, $width as  xs:string, $alt as xs:string)  {
    <img src="{$helpers:rootPath}/{$path}" alt="{$alt}" width="{$width}"></img>
 };
 
  declare function helpers:coerpEmail($node as node(), $model as map(*)) as xs:string {
    let $coerpEmail := $config:from
    return $coerpEmail
 };
 
(:~
 : RootPfad vor den Inhalt eines Attributs $attributeName schreiben
 :)
 declare function helpers:prependRootPath($node as node(), $model as map(*), $attributeName as xs:string) {
    let $attributeValue := $node/@*[./name() = $attributeName]/string()
    return element 
        {node-name($node)} 
        {
            for $att in $node/@*
            return
                if (name($att) = $attributeName) then
                    attribute {$attributeName} {$helpers:rootPath || $attributeValue}
                else
                    $att
            , templates:process($node/node(), $model)
        }
};

(:~
 : Einen einzelnen Link zurückgeben, der auf die Ressource verweist, die gerade
 : unter diesem Namen im Model liegt
 : Bsp: model("genre") = "catechism" wird zu <a href="root/pfad/genre/catechism>Catechism</a>
 :      model("author") = "John"     wird zu <a href="root/pfad/author/john">John</a>
 :)
declare function helpers:resourceLink($node as node(), $model as map(*), $resource as xs:string) {
    let $resourceStr := $model($resource)
    let $words := helpers:prettifyUnderscoreString($resourceStr)
    let $resourceStr := helpers:url-encode($resourceStr)
    return 
        <a href="{$helpers:rootPath}/{$resource}/{$resourceStr}">{$words}</a>
};

declare function helpers:printCheckbox($node as node(), $model as map(*), $prefix as xs:string, $for as xs:string) {
    <label class="checkbox">
        <input type="checkbox" name="{concat($prefix, $model($for))}" value="1">
        {if (exists(request:get-parameter("query", ())) and exists(request:get-parameter(concat($prefix, $model($for)), ()))) 
            then attribute checked {"checked"} 
         else if (exists(request:get-parameter("query", ())) and exists(request:get-parameter("type", ())))
            then attribute checked {"checked"} 
         else if (exists(request:get-parameter("query", ())))
            then ()
         else attribute checked {"checked"}}
        </input>
        {helpers:firstToUpper($model($for))}
    </label>
};

(:
Funktion die die aktuelle URL ausliest und so das geöffnete Dokument herrausfindet
:)

declare function helpers:getShortTitle($node as node(), $model as map(*)){
    
    let $url := request:get-url()
    return <p>{$url}</p>

};



declare function helpers:getFilenameList($node as node(), $model as map(*)){
<select name="files-ptm">
  <option></option> 
     {system:as-user($config:admin-id, $config:admin-pass,
     for $file in file:directory-list(concat($config:data-root, "/texts"), "*.xml")//file:file
     let $name := $file/data(@name)
     return <option>{$name}"></option>
    )}
</select>
};


(:
 : DEBUG
 : Verschiedene Funktionen, um direkt Debug-Output zu erzeugen
 :)
 
 declare function helpers:_print_map($input) { 
    if ($input instance of map) then (        
        <div class="map" style="margin:11px">
            {for $key in map:keys($input)
                return <div class="debug-info">{$key} =&gt; {helpers:_print_map($input($key))}</div>
            }
        </div>
    )
    else if ($input[1] instance of map) then (
        for $mapInSequence in $input
            return helpers:_print_map($mapInSequence)
    )
    else ($input)
 };
 
 declare function helpers:print_model($node as node(), $model as map(*)) {
    <div class="debug well well-small">
        <h6>Model</h6>
        {helpers:_print_map($model)}
    </div>
 };
 
declare function helpers:print_params($node as node(), $model as map(*)) {
    if (count(request:get-parameter-names()) gt 0) then (
        let $parameters :=  request:get-parameter-names()
        return
            <div class="debug well well-small" >
                <h6>Params</h6>
                {for $parameter in $parameters
                return
                    <div class="debug-info">"{$parameter}" =&gt; "{request:get-parameter($parameter, '')}"</div>
                }
            </div>
    )    
    else ()
};

declare function helpers:print_attribs($node as node(), $model as map(*)) {
    if (count(request:attribute-names()) gt 0) then (
        let $attributes :=  request:attribute-names()
        return
            <div class="debug well well-small" >
                <h6>Attributes</h6>
                {for $attribute in $attributes
                return             
                    <div class="debug-info">"{$attribute}" =&gt; "{request:get-attribute($attribute)}"</div>
                }
            </div>
    )    
    else ()
};
 
 
