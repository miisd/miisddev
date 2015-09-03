public with sharing class ArticleDetailController {
    public KnowledgeArticleVersion KnowledgeArticleVersion{get;set;}
    public KnowledgeArticleViewStat knowledgeView{get;set;}
    public string articleId{get;set;}
    public string lifeEventId{get;set;}
    public boolean showMessage{get;set;}
    public boolean showDeleteMessage{get;set;}
    public boolean showButton{get;set;}
    public boolean showDeleteButton{get;set;}
    public Having_a_Baby__kav havingBabyBody{get;set;}
    public list<Reading_List__c> readingLst;

    public ArticleDetailController(){
        KnowledgeArticleVersion = new KnowledgeArticleVersion();
        knowledgeView=new KnowledgeArticleViewStat();
        havingBabyBody = new Having_a_Baby__kav();
        readingLst = new list<Reading_List__c>();
        showMessage=false;
        showButton=false;
        showDeleteButton = false;
        showDeleteMessage = false;
        articleId = apexpages.currentpage().getParameters().get('id');
        lifeEventId ='';
        if(apexpages.currentpage().getParameters().get('le_id') != '' && apexpages.currentpage().getParameters().get('le_id') != null){
            lifeEventId = apexpages.currentpage().getParameters().get('le_id');
        }
        if(articleId != null && articleId != ''){            
            fetchArticleViewStat();
        }
    }
    
    public void fetchArticleViewStat(){
        KnowledgeArticleVersion  = [SELECT Id,articlenumber,ArticleType,MasterVersionId,KnowledgeArticleId,urlName,summary,title,VersionNumber,LastModifiedDate  FROM KnowledgeArticleVersion where Id =:articleId limit 1];
        if(lifeEventId != null && lifeEventId != ''){
            readingLst = [select id,Life_Event__c,Knowledge_Article_ID__c from Reading_List__c where Life_Event__c =: lifeEventId AND Knowledge_Article_ID__c =: articleId];
            if(readingLst.size() >0){
                showDeleteButton = true;
                showButton=false;
            }
            else{
                showButton=true;
                showDeleteButton = false;
            }
        }
        if(KnowledgeArticleVersion != null){
            knowledgeView=[select id,ViewCount,NormalizedScore,ParentId,Channel from KnowledgeArticleViewStat where parentId =: KnowledgeArticleVersion.KnowledgeArticleId and Channel='AllChannels' limit 1];
            if(KnowledgeArticleVersion.ArticleType =='Having_a_Baby__kav'){
              havingBabyBody=[SELECT Body__c FROM Having_a_Baby__kav where id=:KnowledgeArticleVersion.MasterVersionId And PublishStatus ='Online' AND Language='en_US' limit 1];
            }            
        }
    }
    public pagereference deleteReadingList(){
        if(readingLst.size() >0){
            try{
                delete readingLst;
                showMessage = false;
                showButton=true;
                showDeleteMessage = true;
                showDeleteButton = false;
            }
            catch(exception e){
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                ApexPages.addMessage(errMsg);
            }
            system.debug('@@@___'+readingLst);
        }
        return null;
    }
    public pagereference addReadingList(){
        Reading_List__c readingList = new Reading_List__c();
        readingList.Name = KnowledgeArticleVersion.title;
        readingList.Knowledge_Article_ID__c=articleId;
        readingList.Knowledge_Article_URL__c='/StateofWellbeing/apex/ArticleDetail?id='+articleId;
        readingList.Life_Event__c=lifeEventId;
        try{
            insert readingList;
            readingLst.add(readingList);
            showMessage=true;
            showButton=false;
            showDeleteButton = true;
            showDeleteMessage = false;
        }
        catch(exception e){
             ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(errMsg);
        }
        return null;
    }
}