# IIdentity


IdenetityManager is used to verify the account.

> 管理所有成员的元数据.
     每个地址都可以针对每个用户设置kv数据, "每个地址"代表作用域, 可以由外 部合约指定要读取哪个作用域下的用户设置.
     核心用于用户kyc时, 不同机构可以对同一个用户指定不同值, 由外部决定采 用哪个机构的数据.

## 1.Contents
<!-- START doctoc -->
<!-- END doctoc -->

## 2.Globals

## 3.Modifiers

## 4.Functions

### batchSetUserKVs



*Declaration:*
```solidity
function batchSetUserKVs(
) external
```




### getUserKV



*Declaration:*
```solidity
function getUserKV(
) external returns
(bytes32 typeID, bytes data)
```




## 5.Events
