### 2021.12.9

---

1. 正在开发局部历史预测器
2. 完成PHT_update.v功能，用于更新状态机
3. 正在开发全局历史预测器



**问题**：

~~*branch_global.v*中的PHT需要添加更新功能~~
~~*branch_global.v*中的hash可能有问题~~
- [x] *branch_history.v*中的BHT和PHT需要添加更新功能
- [x] *branch_history.v*中的hash可能有问题



**目标任务**：

- [x] 完成竞争的分支预测器，在局部历史预测器和全局历史预测器外增加CPHT



### 2021.12.10

---

1. 继续开发两个分支预测器
2. 为*branch_history.v*中的BHT增加更新功能
3. 将PHT_FSM加入两个模块中，仍然缺失更新PHT功能，可能需要结合流水线提交阶段的设计
4. ~~完成全局历史分支预测器的GHR更新功能~~



### 2021.12.11

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



### 2021.12.13

---

1. 移除全局历史分支预测器和竞争分支预测器，仅保留局部历史分支预测器
2. 合并*PHT_FSM.v*和*branch_history.v*
3. 正在开发BTB，完成基本架构，需要添加BTB缺失处理以及替换算法



**问题**：

- [x] 可能需要对*branch.v*修改，删除预解码功能



**目标任务**：

- [x] 添加BTB缺失处理以及替换算法
- [x] 添加间接跳转分支预测功能相关结构



### 2021.12.14

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
- [x] 需要针对一个周期内对多条指令进行分支预测的需求对分支预测器进行调整
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



### 2022.1.5

---

1. 完成译码阶段，提供四条指令同时译码


**问题**:
- [x] 需要修改译码器，确定寄存器重命名阶段所需的寄存器



### 2022.1.9

---

1. 完成四端口的FIFO



### 2022.1.10

---

1. 修改译码器完成，为rs、rt、rd增加确定使能，当rd_en为1时，目的寄存器为rd，反之则为rt



### 2022.1.11

---

1. 正在开发寄存器重命名阶段
2. 正在编写SRAM RAT


**目标任务**

- [x] 完成sRAT，输出重命名映射结果


**问题**

- [ ] ~~目前仅使用一个checkout point，需要修改RAT结构，使其能够增加多个checkout point~~



### 2022.1.12

---

1. 继续开发寄存器重命名阶段
2. 寄存器重命名阶段的恢复使用Architecture State进行恢复，需要在提交阶段添加一个aRAT
3. 开发free list

**问题**

- [ ] freeList需要在提交阶段进行更新，因此部分端口暂时未连接



### 2022.1.21

---

1. 开始开发发射阶段
2. 对于发射队列IQ，采用压缩结构

**问题**

- [x] 需要根据输入和输出使能信号对8个MUX的选择信号进行赋值



### 2022.1.22

---

1. 继续开发发射阶段
2. ~~完成压缩结构的发射队列~~



### 2022.1.23

---

1. 继续开发发射队列
2. 为发射队列添加输出数据功能
2. 发现发射队列存在一定的问题

**问题**

- [x] 发射队列缺失写入功能
- [ ] 寄存器重命名需要接收发射队列`full`信号，确定是否停止重命名



### 2022.1.24

---

1. 继续开发发射队列
2. 完成发射队列写入数据功能和输出数据功能~~仍然需要进行测试~~



### 2022.1.25

---

1. 发现发射队列存在bug，~~*count寄存器只增不减*~~
2. 修复今日发现的bug
3. 将模块`issue_queue`更名为`issue_queue_two`
4. 增加模块`issue_queue_one`，功能为压缩一个表项的发射队列



### 2022.1.27

---

1. 继续开发发射队列
2. 将模块`issue_queue_two`更名为`issue_queue_ALU`
3. 修改模块`issue_queue_ALU`中的发射队列的宽度为, 5 bits SrcL, 1 bit ValL, 1 bit RdyL, 5 bits SrcR, 1 bit ValR, 1 bit RdyR, 5 bits Dest, 1 bit SrcR_imm_valid, 1 bit Issued，共21 bits

**问题**

- [ ] 需要对译码模块进行修改，根据发射队列修改单周期延迟指令的输出信号



### 2022.2.10

---

1. 继续开发发射队列
2. 复制模块`issue_queue_one`并更名为`issue_queue_MUL_DIV`用于乘法和除法FU
3. `issue_queue_MUL_DIV`发射队列宽度为, 1 bit Issued, 5 bits SrcL, 1 bit SrcL_M, 34 bits SrcL_SHIFT, 5 bits SrcR, 1 bit SrcR_M, 34 bits SrcR_SHIFT, 1 bit SrcR_imm_valid, 5 bits Dest, 34 bits delay，共121 bits



### 2022.2.11

---

1. 继续开发发射队列
2. `issue_queue_Load_Store`发射队列宽度为, 5 bits SrcL, 1 bit ValL, 1 bit RdyL, 5 bits SrcR, 1 bit ValR, 1 bit RdyR, 5 bits Dest, 1 bit SrcR_imm_valid, 1 bit Issued，共21 bits



### 2022.2.12

---

1. 继续开发发射队列
2. 完成1 to M仲裁及2 to M仲裁并经过测试



### 2022.2.14

---

1. 将仲裁模块从`issue.v`中分离，新增`select.v`，内容为仲裁及唤醒

**目标任务**

- [ ] 完成`select.v`中的唤醒功能


### 2022.2.15

---

1. 继续开发`select.v`

**问题**

- [x] 仲裁电路中需要调整选择条件，当源寄存器就绪时，需考虑该项是否issued



### 2022.2.16

---

1. 继续开发`select.v`及`issue.v`
2. 当仲裁电路选择出单周期唤醒的指令时，根据目的寄存器和输入的发射队列的源寄存器，修改发射队列中的rdy



### 2022.2.23

---

1. 继续开发`select.v`及`issue.v`
2. `issue.v`接受`decode.v`中发送的指令标记以及`register_rename.v`中发送的重命名后的寄存器编号，并且根据接受的结果发送到相应的发射队列中

**问题**

- [ ] 译码阶段需要根据发送到的发射队列对指令进行标记，当从流水线寄存器输出至issue时，issue根据指令中的标记将指令发送到相应的发射队列中
- [ ] 需要对发射队列的宽度进行更新，用于存储更加具体的指令信息，如立即数和指令操作等



### 2022.2.24

---

1. 继续开发`issue.v`
2. 对发射队列宽度进行修改
    1. 修改`issue_queue_ALU`发射队列的宽度为, 2 bits types, 9 bits operations, 26 bits imm, 5 bits SrcL, 1 bit ValL, 1 bit RdyL, 5 bits SrcR, 1 bit ValR, 1 bit RdyR, 5 bits Dest, 1 bit SrcR_imm_valid, 1 bit Issued，共58 bits
    2. 修改`issue_queue_Load_Store`发射队列宽度为, 5 bits operations, 16 bits imm, 5 bits SrcL, 1 bit ValL, 1 bit RdyL, 5 bits SrcR, 1 bit ValR, 1 bit RdyR, 5 bits Dest, 1 bit SrcR_imm_valid, 1 bit Issued，共42 bits
    3. 修改`issue_queue_MUL_DIV`发射队列宽度为, 4 bits operations, 1 bit Issued, 5 bits SrcL, 1 bit SrcL_M, 34 bits SrcL_SHIFT, 5 bits SrcR, 1 bit SrcR_M, 34 bits SrcR_SHIFT, 5 bits Dest, 34 bits delay，共124 bits
3. 调整`register_rename.v`，修改语义不明的信号

**问题**

- [ ] 寄存器重命名中需要根据freelist是否有足够的空余寄存器和是否有足够的指令来决定写入数量

**目标**

- [ ] 修改译码阶段的信号