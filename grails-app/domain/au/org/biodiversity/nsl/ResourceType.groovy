package au.org.biodiversity.nsl

class ResourceType {

    String name
    String description //longer description
    Media mediaIcon
    String cssIcon

    Boolean display = true
    Boolean deprecated = false
    String rdfId

    static mapping = {
        //datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        deprecated defaultvalue: "false"
        display defaultvalue: "true"
        name sqlType: 'text'
        description sqlType: 'text'
        cssIcon sqlType: 'text'
    }

    static constraints = {
        rdfId maxSize: 50, nullable: true
        mediaIcon nullable: true
        cssIcon nullable: true, maxSize: 100
    }
}
