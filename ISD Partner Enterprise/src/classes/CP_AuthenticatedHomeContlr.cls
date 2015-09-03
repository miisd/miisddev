Global without sharing class CP_AuthenticatedHomeContlr {
    public List<Life_Event__c> llifeEve{get;set;}
    public Set<Id> lifeIds{get;set;}
    public List<Reading_List__c> lReadList{get;set;}
    public Boolean bRead{get;set;}
    public List<Task> lTask{get;set;}
    public List<Event> lEvent{get;set;}
    public Id closeTask{get;set;}
    public Task uTask{get;set;}
    public List<Application_Step__c> lApp{get;set;}
    public Set<Id> sCMSLife{get;set;}
    public List<CMS_Application_Step__c> lCMSApp{get;set;}
    public Set<Id> sCMSLifeEveStep{get;set;}
    public Map<ID, CMS_Application_Step__c> AppMap = new Map<ID, CMS_Application_Step__c>();

    public List<Application_Step__Feed> appStepFeedList {get;set;}
    public List<Application_Step__c> appStepList {get;set;}
    public map<string,string> GroupImgURL {get;set;}
    public string commentText {get;set;}
    public boolean bDisplayAddComment {get;set;}
    public string feedIdVal {get;set;}
    public Attachment att {get;set;}
    public string readingId{get;set;}


    public User currentUser {get;set;}
    public List<CollaborationGroupFeed> newsFeedItems {get;set;}

  public CP_AuthenticatedHomeContlr(){
    llifeEve = new List<Life_Event__c>();
    readingId='';
    lifeIds = new Set<Id>();
    lReadList = new List<Reading_List__c>();
    lTask = new List<Task>();
    uTask = new Task();
    lEvent = new List<Event>();
    lApp = new List<Application_Step__c>();
    sCMSLife=new Set<id>();
    sCMSLifeEveStep=new Set<id>();
    lCMSApp= new List<CMS_Application_Step__c>();
    appStepFeedList = new List<Application_Step__Feed> ();

    bDisplayAddComment  = false;
    att = new Attachment();
    bRead=false;

    currentUser = [SELECT Id, ContactId, FullPhotoUrl, SmallPhotoUrl from User where Id = :userInfo.getUserId()];

    newsFeedItems = queryNewsFeed();

   //if(userRec!=null){
    llifeEve = [SELECT Id, Name,Contact__c, CMS_Life_Event__c, Img__c, Display_Name_c__c, Image_URL__c from Life_Event__c where Contact__c = :currentUser.ContactId ORDER BY Status__c ASC, CreatedDate DESC];
    if (llifeEve.size() == 0) {
      return;
    }
    for(Life_Event__c l:llifeEve){
        lifeIds.add(l.id);
    }

    queryReadingList(lifeIds);
    queryTaskList(lifeIds);
    queryEventList(lifeIds);
    queryAppList(lifeIds);


    //queryCMSAppList(sCMSLife);
  }

  public list<Reading_List__c> queryReadingList(Set<id> lSet){
      lReadList = [SELECT Id, Name, Life_Event__c,Knowledge_Article_URL__c from Reading_List__c where Life_Event__r.id IN : lSet];
    return lReadList;
  }
  public list<Task> queryTaskList(Set<id> lSet){
      lTask = [SELECT Id, Subject, WhatId,Status from Task where WhatId IN : lSet AND (Status='Not Started' OR Status='In Progress' OR Status='Waiting on someone else')];
    return lTask;
  }
  public list<Event> queryEventList(Set<id> lSet){
      lEvent = [SELECT Id, Subject, whatId from Event where WhatId IN : lSet ];
    return lEvent;
  }
  public list<Application_Step__c> queryAppList(Set<id> lSet){
      lApp = [SELECT Id,Name,Status__c,Status_F__c,Sequence__c,Life_Event__c,CMS_Life_Event_Step__r.type__c,CMS_Life_Event_Step__c,CMS_Life_Event_Name__c  from Application_Step__c where Life_Event__c IN : lSet AND CMS_Life_Event_Step__r.type__c!='External' ORDER BY Sequence__c ASC];
    return lApp ;
  }

  public List<CollaborationGroupFeed> queryNewsFeed() {

    Map<Id, CollaborationGroup> groups = new Map<Id, CollaborationGroup>([select Id, Name, SmallPhotoUrl from CollaborationGroup where Name!='All Deloitte Consulting (Strategic Allia' AND Name!= 'State of Wellbeing']);

    List<CollaborationGroupMember> groupMemberships = [select Id, MemberId, CollaborationGroupId  from CollaborationGroupMember where CollaborationGroupId In :groups.keySet() AND MemberId = :currentUser.Id];

    Set<Id> currentUserGroupMemberships = new Set<Id>();
    for (CollaborationGroupMember membership : groupMemberships) {
        currentUserGroupMemberships.add(membership.CollaborationGroupId);
    }

    List<CollaborationGroupFeed> feedItems = [SELECT Id, Type, Body, Parent.SmallPhotoUrl, Parent.Name, CreatedBy.Name,
                          (SELECT Id, CommentBody, CreatedDate, CreatedBy.FirstName, CreatedById, CreatedBy.LastName FROM FeedComments ORDER BY CreatedDate LIMIT 5)
                          FROM CollaborationGroupFeed where ParentId IN :currentUserGroupMemberships ORDER BY createdDate DESC  LIMIT 5];

    return feedItems;
  }

   public PageReference deleteReadingList(){
      try{
          delete new Reading_List__c(Id = readingId);
      }
      catch(exception e){
          //system.debug(e);
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
      }
      return null;
  }

  /*public list<CMS_Application_Step__c> queryCMSAppList(Set<id> lSet){

      lCMSApp = [SELECT Id,Display_Name__c,CMS_Life_Event__c  from CMS_Application_Step__c where CMS_Life_Event__c IN : lSet ];
      //system.debug('CMS LIFE EVENT STEP:'+lCMSApp );
      if(lCMSApp.size()>0){
        for(CMS_Application_Step__c lCMSApp:lCMSApp){

        sCMSLifeEveStep.add(lCMSApp.id);
      }
      }

    return lCMSApp;
  }*/
  public void closeTask(){
    if(closeTask!=null){
     try{
      uTask.id=closeTask;
      uTask.Status='Completed';
      update uTask;
      queryTaskList(lifeIds);
     }
     catch(Exception e){
       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Unable to create MyVault due to system exception');
     }
   }
  }

   public String communityId {
        get;

        set {
            if (value == '') {
                communityId = null;
            } else {
                communityId = value;
            }
        }
    }

    global static List<SelectOption> getCommunityOptions() {
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('', 'Internal'));

        ConnectApi.CommunityPage communityPage = ConnectApi.Communities.getCommunities(ConnectApi.CommunityStatus.Live);
        for (ConnectApi.Community community : communityPage.communities) {
            options.add(new SelectOption(community.id, community.name));
        }
        return options;
    }

    global List<ConnectApi.FeedItem> getNewsFeedItems() {
         String communityIds=Network.getNetworkId();
        return ConnectApi.ChatterFeeds.getFeedItemsFromFeed(communityIds, ConnectApi.FeedType.News, 'me', null, 5, null).items ;

       // List <ConnectApi.FeedItem>  Temp = ConnectApi.ChatterFeeds.getFeedItemsFromFeed(communityId, ConnectApi.FeedType.News, 'me', null, 5, CreatedDateDesc).items;


      // return  Temp ;

    }

    public PageReference choose() {
        return null;
    }

    public void DisplayAddComment(){
        //system.debug('-----feedIdVal-------'+feedIdVal);
        bDisplayAddComment = true;
    }
    public PageReference AddComment(){
        //system.debug('-----feedIdVal-------'+feedIdVal);
        bDisplayAddComment = false;
        ContentVersion v = new ContentVersion();
        //system.debug('-----att.body-------'+att);
        //system.debug('-----att.body-------'+att.body);
        /*v.versionData = att.body;
        v.title = att.Name;
        v.pathOnClient ='/'+att.Name;*/
        v.versionData = Blob.valueOf('Test');
        v.title = 'Test Name';
        v.pathOnClient ='/Test Name';
        insert v;
        //system.debug('-----v------'+v);
        FeedComment fcomment = new FeedComment();
        //cmdid = ApexPages.currentPage().getParameters().get('id');
        fcomment.FeedItemId= feedIdVal;
        fcomment.CommentBody =commentText ;
        //fcomment.relatedRecordId = v.id;
        //fcomment.commentBody = string.valueOf(att.body);
        //fcomment.CommentType = 'ContentComment';
        insert fcomment;
        return null;
    }
}