<template>
	<div class="hello">
		<el-button class="connect" @click="connectWallet" v-show="!checksumAddress"
		>连接钱包</el-button
		>
		<el-button class="connect" disabled v-show="checksumAddress">钱包已连接</el-button>

		<h1>{{ msg }}</h1>
		<el-radio-group v-model="tabSwitch">
			<el-radio-button label="1">Keyspace</el-radio-button>
			<el-radio-button label="2">存储</el-radio-button>
			<el-radio-button label="3">获取</el-radio-button>
		</el-radio-group>

		<div class="keyspace" v-if="tabSwitch == 1">
			<el-input
					v-model="keySpaceTab.input0"
					type="text"
					minlength="5"
					placeholder="Keyspace:  请尽量使用全网唯一的内容，例如：您的邮箱、身份证ID或NFT作品地址等."
			></el-input>
			<el-input
					type="password"
					v-model="keySpaceTab.input1"
					placeholder="Password:  输入加密密钥，请务必牢记于心."
			></el-input>
			<el-dialog title="" :visible.sync="keySpaceTab.confirm" width="50%">
				<el-input
						type="password"
						v-model="keySpaceTab.input1Confirm"
						placeholder="再次输入加密密钥"
				></el-input>
				<el-button type="primary" @click="initKeySpace">确认初始化</el-button>
			</el-dialog>
			<el-button @click="beforeInitKeySpace" type="primary"
			>Keyspace 初始化</el-button
			>
		</div>

		<div class="set" v-if="tabSwitch == 2">
			<el-input
					v-model="setTab.input0"
					placeholder="Keyspace:  请输入初始化时使用的密钥空间值"
			></el-input>
			<el-dialog title="" :visible.sync="setTab.confirm" width="50%">
				<el-input
						type="password"
						v-model="setTab.password"
						placeholder="请输入加密密钥"
				></el-input>
				<el-button type="primary" @click="savePrivateSecret"
				>确认存储</el-button
				>
			</el-dialog>
			<div class="flex">
				<el-input
						v-model="setTab.input1"
						class="mini-input"
						style="margin-right: 5px"
						placeholder="私钥标签"
				></el-input>
				<el-input v-model="setTab.input2" placeholder="私钥内容"></el-input>
			</div>
			<el-button type="primary" @click="beforeSavePrivateSecret"
			>存储</el-button
			>
		</div>

		<div class="get" v-if="tabSwitch == 3">
			<el-input
					v-model="getTab.input0"
					placeholder="Keyspace: 请输入初始化时使用的密钥空间值"
					@keyup.enter="queryPrivateSecret"
			></el-input>
			<div>{{ getTab.result }}</div>
		</div>
	</div>
</template>

<script>
	//import NodeRSA from 'node-rsa';
	import {ethers} from 'ethers';
	import Web3 from "web3";
	import CryptoJS from 'crypto-js';
	let web3 = new Web3(window.ethereum)
	// todo 此处填写合约地址
	const CONTRACT_ADDRESS = "0x3694FD2B16820016A4FB722ce1523FF742cC1016"
	const zlib = require("zlib");

	export default {
		name: "Home",
		props: {
			msg: String,
		},
		data() {
			return {
				checksumAddress: "",
				connectAddress: "",
				passwordStore: "",
				keySpaceTab: {
					input0: "",
					input1: "",
					input1Confirm: "",
					confirm: false,
				},
				setTab: {
					confirm: false,
					input0: "",
					input1: "",
					input2: "",
					password: "",
				},
				getTab: {
					input0: "",
					result: "",
				},

				tabSwitch: 1,
			}
		},
		mounted() {
			this.init()
		},
		methods: {
			async init() {
				const accounts = await window.ethereum.request({ method: "eth_accounts" })
				const address = accounts[0] || null
				const checksumAddress = address && web3.utils.toChecksumAddress(address)
				this.checksumAddress = checksumAddress
				window.ethereum.on("accountsChanged", (accounts) => {
					const address = accounts[0] || null
					const checksumAddress = address && web3.utils.toChecksumAddress(address)
					this.checksumAddress = checksumAddress
				})
			},
			connectWallet() {
				window.ethereum.request({ method: "eth_requestAccounts" })
			},

			calculateMultiHash(str, n){
				var sha256Value = "";
				for (var i=0;i<n;i++){
					sha256Value = ethers.utils.sha256(ethers.utils.toUtf8Bytes(str))
					str = sha256Value
				}
				return sha256Value
			},

			calculateValidSeed(str1, str2){
				const DEEPING = 64;
				let h1 = this.calculateMultiHash(str1, 2);
				let h2 = this.calculateMultiHash(str2, 2);
				for(var i=0; i<DEEPING; i++){
					let pair1 = this.calculatePairsBaseOnSeed(h1);
					let pair2 = this.calculatePairsBaseOnSeed(h2);

					h1 = web3.eth.accounts.sign(h2,pair1.privKey).messageHash;
					h2 = web3.eth.accounts.sign(h1, pair2.privKey).messageHash;
				}
				return ethers.utils.sha256(ethers.utils.toUtf8Bytes(h1+h2))
			},

			calculateWalletAddressBaseOnSeed(seed){
				return ethers.utils.computeAddress(seed);
			},

			calculatePairsBaseOnSeed(seed){
				var secp256k1=require('secp256k1');
				var createKeccakHash=require('keccak');

				var privKey = Buffer.from(seed.slice(2),'hex');
				var pubKey=secp256k1.publicKeyCreate(privKey,false).slice(1);

				return {privKey:privKey.toString('hex'), pubKey: pubKey.toString('hex')};

			},

			calculateStringKeccak256(str){
				return ethers.utils.solidityKeccak256(['string'],[str]);
			},

			encryptMessage(message, password){
				return CryptoJS.AES.encrypt(message, password).toString();
			},

			decryptMessage(message, password){
				return CryptoJS.AES.decrypt(message,password).toString(CryptoJS.enc.Utf8)
			},

			compressMessage(plain){
				return zlib.deflateRawSync(plain).toString('base64')
			},

			decompressMessage(plain){
				//const zlib = require("zlib");
				return zlib.inflateRawSync(Buffer.from(plain,'base64')).toString()
			},

			beforeInitKeySpace() {
				if (!this.keySpaceTab.input0.trim() || !this.keySpaceTab.input1.trim()) {
					this.$message.error("请在将 Keyspace 与 Password 输入框填写完整")
					return
				} else {
					this.keySpaceTab.confirm = true
				}

				let seed = this.calculateValidSeed(this.keySpaceTab.input0, this.keySpaceTab.input1)
				let addr = this.calculateWalletAddressBaseOnSeed(seed)
				let pairs = this.calculatePairsBaseOnSeed(seed)

				let message = "\x19Ethereum Signed Message:\n"+addr.length+addr;

				let signature = web3.eth.accounts.sign(message,pairs.privKey);
				console.log('addr:', (addr))
				console.log("sign.v:", signature.v)
				console.log("sign.r:", signature.r)
				console.log("sign.s:", signature.s)
                console.log("hash:",signature.messageHash)

				let encryptText = this.encryptMessage("haliluya hello world what can fuck you please tell me may somebody","123456");
                console.log("enctypt:",encryptText,",length:",encryptText.length)
				console.log("end file:",this.decryptMessage(encryptText,"123456"))

			},
			async initKeySpace() {
				if (this.keySpaceTab.input1Confirm != this.keySpaceTab.input1) {
					this.$message({
						message: "密码确认不一致",
						type: "error",
					})
					return
				}
				const myAddress = (await web3.eth.getAccounts())[0]
				console.log("myAddress is", myAddress)
				const keySpaceContract = new web3.eth.Contract(
						require("../assets/abi.json"),
						CONTRACT_ADDRESS
				)
				return await keySpaceContract.methods
						.initKeySpace(this.keySpaceTab.input0, this.keySpaceTab.input1)
						.send({ from: myAddress })
			},
			beforeSavePrivateSecret() {
				if (
						!this.setTab.input0.trim() ||
						!this.setTab.input1.trim() ||
						!this.setTab.input2.trim()
				) {
					this.$message.error("请将输入框填写完整")
					return
				} else {
					this.setTab.confirm = true
				}
			},
			async savePrivateSecret() {
				this.passwordStore = this.setTab.password
				const myAddress = (await web3.eth.getAccounts())[0]
				const keySpaceContract = new web3.eth.Contract(
						require("../assets/abi.json"),
						CONTRACT_ADDRESS
				)
				return await keySpaceContract.methods
						.savePrivateSecret(
								this.setTab.input0,
								this.setTab.input1,
								this.setTab.input2
						)
						.send({ from: myAddress })
			},
			async queryPrivateSecret() {
				const myAddress = (await web3.eth.getAccounts())[0]
				const keySpaceContract = new web3.eth.Contract(
						require("../assets/abi.json"),
						CONTRACT_ADDRESS
				)
				this.getTab.result = await keySpaceContract.methods
						.queryPrivateSecret(this.getTab.input0)
						.send({ from: myAddress })
			},
		},
	}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
	.flex {
		display: flex;
	}
	.hello {
		width: 600px;
		margin: 0 auto;
		.connect {
			position: absolute;
			top: 30px;
			right: 50px;
		}
		.tab-container {
			width: 100%;
		}
		.el-radio-group {
			margin-bottom: 10px;
		}
		.el-input {
			margin-bottom: 10px;
		}
		.mini-input {
			width: 110px;
		}
	}
	h3 {
		margin: 40px 0 0;
	}
	ul {
		list-style-type: none;
		padding: 0;
	}
	li {
		display: inline-block;
		margin: 0 10px;
	}
	a {
		color: #42b983;
	}
</style>
