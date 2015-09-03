public class CC_LifeEvent_Controller {

    public static Id lifeEventId;

    public List<EventTypeWrap> stepGroups {get; set;}
    public List<KnowledgeArticleVersion> lstKnowledgeVersion {get; set;}
    public String iframeURL {get; set;}
    public String canUseVault {get;set;}

    public CMS_Life_Event__c cmsLifeEvent {get; set;}
    public Life_Event__c lifeEvent {get; set;}
    public User user {get; set;}

    public Application_Step__c currentApplicationStep {get; set;}
    public string lifeEventIdRecord{get;set;}

    public Boolean inVault {get; private set;}
    public Boolean inVaultVisible {get; private set;}
    public Boolean isNavigator {get; set;}
    
    
    public CC_LifeEvent_Controller(){
        loadUser();

        lifeEventId = Apexpages.currentPage().getParameters().get('leid');
        
        lifeEventIdRecord = '';
        loadLifeEvent();

        lstKnowledgeVersion = new List<KnowledgeArticleVersion>();
        currentApplicationStep = new Application_Step__c();
        inVaultVisible=false;
        getLifeEventActivities();
        openActivities();
        checkNavigator(lifeEventId);
    }

    private void loadLifeEvent() {
        cmsLifeEvent = new CMS_Life_Event__c();
        try {
            cmsLifeEvent = [Select Id, Display_Name__c, Description__c from CMS_Life_Event__c where Id = :lifeEventId];
        } catch (Exception e) {
            // Do nothing.
        }
        lifeEvent = new Life_Event__c();
        if (cmsLifeEvent == null) {
            return;
        }
        if (user == null || user.ContactId == null) {
            return;
        }
        try {
            lifeEvent = [Select Id, Status__c from Life_Event__c Where CMS_Life_Event__c = :cmsLifeEvent.Id and Contact__c = :user.ContactId];
        } catch (Exception e) {
            // Do nothing.
        }
    }

    private void loadUser() {
        user = null;
        try {
            user = [Select Id, ContactId, LastName from User where Id = :Userinfo.getUserId()];
        } catch (Exception e) {
            // No user found - carry on.
        }
    }

    private List<CMS_Application_Step__c> getCMSApplicationSteps(List<CMS_Life_Event_Type__c> eventStepGroups) {
        if (user != null && user.ContactId != null) {
            return [Select Id,
                Display_Name__c,
                Iframe_Url__c,  Can_Use_Vault__c,
                CMS_Life_Event_Type__r.Display_Name__c,
                Sequence__c,
                (
                  Select Id,
                  Status__c,
                  Life_Event__c,
                  Life_Event__r.Contact__c
                  from Life_Event_Steps__r
                  where Life_Event__r.Contact__c = :user.ContactId
                )
                From CMS_Application_Step__c where CMS_Life_Event_Type__c IN :eventStepGroups
                Order by Sequence__c asc
            ];
        }
        return [
            Select Id,
            Display_Name__c,
            Iframe_Url__c,
            CMS_Life_Event_Type__r.Display_Name__c,
            Sequence__c,Can_Use_Vault__c 
            From CMS_Application_Step__c
            Where CMS_Life_Event_Type__c IN :eventStepGroups
            Order by Sequence__c asc
        ];
    }

    public void getLifeEventActivities() {
        inVault = lifeEvent != null && lifeEvent.Id != null;
        
        stepGroups = new List<EventTypeWrap>();

        if (cmsLifeEvent == null) {
            return;
        }

        List<CMS_Life_Event_Type__c> eventTypes = [Select Id,
            Life_Event__c,
            Display_Name__c
            From CMS_Life_Event_Type__c
            Where Life_Event__c = :cmsLifeEvent.Id
            Order by Sequence__c asc
        ];

        if (eventTypes.size() == 0) {
            return;
        }

        List<CMS_Application_Step__c> cmsApplicationSteps = getCMSApplicationSteps(eventTypes);
        if (cmsApplicationSteps.size() == 0) {
            return;
        }

        Map<Id, String> mapLifeEventStatus = new Map<Id, String>();
        Map<Id, Application_Step__c> mapRelatedapplicationStep = new Map<Id, Application_Step__c>();
        if (user != null && user.ContactId != null) {
            List<Application_Step__c> applicationSteps = [
                Select Id,
                CMS_Life_Event_Step__c,
                Life_Event__r.contact__c,
                Status__c
                From Application_Step__c
                Where CMS_Life_Event_Step__c = :cmsApplicationSteps AND Life_Event__r.contact__c = :user.ContactId
            ];
            for(Application_Step__c applicationStep : applicationSteps) {
                mapLifeEventStatus.put(applicationStep.CMS_Life_Event_Step__c, applicationStep.Status__c);
                mapRelatedapplicationStep.put(applicationStep.CMS_Life_Event_Step__c,applicationStep);
            }
        }

        Map<Id, List<CMS_Application_Step__c>> mapApplicationStep = new Map<Id, List<CMS_Application_Step__c>>();
        for (CMS_Application_Step__c applicationStep : cmsApplicationSteps) {
            if (!mapApplicationStep.containsKey(applicationStep.CMS_Life_Event_Type__c)) {
                mapApplicationStep.put(applicationStep.CMS_Life_Event_Type__c, new List<CMS_Application_Step__c>());
            }
            mapApplicationStep.get(applicationStep.CMS_Life_Event_Type__c).add(applicationStep);
        }

        for (CMS_Life_Event_Type__c eventType : eventTypes) {
            EventTypeWrap eventWrap = new EventTypeWrap(eventType);
            if (mapApplicationStep.containsKey(eventType.Id)) {
                for (CMS_Application_Step__c applicationStep : mapApplicationStep.get(eventType.Id)) {
                    String status = 'new';
                    Application_Step__c applicationStepRecord = new Application_Step__c();
                    if (mapLifeEventStatus.containsKey(applicationStep.Id)) {
                        status = mapLifeEventStatus.get(applicationStep.Id);
                        applicationStepRecord = mapRelatedapplicationStep.get(applicationStep.Id);
                    }
                    eventWrap.steps.add(new ApplicationStepWrap(applicationStep, status,applicationStepRecord));
                }
            }
            stepGroups.add(eventWrap);
        }
    }

    public void openActivities() {
        canUseVault = Apexpages.currentPage().getParameters().get('canUseVault');
        if(canUseVault != null && canUseVault != ''){
            inVaultVisible=boolean.valueOf(canUseVault);
        }
        system.debug('----------------------'+canUseVault+'___'+inVaultVisible);
        String activityName = Apexpages.currentPage().getParameters().get('activityName');
        String activityId = Apexpages.currentPage().getParameters().get('activityId');
        String lifeEventIdRec = '';
        lifeEventIdRecord = '';
        if(Apexpages.currentPage().getParameters().get('lifeEventId') != null && Apexpages.currentPage().getParameters().get('lifeEventId') != ''){
            lifeEventIdRec = Apexpages.currentPage().getParameters().get('lifeEventId');
        }
        openIframe(activityName,activityId,lifeEventIdRec);
    }

    public void openIframe(String activityName,string activityId,string lifeEventIdRec){
        if((activityName != null && activityName !='') && (activityId != null && activityId !='')){
            String iframeName = activityName;
            lifeEventIdRecord = lifeEventIdRec;
            lstKnowledgeVersion = new list<KnowledgeArticleVersion>();
            set<string>setEventTypeTags = new set<string>();
            // Fetch the URL from the step name
            CMS_Application_Step__c cmsAppStep = [Select iframe_url__c, Type__c from CMS_Application_Step__c where Display_Name__c = :iframeName];
            //iframeURL = cmsAppStep.iframe_url__c;
            
                /**** Added by Subodh ****/
            if(user.contactId != null){
                String contactId18 = user.contactId;
                String contactId = contactId18.substring(0,15);
                
                String leStepId;
                if(contactId != null){
                    List <Application_Step__c> listLeStep = [Select Id from Application_Step__c where contact_Id__c =: contactId and CMS_Life_Event_Step__c =: activityId];
                    if(listLeStep.size() > 0){
                        leStepId = listLeStep[0].Id;
                    }
                }
                System.debug(iframeURL);
                System.debug(user.contactId);
                System.debug(activityName);
                System.debug(activityId);
                System.debug(lifeEventIdRec);
                System.debug(leStepId);
                System.debug(contactId);
                if(cmsAppStep.Type__c != 'SmartGuide')
                    iframeURL = cmsAppStep.iframe_url__c;//+'&d_param1='+contactId+'&d_param2='+leStepId;
                else
                    iframeURL = cmsAppStep.iframe_url__c+'&d_param1='+contactId+'&d_param2='+leStepId;
                     
            }
            else
                iframeURL = cmsAppStep.iframe_url__c;

        /*************************/
            
            if (user != null && user.ContactId != null) {
                try {
                    currentApplicationStep = [Select Id, Status__c From Application_Step__c Where CMS_Life_Event_Step__c = :cmsAppStep.Id and Life_Event__r.Contact__c = :user.ContactId];
                } catch (Exception e) {

                }
            }
            // Set the iframeURL
            setEventTypeTags.add(activityName);
            list<CMS_Application_Step__c>lstApplicationTag=[SELECT Id,Name FROM CMS_Application_Step__c where Id =:activityId];
            if(lstApplicationTag.size()>0){
                for(CMS_Application_Step__c applicationtag : lstApplicationTag){
                    setEventTypeTags.add(applicationtag.name);
                }
                if(setEventTypeTags.size() >0){
                    lstKnowledgeVersion=[SELECT Id,articlenumber,urlName,summary,title FROM KnowledgeArticleVersion WHERE (title IN : setEventTypeTags OR summary IN: setEventTypeTags) AND PublishStatus ='Online' AND Language='en_US'];
                }
            }
        }
    }

    public PageReference addEventToVault() {
        if (user == null || user.LastName == 'Site Guest User') {
            addMessage('You must be logged into to access your vault.');
            return null;
        }
        if (user.ContactId == null) {
            // Can only create life events for contact-linked users
            addMessage('Your user must be linked to a contact to enable your vault.');
            return null;
        }
        if (lifeEvent != null && lifeEvent.Id != null) {
            // Can only have one life event record per CMS life event
            addMessage('You have already added this life event to your vault.');
            return null;
        }
        lifeEvent = new Life_Event__c();
        lifeEvent.Contact__c = user.ContactId;
        lifeEvent.CMS_Life_Event__c = cmsLifeEvent.Id;
        insert lifeEvent;
        getLifeEventActivities();
        return null;
    }

    public String applicationStepId {get; set;}
    public PageReference markStepAsCompleted() {
        

        if (currentApplicationStep.id == null) {
            addMessage('An error occured. Code: NO_ASID.');
            return null;
        }
        if (user == null || user.LastName == 'Site Guest User') {
            addMessage('You must be logged into to access your vault.');
            return null;
        }
        if (user.ContactId == null) {
            // Can only create life events for contact-linked users
            addMessage('Your user must be linked to a contact to enable your vault.');
            return null;
        }
        if (lifeEvent == null || lifeEvent.Id == null) {
            // Must have a life event record
            addMessage('You must add this event to your vault before marking a step as complete.');
            return null;
        }

        Application_Step__c step = [Select Id, Status__c, Life_Event__r.Contact__c, Life_Event__c, Life_Event__r.CMS_Life_Event__c From Application_Step__c Where Id = :currentApplicationStep.Id];
        system.debug(step + 'step');
        if (step.Life_Event__c != lifeEvent.Id) {
            addMessage('An error occured. Code: E_LEID');
            return null;
        }

        step.Status__c = 'Submitted';
        upsert step;
        getLifeEventActivities();
        return null;
    }

    public class EventTypeWrap {
        public CMS_Life_Event_Type__c eventGroup {get; set;}
        public List<ApplicationStepWrap> steps {get; set;}

        public EventTypeWrap(CMS_Life_Event_Type__c eventGroup) {
            this.eventGroup = eventGroup;
            steps = new List<ApplicationStepWrap>();
        }
    }
    public class ApplicationStepWrap {
        public CMS_Application_Step__c applicationStep {get; set;}
        public Application_Step__c relatedApplicationStep {get;set;}
        public String status {get; set;}

        public ApplicationStepWrap(CMS_Application_Step__c cmsApplicationStep, String status,Application_Step__c applicationStep1) {
            applicationStep = cmsApplicationStep;
            this.status = status;
            relatedApplicationStep = applicationStep1;
        }
    }

    public void addMessage(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
    }
    
    public void checkNavigator(String leId){
        List <CMS_LIfe_Event__c> listCMS = [Select id from CMS_Life_Event__c where id = : lifeEventId and Navigator__c = false];
        if(listCMS.size() > 0){
            isNavigator = true;
        }
        else
            isNavigator = false;
    }
}