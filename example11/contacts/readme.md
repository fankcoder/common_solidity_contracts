## 完整工作流程
```
javascript
// 1. 向多签钱包存款
await ethers.provider.getSigner().sendTransaction({
    to: multiSig.address,
    value: ethers.utils.parseEther("10.0")
});

// 2. 查询余额
const balance = await multiSig.getBalance();
console.log("余额:", ethers.utils.formatEther(balance), "ETH");

// 3. 所有者1提交交易（转账5 ETH给接收地址）
const recipient = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199";
const txId = await multiSig.connect(owner1).submitTransaction(
    recipient,
    ethers.utils.parseEther("5.0"),
    "0x"
);
console.log("交易ID:", txId.toString());

// 4. 所有者1确认交易
await multiSig.connect(owner1).confirmTransaction(txId);

// 5. 查看确认状态
const confirmations = await multiSig.getConfirmations(txId);
console.log("已确认:", confirmations);

// 6. 所有者2确认交易（达到required=2）
await multiSig.connect(owner2).confirmTransaction(txId);

// 7. 执行交易
await multiSig.connect(owner1).executeTransaction(txId);

// 8. 验证交易状态
const tx = await multiSig.getTransaction(txId);
console.log("交易已执行:", tx.executed);
```