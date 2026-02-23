// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MultiSigWallet
 * @dev 多签钱包合约，需要多个所有者确认后才能执行交易
 */
contract MultiSigWallet {
    // 事件
    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    event SubmitTransaction(
        address indexed owner,
        uint256 indexed txId,
        address indexed to,
        uint256 value,
        bytes data
    );
    event ConfirmTransaction(address indexed owner, uint256 indexed txId);
    event RevokeConfirmation(address indexed owner, uint256 indexed txId);
    event ExecuteTransaction(address indexed owner, uint256 indexed txId);
    
    // 交易结构
    struct Transaction {
        address to;           // 目标地址
        uint256 value;        // 发送的ETH数量
        bytes data;           // 调用数据
        bool executed;        // 是否已执行
        uint256 confirmCount; // 确认数量
    }
    
    // 所有者数组
    address[] public owners;
    // 所有者映射，用于快速检查
    mapping(address => bool) public isOwner;
    // 所需确认数量
    uint256 public required;
    
    // 所有交易
    Transaction[] public transactions;
    // 交易确认映射: txId => owner => confirmed
    mapping(uint256 => mapping(address => bool)) public confirmed;
    
    /**
     * @param _owners 所有者地址数组
     * @param _required 所需确认数量
     */
    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "需要至少一个所有者");
        require(
            _required > 0 && _required <= _owners.length,
            "所需确认数量必须在1和所有者数量之间"
        );
        
        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "所有者地址不能为零地址");
            require(!isOwner[owner], "所有者不能重复");
            
            isOwner[owner] = true;
            owners.push(owner);
        }
        
        required = _required;
    }
    
    /**
     * @dev 接收ETH
     */
    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }
    
    /**
     * @dev 修改器：只允许所有者调用
     */
    modifier onlyOwner() {
        require(isOwner[msg.sender], "不是所有者");
        _;
    }
    
    /**
     * @dev 修改器：检查交易是否存在
     */
    modifier txExists(uint256 _txId) {
        require(_txId < transactions.length, "交易不存在");
        _;
    }
    
    /**
     * @dev 修改器：检查交易未执行
     */
    modifier notExecuted(uint256 _txId) {
        require(!transactions[_txId].executed, "交易已执行");
        _;
    }
    
    /**
     * @dev 修改器：检查所有者未确认
     */
    modifier notConfirmed(uint256 _txId) {
        require(!confirmed[_txId][msg.sender], "交易已被确认");
        _;
    }
    
    /**
     * @dev 提交新交易
     * @param _to 目标地址
     * @param _value ETH数量
     * @param _data 调用数据
     * @return 交易ID
     */
    function submitTransaction(
        address _to,
        uint256 _value,
        bytes memory _data
    ) external onlyOwner returns (uint256) {
        uint256 txId = transactions.length;
        
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            confirmCount: 0
        }));
        
        emit SubmitTransaction(msg.sender, txId, _to, _value, _data);
        
        return txId;
    }
    
    /**
     * @dev 确认交易
     * @param _txId 交易ID
     */
    function confirmTransaction(uint256 _txId)
        external
        onlyOwner
        txExists(_txId)
        notExecuted(_txId)
        notConfirmed(_txId)
    {
        Transaction storage transaction = transactions[_txId];
        transaction.confirmCount += 1;
        confirmed[_txId][msg.sender] = true;
        
        emit ConfirmTransaction(msg.sender, _txId);
    }
    
    /**
     * @dev 取消确认
     * @param _txId 交易ID
     */
    function revokeConfirmation(uint256 _txId)
        external
        onlyOwner
        txExists(_txId)
        notExecuted(_txId)
    {
        require(confirmed[_txId][msg.sender], "交易未被确认");
        
        Transaction storage transaction = transactions[_txId];
        transaction.confirmCount -= 1;
        confirmed[_txId][msg.sender] = false;
        
        emit RevokeConfirmation(msg.sender, _txId);
    }
    
    /**
     * @dev 执行交易（达到所需确认数量后）
     * @param _txId 交易ID
     */
    function executeTransaction(uint256 _txId)
        external
        onlyOwner
        txExists(_txId)
        notExecuted(_txId)
    {
        Transaction storage transaction = transactions[_txId];
        
        require(
            transaction.confirmCount >= required,
            "确认数量不足"
        );
        
        transaction.executed = true;
        
        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "交易执行失败");
        
        emit ExecuteTransaction(msg.sender, _txId);
    }
    
    /**
     * @dev 获取所有者数量
     */
    function getOwnersCount() external view returns (uint256) {
        return owners.length;
    }
    
    /**
     * @dev 获取交易数量
     */
    function getTransactionsCount() external view returns (uint256) {
        return transactions.length;
    }
    
    /**
     * @dev 获取合约余额
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @dev 批量获取交易确认状态
     * @param _txId 交易ID
     * @return 所有所有者的确认状态
     */
    function getConfirmations(uint256 _txId)
        external
        view
        returns (address[] memory)
    {
        address[] memory confirmations = new address[](owners.length);
        uint256 count = 0;
        
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmed[_txId][owners[i]]) {
                confirmations[count] = owners[i];
                count++;
            }
        }
        
        // 调整数组大小
        assembly {
            mstore(confirmations, count)
        }
        
        return confirmations;
    }
    
    /**
     * @dev 获取交易详情
     */
    function getTransaction(uint256 _txId)
        external
        view
        returns (
            address to,
            uint256 value,
            bytes memory data,
            bool executed,
            uint256 confirmCount
        )
    {
        Transaction storage transaction = transactions[_txId];
        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.confirmCount
        );
    }
    
    /**
     * @dev 检查所有者是否已确认交易
     */
    function isConfirmed(uint256 _txId, address _owner)
        external
        view
        returns (bool)
    {
        return confirmed[_txId][_owner];
    }
}