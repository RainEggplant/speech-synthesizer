# MATLAB 语音合成实验

> 无 76	RainEggplant	2017\*\*\*\*\*\*



## 1. 语音预测模型

### (1) 滤波器

> 给定
> $$
> e(n) = s(n) - a_1 s(n-1) - a_2 s(n-2)
> $$
> 假设 $$e(n)$$ 是输入信号， $$s(n)$$ 是输出信号， 上述滤波器的传递函数是什么？
>
> 如果 $$a_1 = 1.3789$$， $$a_2 = -0.9506$$，上述合成模型的共振峰频率是多少？
>
> 用 `zplane` ，`freqz` ，`impz` 分别绘出零极点图， 频率响应和单位样值响应。 用 `filter` 绘出单位样值响应， 比较和 `impz` 的是否相同。 



对差分方程做 z 变换，得
$$
E(z) = S(z) - a_1 z^{-1} S(z) - a_2 z^{-2} S(z)
$$
因此传递函数为
$$
H(z) = \frac {S(z)}{E(z)} = \frac {1}{1 - a_1 z^{-1} - a_2 z^{-2}}
$$


在 $$a_1 = 1.3789$$， $$a_2 = -0.9506$$ 的条件下，编写 MATLAB 代码 （`plot_filter.m`） ：

```matlab
% Define filter parameters
b = 1;
a = [1, -1.3789, 0.9506];

% Plot zeros and polars
figure;
zplane(b, a);

% Plot frequency response
figure;
freqz(b, a);
% Find maximum and mark it
h_line = findobj(gca, 'Type', 'line');
h = get(h_line, 'Ydata');
[h_max, idx] = max(h(1:length(h)-1));
w = get(h_line,'Xdata');
w_max = w(idx);
text(w_max-0.05, h_max + 4, ...
    ['(', num2str(w_max), ',', num2str(h_max), ')']);

% Use `impz` to draw impulse response
figure;
subplot(2, 1, 1);
impz(b, a, 100);
title('Impulse Response (using `impz`)');

% Use `filter` to draw impulse response
x = zeros(1,100);
x(1) = 1;
y = filter(b, a, x);
subplot(2, 1, 2);
stem([1:100], y);
title('Impulse Response (using `filter`)');
xlabel('n (samples)');
ylabel('Amplitude');
```



得到以下结果：

**零、极点分布图**

可以看到，原点处有一二阶零点。单位圆内靠近单位圆处上有一对一阶共轭极点。

![](report.assets/1-zplane.png)



**频率响应**

从这张图上，我们能够知道上述合成模型的共振峰频率为 $$0.25 \times \pi$$ rad/sample。

![](report.assets/1-freq_res.png)



**单位样值响应**

可以看到两种方式求得的单位样值响应是一致的。

![](report.assets/1-impulse_res.png)



### (2) 阅读 `speechproc.m` 并理解基本流程

