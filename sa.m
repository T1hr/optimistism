clear
close all
clc
m=40;
n=10;
temp = load('F:\matlab xiazai\optimization\example_11.mat').example_11;
%{5,7,9;9,9,7;5,9,5};%如果需要切换用例，只需更改temp
%模拟退火算法
%temp = cell2mat(temp);
index=1:m;
T=10000;%温度的初始值
r=0.98;%控制T下降的快慢
i=1;
while T>0.0001
    p1=floor(1+m*rand);
    p2=floor(1+m*rand);
    while(p1==p2)%直到p1!=p2,随机抽取工件p1,p2交换位置
        p1=floor(1+m*rand);
        p2=floor(1+m*rand);
    end
    
    y1=calculator(temp,m,n);
    [temp,index]=change(temp,index,p1,p2,n);
    y2=calculator(temp,m,n);
    dE=y2-y1;
    if dE<0%如果发现交换后所用时间更短，交换位置
        Y(i,1)=y1;
        Y(i,2)=y2;
        i=i+1;
    else%如果时间没有变短，有exp(-dE/T)的概率交换位置
        if exp(-dE/T)<rand
            [temp,index]=change(temp,index,p1,p2,n);
        else
            Y(i,1)=y1;
            Y(i,2)=y2;
            i=i+1;
        end
    end
    
    T=T*r;
end

%画图
x=1:i-1;
plot(x,Y(x,1));


function [temp,index]=change(temp,index,x1,x2,n)%交换函数交换两个工件的顺序
    for i=1:n
        x=temp(x1,i);
        temp(x1,i)=temp(x2,i);
        temp(x2,i)=x;
    end
    t=index(x1);
    index(x1)=index(x2);
    index(x2)=t;
end

function result=calculator(temp,m,n)%计算总时间
    pretime=[];%上一个工件在机器X中完成的时间（保证机器空闲）
    pretime(1)=temp(1,1);
    curtime=[];
    curtime(1)=temp(1,1);%当前工件在机器X-1中完成的时间（保证工件空闲）
    %用i表示第几个工件，j表示第几个机器
    %对pretime初始化，第一个机器加工所有零件所需时间
    for i=2:m
        curtime(i)=curtime(i-1)+temp(i,1);
    end
    for j=2:n
        pretime(j)=pretime(j-1)+temp(1,j);
    end
    %开始循环
    for j=2:n
        for i=2:m
            if pretime(j)<curtime(i)
                pretime(j)=curtime(i)+temp(i,j);
                curtime(i)=pretime(j);
            else 
                pretime(j)=pretime(j)+temp(i,j);
                curtime(i)=pretime(j);
            end
        end
    end
    result=pretime(n);
end


    
    