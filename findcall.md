# 移除植物
直接使用data call_delete_plant

# 放置植物
## x32dbg附加pvz
tab内存布局，双击地址=00401000 text 可执行代码 一行，能直接跳转到代码段，方便查找
## 断点
从pvztoolkit代码data.cpp读取 call_put_plant，以下均以1051为例，地址为0x0040d120
放置植物后断点触发

![alt text](img/call/break.png)

重复两次“运行到返回、步过”，EIP上一行为所需地址

![alt text](img/call/call_plant.png)

# 选择卡片与释放
## CheatEngine附加
手拿玉米投手不要放下，扫描34，然后手拿玉米加农炮，扫描47，可以直接得到唯一地址
右键地址，选择找出什么写入这个地址
点击手拿植物，右键点击释放植物，分别得到两个地址，记录下

![alt text](img/call/card_release_addr.png)

## x32dbg附加
断点上图488DE5，点击卡片触发
重复一次“运行到返回、步过”，EIP上一行为选择卡片地址

![alt text](img/call/call_card.png)

断点上上图41239A，释放卡片触发
重复两次“运行到返回、步过”，EIP上一行为释放卡片地址

![alt text](img/call/call_release.png)

# 发炮
## CheatEngine附加
种植玉米加农炮，炮填充状态为37，空状态（非发炮或填充过程中）为35，扫描若干次
定位地址后，找出什么写入这个地址，然后发炮

![alt text](img/call/cob_state_addr.png)
有多个地址，注意找发炮瞬间的，此处为466D6B

## x32dbg附加
断点466D6B，发炮时触发
重复一次“运行到返回、步过”，EIP上一行为发炮地址

![alt text](img/call/call_fire.png)