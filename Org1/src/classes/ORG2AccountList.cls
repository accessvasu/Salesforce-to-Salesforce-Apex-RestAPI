//wrapper class for the api responses
public class ORG2AccountList {
    public String isActive {get; set;}
    public String accNumber {get; set;}
    public String accName {get; set;}
    public String accId {get; set;}
    public ORG2AccountList(String isa, String an, String n, String id){
        this.isActive = isa;
        this.accNumber = an;
        this.accName = n;
        this.accId = id;    
    }
}