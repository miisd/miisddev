public class CC_MyProfileController {
    public static String contactId;
    public static String userId;
    public String MailingAddress{get;set;}
    public String OtherAddress{get;set;}
    public String myPhone {get;set;}
    public String myEmail {get;set;}
    public String myMobilePhone {get;set;}
    
    
    public CC_MyProfileController(ApexPages.StandardController controller) {
        userId = userinfo.getUserId();
        contactId = [Select contactId from User where Id =: userId][0].contactId;
    }

    public void updateProfile(){
        Contact con = [Select Id, FirstName, lastName, MailingAddress, OtherAddress,Phone from Contact where Id =: contactId];
        system.debug(con);
        //con.MailingAdddress = MailingAddress;
        System.Debug(myPhone);
        System.Debug(myEmail);
        System.Debug(myMobilePhone);
        con.Phone = myPhone;
        //update con;
        
    }
}