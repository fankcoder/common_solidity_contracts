## 第一步：准备 Subscription（订阅机制）

创建一个 Subscription ID
在官方的 Subscription Manager UI（https://vrf.chain.link）上通过你的钱包创建一个订阅。

这个 Subscription 会绑定你的 LINK 余额，用来支付未来所有随机数请求。

给这个 Subscription 充值 LINK 或者支持支付原生币（如 ETH）
在 Subscription Manager 界面选择 Fund subscription，充值足够的 LINK（或在 v2.5 中也可充值原生币）。

将合约地址添加为该 Subscription 的可以调用者（Consumer）
只有被授权的合约才能使用这个 Subscription 去请求随机数。

注意：订阅机制提高了重复请求的经济性，因为不需要每次单独支付，而是从预充值中扣费。

## 第二步：合约继承与初始化

在的 Solidity 合约中，需要继承官方提供的 VRF 基类，并配置 VRFCoordinator、Subscription ID 和参数：

关键继承
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

（VRFConsumerBaseV2Plus 是 v2.5 新版本基类；官方文档推荐使用它）

构造函数配置
constructor(
    address vrfCoordinator,
    uint64 subscriptionId,
    bytes32 keyHash
) VRFConsumerBaseV2Plus(vrfCoordinator) {
    s_vrfCoordinator = VRFCoordinatorV2PlusInterface(vrfCoordinator);
    s_subscriptionId = subscriptionId;
    s_keyHash = keyHash;
}

其中：

vrfCoordinator：随机数协调者合约地址（不同链不同地址）

subscriptionId：在 Subscription Manager 上创建的 ID

keyHash：指定 gas lane 和 oracle job（影响价格和速度）

## 第三步：发起随机数请求
调用请求随机数

当前主流程中的函数是：

uint256 requestId = s_vrfCoordinator.requestRandomWords(
    VRFV2PlusClient.RandomWordsRequest({
        keyHash: s_keyHash,
        subId: s_subscriptionId,
        requestConfirmations: 3,        // 建议至少 3 个区块确认
        callbackGasLimit: 200000,        // 回调 gas 限额
        numWords: 1,
        extraArgs: VRFV2PlusClient._argsToBytes(
            VRFV2PlusClient.ExtraArgsV1({ nativePayment: false })
        )
    })
);

核心参数说明：

```
参数	含义
keyHash	指定使用哪个 oracle gas lane 进行请求
subId	订阅 ID
requestConfirmations	oracle 等待多少个区块确认随机数安全性
callbackGasLimit	回调函数最多消耗的 gas
numWords	请求多少个随机数（通常 1 就够）
extraArgs	支持原生支付或其他新参数（v2.5 特有）

返回值 requestId 是本次请求的唯一 ID，用于和回调中的随机数做关联。
```

## 第四步：回调处理随机数（最关键）

在你的合约中，必须实现回调函数：

function fulfillRandomWords(
    uint256 requestId,
    uint256[] memory randomWords
) internal override {
    // 处理随机数：比如存到变量
    s_randomResult = randomWords[0];
    // 你自己的逻辑，比如确定抽奖结果等
}

这个函数由 VRFCoordinator 合约调用（Chainlink 节点先生成随机数然后由 Coordinator 调用）

实际生成的 randomized words 数组长度由你在 requestRandomWords 时的 numWords 决定

不同支付方式：

LINK 支付（传统方式）：把 LINK 充值到 Subscription

原生支付（v2.5 支持）：可选择用 native token（如 ETH）支付费用（需设置 nativePayment: true）