import {LightningElement} from 'lwc';

export default class AnimateJavaScript extends LightningElement {

    doTheThing() {
        const zeros = '0000000';
        let color = '#' + Math.floor(Math.random() * 0xFFFFFF).toString(16);
        const colorLength = color.length;
        if (colorLength < 7) {
            color += zeros.substring(0, zeros.length - colorLength);
        }
        const button = this.template.querySelector('lightning-button');
        button.classList.toggle('funky-mode');
        button.style.setProperty('--changing-background', color);
    }
}