import { LightningElement } from 'lwc';

export default class JfwHelpDeskComponent extends LightningElement {

    openHelpDesk(event) {
        var strWindowFeatures = "location=yes,height=570,width=520,scrollbars=yes,status=yes";
        var URL = "mailto:?to=helpdesk@uxltechnologies.net";
        var win = window.open(URL, "_blank", strWindowFeatures);
    }
}