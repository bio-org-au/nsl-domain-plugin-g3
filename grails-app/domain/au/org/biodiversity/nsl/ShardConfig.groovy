package au.org.biodiversity.nsl

class ShardConfig {

    String name
    String value
    String useNotes
    boolean deprecated = false

    static mapping = {
        version(false)
        id generator: 'native', params: [sequence_name: 'hibernate_sequence'], defaultValue: "nextval('hibernate_sequence')"
        deprecated defaultvalue: "false"
    }

    static constraints = {
        name unique: true
        value maxSize: 5000
        useNotes maxSize: 255, nullable: true
    }
}
