# BJTU Intelligent Traffic Intersection Control Experiment
 基于北京交通大学TPC-JK-II实验平台的智慧交通路口测速实验

## 一、功能简介
- 用开关表示车辆驶入和驶出的状态
- 用七段数码管实时显示测速时间
- 测速结束后用定时器的值间接求出车辆平均速度并在控制台显示速度。

## 二、开发环境与实验套件
-  开发环境：Masm for Windows集成实验环境 2012.5
-  实验平台：北京交通大学TPC-JK-II实验平台

## 三、实验目的
- 学会使用8254定时器

## 四、优化方向（课程时间限制，未实现）
- 添加4*4按键扫描
- LCD显示屏
- 对除法潜在的异常进行特殊处理，提高程序健壮性

## 五、注意点
```
使用存储器作为偏移地址进行寻址的时候，应该先将存储器的值转移到寄存器来进行操作。
例如:
MOV AL, [BX+TIME] 
是把TIME的存储器地址直接作为变量与BX相加

MOV AH, 00H  
MOV AL, TIME  
MOV SI, AX  
MOV AL, [BX+SI]
则是把TIME里存储的数据作为变量与BX相加
```

## 六、实验箱接线图
![image](https://github.com/user-attachments/assets/498a9b5e-d96b-4b54-81e1-49b49978bab9)




