//import {ethers} from "ethers";

const Web3 = require("web3");
const KeySpace = artifacts.require("KeySpace");
const secp256k1=require('secp256k1');
const ethers = require("ethers");
const Save=artifacts.require("Save");
//const Web3 = artifacts.require("Web3");
contract('KeySpace', (accounts) => {
    it("init keyspace", async()=>{
        const keySpaceInstance = await KeySpace.deployed();

        let web3 = new Web3();
        let seed= ethers.utils.sha256(ethers.utils.toUtf8Bytes('private key seed'))

        let privKey = Buffer.from(seed.slice(2),'hex').toString('hex');
        let addr = ethers.utils.computeAddress(seed);

        let message = "\x19Ethereum Signed Message:\n"+addr.length+addr;
        let signature = web3.eth.accounts.sign(message,privKey);

        console.log("init keyspace,addr:",addr)
        var s1= await keySpaceInstance.initKeySpace(addr, signature.messageHash, signature.r, signature.s,signature.v,"v-0.1");
        console.log("init keyspace result:",s1)
    });

    it("space exist", async()=>{
        const keySpaceInstance = await KeySpace.deployed();
        let seed= ethers.utils.sha256(ethers.utils.toUtf8Bytes('private key seed'))

        let privKey = Buffer.from(seed.slice(2),'hex').toString('hex');
        let addr = ethers.utils.computeAddress(seed);
        var result = await keySpaceInstance.spaceExist.call(addr);
        console.log("(maybe relavant to auth /internal/private)space exist:", result,",addr:",addr)
    });

    it("add key with label", async()=>{
        const keySpaceInstance = await KeySpace.deployed();

        let web3 = new Web3();
        let seed= ethers.utils.sha256(ethers.utils.toUtf8Bytes('private key seed'))

        let privKey = Buffer.from(seed.slice(2),'hex').toString('hex');
        let addr = ethers.utils.computeAddress(seed);

        let message = "\x19Ethereum Signed Message:\n"+addr.length+addr;
        let signature = web3.eth.accounts.sign(message,privKey);

        console.log("init keyspace,addr:",addr)

        let labelName="lableName";
        let cryptoKey="cryptoKey content";
        //let _label = ethers.utils.sha256(addr.toString()+labelName);
        let labelSeed = ethers.utils.sha256(ethers.utils.toUtf8Bytes(addr.toString()+labelName));
        let label =ethers.utils.computeAddress(labelSeed).toLowerCase();

        let labelKeyHash = ethers.utils.solidityKeccak256(['string'],[label+cryptoKey+labelName+"v-0.1"]);
        var s1= await keySpaceInstance.addKey(addr, signature.messageHash, signature.r, signature.s,signature.v,label,cryptoKey,labelName,"v-0.1",labelKeyHash);
        console.log("add key s1:",s1)
    });

    it("verify signature", async()=>{
        let web3 = new Web3();
        const keySpaceInstance = await KeySpace.deployed();
        let seed= ethers.utils.sha256(ethers.utils.toUtf8Bytes('private key seed'))

        let privKey = Buffer.from(seed.slice(2),'hex').toString('hex');
        let addr = ethers.utils.computeAddress(seed);

/*
        let seed0= ethers.utils.sha256(ethers.utils.toUtf8Bytes('private key seed0'))
        let addr0 = ethers.utils.computeAddress(seed0);
*/

/*
        let message = "\x19Ethereum Signed Message:\n"+addr.length+addr;
        let signature = web3.eth.accounts.sign(message,privKey);

        const keySpaceInstance = await KeySpace.deployed();
        var s1= await keySpaceInstance.verifySignature.call(addr, signature.messageHash, signature.r, signature.s,signature.v);
        console.log("verify signature:", s1)
*/
    });
    it("get labels", async()=>{
        const keySpaceInstance = await KeySpace.deployed();
        let seed= ethers.utils.sha256(ethers.utils.toUtf8Bytes('private key seed'))

        let privKey = Buffer.from(seed.slice(2),'hex').toString('hex');
        let addr = ethers.utils.computeAddress(seed);
        var result = await keySpaceInstance.allLabels.call(addr);
        console.log("space exist:", result,",addr:",addr)
    });
    it("get key", async()=>{
        const keySpaceInstance = await KeySpace.deployed();

        let web3 = new Web3();
        let seed= ethers.utils.sha256(ethers.utils.toUtf8Bytes('private key seed'))

        let privKey = Buffer.from(seed.slice(2),'hex').toString('hex');
        let addr = ethers.utils.computeAddress(seed);

        let message = "\x19Ethereum Signed Message:\n"+addr.length+addr;
        let signature = web3.eth.accounts.sign(message,privKey);

        console.log("init keyspace,addr:",addr)

        let labelName="lableName";
        let cryptoKey="cryptoKey content";
        //let _label = ethers.utils.sha256(addr.toString()+labelName);
        let labelSeed = ethers.utils.sha256(ethers.utils.toUtf8Bytes(addr.toString()+labelName));
        let label =ethers.utils.computeAddress(labelSeed).toLowerCase();

        let labelHash = ethers.utils.solidityKeccak256(['string'],[label]);
        var s1= await keySpaceInstance.getKey.call(addr, signature.messageHash, signature.r, signature.s,signature.v,label,labelHash);
        console.log("get key content:",s1)


    })
});
