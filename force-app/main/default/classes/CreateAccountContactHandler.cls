public without sharing class CreateAccountContactHandler implements Triggers.Handler {
    public void handle(){
        List<Contact> conList = new List<Contact>();

        for (Account acc : (List<Account>)Trigger.new) {
            Contact con = new Contact();
            con.Phone = acc.Phone;
            con.AccountId = acc.Id;
            con.Fax = acc.Fax;
            con.MailingCountry = acc.ShippingCountry;
            con.MailingCity = acc.ShippingCity;
            con.MailingStreet = acc.ShippingStreet;
            con.MailingPostalCode = acc.ShippingPostalCode;
            con.MailingLatitude = acc.ShippingLatitude;
            con.MailingLongitude = acc.ShippingLongitude;
            conList.add(con);
        }

        if (conList.size() > 0) {
            INSERT conList;
        }
    }
}