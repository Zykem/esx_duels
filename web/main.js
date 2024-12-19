elements = {
    container: document.getElementById('mainContainer'),
    opponent: document.getElementById('opponent'),
    seconds: document.getElementById('seconds')
}

let countdownInterval

const startCountdown = () => {
    if (countdownInterval) clearInterval(countdownInterval);
    
    let countdownValue = 5;

    elements.seconds.textContent = '5'

    countdownInterval = setInterval(() => {
        countdownValue--;
        elements.seconds.textContent = countdownValue;

        if (countdownValue <= 0) {
            elements.container.style.transform = 'translateX(-100%)';
        }
    }, 1000)
}

const onMessage = (e) => {
    const { data } = e;

    switch (data.action) {
        case 'startCountdown':
            elements.container.style.transform = 'translateX(0%)';
            elements.opponent.textContent = data.opponent;
            startCountdown();
            break;
        default:
            break;
    }
}

window.addEventListener('message', onMessage)