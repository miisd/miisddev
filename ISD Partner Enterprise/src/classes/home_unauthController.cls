/* 
     * @Page Name    : Home
     * @Description  : This controller is the unauthenticated page's controller.
     * @Created By   : @ShishirChauhan
     * @Created On   : 
     * @Modification Log:  
     * --------------------------------------------------------------------------------------------------------------------------------
     * @Developer                Date                  Description              
     * --------------------------------------------------------------------------------------------------------------------------------
     * @ShishirChauhan                                   Created
     * @Subodhbahl                                       Added modification logs
     * @Subodhbahl                                       Modified, added the functionality as the new wireframes
     * @MarkDiego               10/01/2014               Added Top News, All News and All Top Services
     * --------------------------------------------------------------------------------------------------------------------------------
*/

public class home_unauthController {
    
    // Properties
    public list<string>categoryType{get;set;} 
    public list<CMS_Life_Event__c>lstCmsLifeEvent{get;set;} 
    public map<string,string>mapDisplayName{get;set;}
    public list <CMS_life_Event__c> lstTopServices {get;set;}
    public list <CMS_life_Event__c> lstAllTopServices {get;set;}
    public list <News__c> lstTopNews {get;set;}
    public list <News__c> lstAllNews {get;set;}
    public String categoryName;
    
    // Constructor
    public home_unauthController(){
        categoryType = new list<string>{'My Money','My Family','My Home','My Ride','My Citizenship','My Education','My Job','My Health','My Trip'}; //Modified by Mark Diego, March 30, 2015 for Boulder RFP
        //categoryType = new list<string>{'Housing',  'Food Assistance',  'Elder Services',   'Cash Assistance',  'My Job', 'Health Coverage',  'Education and Skill Building', 'Family and Children Services'}; //Modified by Mark Diego, March 30, 2015 for Boulder RFP
        lstCmsLifeEvent = new list<CMS_Life_Event__c>(); 
        
        // Get Top Services
        lstTopServices = new list <CMS_life_Event__c>();
        lstTopServices = [Select id, Display_Name__c,Img__c from CMS_Life_Event__c where top_service__c = true LIMIT 5];

        // Get All Top Services
        lstAllTopServices = new list <CMS_life_Event__c>();
        lstAllTopServices = [Select id, Display_Name__c,Img__c, Description__c from CMS_Life_Event__c where top_service__c = true];

        // Get Top News
        lstTopNews = new list <News__c>();
        lstTopNews = [Select id, Headline__c, Body__c, Link__c from News__c WHERE Publish_From__c < TODAY AND Publish_Through__c > TODAY ORDER BY Publish_From__c desc LIMIT 2];

        // Get All News
        lstAllNews = new list <News__c>();
        lstAllNews = [Select id, Headline__c, Body__c, Link__c, CreatedBy.Name, Publish_From__c from News__c WHERE Publish_From__c < TODAY AND Publish_Through__c > TODAY ORDER BY Publish_From__c desc];
        
   }
    
    public void getLifeEvent(){
        // Fetch Life Events based on the categories
        categoryName = Apexpages.currentPage().getParameters().get('categoryName');
        lstCmsLifeEvent = [select id,Display_Name__c,Description__c,Category__c,Image__c,Img__c,Image_URL__c from CMS_Life_Event__c where Category__c=:CategoryName AND Deployed__c = TRUE AND Sub_Event__c = FALSE];
    }

    public pagereference redirectToLifeEvent(){
        string lifeEventId = Apexpages.currentPage().getParameters().get('lifeEventId');
        pagereference pg = new pagereference('/apex/CC_LifeEvent?leid='+lifeEventId);
        return pg;
    }
   
}