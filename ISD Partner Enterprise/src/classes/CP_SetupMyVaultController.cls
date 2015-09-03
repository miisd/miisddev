public with sharing class CP_SetupMyVaultController {

    public Contact conObj {
        get;
        set;
    }
    public User userObj {
        get;
        set;
    }
    public Account accObj {
        get;
        set;
    }
    public Household__c houseObj {
        get;
        set;
    }
    public Payment_Information__c payObj {
        get;
        set;
    }
    public boolean page1 {
        get;
        set;
    }
    public boolean page2 {
        get;
        set;
    }
    public boolean page3 {
        get;
        set;
    }
    public boolean page4 {
        get;
        set;
    }
    public boolean page5 {
        get;
        set;
    }
    public boolean page6 {
        get;
        set;
    }
    public boolean page7 {
        get;
        set;
    }
    public boolean page8 {
        get;
        set;
    }
    public boolean page9 {
        get;
        set;
    }
    public string password {
        get;
        set;
    }
    public string retypePassword {
        get;
        set;
    }

    public CP_SetupMyVaultController() {
        conObj = new Contact();
        accObj = new Account();
        userObj = new User();
        houseObj = new Household__c();
        payObj = new Payment_Information__c();
        page9display();
    }

    public void page1display() {
        page1 = true;
        page2 = false;
        page3 = false;
        page4 = false;
        page5 = false;
        page6 = false;
        page7 = false;
        page8 = false;
        page9 = false;
    }
    public void page2display() {
        page1 = false;
        page2 = true;
        page3 = false;
        page4 = false;
        page5 = false;
        page6 = false;
        page7 = false;
        page8 = false;
        page9 = false;
    }
    public void page3display() {
        page1 = false;
        page2 = false;
        page3 = true;
        page4 = false;
        page5 = false;
        page6 = false;
        page7 = false;
        page8 = false;
        page9 = false;
    }
    public void page4display() {
        page1 = false;
        page2 = false;
        page3 = false;
        page4 = true;
        page5 = false;
        page6 = false;
        page7 = false;
        page8 = false;
        page9 = false;
    }
    public void page5display() {
        page1 = false;
        page2 = false;
        page3 = false;
        page4 = false;
        page5 = true;
        page6 = false;
        page7 = false;
        page8 = false;
        page9 = false;
    }
    public void page6display() {

        page1 = false;
        page2 = false;
        page3 = false;
        page4 = false;
        page5 = false;
        page6 = true;
        page7 = false;
        page8 = false;
        page9 = false;
        if (conObj != null) {
            try {
                insert conObj;
                if (houseObj != null) {
                    houseObj.Contact__c = conObj.id;
                    insert houseObj;
                }
                if (payObj != null) {
                    payObj.Contact__c = conObj.id;

                    insert payObj;
                }
            } catch (exception e) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Unable to create MyVault due to system exception');
            }
        }


    }

    public void page7display() {
        page1 = false;
        page2 = false;
        page3 = false;
        page4 = false;
        page5 = false;
        page6 = false;
        page7 = true;
        page8 = false;
        page9 = false;
    }
    public void page8display() {
        page1 = false;
        page2 = false;
        page3 = false;
        page4 = false;
        page5 = false;
        page6 = false;
        page7 = false;
        page8 = true;
        page9 = false;
    }
    public void page9display() {
        page1 = false;
        page2 = false;
        page3 = false;
        page4 = false;
        page5 = false;
        page6 = false;
        page7 = false;
        page8 = false;
        page9 = true;
    }


}