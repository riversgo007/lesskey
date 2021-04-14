//import {ethers} from "ethers";

const Web3 = require("web3");
const KeySpace = artifacts.require("KeySpace");
const secp256k1=require('secp256k1');
const ethers = require("ethers");
//const Web3 = artifacts.require("Web3");
contract('KeySpace', (accounts) => {
    it("init keyspace", async()=>{
        let web3 = new Web3();
        let seed= ethers.utils.sha256(ethers.utils.toUtf8Bytes('private key seed'))

        let privKey = Buffer.from(seed.slice(2),'hex').toString('hex');
        let addr = ethers.utils.computeAddress(seed);

        let message = "\x19Ethereum Signed Message:\n"+addr.length+addr;
        let signature = web3.eth.accounts.sign(message,privKey);

        const keySpaceInstance = await KeySpace.deployed();
        console.log("init keyspace,addr:",addr)
        var s1= await keySpaceInstance.initKeySpace.call(addr, signature.messageHash, signature.r, signature.s,signature.v,"v-0.1");
        console.log("init keyspace result:",s1)

    });

    it("get seed", async()=>{
        const keySpaceInstance = await KeySpace.deployed();
        let seed= ethers.utils.sha256(ethers.utils.toUtf8Bytes('private key seed'))

        let privKey = Buffer.from(seed.slice(2),'hex').toString('hex');
        let addr = ethers.utils.computeAddress(seed);
        var result = await keySpaceInstance.spaceExist.call(addr);
        console.log("space exist:", result,",addr:",addr)
    });

    it("verify signature", async()=>{
        let web3 = new Web3();
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

});
