const path = require('path');
const fs = require('fs');
const solc = require('solc');

const compileContract = (contractName) => {
    const contractPath = path.resolve(__dirname, 'contracts', `${contractName}.sol`);
    const source = fs.readFileSync(contractPath, 'utf8');

    const input = {
        language: 'Solidity',
        sources: {
            [`${contractName}.sol`]: {
                content: source,
            },
        },
        settings: {
            outputSelection: {
                '*': {
                    '*': ['*'],
                },
            },
        },
    };

    const output = JSON.parse(solc.compile(JSON.stringify(input)));
    const contract = output.contracts[`${contractName}.sol`][contractName];

    return {
        abi: contract.abi,
        bytecode: contract.evm.bytecode.object,
    };
};

module.exports = compileContract;
