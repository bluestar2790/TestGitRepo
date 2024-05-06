import { LightningElement } from 'lwc';

export default class myFirstLwc extends LightningElement {
    greeting = 'World';
    changeHandler(event) {
        console.log(event.target);
        this.greeting = event.target.value;
    }

    areDetailsVisible = false;
    handleChange(event) {
        console.log(event.target);
        this.areDetailsVisible = event.target.checked;
    }

    contacts = [
        {
            Id: 1,
            Name: 'Amy Taylor',
            Title: 'VP of Engineering',
        },
        {
            Id: 2,
            Name: 'Michael Jones',
            Title: 'VP of Sales',
        },
        {
            Id: 3,
            Name: 'Jennifer Wu',
            Title: 'CEO',
        },
    ];

}