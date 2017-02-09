/*********************************************************************************
Name:           FacebookPostParser
Author:         Himanshu Verma [Fujitsu]
Purpose:        This class is to parse the JSON Response from the Facebook Page Feed.
Created Date:   16/01/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/


public class FacebookPostParser{

    public String post_id {get;set;} 
    public String sender_name {get;set;} 
    public Long sender_id {get;set;} 
    public String item {get;set;} 
    public String verb {get;set;} 
    public Integer created_time {get;set;} 
    public Boolean is_hidden {get;set;} 
    public String message {get;set;}

    public FacebookPostParser(JSONParser parser) {
        while (parser.nextToken() != JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != JSONToken.VALUE_NULL) {
                    if (text == 'post_id') {
                        post_id = parser.getText();
                    } else if (text == 'sender_name') {
                        sender_name = parser.getText();
                    } else if (text == 'sender_id') {
                        sender_id = parser.getLongValue();
                    } else if (text == 'item') {
                        item = parser.getText();
                    } else if (text == 'verb') {
                        verb = parser.getText();
                    } else if (text == 'created_time') {
                        created_time = parser.getIntegerValue();
                    } else if (text == 'is_hidden') {
                        is_hidden = parser.getBooleanValue();
                    } else if (text == 'message') {
                        message = parser.getText();
                    } 
                }
            }
        }
    }
}