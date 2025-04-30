package au.org.biodiversity.nsl

class Media {

    byte[] data
    String fileName
    String description
    String mimeType
    static mapping = {

        id generator: 'native', params: [sequence_name: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"

        fileName sqlType: 'text'
        description sqlType: 'text'
        mimeType sqlType: 'text'
    }
    
    static constraints = {
    }
}
