/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        String communityUrl = 'https://isddev-isddev.cs51.force.com/';
      //  String customHomePage = '_ui/core/chatter/ui/ChatterPage';
        
        if (UserInfo.getUserType().equals('Guest')) {
            return new PageReference(communityUrl + 'Home');
        } else {
          return new PageReference(communityUrl + 'HomeAuthenticated' );
          //    return null;
            }
      //  return Network.communitiesLanding();
    }
    
    public CommunitiesLandingController() {}
}