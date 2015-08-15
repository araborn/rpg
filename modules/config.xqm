xquery version "3.0";

(:~
 : A set of helper functions to access the application context from
 : within a module.
 :)
module namespace config="http://localhost:8080/exist/apps/rpg/config";

declare namespace templates="http://exist-db.org/xquery/templates";

declare namespace repo="http://exist-db.org/xquery/repo";
declare namespace expath="http://expath.org/ns/pkg";

(: 
    Determine the application root collection from the current module load path.
    $config:app-root = /db/apps/coerp
:)
declare variable $config:app-root := 
    let $rawPath := system:get-module-load-path()
    let $modulePath :=
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring($rawPath, 36)
            else
                substring($rawPath, 15)
        else
            $rawPath
    return
        substring-before($modulePath, "/modules")
;
declare variable $config:conf-file := doc("/db/apps/rpg/conf.xml");
declare variable $config:webapp-root := $config:conf-file//webapp-root/data(.);
declare variable $config:data-root := $config:app-root || "/data";

declare variable $config:user-data := $config:app-root || "/data/users";

declare variable $config:repo-descriptor := doc(concat($config:app-root, "/repo.xml"))/repo:meta;

declare variable $config:expath-descriptor := doc(concat($config:app-root, "/expath-pkg.xml"))/expath:package;

declare variable $config:admin-id := "admin";
declare variable $config:admin-pass := "knight";
declare variable $config:signatur-plaintext as xs:string := string(doc($config:data-root || "/mail/mail-signatur-plaintext.xml"));
declare variable $config:signatur-xhtml := util:eval(util:serialize(doc($config:data-root || "/mail/mail-signatur-xhtml.xml"),()));
declare variable $config:from := "coerp-info@uni-koeln.de";

(:~
 : Resolve the given path using the current application context.
 : If the app resides in the file system,
 :)
declare function config:resolve($relPath as xs:string) {
    if (starts-with($config:app-root, "/db")) then
        doc(concat($config:app-root, "/", $relPath))
    else
        doc(concat("file://", $config:app-root, "/", $relPath))
};

(:~
 : Returns the repo.xml descriptor for the current application.
 :)
declare function config:repo-descriptor() as element(repo:meta) {
    $config:repo-descriptor
};

(:~
 : Returns the expath-pkg.xml descriptor for the current application.
 :)
declare function config:expath-descriptor() as element(expath:package) {
    $config:expath-descriptor
};

declare %templates:wrap function config:app-title($node as node(), $model as map(*)) as text() {
    $config:expath-descriptor/expath:title/text()
};

declare function config:app-meta($node as node(), $model as map(*)) as element()* {
    <meta xmlns="http://www.w3.org/1999/xhtml" name="description" content="{$config:repo-descriptor/repo:description/text()}"/>
};

(:~
 : For debugging: generates a table showing all properties defined
 : in the application descriptors.
 :)
declare function config:app-info($node as node(), $model as map(*)) {
    let $expath := config:expath-descriptor()
    let $repo := config:repo-descriptor()
    return
        <table class="app-info">
            <tr>
                <td>app collection:</td>
                <td>{$config:app-root}</td>
            </tr>
            {
                for $attr in ($expath/@*, $expath/*, $repo/*)
                return
                    <tr>
                        <td>{node-name($attr)}:</td>
                        <td>{$attr/string()}</td>
                    </tr>
            }
            <tr>
                <td>Controller:</td>
                <td>{ request:get-attribute("$exist:controller") }</td>
            </tr>
        </table>
};


declare function config:logged-in() {
	if (xmldb:get-user-groups(xmldb:get-current-user()) = ("coerp")) then true() else false()
};

declare function config:get-user-name($node as node(), $model as map(*)) {
    let $user := xmldb:get-current-user()
return $user
};

(:(\: gibt den namen der Gruppe zurück in der der aktuelle user angemeldet ist :\)
declare function config:get-user-group() {
    let $current-group := xmldb:get-user-groups(xmldb:get-current-user())
    return $current-group
};
:)