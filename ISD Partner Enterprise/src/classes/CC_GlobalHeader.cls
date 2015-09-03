public class CC_GlobalHeader {

    public String testvalue { get; set; }
    public string strSeacrhText{get;set;}
    Public List<List<SObject>> searchList{get;set;}
    public List<KnowledgeArticleVersion> listArticles {get;set;}
    public Boolean InitiateSearch{get;set;}
    public map<Id,Integer>mapKnowledgeArticleViewStat{get;set;}
    public innerWrapper innerList{get;set;}
    public Boolean searchedPanel{get;set;}
    public Boolean articleList{get;set;}
    public Boolean CMSList{get;set;}
    public string Id {get;set;}
    public Boolean noResultFound{get;set;}
    public integer AllSearchResult{get;set;}
    public integer ArticleSearchResult{get;set;}
    public integer LifeEventSearchResult{get;set;} 
   
    
    public CC_GlobalHeader(){
        ArticleSearchResult=0;
        LifeEventSearchResult=0;
        InitiateSearch = false;
        searchedPanel = false;
        listArticles = new List<KnowledgeArticleVersion>();
        CMSList =false;
        testvalue ='';
        articleList = false;
        noResultFound =false;
        AllSearchResult =0;
        strSeacrhText='';        
        if(ApexPages.currentPage().getParameters().get('token') != null){
            strSeacrhText=ApexPages.currentPage().getParameters().get('token');
            searchResults();
        }
    }
    
     public PageReference redirPage(){
        system.debug('------------------articleList----'+articleList);
        system.debug('------------------cmslist----'+cmslist);
        return null;
    }
    
    public class innerWrapper{
        public list<KnowledgeArticleVersion> knowledgeList{get;set;}
        public list<CMS_Life_Event__c> cmsList{get;set;}
    }

    Public PageReference search(){
        PageReference searchPage = new PageReference('/StateofWellbeing/SearchResults');
        searchPage.setRedirect(true);
        return searchPage;
    }

    public static String LAST_SEARCH_STRING = '';
    @RemoteAction
    Public static list<searchResultWrapper> searchKnowledgeBase(string strSearch){          

        List<searchResultWrapper> result = new List<searchResultWrapper>();
        if(LAST_SEARCH_STRING == strSearch)
            return result;

        LAST_SEARCH_STRING = strSearch;
        string searchquery;

        if(strSearch !=null || strSearch!=''){
            searchquery =  'FIND \'' + strSearch+ '*' + '\'' + 'IN ALL FIELDs Returning KnowledgeArticleVersion(ID, KnowledgeArticleId, ArticleNumber,Title,Summary,UrlName,VersionNumber WHERE PublishStatus =\'Online\' AND Language=\'en_US\'),CMS_Life_Event__c(ID,Description__c,Display_Name__c,Image__c,Name where Sub_event__c = false AND Deployed__c = TRUE)'; 
            list<list<sObject>> searchList = search.query(searchquery);
            list<KnowledgeArticleVersion> lstKnowledge = new list<KnowledgeArticleVersion>();
            list<CMS_Life_Event__c> lstCMS = new list<CMS_Life_Event__c>();            

            Set<Id> idSet = new Set<Id>(); 
            for(list<sObject> objectListSearched : searchList){
                if(objectListSearched.getSObjectType().getDescribe().getName() == 'KnowledgeArticleVersion'){
                    lstKnowledge = objectListSearched;
                }

                if(lstKnowledge != null){
                    for(KnowledgeArticleVersion KnwObject : lstKnowledge){
                        if(idSet.contains(KnwObject.Id)){
                            continue;
                        }
                        searchResultWrapper srw = new searchResultWrapper();
                        srw.category = 'Knowledge Articles';
                        srw.label = KnwObject.Title;
                        srw.id = string.valueOf(KnwObject.Id);
                        result.add(srw);
                        idSet.add(KnwObject.Id);
                    }
                }

                if(objectListSearched.getSObjectType().getDescribe().getName() == 'CMS_Life_Event__c'){
                     lstCMS = objectListSearched;
                }

                if(lstCMS != null){
                    for(CMS_Life_Event__c  CMSObject : lstCMS ){
                        if(idSet.contains(CMSObject.Id)){
                            continue;
                        }
                        searchResultWrapper srw = new searchResultWrapper();
                        srw.category = 'Life Events';
                        srw.label = CMSObject.Name;
                        srw.id=string.valueOf(CMSObject.Id);
                        result.add(srw);
                        idSet.add(CMSObject.Id);                        
                    }
                }    
            }            
        }
        return result; 
    }
    
    public class searchResultWrapper{
       public string category {get;set;} 
       public string label {get;set;}
       public string id{get;set;}
    }


    Public pageReference searchResults(){
        CMSList =true;
        articleList = true;
        searchedPanel = true;
        InitiateSearch = True;
        listArticles = new List<KnowledgeArticleVersion>();
        List<CMS_Life_Event__c> listArticlesCMS   = new List<CMS_Life_Event__c>();
        mapKnowledgeArticleViewStat=new map<Id,Integer>();
        String status = 'Online';
        String lang  = 'en_US';
        // strSeacrhText = testvalue;
        
        /*strSeacrhText= strSeacrhText.trim();
        system.debug('strstrstrstr'+strSeacrhText);
        
        strSeacrhText = strSeacrhText.replaceAll('(\\s+)', ' OR ');*/
        string querywhere = strSeacrhText+'*';
        String searchquery;
        if(strSeacrhText==null || strSeacrhText == '' || strSeacrhText.length()<2){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide at least 2 characters to perform a search'));
            InitiateSearch = false;
            return null;            
        }
        searchquery =  'FIND \'' + querywhere + '*' + '\'' + 
      'IN ALL FIELDs Returning KnowledgeArticleVersion(ID, KnowledgeArticleId, ArticleNumber,Title,Summary,UrlName,VersionNumber WHERE PublishStatus =\'Online\' AND Language=\'en_US\'),CMS_Life_Event__c(ID,Description__c,Display_Name__c,Image__c,Name where Sub_event__c = false AND Deployed__c = TRUE)'; 
                       
        searchList = search.query(searchquery);
        listArticles  = ((List<KnowledgeArticleVersion>)searchList[0]);
        ArticleSearchResult= listArticles.size();
        listArticlesCMS  = ((List<CMS_Life_Event__c>)searchList[1]);
        LifeEventSearchResult= listArticlesCMS.size();
        AllSearchResult = listArticles.size()+listArticlesCMS.size();
       
        if(listArticles.isEmpty() && listArticlesCMS.isEmpty()){
            noResultFound =true;
            searchedPanel = false;
        }
        else{
            noResultFound =false;
            searchedPanel = true;
        }

        innerList  =  new innerWrapper();
        system.debug('test searchlist listArticles  '+listArticles.size()+'test listArticlesCMS '+listArticlesCMS.size());
        innerList.knowledgeList = listArticles;
        innerList.cmsList = listArticlesCMS;
        
        set<Id>setArticleId = new set<Id>();
        system.debug('@@@___'+listArticles);
        if(listArticles.size() > 0){
            for(KnowledgeArticleVersion articleVersion : listArticles){
                setArticleId.add(articleVersion.KnowledgeArticleId);                
            }
        }
        system.debug('@@@1___'+setArticleId);
        if(setArticleId.size() > 0){
            list<KnowledgeArticleViewStat>lstKnowledgeViewStat=[select id,ViewCount,ParentId from KnowledgeArticleViewStat where parentId IN : setArticleId];
            system.debug('@@@2___'+lstKnowledgeViewStat);
            if(lstKnowledgeViewStat.size() >0){
                for(KnowledgeArticleViewStat viewStat : lstKnowledgeViewStat){
                    mapKnowledgeArticleViewStat.put(viewStat.ParentId,viewStat.ViewCount);
                }
            }
        }  
        system.debug('@@@3___'+mapKnowledgeArticleViewStat);     
        system.debug('test hello--->listArticle'+mapKnowledgeArticleViewStat );
       
      return null; 
    }
}