#### 2021.12.9

---

1. 正在开发局部历史预测器
2. 完成PHT_update.v功能，用于更新状态机
3. 正在开发全局历史预测器



**bug**：

- [ ] *branch_history.v*中的BHT和PHT需要添加更新功能
- [ ] *branch_history.v*中的hash可能有问题
- [ ] *branch_global.v*中的PHT需要添加更新功能
- [ ] *branch_global.v*中的hash可能有问题



**目标任务**：

- [ ] 完成竞争的分支预测器，在局部历史预测器和全局历史预测器外增加CPHT



#### 2021.12.10

---

1. 继续开发两个分支预测器
2. 为*branch_history.v*中的BHT增加更新功能
3. 将PHT_FSM加入两个模块中，仍然缺失更新PHT功能，可能需要结合流水线提交阶段的设计
