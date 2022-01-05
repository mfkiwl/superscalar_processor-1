#### 2021.12.9

---

1. 正在开发局部历史预测器
2. 完成PHT_update.v功能，用于更新状态机
3. 正在开发全局历史预测器



**问题**：

~~*branch_global.v*中的PHT需要添加更新功能~~ 
~~*branch_global.v*中的hash可能有问题~~ 
- [x] *branch_history.v*中的BHT和PHT需要添加更新功能
- [ ] *branch_history.v*中的hash可能有问题



**目标任务**：

- [x] 完成竞争的分支预测器，在局部历史预测器和全局历史预测器外增加CPHT



#### 2021.12.10

---

1. 继续开发两个分支预测器
2. 为*branch_history.v*中的BHT增加更新功能
3. 将PHT_FSM加入两个模块中，仍然缺失更新PHT功能，可能需要结合流水线提交阶段的设计
4. ~~完成全局历史分支预测器的GHR更新功能~~



#### 2021.12.11

---

1. 全局历史分支预测器和局部历史分支预测器除更新功能外基本完成
2. 竞争分支预测器除更新功能外基本完成
3. 完成两个分支预测器的更新功能，都在指令退休时进行更新



**问题**：

~~CPHT更新需要流水线执行阶段结果，可能需要对两个分支预测器的结果进行保存以便和流水线中的结果进行对比~~

- [x] 局部历史分支预测器的BHT更新有问题，需要修正



**目标任务**：

~~添加GHR的修复功能~~
- [ ] 添加BHT的修复功能



#### 2021.12.13

---

1. 移除全局历史分支预测器和竞争分支预测器，仅保留局部历史分支预测器
2. 合并*PHT_FSM.v*和*branch_history.v*
3. 正在开发BTB，完成基本架构，需要添加BTB缺失处理以及替换算法



**问题**：

- [x] 可能需要对*branch.v*修改，删除预解码功能



**目标任务**：

- [x] 添加BTB缺失处理以及替换算法
- [x] 添加间接跳转分支预测功能相关结构



#### 2021.12.14

---

1. 完成分支预测器的大部分功能
2. 完成间接跳转分支预测
3. 将已完成的分支预测相关模块进行组装



**问题**：

- [ ] 需要添加BTA的修复功能
- [ ] 需要添加Target_cache的修复功能



### 2021.12.15

---

1. 开始开发cache
2. 完成I-cache的状态机设计


**问题**：

- [ ] 由于分支预测修复功能需要结合后续流水线阶段，暂时停止开发，等待后续开发完成后继续开发
- [ ] 需要针对一个周期内对多条指令进行分支预测的需求对分支预测器进行调整
- [x] 由于超标量处理器取值可能出现多条指令不在同一cache line问题，仍需要找到解决办法



### 2021.12.16

---

1. 解决cache_line问题，解决方法为对cache line的容量进行扩容
2. 完成I-cache命中时的读数据问题


**目标任务**：

- [x] 增加cache写策略，并完成写cache过程



### 2021.12.17

---

1. 正在开发LRU cache替换算法
2. 完成I-Cache开发

**问题**：

- [x] 需要对TagV_Table增加一位年龄位

**目标任务**：

- [x] 完成LRU替换算法



### 2021.12.18

---

1. 更新分支预测器
2. 完成I-Cache开发

**问题**：

- [x] 分支预测器的BHR更新问题，可能无法对紧接着的几条分支预测指令结果产生作用
- [x] 需要对写入PHT和BHT的PC进行预解码
- [x] 需要考虑BTB缺失的结果



### 2021.12.19

---

1. 继续修改分支预测器

**目标任务**：

- [ ] ~修改分支预测器内部元件的组成方式，用交叠的方式重构元件~



### 2021.12.20

---

1. ~完成`branch_history.v`的交叠重构~
2. ~完成`Branch_Target_Buffer.v`的交叠重构~
3. ~完成`Target_Cache.v`的交叠重构~

**问题**：

- [ ] ~RAS需要对多条pc同时访问进行处理~



### 2022.1.4

---


**问题**：

- [ ] 为取指阶段添加端口`input full`表示指令缓存已满，停止取指