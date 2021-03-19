<template>
	<div class="hello">
		<el-button class="connect" @click="connectWallet" v-show="!checksumAddress"
			>连接钱包</el-button
		>
		<el-button disabled v-show="checksumAddress">钱包已连接</el-button>

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
import Web3 from "web3"
let web3 = new Web3(window.ethereum)
// todo 此处填写合约地址
const CONTRACT_ADDRESS = "0x3694FD2B16820016A4FB722ce1523FF742cC1016"
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
		beforeInitKeySpace() {
			if (!this.keySpaceTab.input0.trim() || !this.keySpaceTab.input1.trim()) {
				this.$message.error("请在将 Keyspace 与 Password 输入框填写完整")
				return
			} else {
				this.keySpaceTab.confirm = true
			}
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
			const assetContract = new web3.eth.Contract(
				require("../assets/abi.json"),
				CONTRACT_ADDRESS
			)
			return await assetContract.methods
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
			const assetContract = new web3.eth.Contract(
				require("../assets/abi.json"),
				CONTRACT_ADDRESS
			)
			return await assetContract.methods
				.savePrivateSecret(
					this.setTab.input0,
					this.setTab.input1,
					this.setTab.input2
				)
				.send({ from: myAddress })
		},
		async queryPrivateSecret() {
			const myAddress = (await web3.eth.getAccounts())[0]
			const assetContract = new web3.eth.Contract(
				require("../assets/abi.json"),
				CONTRACT_ADDRESS
			)
			this.getTab.result = await assetContract.methods
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
