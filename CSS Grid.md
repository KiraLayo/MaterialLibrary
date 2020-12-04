# 基础概念

- 行和列
- 单元格
- 网格线

	- 从1开始

## 属性

```
display: grid;
display: inline-grid; // 行内
```

> 注意，设为网格布局以后，容器子元素（项目）的`float`、`display: inline-block`、`display: table-cell`、`vertical-align`和`column-*`等设置都将失效。

## grid-template

### grid-template-columns & grid-template-rows

```
// 三行三列的网格，列宽和行高都是100px

display: grid;
grid-template-columns: 100px 100px 100px;
grid-template-rows: 100px 100px 100px;

display: grid;
grid-template-columns: 33.33% 33.33% 33.33%;
grid-template-rows: 33.33% 33.33% 33.33%;
```

### repeat()

第一个参数是重复的次数，第二个参数是所要重复的值。

```
grid-template-columns: repeat(2, 100px 20px 80px);
grid-template-columns: repeat(3, 33.33%);	
```

### auto-fill

```
display: grid;
grid-template-columns: repeat(auto-fill, 100px);
```

容纳尽可能多的单元格

### fr

表示比例关系

```
display: grid;
grid-template-columns: 1fr 1fr;
```

`fr`可以与绝对长度的单位结合使用

```
display: grid;
grid-template-columns: 150px 1fr 2fr;
```

### minmax()

表示长度就在这个范围之中。它接受两个参数，分别为最小值和最大值。

```
grid-template-columns: 1fr 1fr minmax(100px, 1fr);
```

### auto

`auto`关键字表示由浏览器自己决定长度。根据单元格内容决定

### 网格线的名称

```
.container {
  display: grid;
  grid-template-columns: [c1] 100px [c2] 100px [c3] auto [c4];
  grid-template-rows: [r1] 100px [r2] 100px [r3] auto [r4];
}

// 允许同一根线有多个名字，比如[fifth-line row-5]
```

