/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class CommunitiesLoginController {
    global String username {get;set;}
    global String password {get;set;}
    global Boolean userRememberMe{get;set;}
    
    global CommunitiesLoginController () {}
    
    // Code we will invoke on page load.
    global PageReference forwardToAuthPage() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        String displayType = System.currentPageReference().getParameters().get('display');
        return Network.forwardToAuthPage(startUrl, displayType);
    }
    
    global PageReference forwardToCustomAuthPage() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');        
        if (Site.getPathPrefix() != null && startUrl != null) {
            return new PageReference(Site.getPathPrefix() + '/Home?startURL=' +
            EncodingUtil.urlEncode(startURL, 'UTF-8'));
        } else
        return null;
    }
        
    global PageReference login()
    {
        String startUrl = System.currentPageReference().getParameters().get('startURL');        
        Pagereference p = Site.login(username, password, startUrl);
        return p;
    }

      /*
    * @description: This method is to set or remove user info cookies
    * @param: none
    * @return type: none
    */
    global void userCookiesSet(){
        if(userRememberMe == true){
        system.debug('test here userRememberMe  value as true'+userRememberMe );
            Apexpages.currentPage().setCookies(new Cookie[]{new Cookie('prtlUsrName',username,null,315569260,true)});      
            Apexpages.currentPage().setCookies(new Cookie[]{new Cookie('prtlRemebrMe',String.valueof(userRememberMe),null,315569260,true)});
        } 
        else if(userRememberMe ==false){
        system.debug('test here userRememberMe  value as false'+userRememberMe );
            Apexpages.currentPage().setCookies(new Cookie[]{new Cookie('prtlUsrName',username,null,0,true)});      
            Apexpages.currentPage().setCookies(new Cookie[]{new Cookie('prtlRemebrMe',String.valueof(userRememberMe),null,0,true)});
        }
    }
}