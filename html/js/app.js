function main(){
    return {
        display: false,
        eyeActive: false,
        target: [],
        executeTarget(id){
            console.log(`[DEBUG] UI: Executing target ${id}`);
            console.log(JSON.stringify(this.target[id], null, 2))
            if(this.target[id]){
                const target = id + 1
                console.log(`[DEBUG] UI: Sending target ${target}`);
                postData(`selectTarget`, target).then(data => {
                    if (data.status == 'success') {
                        this.display = false;
                    }
                })
            }
        },
        
        listen(){
            window.addEventListener('message', (event) => {
                const item = event.data
                switch (item.response) {
                    case 'validTarget':
                        console.log(JSON.stringify(item.data, null, 2))
                        this.target.splice(0, this.target.length);
                        for (let [index, itemData] of Object.entries(item.data)) {
                            if (itemData !== null) {
                                this.target.push(itemData)
                            }
                          }
                        this.eyeActive = true;
                        console.log(JSON.stringify(this.target, null, 2))
                        break;
                    case 'openTarget':
                        this.display = true;
                        break;
                    case 'closeTarget':
                        this.display = false;
                        this.eyeActive = false;
                        this.target.splice(0, this.target.length);
                        break;
                    case 'leftTarget':
                        this.eyeActive = false;
                        this.target.splice(0, this.target.length);
                        break
                }
            })
        }
    }
}

async function postData(event = '', data = {}) {
    const response = await fetch(`https://${GetParentResourceName()}/${event}`, {
      method: 'POST', // *GET, POST, PUT, DELETE, etc.
      mode: 'cors', // no-cors, *cors, same-origin
      cache: 'no-cache', // *default, no-cache, reload, force-cache, only-if-cached
      credentials: 'same-origin', // include, *same-origin, omit
      headers: {
        'Content-Type': 'application/json'
      },
      redirect: 'follow',
      referrerPolicy: 'no-referrer',
      body: JSON.stringify(data)
    });
    return response.json();
  }
