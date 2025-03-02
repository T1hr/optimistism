clc;clear
close all
pop=100;%定义种群大小
generation=100;%循环次数
mrate=0.5;%突变概率

%输入
m=40;%工件的数量
n=10;%机器的数量
temp = load('F:\matlab xiazai\optimization\example_11.mat').example_11;
%temp = cell2mat(temp);
%初始化
population=zeros(pop,m);
for i=1:pop
    population(i,:)=randperm(m);
end
sign=1;
F=[];%记录每次迭代最小的适应度
resume=[];%记录每次迭代的工件排列顺序
for k= 1:generation
    %计算适应度
    fitness=zeros(pop,1);
    for i=1:pop
    %交换temp中的顺序
        for j=1:m
            copy(j,:)=temp(population(i,j),:);%按照population中的随机序列改变temp中的工件顺序
        end
        fitness(i)=calculator(copy,m,n);
    
    end
    [select_parents,index,F,sign,resume]=selection(F,fitness,pop,sign,population,resume);%基因选择
    cross_parents=cross(population,select_parents,m);%基因交叉
    Child1=cell2mat(cross_parents(1,1));
    Child2=cell2mat(cross_parents(1,2));
    mutate1=mutation(Child1,mrate,m);%基因突变
    mutate2=mutation(Child2,mrate,m);
    population(index(1),:)=mutate1;
    population(index(2),:)=mutate2;
end
%画图
k=1:sign-1;
plot(k,F);



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

function [select,index,F,sign,resume]=selection(F,fitness,pop,sign,population,resume)
    % 对向量进行排序并获取排序后的索引值
    [sorted_fitness, sorted_indices] = sort(fitness);
    F(sign)=sorted_fitness(1);
    F(sign+1)=sorted_fitness(2);
    select=sorted_indices(1:2);
    index=sorted_indices(pop-1:pop);
    resume(sign,:)=population(sorted_indices(1),:);
    resume(sign+1,:)=population(sorted_indices(2),:);
    sign=sign+2;
end

function crossed=cross(population,select_parents,m)
    integer1=randi([1, m]);%随机生成0-m整数
    integer2=randi([1,m]);
    while integer1>=integer2
        integer1=randi([1, m]);
        integer2=randi([1,m]);
    end

    x1=population(select_parents(1),:);
    x2=population(select_parents(2),:);
    %对copy1进行拼接
    copy1=x1;copy2=x2;
    i=fun(integer2+1,m);%copy1片段的索引
    for j=integer2+1:m
        t=1;
        for k=integer1:integer2
            if copy2(j)==copy1(k)
                t=0;
                break;
            end
        end
        if t==1
            copy1(i)=copy2(j);
            i=fun(i+1,m);
        end
    end
    for j=1:integer2
        t=1;
        for k=integer1:integer2
            if copy2(j)==copy1(k)
                t=0;
                break;
            end
        end
        if t==1
            copy1(i)=copy2(j);
            i=fun(i+1,m);
        end
        if i==integer1
            break;
        end
    end

    output1=copy1;
    
    %对copy2进行拼接
    copy1=x2;copy2=x1;
    i=fun(integer2+1,m);%copy1片段的索引
    for j=integer2+1:m
        t=1;
        for k=integer1:integer2
            if copy2(j)==copy1(k)
                t=0;
                break;
            end
        end
        if t==1
            copy1(i)=copy2(j);
            i=fun(i+1,m);
        end
    end
    for j=1:integer2
        t=1;
        for k=integer1:integer2
            if copy2(j)==copy1(k)
                t=0;
                break;
            end
        end
        if t==1
            copy1(i)=copy2(j);
            i=fun(i+1,m);
        end
        if i==integer1
            break;
        end
    end

    output2=copy1;
    crossed={output1,output2};

end

%保证i不会大于工件数m
function n=fun(i,m)
    if i>m
        n=i-m;
    else
        n=i;
    end
end

function mu=mutation(parents,mrate,m)
    p1=floor(1+m*rand);
    p2=floor(1+m*rand);
    while p1==p2
        p1=floor(1+m*rand);
        p2=floor(1+m*rand);
    end
    if rand<mrate
        t=parents(p1);
        parents(p1)=parents(p2);
        parents(p2)=t;
    end
    mu=parents;
    
end
