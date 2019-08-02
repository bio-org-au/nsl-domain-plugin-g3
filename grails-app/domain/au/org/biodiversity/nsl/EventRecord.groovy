package au.org.biodiversity.nsl

import net.kaleidos.hibernate.usertype.JsonbMapType

import java.sql.Timestamp

/**
 * An event record is used to store event data from database triggers/notifications in the notification table
 * or message events from, say, Rabbitmq. These records can be used by reports or a user notification service
 * to provide further actions.
 *
 * type is the type of event record, e.g. "Synonomy updated"
 * data is a JSON object with data relevant to this event, e.g.
 *   {treeId: 1234, tree_version_element: "/tree/555/136546", instanceId: 123654, synonomy: [...], synonomyHtml: "<synonym>..."}
 * dealtWith indicates that we think the user has dealtWith this event in some way.
 *
 * If the event doesn't need to be saved for archival purposes then it should be deleted.
 *
 */
class EventRecord {

    String type
    Map data
    Boolean dealtWith = false

    String updatedBy
    Timestamp updatedAt
    String createdBy
    Timestamp createdAt

    static mapping = {

        type sqlType: 'text', index: 'event_record_type_index,event_record_index'
        data type: JsonbMapType
        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone', index: 'event_record_created_index,event_record_index'
        dealtWith defaultvalue: "false", index: 'event_record_dealt_index,event_record_index'
    }

    static constraints = {
        updatedBy maxSize: 50
        createdBy maxSize: 50
    }
}
