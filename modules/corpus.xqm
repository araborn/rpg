xquery version "3.0";

module namespace corpus="http://localhost:8080/exist/apps/coerp_new/corpus";

import module namespace helpers="http://localhost:8080/exist/apps/coerp_new/helpers" at "helpers.xqm";

declare namespace util="http://exist-db.org/xquery/util";
declare namespace text="http://exist-db.org/xquery/text";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace coerp="http://coerp.uni-koeln.de/schema";

declare function corpus:test($node as node()*, $model as map(*)) as xs:string{

let $test := "im Alive"
return $test
};

declare function corpus:getLists($node as node()*, $model as map(*), $param as xs:string, $term as xs:string) as node()* {
    let $db := collection("/db/apps/coerp_new/data/texts")
    for $item in corpus:getInformations(corpus:scanDB($db,$param, $term))
    return   if(exists($item)) then (
    <div class="list_main whiteBorder"> {
        for $tag in $item/item return
        if($tag/@class/data(.) = "author") then 
                        <div class="list_{$tag/@class/data(.)}">{$tag/@data/data(.)}</div>
        else if($tag/@class/data(.) = "short_title") then
                <div class="list_{$tag/@class/data(.)}"><a href="{$tag/@ref/data(.)}">{$tag/@data/data(.)}</a></div>
        else 
        <div class="list_{$tag/@class/data(.)} list_inner"><p class="list_left">{$tag/@name/data(.)}</p><p class="list_right">
        { if($tag/@data/data(.) != "") then $tag/@data/data(.) else "-" }
        </p></div>
            }  </div>)
    else <p> Nothing found</p>
};


declare function corpus:scanDB($db as node()*, $param as xs:string, $term as xs:string) as node()* {
        let $range := concat("//range:field-contains(('",$param,"'),'",$term,"')")
        let $build := concat("$db",$range)
        return util:eval($build)
};


declare function corpus:getInformations($db as node()*) as item()* {
    for $item in $db
    let $author :=  $item//coerp:coerp_header/coerp:author_profile/coerp:author 
    let $short_title := $item//coerp:coerp_header/coerp:text_profile/coerp:short_title 
    let $year :=  $item//coerp:coerp_header/coerp:text_profile/coerp:year/coerp:from
    let $genre :=  $item//coerp:coerp_header/coerp:text_profile/coerp:genre 
    let $title :=   $item//coerp:coerp_header/coerp:text_profile/coerp:title 
    let $denom :=   $item//coerp:coerp_header/coerp:author_profile/coerp:denom 
    let $translator := $item//coerp:coerp_header/coerp:author_profile/coerp:translator 
    let $author_preface := $item//coerp:coerp_header/coerp:author_profile/coerp:author_preface 

    let $ref := substring-before(concat($helpers:app-root,"/text/",root($item)/util:document-name(.)),".xml")
    return <items> 
                        <item class="author"  data="{$author}" name="Author" /> 
                        <item class="short_title"  data="{$short_title}" name="Short Title" ref="{$ref}"/>
                        <item class="year"  data="{$year}" name="Year"/>
                        <item class="genre"  data="{$genre}" name="Genre"/>
                        <item class="title"  data="{$title}" name="Title"/>
                        <item class="denom"  data="{$denom}" name="Denomination"/>
                        <item class="translator"  data="{$translator}" name="Translator"/>
                        <item class="author_preface"  data="{$author_preface}" name="Author Preface"/>
                 </items>        
};