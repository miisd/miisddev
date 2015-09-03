/**
 * An apex class that keeps updates of a portal user in sync with its corresponding contact.
 * Guest users are never able to access this page.
 */
public without sharing class MyProfilePageController {

    public User user {get; set;}
    public List<Contact> householdMembers {get; set;}
    public Boolean showHouseholdMemberForm {get; private set;}
	public Boolean isEdit {get;set;}
    
    public Contact newHouseholdMember {get; set;}

    public MyProfilePageController() {
        initialize();
    }
	
	public void edit() {}

    private void initialize() {
        showHouseholdMemberForm = false;

        loadUser();
        loadHousehold();

        // guest users should never be able to access this page
        if (user.usertype == 'GUEST') {
            throw new NoAccessException();
        }

        Id accountId = user.Contact != null ? user.Contact.AccountId : null;
        newHouseholdMember = new Contact(AccountId = accountId);
    }

    private void loadUser() {
        user = [SELECT id, email, username, usertype, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contactid,
                contact.accountid, contact.email, contact.phone, contact.mobilephone,
                contact.mailingstreet, contact.mailingcity, contact.mailingstate, contact.mailingpostalcode, contact.mailingcountry,
                contact.otherstreet, contact.othercity, contact.otherstate, contact.otherpostalcode, contact.othercountry, contact.birthdate,
                contact.firstname, contact.lastname, smallphotourl, contact.relationship__c
                FROM User
                WHERE id = :UserInfo.getUserId()];
    }

    private void loadHousehold() {
        householdMembers = [Select Id, Name, FirstName, LastName, Email, Phone, MobilePhone, Birthdate, Relationship__c From Contact Where AccountId = :user.contact.AccountId and Id != :user.contactid];
    }

    public void showAddHouseholdMemberForm() {
        showHouseholdMemberForm = true;
    }

    public void save() {
        if (user.contact != null) {
            setContactFields(user.contact, user);
        }

        try {
            update user;
            if (user.contact != null) {
                update user.contact;
            }
        } catch(DmlException e) {
            ApexPages.addMessages(e);
        }
    }

    public void addHouseholdMember() {
        try {
            upsert newHouseholdMember;
            initialize();
        } catch(DmlException e) {
            ApexPages.addMessages(e);
        }
    }
    
    public void editHouseholdMember() {
        Id householdMemberId = (Id) apexpages.currentPage().getParameters().get('selectedHouseholdMemberId');
        newHouseholdMember = [Select Id, Name, FirstName, LastName, Email, Phone, MobilePhone, Birthdate, Relationship__c From Contact Where Id = :householdMemberId];
        showHouseholdMemberForm = true;
    }
    
    public void deleteHouseholdMember() {
        try {
            Id householdMemberId = (Id) apexpages.currentPage().getParameters().get('selectedHouseholdMemberId');
            delete new Contact(Id = householdMemberId);
            initialize();
        } catch(DmlException e) {
            ApexPages.addMessages(e);
        }
    }

    public PageReference changePassword() {
        return Page.ChangePassword;
    }

    public PageReference cancel() {
        return ApexPages.currentPage().setRedirect(true);
    }

    public static void setContactFields(Contact c, User u) {
        /*c.title = u.title;
        c.firstname = u.firstname;
        c.lastname = u.lastname;
        c.email = u.email;
        c.phone = u.phone;
        c.mobilephone = u.mobilephone;
        c.fax = u.fax;
        c.mailingstreet = u.street;
        c.mailingcity = u.city;
        c.mailingstate = u.state;
        c.mailingpostalcode = u.postalcode;
        c.mailingcountry = u.country;*/
    }
}