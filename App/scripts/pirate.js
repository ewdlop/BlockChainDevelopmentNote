const IPFS = require('ipfs-api');
const ipfs = IPFS({ host: 'ipfs.infura.io', port: 5001, protocol: 'https' });

async function uploadData(data) {
    const buffer = Buffer.from(JSON.stringify(data));
    const result = await ipfs.add(buffer);
    console.log('Data uploaded to IPFS:', result[0].hash);
    return result[0].hash;
}

async function downloadData(hash) {
    const files = await ipfs.cat(hash);
    const data = JSON.parse(files.toString());
    console.log('Data downloaded from IPFS:', data);
    return data;
}

// Example usage:
const data = { x: 10, y: 10, vx: 1, vy: 1 };
uploadData(data).then(hash => {
    downloadData(hash);
});
