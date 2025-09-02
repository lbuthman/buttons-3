import {LightningElement, track} from 'lwc';
import ZOMBIES from '@salesforce/resourceUrl/maleZombie';

const IDLE_IMAGES = ['idle1.png', 'idle2.png', 'idle3.png', 'idle4.png', 'idle5.png', 'idle6.png', 'idle7.png',
    'idle8.png', 'idle9.png', 'idle10.png', 'idle11.png', 'idle12.png', 'idle13.png', 'idle14.png', 'idle15.png'];
const DEAD_IMAGES = ['dead1.png', 'dead2.png', 'dead3.png', 'dead4.png', 'dead5.png', 'dead6.png',
    'dead7.png', 'dead8.png', 'dead9.png', 'dead10.png', 'dead11.png', 'dead12.png'];

const STATE = {IDLE: 'IDLE', DEAD: 'DEAD'};

export default class FirstComponent extends LightningElement {

    notInitialized = true;
    idleIndex = 0;
    deadIndex = 0;
    animationSpeed = 40;

    @track zombie = ZOMBIES + '/male-zombie/' + IDLE_IMAGES[this.idleIndex];
    currentState = STATE.IDLE;

    renderedCallback() {
        if (this.notInitialized) {
            this.animate();
            this.notInitialized = false;
        }
    }

    animate() {
        if (this.currentState === STATE.IDLE) {
            this.idleIndex = this.idleIndex === 15 ? 0 : (this.idleIndex + 1);
            this.zombie = ZOMBIES + '/male-zombie/' + IDLE_IMAGES[this.idleIndex];
            this.reFireAnimation()
        }
        else if (this.currentState === STATE.DEAD) {
            if (this.deadIndex < 11) {
                this.deadIndex += 1;
                this.zombie = ZOMBIES + '/male-zombie/' + DEAD_IMAGES[this.deadIndex];
                this.reFireAnimation();
            }
        }
    }

    reFireAnimation() {
        setTimeout(() => {
            window.requestAnimationFrame(this.animate);
            this.animate();
        }, this.animationSpeed);
    }

    handleSlowDown() {
        this.animationSpeed += 5;
        if (this.animationSpeed >= 80) {
            this.currentState = STATE.DEAD;
        }
    }

    get idleZombieURL() {
        return ZOMBIES + '/male-zombie/' + IDLE_IMAGES[this.idleIndex];
    }
}