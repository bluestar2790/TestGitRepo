import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Testlwc2 extends NavigationMixin(LightningElement) {
    @api invoke() {
        let cmpDef = {
            componentDef: "c:corningTest"
        };
      
        let encodedDef = btoa(JSON.stringify(cmpDef));
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: "/one/one.app#" + encodedDef
            }
        });
    }
}