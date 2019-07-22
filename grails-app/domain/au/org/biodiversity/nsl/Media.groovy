package au.org.biodiversity.nsl

class Media {

    byte[] data
    String fileName
    String description
    String mimeType
    static mapping = {
        //datasource 'nsl'
        id generator: 'native', params: [sequence: 'hibernate_sequence'], defaultValue: "nextval('hibernate_sequence')"

        fileName sqlType: 'text'
        description sqlType: 'text'
        mimeType sqlType: 'text'
    }
    
    static constraints = {
    }
}
