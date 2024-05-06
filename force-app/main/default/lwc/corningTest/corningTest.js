import { LightningElement, wire, api, track } from 'lwc';
import getUserList from '@salesforce/apex/CorningTestExtension.getUserList';
import getBookList from '@salesforce/apex/CorningTestExtension.getBookList';
import getAllOpps from '@salesforce/apex/CorningTestExtension.getAllOpps';
import currentUserId from '@salesforce/user/Id';
import LightningAlert from 'lightning/alert';
import LightningConfirm from 'lightning/confirm';
import {
    subscribe,
    unsubscribe,
    onError,
    setDebugFlag,
    isEmpEnabled,
} from 'lightning/empApi';


export default class CorningTest extends LightningElement {

    async handleAlertClick() {
        // await LightningAlert.open({
        //     message: 'this is the alert message',
        //     theme: 'shade', // a red theme intended for error states
        //     label: 'shade!', // this is the header text
        // });
        //Alert has been closed
        // await LightningAlert.open({
        //     message: 'this is the alert message',
        //     theme: 'inverse', // a red theme intended for error states
        //     label: 'inverse!', // this is the header text
        // });
        // await LightningAlert.open({
        //     message: 'this is the alert message',
        //     theme: 'alt-inverse', // a red theme intended for error states
        //     label: 'alt-inverse!', // this is the header text
        // });
        // await LightningAlert.open({
        //     message: 'this is the alert message',
        //     theme: 'success', // a red theme intended for error states
        //     label: 'success!', // this is the header text
        // });
        await LightningAlert.open({
            message: 'this is the alert message',
            theme: 'info', // a red theme intended for error states
            label: 'info!', // this is the header text
        });
        // await LightningAlert.open({
        //     message: 'this is the alert message',
        //     theme: 'warning', // a red theme intended for error states
        //     label: 'warning!', // this is the header text
        // });
        // await LightningAlert.open({
        //     message: 'this is the alert message',
        //     theme: 'offline', // a red theme intended for error states
        //     label: 'offline!', // this is the header text
        // });
    }

    async handleConfirmClick() {
        const result = await LightningConfirm.open({
            message: 'this is the error message',
            variant: 'headerless',
            label: 'this is the aria-label value',
            theme: 'error'
            // setting theme would have no effect
        });
        //Confirm has been closed
        //result is true if OK was clicked
        //and false if cancel was clicked
    }
    
    connectedCallback() {
        // this.getUserListJS().then(
        //     this.getBookListJS()
        // ).then(res => {
        //     console.log('res :>> ', res);
        //     console.log('this.userList :>> ', this.userList);
        //     console.log('this.bookList :>> ', this.bookList);
        // });
        this.init();
    }

    async init() {
        await this.getUserListJS();
        await this.getBookListJS();
        
        
    }

    @api recordId;

    @track userList = [];
    @track bookList = [];

    async getUserListJS() {
        // return new Promise(function (resolve, reject) {
            await getUserList(

            ).then(data => {
                this.userList = data;
                console.log('getUserListJS data :>> ', data);
                // resolve(data);
            }).catch(error => {
                // reject(error);
                console.log('getUserListJs error :>> ', error);
            }).finally(() => {
                console.log('getUserListJs finilly');
            });
        // });
    }

    async getBookListJS() {
        // return new Promise(function (resolve, reject) {
            await getBookList({
                userId: currentUserId
            }).then(data => {
                console.log('getBookListJs data :>> ', data);
                this.bookList = data;
                // resolve(data);
            }).catch(error => {
                // reject(error);
                console.log('getBookListJs error :>> ', error);
            }).finally(() => {
                console.log('getBookListJs finilly');
            });
        // });
    }




    @track columns = [
        {
            label: 'Opportunity name',
            fieldName: 'nameUrl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'Name' }, 
            target: '_blank'},
            sortable: true
        },
        {
            label: 'Stage Name',
            fieldName: 'StageName',
            type: 'text',
            sortable: true
        },
        {
            label: 'Close date',
            fieldName: 'CloseDate',
            type: 'date',
            sortable: true
        }

    ];

    @track error;
    @track opportunities = [];


    @wire(getAllOpps)
    wiredOpps(result) {
        const { data, error } = result;
        if(data) {
            let nameUrl;
            this.opportunities = data.map(row => { 
                nameUrl = `/${row.Id}`;
                return {...row , nameUrl} 
            })
            this.error = null;
            console.log(this.opportunities);
        }
        if(error) {
            this.error = error;
            this.opportunities = [];
        }
    }




    channelName = '/event/Test__e';
    isSubscribeDisabled = false;
    isUnsubscribeDisabled = !this.isSubscribeDisabled;

    subscription = {};

    // Tracks changes to channelName text field
    handleChannelName(event) {
        this.channelName = event.target.value;
    }

    // Initializes the component
    connectedCallback() {
        // Register error listener
        this.registerErrorListener();
    }

    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = function (response) {
            console.log('New message received: ', JSON.stringify(response));
            // Response contains the payload of the new message received
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then((response) => {
            // Response contains the subscription information on subscribe call
            console.log(
                'Subscription request sent to: ',
                JSON.stringify(response.channel)
            );
            this.subscription = response;
            this.toggleSubscribeButton(true);
        });
    }

    // Handles unsubscribe button click
    handleUnsubscribe() {
        this.toggleSubscribeButton(false);

        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, (response) => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }

    toggleSubscribeButton(enableSubscribe) {
        this.isSubscribeDisabled = enableSubscribe;
        this.isUnsubscribeDisabled = !enableSubscribe;
    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError((error) => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }


}