---
author: "Payakorn Saksuriya"
title: "Report"
---


# Vehicle Routing Problem with Time Windows

---
Import package:


```julia
using VehicleRoutingProblems
using PrettyTables
using DataFrames
using CSV
```





---


## Solomon's Instances Results


Result of 25 customers compare with optimum


```julia
df = CSV.File("../data/opt_solomon/all_25.csv") |> DataFrame
hl_v = HTMLHighlighter( (df,i,j)->(j in (1, 6)) && df[i,4] >= df[i, 6], HTMLDecoration(color = "red", font_weight = "bold"));
pretty_table(df, show_row_number=true, tf=tf_html_matrix, highlighters = (hl_v, ))
```


<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
  table {
      position: relative;
  }

  table::before,
  table::after {
      border: 1px solid #000;
      content: "";
      height: 100%;
      position: absolute;
      top: 0;
      width: 6px;
  }

  table::before {
      border-right: 0px;
      left: -6px;
  }

  table::after {
      border-left: 0px;
      right: -6px;
  }

  td {
      padding: 5px;
      text-align: center;
  }

</style>
<body>
<table>
  <thead>
    <tr class = "header">
      <th class = "rowNumber">Row</th>
      <th style = "text-align: right;">Problem</th>
      <th style = "text-align: right;">Num_customer</th>
      <th style = "text-align: right;">NV</th>
      <th style = "text-align: right;">Opt</th>
      <th style = "text-align: right;">Our_NV</th>
      <th style = "text-align: right;">Our_floor</th>
      <th style = "text-align: right;">Our</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th></th>
      <th style = "text-align: right;">String7</th>
      <th style = "text-align: right;">Int64</th>
      <th style = "text-align: right;">Float64</th>
      <th style = "text-align: right;">Float64</th>
      <th style = "text-align: right;">Int64</th>
      <th style = "text-align: right;">Float64</th>
      <th style = "text-align: right;">Float64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class = "rowNumber">1</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C101</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">191.3</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">191.3</td>
      <td style = "text-align: right;">191.8</td>
    </tr>
    <tr>
      <td class = "rowNumber">2</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C102</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">190.3</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">190.3</td>
      <td style = "text-align: right;">190.7</td>
    </tr>
    <tr>
      <td class = "rowNumber">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C103</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">190.3</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">190.3</td>
      <td style = "text-align: right;">190.7</td>
    </tr>
    <tr>
      <td class = "rowNumber">4</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C104</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">186.9</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">186.9</td>
      <td style = "text-align: right;">187.4</td>
    </tr>
    <tr>
      <td class = "rowNumber">5</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C105</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">191.3</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">191.3</td>
      <td style = "text-align: right;">191.8</td>
    </tr>
    <tr>
      <td class = "rowNumber">6</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C106</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">191.3</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">191.3</td>
      <td style = "text-align: right;">191.8</td>
    </tr>
    <tr>
      <td class = "rowNumber">7</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C107</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">191.3</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">191.3</td>
      <td style = "text-align: right;">191.8</td>
    </tr>
    <tr>
      <td class = "rowNumber">8</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C108</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">191.3</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">191.3</td>
      <td style = "text-align: right;">191.8</td>
    </tr>
    <tr>
      <td class = "rowNumber">9</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C109</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">191.3</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">191.3</td>
      <td style = "text-align: right;">191.8</td>
    </tr>
    <tr>
      <td class = "rowNumber">10</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C201</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">214.7</td>
      <td style = "text-align: right;">2</td>
      <td style = "color: red; font-weight: bold; text-align: right;">214.7</td>
      <td style = "text-align: right;">215.5</td>
    </tr>
    <tr>
      <td class = "rowNumber">11</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C202</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">214.7</td>
      <td style = "text-align: right;">2</td>
      <td style = "color: red; font-weight: bold; text-align: right;">214.7</td>
      <td style = "text-align: right;">215.5</td>
    </tr>
    <tr>
      <td class = "rowNumber">12</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C203</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">214.7</td>
      <td style = "text-align: right;">2</td>
      <td style = "color: red; font-weight: bold; text-align: right;">214.7</td>
      <td style = "text-align: right;">215.5</td>
    </tr>
    <tr>
      <td class = "rowNumber">13</td>
      <td style = "text-align: right;">C204</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">213.1</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">214.5</td>
      <td style = "text-align: right;">215.3</td>
    </tr>
    <tr>
      <td class = "rowNumber">14</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C205</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">214.7</td>
      <td style = "text-align: right;">2</td>
      <td style = "color: red; font-weight: bold; text-align: right;">214.7</td>
      <td style = "text-align: right;">215.5</td>
    </tr>
    <tr>
      <td class = "rowNumber">15</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C206</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">214.7</td>
      <td style = "text-align: right;">2</td>
      <td style = "color: red; font-weight: bold; text-align: right;">214.7</td>
      <td style = "text-align: right;">215.5</td>
    </tr>
    <tr>
      <td class = "rowNumber">16</td>
      <td style = "text-align: right;">C207</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">214.5</td>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">274.0</td>
      <td style = "text-align: right;">274.8</td>
    </tr>
    <tr>
      <td class = "rowNumber">17</td>
      <td style = "text-align: right;">C208</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">214.5</td>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">229.1</td>
      <td style = "text-align: right;">229.8</td>
    </tr>
    <tr>
      <td class = "rowNumber">18</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R101</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">8.0</td>
      <td style = "text-align: right;">617.1</td>
      <td style = "text-align: right;">8</td>
      <td style = "color: red; font-weight: bold; text-align: right;">617.1</td>
      <td style = "text-align: right;">618.3</td>
    </tr>
    <tr>
      <td class = "rowNumber">19</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R102</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">7.0</td>
      <td style = "text-align: right;">547.1</td>
      <td style = "text-align: right;">7</td>
      <td style = "color: red; font-weight: bold; text-align: right;">547.1</td>
      <td style = "text-align: right;">548.1</td>
    </tr>
    <tr>
      <td class = "rowNumber">20</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R103</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">454.6</td>
      <td style = "text-align: right;">5</td>
      <td style = "color: red; font-weight: bold; text-align: right;">454.6</td>
      <td style = "text-align: right;">455.7</td>
    </tr>
    <tr>
      <td class = "rowNumber">21</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R104</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">416.9</td>
      <td style = "text-align: right;">4</td>
      <td style = "color: red; font-weight: bold; text-align: right;">416.9</td>
      <td style = "text-align: right;">418.0</td>
    </tr>
    <tr>
      <td class = "rowNumber">22</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R105</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">6.0</td>
      <td style = "text-align: right;">530.5</td>
      <td style = "text-align: right;">6</td>
      <td style = "color: red; font-weight: bold; text-align: right;">530.5</td>
      <td style = "text-align: right;">531.5</td>
    </tr>
    <tr>
      <td class = "rowNumber">23</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R106</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">465.4</td>
      <td style = "text-align: right;">5</td>
      <td style = "color: red; font-weight: bold; text-align: right;">465.4</td>
      <td style = "text-align: right;">466.5</td>
    </tr>
    <tr>
      <td class = "rowNumber">24</td>
      <td style = "text-align: right;">R107</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">424.3</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">430.8</td>
      <td style = "text-align: right;">431.8</td>
    </tr>
    <tr>
      <td class = "rowNumber">25</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R108</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">397.3</td>
      <td style = "text-align: right;">4</td>
      <td style = "color: red; font-weight: bold; text-align: right;">397.3</td>
      <td style = "text-align: right;">398.3</td>
    </tr>
    <tr>
      <td class = "rowNumber">26</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R109</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">441.3</td>
      <td style = "text-align: right;">5</td>
      <td style = "color: red; font-weight: bold; text-align: right;">441.3</td>
      <td style = "text-align: right;">442.6</td>
    </tr>
    <tr>
      <td class = "rowNumber">27</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R110</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">444.1</td>
      <td style = "text-align: right;">5</td>
      <td style = "color: red; font-weight: bold; text-align: right;">444.1</td>
      <td style = "text-align: right;">445.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">28</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R111</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">428.8</td>
      <td style = "text-align: right;">4</td>
      <td style = "color: red; font-weight: bold; text-align: right;">428.8</td>
      <td style = "text-align: right;">429.7</td>
    </tr>
    <tr>
      <td class = "rowNumber">29</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R112</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">393.0</td>
      <td style = "text-align: right;">4</td>
      <td style = "color: red; font-weight: bold; text-align: right;">393.0</td>
      <td style = "text-align: right;">394.1</td>
    </tr>
    <tr>
      <td class = "rowNumber">30</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R201</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">463.3</td>
      <td style = "text-align: right;">4</td>
      <td style = "color: red; font-weight: bold; text-align: right;">463.3</td>
      <td style = "text-align: right;">464.4</td>
    </tr>
    <tr>
      <td class = "rowNumber">31</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R202</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">410.5</td>
      <td style = "text-align: right;">4</td>
      <td style = "color: red; font-weight: bold; text-align: right;">410.5</td>
      <td style = "text-align: right;">411.5</td>
    </tr>
    <tr>
      <td class = "rowNumber">32</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R203</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">391.4</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">391.4</td>
      <td style = "text-align: right;">392.3</td>
    </tr>
    <tr>
      <td class = "rowNumber">33</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R204</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">355.0</td>
      <td style = "text-align: right;">2</td>
      <td style = "color: red; font-weight: bold; text-align: right;">355.0</td>
      <td style = "text-align: right;">355.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">34</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R205</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">393.0</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">393.0</td>
      <td style = "text-align: right;">394.1</td>
    </tr>
    <tr>
      <td class = "rowNumber">35</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R206</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">374.4</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">374.4</td>
      <td style = "text-align: right;">375.5</td>
    </tr>
    <tr>
      <td class = "rowNumber">36</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R207</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">361.6</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">361.6</td>
      <td style = "text-align: right;">362.6</td>
    </tr>
    <tr>
      <td class = "rowNumber">37</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R208</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">1.0</td>
      <td style = "text-align: right;">328.2</td>
      <td style = "text-align: right;">1</td>
      <td style = "color: red; font-weight: bold; text-align: right;">328.2</td>
      <td style = "text-align: right;">329.3</td>
    </tr>
    <tr>
      <td class = "rowNumber">38</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R209</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">370.7</td>
      <td style = "text-align: right;">2</td>
      <td style = "color: red; font-weight: bold; text-align: right;">370.7</td>
      <td style = "text-align: right;">371.6</td>
    </tr>
    <tr>
      <td class = "rowNumber">39</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R210</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">404.6</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">404.6</td>
      <td style = "text-align: right;">405.5</td>
    </tr>
    <tr>
      <td class = "rowNumber">40</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R211</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">350.9</td>
      <td style = "text-align: right;">2</td>
      <td style = "color: red; font-weight: bold; text-align: right;">350.9</td>
      <td style = "text-align: right;">351.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">41</td>
      <td style = "color: red; font-weight: bold; text-align: right;">RC101</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">461.1</td>
      <td style = "text-align: right;">4</td>
      <td style = "color: red; font-weight: bold; text-align: right;">461.1</td>
      <td style = "text-align: right;">462.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">42</td>
      <td style = "color: red; font-weight: bold; text-align: right;">RC102</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">351.8</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">351.8</td>
      <td style = "text-align: right;">352.7</td>
    </tr>
    <tr>
      <td class = "rowNumber">43</td>
      <td style = "color: red; font-weight: bold; text-align: right;">RC103</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">332.8</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">332.8</td>
      <td style = "text-align: right;">333.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">44</td>
      <td style = "color: red; font-weight: bold; text-align: right;">RC104</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">306.6</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">306.6</td>
      <td style = "text-align: right;">307.1</td>
    </tr>
    <tr>
      <td class = "rowNumber">45</td>
      <td style = "color: red; font-weight: bold; text-align: right;">RC105</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">411.3</td>
      <td style = "text-align: right;">4</td>
      <td style = "color: red; font-weight: bold; text-align: right;">411.3</td>
      <td style = "text-align: right;">412.4</td>
    </tr>
    <tr>
      <td class = "rowNumber">46</td>
      <td style = "color: red; font-weight: bold; text-align: right;">RC106</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">345.5</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">345.5</td>
      <td style = "text-align: right;">346.5</td>
    </tr>
    <tr>
      <td class = "rowNumber">47</td>
      <td style = "color: red; font-weight: bold; text-align: right;">RC107</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">298.3</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">298.3</td>
      <td style = "text-align: right;">298.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">48</td>
      <td style = "color: red; font-weight: bold; text-align: right;">RC108</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">294.5</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">294.5</td>
      <td style = "text-align: right;">295.0</td>
    </tr>
    <tr>
      <td class = "rowNumber">49</td>
      <td style = "color: red; font-weight: bold; text-align: right;">RC201</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">360.2</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">360.2</td>
      <td style = "text-align: right;">361.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">50</td>
      <td style = "color: red; font-weight: bold; text-align: right;">RC202</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">338.0</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">338.0</td>
      <td style = "text-align: right;">338.8</td>
    </tr>
    <tr>
      <td class = "rowNumber">51</td>
      <td style = "color: red; font-weight: bold; text-align: right;">RC203</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">326.9</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">326.9</td>
      <td style = "text-align: right;">327.7</td>
    </tr>
    <tr>
      <td class = "rowNumber">52</td>
      <td style = "color: red; font-weight: bold; text-align: right;">RC204</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">299.7</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">299.7</td>
      <td style = "text-align: right;">300.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">53</td>
      <td style = "color: red; font-weight: bold; text-align: right;">RC205</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">338.0</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">338.0</td>
      <td style = "text-align: right;">338.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">54</td>
      <td style = "color: red; font-weight: bold; text-align: right;">RC206</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">324.0</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">324.0</td>
      <td style = "text-align: right;">325.1</td>
    </tr>
    <tr>
      <td class = "rowNumber">55</td>
      <td style = "color: red; font-weight: bold; text-align: right;">RC207</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">298.3</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">298.3</td>
      <td style = "text-align: right;">298.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">56</td>
      <td style = "color: red; font-weight: bold; text-align: right;">RC208</td>
      <td style = "text-align: right;">25</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">269.1</td>
      <td style = "text-align: right;">2</td>
      <td style = "color: red; font-weight: bold; text-align: right;">269.1</td>
      <td style = "text-align: right;">269.6</td>
    </tr>
  </tbody>
</table>
</body>
</html>





---


Result of 50 customers compare with optimum


```julia
df = CSV.File("../data/opt_solomon/all_50.csv") |> DataFrame
hl_v = HTMLHighlighter( (df,i,j)->(j in (1, 6) && !ismissing(df[i, 4])) && df[i,4] >= df[i, 6] , HTMLDecoration(color = "red", font_weight = "bold"));
pretty_table(df, show_row_number=true, tf=tf_html_matrix, highlighters = (hl_v, ), formatters = ft_nomissing)
```


<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
  table {
      position: relative;
  }

  table::before,
  table::after {
      border: 1px solid #000;
      content: "";
      height: 100%;
      position: absolute;
      top: 0;
      width: 6px;
  }

  table::before {
      border-right: 0px;
      left: -6px;
  }

  table::after {
      border-left: 0px;
      right: -6px;
  }

  td {
      padding: 5px;
      text-align: center;
  }

</style>
<body>
<table>
  <thead>
    <tr class = "header">
      <th class = "rowNumber">Row</th>
      <th style = "text-align: right;">Problem</th>
      <th style = "text-align: right;">Num_customer</th>
      <th style = "text-align: right;">NV</th>
      <th style = "text-align: right;">Opt</th>
      <th style = "text-align: right;">Our_NV</th>
      <th style = "text-align: right;">Our_floor</th>
      <th style = "text-align: right;">Our</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th></th>
      <th style = "text-align: right;">String7</th>
      <th style = "text-align: right;">Int64</th>
      <th style = "text-align: right;">Float64?</th>
      <th style = "text-align: right;">Float64?</th>
      <th style = "text-align: right;">Int64</th>
      <th style = "text-align: right;">Float64</th>
      <th style = "text-align: right;">Float64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class = "rowNumber">1</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C101</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">362.4</td>
      <td style = "text-align: right;">5</td>
      <td style = "color: red; font-weight: bold; text-align: right;">362.4</td>
      <td style = "text-align: right;">363.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">2</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C102</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">361.4</td>
      <td style = "text-align: right;">5</td>
      <td style = "color: red; font-weight: bold; text-align: right;">361.4</td>
      <td style = "text-align: right;">362.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">3</td>
      <td style = "text-align: right;">C103</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">361.4</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">382.1</td>
      <td style = "text-align: right;">382.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">4</td>
      <td style = "text-align: right;">C104</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">358.0</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">361.1</td>
      <td style = "text-align: right;">362.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">5</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C105</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">362.4</td>
      <td style = "text-align: right;">5</td>
      <td style = "color: red; font-weight: bold; text-align: right;">362.4</td>
      <td style = "text-align: right;">363.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">6</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C106</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">362.4</td>
      <td style = "text-align: right;">5</td>
      <td style = "color: red; font-weight: bold; text-align: right;">362.4</td>
      <td style = "text-align: right;">363.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">7</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C107</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">362.4</td>
      <td style = "text-align: right;">5</td>
      <td style = "color: red; font-weight: bold; text-align: right;">362.4</td>
      <td style = "text-align: right;">363.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">8</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C108</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">362.4</td>
      <td style = "text-align: right;">5</td>
      <td style = "color: red; font-weight: bold; text-align: right;">362.4</td>
      <td style = "text-align: right;">363.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">9</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C109</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">362.4</td>
      <td style = "text-align: right;">5</td>
      <td style = "color: red; font-weight: bold; text-align: right;">362.4</td>
      <td style = "text-align: right;">363.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">10</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C201</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">360.2</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">360.2</td>
      <td style = "text-align: right;">361.8</td>
    </tr>
    <tr>
      <td class = "rowNumber">11</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C202</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">360.2</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">360.2</td>
      <td style = "text-align: right;">361.8</td>
    </tr>
    <tr>
      <td class = "rowNumber">12</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C203</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">359.8</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">359.8</td>
      <td style = "text-align: right;">361.4</td>
    </tr>
    <tr>
      <td class = "rowNumber">13</td>
      <td style = "text-align: right;">C204</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">350.1</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">357.6</td>
      <td style = "text-align: right;">359.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">14</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C205</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">359.8</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">359.8</td>
      <td style = "text-align: right;">361.4</td>
    </tr>
    <tr>
      <td class = "rowNumber">15</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C206</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">359.8</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">359.8</td>
      <td style = "text-align: right;">361.4</td>
    </tr>
    <tr>
      <td class = "rowNumber">16</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C207</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">359.6</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">359.6</td>
      <td style = "text-align: right;">361.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">17</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C208</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">350.5</td>
      <td style = "text-align: right;">2</td>
      <td style = "color: red; font-weight: bold; text-align: right;">350.5</td>
      <td style = "text-align: right;">352.1</td>
    </tr>
    <tr>
      <td class = "rowNumber">18</td>
      <td style = "text-align: right;">R101</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">12.0</td>
      <td style = "text-align: right;">1044.0</td>
      <td style = "text-align: right;">12</td>
      <td style = "text-align: right;">1049.2</td>
      <td style = "text-align: right;">1052.0</td>
    </tr>
    <tr>
      <td class = "rowNumber">19</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R102</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">11.0</td>
      <td style = "text-align: right;">909.0</td>
      <td style = "text-align: right;">11</td>
      <td style = "color: red; font-weight: bold; text-align: right;">909.0</td>
      <td style = "text-align: right;">911.4</td>
    </tr>
    <tr>
      <td class = "rowNumber">20</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R103</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">9.0</td>
      <td style = "text-align: right;">772.9</td>
      <td style = "text-align: right;">9</td>
      <td style = "color: red; font-weight: bold; text-align: right;">772.9</td>
      <td style = "text-align: right;">775.7</td>
    </tr>
    <tr>
      <td class = "rowNumber">21</td>
      <td style = "text-align: right;">R104</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">6.0</td>
      <td style = "text-align: right;">625.4</td>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">636.0</td>
      <td style = "text-align: right;">638.7</td>
    </tr>
    <tr>
      <td class = "rowNumber">22</td>
      <td style = "text-align: right;">R105</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">9.0</td>
      <td style = "text-align: right;">899.3</td>
      <td style = "text-align: right;">11</td>
      <td style = "text-align: right;">922.4</td>
      <td style = "text-align: right;">925.0</td>
    </tr>
    <tr>
      <td class = "rowNumber">23</td>
      <td style = "text-align: right;">R106</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">793.0</td>
      <td style = "text-align: right;">9</td>
      <td style = "text-align: right;">795.5</td>
      <td style = "text-align: right;">797.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">24</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R107</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">7.0</td>
      <td style = "text-align: right;">711.1</td>
      <td style = "text-align: right;">7</td>
      <td style = "color: red; font-weight: bold; text-align: right;">711.1</td>
      <td style = "text-align: right;">713.5</td>
    </tr>
    <tr>
      <td class = "rowNumber">25</td>
      <td style = "text-align: right;">R108</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">6.0</td>
      <td style = "text-align: right;">617.7</td>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">623.7</td>
      <td style = "text-align: right;">626.0</td>
    </tr>
    <tr>
      <td class = "rowNumber">26</td>
      <td style = "text-align: right;">R109</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">8.0</td>
      <td style = "text-align: right;">786.8</td>
      <td style = "text-align: right;">8</td>
      <td style = "text-align: right;">792.0</td>
      <td style = "text-align: right;">794.4</td>
    </tr>
    <tr>
      <td class = "rowNumber">27</td>
      <td style = "text-align: right;">R110</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">7.0</td>
      <td style = "text-align: right;">697.0</td>
      <td style = "text-align: right;">8</td>
      <td style = "text-align: right;">718.5</td>
      <td style = "text-align: right;">720.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">28</td>
      <td style = "text-align: right;">R111</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">7.0</td>
      <td style = "text-align: right;">707.2</td>
      <td style = "text-align: right;">7</td>
      <td style = "text-align: right;">719.3</td>
      <td style = "text-align: right;">721.6</td>
    </tr>
    <tr>
      <td class = "rowNumber">29</td>
      <td style = "text-align: right;">R112</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">6.0</td>
      <td style = "text-align: right;">630.2</td>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">650.3</td>
      <td style = "text-align: right;">652.5</td>
    </tr>
    <tr>
      <td class = "rowNumber">30</td>
      <td style = "text-align: right;">R201</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">6.0</td>
      <td style = "text-align: right;">791.9</td>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">812.1</td>
      <td style = "text-align: right;">814.5</td>
    </tr>
    <tr>
      <td class = "rowNumber">31</td>
      <td style = "text-align: right;">R202</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">698.5</td>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">715.4</td>
      <td style = "text-align: right;">717.5</td>
    </tr>
    <tr>
      <td class = "rowNumber">32</td>
      <td style = "text-align: right;">R203</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">605.3</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">613.8</td>
      <td style = "text-align: right;">615.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">33</td>
      <td style = "text-align: right;">R204</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">2.0</td>
      <td style = "text-align: right;">506.4</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">512.7</td>
      <td style = "text-align: right;">515.7</td>
    </tr>
    <tr>
      <td class = "rowNumber">34</td>
      <td style = "text-align: right;">R205</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">690.1</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">700.0</td>
      <td style = "text-align: right;">702.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">35</td>
      <td style = "text-align: right;">R206</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">632.4</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">643.4</td>
      <td style = "text-align: right;">645.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">36</td>
      <td style = "text-align: right;">R207</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;"></td>
      <td style = "text-align: right;"></td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">584.2</td>
      <td style = "text-align: right;">586.3</td>
    </tr>
    <tr>
      <td class = "rowNumber">37</td>
      <td style = "text-align: right;">R208</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;"></td>
      <td style = "text-align: right;"></td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">496.2</td>
      <td style = "text-align: right;">498.5</td>
    </tr>
    <tr>
      <td class = "rowNumber">38</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R209</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">600.6</td>
      <td style = "text-align: right;">4</td>
      <td style = "color: red; font-weight: bold; text-align: right;">600.6</td>
      <td style = "text-align: right;">603.1</td>
    </tr>
    <tr>
      <td class = "rowNumber">39</td>
      <td style = "text-align: right;">R210</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">645.6</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">655.5</td>
      <td style = "text-align: right;">657.7</td>
    </tr>
    <tr>
      <td class = "rowNumber">40</td>
      <td style = "text-align: right;">R211</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">535.5</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">552.2</td>
      <td style = "text-align: right;">554.8</td>
    </tr>
    <tr>
      <td class = "rowNumber">41</td>
      <td style = "text-align: right;">RC101</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">8.0</td>
      <td style = "text-align: right;">944.0</td>
      <td style = "text-align: right;">8</td>
      <td style = "text-align: right;">944.8</td>
      <td style = "text-align: right;">946.5</td>
    </tr>
    <tr>
      <td class = "rowNumber">42</td>
      <td style = "text-align: right;">RC102</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">7.0</td>
      <td style = "text-align: right;">822.5</td>
      <td style = "text-align: right;">8</td>
      <td style = "text-align: right;">838.9</td>
      <td style = "text-align: right;">840.3</td>
    </tr>
    <tr>
      <td class = "rowNumber">43</td>
      <td style = "text-align: right;">RC103</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">6.0</td>
      <td style = "text-align: right;">710.9</td>
      <td style = "text-align: right;">7</td>
      <td style = "text-align: right;">754.5</td>
      <td style = "text-align: right;">756.0</td>
    </tr>
    <tr>
      <td class = "rowNumber">44</td>
      <td style = "text-align: right;">RC104</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">545.8</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">552.2</td>
      <td style = "text-align: right;">553.1</td>
    </tr>
    <tr>
      <td class = "rowNumber">45</td>
      <td style = "text-align: right;">RC105</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">8.0</td>
      <td style = "text-align: right;">855.3</td>
      <td style = "text-align: right;">9</td>
      <td style = "text-align: right;">889.0</td>
      <td style = "text-align: right;">890.6</td>
    </tr>
    <tr>
      <td class = "rowNumber">46</td>
      <td style = "text-align: right;">RC106</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">6.0</td>
      <td style = "text-align: right;">723.2</td>
      <td style = "text-align: right;">7</td>
      <td style = "text-align: right;">769.0</td>
      <td style = "text-align: right;">770.6</td>
    </tr>
    <tr>
      <td class = "rowNumber">47</td>
      <td style = "text-align: right;">RC107</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">6.0</td>
      <td style = "text-align: right;">642.7</td>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">670.2</td>
      <td style = "text-align: right;">671.4</td>
    </tr>
    <tr>
      <td class = "rowNumber">48</td>
      <td style = "color: red; font-weight: bold; text-align: right;">RC108</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">6.0</td>
      <td style = "text-align: right;">598.1</td>
      <td style = "text-align: right;">6</td>
      <td style = "color: red; font-weight: bold; text-align: right;">598.1</td>
      <td style = "text-align: right;">599.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">49</td>
      <td style = "color: red; font-weight: bold; text-align: right;">RC201</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">684.8</td>
      <td style = "text-align: right;">5</td>
      <td style = "color: red; font-weight: bold; text-align: right;">684.8</td>
      <td style = "text-align: right;">686.3</td>
    </tr>
    <tr>
      <td class = "rowNumber">50</td>
      <td style = "color: red; font-weight: bold; text-align: right;">RC202</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">613.6</td>
      <td style = "text-align: right;">5</td>
      <td style = "color: red; font-weight: bold; text-align: right;">613.6</td>
      <td style = "text-align: right;">615.0</td>
    </tr>
    <tr>
      <td class = "rowNumber">51</td>
      <td style = "text-align: right;">RC203</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">555.3</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">566.2</td>
      <td style = "text-align: right;">567.6</td>
    </tr>
    <tr>
      <td class = "rowNumber">52</td>
      <td style = "text-align: right;">RC204</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">444.2</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">447.2</td>
      <td style = "text-align: right;">447.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">53</td>
      <td style = "text-align: right;">RC205</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">630.2</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">633.7</td>
      <td style = "text-align: right;">635.3</td>
    </tr>
    <tr>
      <td class = "rowNumber">54</td>
      <td style = "text-align: right;">RC206</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">5.0</td>
      <td style = "text-align: right;">610.0</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">610.1</td>
      <td style = "text-align: right;">611.7</td>
    </tr>
    <tr>
      <td class = "rowNumber">55</td>
      <td style = "text-align: right;">RC207</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;">4.0</td>
      <td style = "text-align: right;">558.6</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">562.5</td>
      <td style = "text-align: right;">563.8</td>
    </tr>
    <tr>
      <td class = "rowNumber">56</td>
      <td style = "text-align: right;">RC208</td>
      <td style = "text-align: right;">50</td>
      <td style = "text-align: right;"></td>
      <td style = "text-align: right;"></td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">490.6</td>
      <td style = "text-align: right;">491.5</td>
    </tr>
  </tbody>
</table>
</body>
</html>




---

Result of 100 customers compare with optimum


```julia
df = CSV.File("../data/opt_solomon/all_100.csv") |> DataFrame
hl_v = HTMLHighlighter( (df,i,j)->(j in (1, 6) && !ismissing(df[i, 4])) && df[i,4] >= df[i, 6], HTMLDecoration(color = "red", font_weight = "bold"));
pretty_table(df, show_row_number=true, tf=tf_html_matrix, highlighters = (hl_v, ))
```


<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
  table {
      position: relative;
  }

  table::before,
  table::after {
      border: 1px solid #000;
      content: "";
      height: 100%;
      position: absolute;
      top: 0;
      width: 6px;
  }

  table::before {
      border-right: 0px;
      left: -6px;
  }

  table::after {
      border-left: 0px;
      right: -6px;
  }

  td {
      padding: 5px;
      text-align: center;
  }

</style>
<body>
<table>
  <thead>
    <tr class = "header">
      <th class = "rowNumber">Row</th>
      <th style = "text-align: right;">Problem</th>
      <th style = "text-align: right;">Num_customer</th>
      <th style = "text-align: right;">NV</th>
      <th style = "text-align: right;">Opt</th>
      <th style = "text-align: right;">Our_NV</th>
      <th style = "text-align: right;">Our_floor</th>
      <th style = "text-align: right;">Our</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th></th>
      <th style = "text-align: right;">String7</th>
      <th style = "text-align: right;">Int64</th>
      <th style = "text-align: right;">Float64?</th>
      <th style = "text-align: right;">Float64?</th>
      <th style = "text-align: right;">Int64</th>
      <th style = "text-align: right;">Float64</th>
      <th style = "text-align: right;">Float64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class = "rowNumber">1</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C101</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">10.0</td>
      <td style = "text-align: right;">827.3</td>
      <td style = "text-align: right;">10</td>
      <td style = "color: red; font-weight: bold; text-align: right;">827.3</td>
      <td style = "text-align: right;">828.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">2</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C102</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">10.0</td>
      <td style = "text-align: right;">827.3</td>
      <td style = "text-align: right;">10</td>
      <td style = "color: red; font-weight: bold; text-align: right;">827.3</td>
      <td style = "text-align: right;">828.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C103</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">10.0</td>
      <td style = "text-align: right;">826.3</td>
      <td style = "text-align: right;">10</td>
      <td style = "color: red; font-weight: bold; text-align: right;">826.3</td>
      <td style = "text-align: right;">828.1</td>
    </tr>
    <tr>
      <td class = "rowNumber">4</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C104</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">10.0</td>
      <td style = "text-align: right;">822.9</td>
      <td style = "text-align: right;">10</td>
      <td style = "color: red; font-weight: bold; text-align: right;">822.9</td>
      <td style = "text-align: right;">824.8</td>
    </tr>
    <tr>
      <td class = "rowNumber">5</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C105</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">10.0</td>
      <td style = "text-align: right;">827.3</td>
      <td style = "text-align: right;">10</td>
      <td style = "color: red; font-weight: bold; text-align: right;">827.3</td>
      <td style = "text-align: right;">828.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">6</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C106</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">10.0</td>
      <td style = "text-align: right;">827.3</td>
      <td style = "text-align: right;">10</td>
      <td style = "color: red; font-weight: bold; text-align: right;">827.3</td>
      <td style = "text-align: right;">828.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">7</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C107</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">10.0</td>
      <td style = "text-align: right;">827.3</td>
      <td style = "text-align: right;">10</td>
      <td style = "color: red; font-weight: bold; text-align: right;">827.3</td>
      <td style = "text-align: right;">828.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">8</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C108</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">10.0</td>
      <td style = "text-align: right;">827.3</td>
      <td style = "text-align: right;">10</td>
      <td style = "color: red; font-weight: bold; text-align: right;">827.3</td>
      <td style = "text-align: right;">828.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">9</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C109</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">10.0</td>
      <td style = "text-align: right;">827.3</td>
      <td style = "text-align: right;">10</td>
      <td style = "color: red; font-weight: bold; text-align: right;">827.3</td>
      <td style = "text-align: right;">828.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">10</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C201</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">589.1</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">589.1</td>
      <td style = "text-align: right;">591.6</td>
    </tr>
    <tr>
      <td class = "rowNumber">11</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C202</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">589.1</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">589.1</td>
      <td style = "text-align: right;">591.6</td>
    </tr>
    <tr>
      <td class = "rowNumber">12</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C203</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">588.7</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">588.7</td>
      <td style = "text-align: right;">591.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">13</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C204</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">588.1</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">588.1</td>
      <td style = "text-align: right;">590.6</td>
    </tr>
    <tr>
      <td class = "rowNumber">14</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C205</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">586.4</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">586.4</td>
      <td style = "text-align: right;">588.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">15</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C206</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">586.0</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">586.0</td>
      <td style = "text-align: right;">588.5</td>
    </tr>
    <tr>
      <td class = "rowNumber">16</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C207</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">585.8</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">585.8</td>
      <td style = "text-align: right;">588.3</td>
    </tr>
    <tr>
      <td class = "rowNumber">17</td>
      <td style = "color: red; font-weight: bold; text-align: right;">C208</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">3.0</td>
      <td style = "text-align: right;">585.8</td>
      <td style = "text-align: right;">3</td>
      <td style = "color: red; font-weight: bold; text-align: right;">585.8</td>
      <td style = "text-align: right;">588.3</td>
    </tr>
    <tr>
      <td class = "rowNumber">18</td>
      <td style = "color: red; font-weight: bold; text-align: right;">R101</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">20.0</td>
      <td style = "text-align: right;">1637.7</td>
      <td style = "text-align: right;">20</td>
      <td style = "color: red; font-weight: bold; text-align: right;">1637.7</td>
      <td style = "text-align: right;">1642.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">19</td>
      <td style = "text-align: right;">R102</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">18.0</td>
      <td style = "text-align: right;">1466.6</td>
      <td style = "text-align: right;">18</td>
      <td style = "text-align: right;">1467.7</td>
      <td style = "text-align: right;">1472.8</td>
    </tr>
    <tr>
      <td class = "rowNumber">20</td>
      <td style = "text-align: right;">R103</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">14.0</td>
      <td style = "text-align: right;">1208.7</td>
      <td style = "text-align: right;">15</td>
      <td style = "text-align: right;">1220.3</td>
      <td style = "text-align: right;">1225.1</td>
    </tr>
    <tr>
      <td class = "rowNumber">21</td>
      <td style = "text-align: right;">R104</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">11.0</td>
      <td style = "text-align: right;">971.5</td>
      <td style = "text-align: right;">10</td>
      <td style = "text-align: right;">984.5</td>
      <td style = "text-align: right;">989.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">22</td>
      <td style = "text-align: right;">R105</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">15.0</td>
      <td style = "text-align: right;">1355.3</td>
      <td style = "text-align: right;">16</td>
      <td style = "text-align: right;">1373.1</td>
      <td style = "text-align: right;">1378.1</td>
    </tr>
    <tr>
      <td class = "rowNumber">23</td>
      <td style = "text-align: right;">R106</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">13.0</td>
      <td style = "text-align: right;">1234.6</td>
      <td style = "text-align: right;">14</td>
      <td style = "text-align: right;">1259.3</td>
      <td style = "text-align: right;">1263.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">24</td>
      <td style = "text-align: right;">R107</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">11.0</td>
      <td style = "text-align: right;">1064.6</td>
      <td style = "text-align: right;">12</td>
      <td style = "text-align: right;">1084.6</td>
      <td style = "text-align: right;">1089.3</td>
    </tr>
    <tr>
      <td class = "rowNumber">25</td>
      <td style = "text-align: right;">R108</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">11</td>
      <td style = "text-align: right;">952.3</td>
      <td style = "text-align: right;">956.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">26</td>
      <td style = "text-align: right;">R109</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">13.0</td>
      <td style = "text-align: right;">1146.9</td>
      <td style = "text-align: right;">13</td>
      <td style = "text-align: right;">1165.9</td>
      <td style = "text-align: right;">1170.7</td>
    </tr>
    <tr>
      <td class = "rowNumber">27</td>
      <td style = "text-align: right;">R110</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">12.0</td>
      <td style = "text-align: right;">1068.0</td>
      <td style = "text-align: right;">12</td>
      <td style = "text-align: right;">1091.2</td>
      <td style = "text-align: right;">1095.5</td>
    </tr>
    <tr>
      <td class = "rowNumber">28</td>
      <td style = "text-align: right;">R111</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">12.0</td>
      <td style = "text-align: right;">1048.7</td>
      <td style = "text-align: right;">12</td>
      <td style = "text-align: right;">1065.3</td>
      <td style = "text-align: right;">1070.0</td>
    </tr>
    <tr>
      <td class = "rowNumber">29</td>
      <td style = "text-align: right;">R112</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">11</td>
      <td style = "text-align: right;">971.8</td>
      <td style = "text-align: right;">976.3</td>
    </tr>
    <tr>
      <td class = "rowNumber">30</td>
      <td style = "text-align: right;">R201</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">8.0</td>
      <td style = "text-align: right;">1143.2</td>
      <td style = "text-align: right;">8</td>
      <td style = "text-align: right;">1146.6</td>
      <td style = "text-align: right;">1151.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">31</td>
      <td style = "text-align: right;">R202</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">7</td>
      <td style = "text-align: right;">1035.8</td>
      <td style = "text-align: right;">1040.4</td>
    </tr>
    <tr>
      <td class = "rowNumber">32</td>
      <td style = "text-align: right;">R203</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">877.0</td>
      <td style = "text-align: right;">880.8</td>
    </tr>
    <tr>
      <td class = "rowNumber">33</td>
      <td style = "text-align: right;">R204</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">742.4</td>
      <td style = "text-align: right;">746.7</td>
    </tr>
    <tr>
      <td class = "rowNumber">34</td>
      <td style = "text-align: right;">R205</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">957.2</td>
      <td style = "text-align: right;">961.6</td>
    </tr>
    <tr>
      <td class = "rowNumber">35</td>
      <td style = "text-align: right;">R206</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">894.4</td>
      <td style = "text-align: right;">898.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">36</td>
      <td style = "text-align: right;">R207</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">808.6</td>
      <td style = "text-align: right;">812.6</td>
    </tr>
    <tr>
      <td class = "rowNumber">37</td>
      <td style = "text-align: right;">R208</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">718.7</td>
      <td style = "text-align: right;">723.0</td>
    </tr>
    <tr>
      <td class = "rowNumber">38</td>
      <td style = "text-align: right;">R209</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">870.3</td>
      <td style = "text-align: right;">874.6</td>
    </tr>
    <tr>
      <td class = "rowNumber">39</td>
      <td style = "text-align: right;">R210</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">916.0</td>
      <td style = "text-align: right;">920.1</td>
    </tr>
    <tr>
      <td class = "rowNumber">40</td>
      <td style = "text-align: right;">R211</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">758.6</td>
      <td style = "text-align: right;">763.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">41</td>
      <td style = "text-align: right;">RC101</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">15.0</td>
      <td style = "text-align: right;">1619.8</td>
      <td style = "text-align: right;">16</td>
      <td style = "text-align: right;">1647.5</td>
      <td style = "text-align: right;">1651.3</td>
    </tr>
    <tr>
      <td class = "rowNumber">42</td>
      <td style = "text-align: right;">RC102</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">14.0</td>
      <td style = "text-align: right;">1457.4</td>
      <td style = "text-align: right;">14</td>
      <td style = "text-align: right;">1473.5</td>
      <td style = "text-align: right;">1477.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">43</td>
      <td style = "text-align: right;">RC103</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">11.0</td>
      <td style = "text-align: right;">1258.0</td>
      <td style = "text-align: right;">12</td>
      <td style = "text-align: right;">1282.5</td>
      <td style = "text-align: right;">1286.3</td>
    </tr>
    <tr>
      <td class = "rowNumber">44</td>
      <td style = "text-align: right;">RC104</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">11</td>
      <td style = "text-align: right;">1159.2</td>
      <td style = "text-align: right;">1162.6</td>
    </tr>
    <tr>
      <td class = "rowNumber">45</td>
      <td style = "text-align: right;">RC105</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">15.0</td>
      <td style = "text-align: right;">1513.7</td>
      <td style = "text-align: right;">15</td>
      <td style = "text-align: right;">1554.9</td>
      <td style = "text-align: right;">1559.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">46</td>
      <td style = "text-align: right;">RC106</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">14</td>
      <td style = "text-align: right;">1398.2</td>
      <td style = "text-align: right;">1401.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">47</td>
      <td style = "text-align: right;">RC107</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">12.0</td>
      <td style = "text-align: right;">1207.8</td>
      <td style = "text-align: right;">12</td>
      <td style = "text-align: right;">1251.0</td>
      <td style = "text-align: right;">1254.2</td>
    </tr>
    <tr>
      <td class = "rowNumber">48</td>
      <td style = "text-align: right;">RC108</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">11.0</td>
      <td style = "text-align: right;">1114.2</td>
      <td style = "text-align: right;">11</td>
      <td style = "text-align: right;">1132.5</td>
      <td style = "text-align: right;">1135.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">49</td>
      <td style = "text-align: right;">RC201</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">9.0</td>
      <td style = "text-align: right;">1261.8</td>
      <td style = "text-align: right;">9</td>
      <td style = "text-align: right;">1268.8</td>
      <td style = "text-align: right;">1272.3</td>
    </tr>
    <tr>
      <td class = "rowNumber">50</td>
      <td style = "text-align: right;">RC202</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">8.0</td>
      <td style = "text-align: right;">1092.3</td>
      <td style = "text-align: right;">8</td>
      <td style = "text-align: right;">1096.3</td>
      <td style = "text-align: right;">1099.5</td>
    </tr>
    <tr>
      <td class = "rowNumber">51</td>
      <td style = "text-align: right;">RC203</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">934.4</td>
      <td style = "text-align: right;">937.4</td>
    </tr>
    <tr>
      <td class = "rowNumber">52</td>
      <td style = "text-align: right;">RC204</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">793.6</td>
      <td style = "text-align: right;">796.3</td>
    </tr>
    <tr>
      <td class = "rowNumber">53</td>
      <td style = "text-align: right;">RC205</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">7.0</td>
      <td style = "text-align: right;">1154.0</td>
      <td style = "text-align: right;">8</td>
      <td style = "text-align: right;">1162.7</td>
      <td style = "text-align: right;">1166.6</td>
    </tr>
    <tr>
      <td class = "rowNumber">54</td>
      <td style = "text-align: right;">RC206</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">7</td>
      <td style = "text-align: right;">1070.2</td>
      <td style = "text-align: right;">1073.8</td>
    </tr>
    <tr>
      <td class = "rowNumber">55</td>
      <td style = "text-align: right;">RC207</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">967.7</td>
      <td style = "text-align: right;">970.9</td>
    </tr>
    <tr>
      <td class = "rowNumber">56</td>
      <td style = "text-align: right;">RC208</td>
      <td style = "text-align: right;">100</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">missing</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">778.4</td>
      <td style = "text-align: right;">781.3</td>
    </tr>
  </tbody>
</table>
</body>
</html>




---

## Compatibility Results


Result of Our Algorithm of 25 customers with Compatibility


```julia
pretty_table(print_all_solution(), show_row_number=true, tf=tf_html_matrix)
```


<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
  table {
      position: relative;
  }

  table::before,
  table::after {
      border: 1px solid #000;
      content: "";
      height: 100%;
      position: absolute;
      top: 0;
      width: 6px;
  }

  table::before {
      border-right: 0px;
      left: -6px;
  }

  table::after {
      border-left: 0px;
      right: -6px;
  }

  td {
      padding: 5px;
      text-align: center;
  }

</style>
<body>
<table>
  <thead>
    <tr class = "header">
      <th class = "rowNumber">Row</th>
      <th style = "text-align: right;">Name</th>
      <th style = "text-align: right;">num_vehi</th>
      <th style = "text-align: right;">dis</th>
      <th style = "text-align: right;">file</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th></th>
      <th style = "text-align: right;">String</th>
      <th style = "text-align: right;">Int64</th>
      <th style = "text-align: right;">Float64</th>
      <th style = "text-align: right;">String</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class = "rowNumber">1</td>
      <td style = "text-align: right;">c101-25</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">228.3</td>
      <td style = "text-align: right;">c101-25-5</td>
    </tr>
    <tr>
      <td class = "rowNumber">2</td>
      <td style = "text-align: right;">c102-25</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">267.9</td>
      <td style = "text-align: right;">c102-25-8</td>
    </tr>
    <tr>
      <td class = "rowNumber">3</td>
      <td style = "text-align: right;">c103-25</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">247.6</td>
      <td style = "text-align: right;">c103-25-5</td>
    </tr>
    <tr>
      <td class = "rowNumber">4</td>
      <td style = "text-align: right;">c104-25</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">263.6</td>
      <td style = "text-align: right;">c104-25-17</td>
    </tr>
    <tr>
      <td class = "rowNumber">5</td>
      <td style = "text-align: right;">c105-25</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">243.5</td>
      <td style = "text-align: right;">c105-25-3</td>
    </tr>
    <tr>
      <td class = "rowNumber">6</td>
      <td style = "text-align: right;">c106-25</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">256.7</td>
      <td style = "text-align: right;">c106-25-8</td>
    </tr>
    <tr>
      <td class = "rowNumber">7</td>
      <td style = "text-align: right;">c107-25</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">246.7</td>
      <td style = "text-align: right;">c107-25-6</td>
    </tr>
    <tr>
      <td class = "rowNumber">8</td>
      <td style = "text-align: right;">c108-25</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">237.3</td>
      <td style = "text-align: right;">c108-25-4</td>
    </tr>
    <tr>
      <td class = "rowNumber">9</td>
      <td style = "text-align: right;">c109-25</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">246.5</td>
      <td style = "text-align: right;">c109-25-9</td>
    </tr>
    <tr>
      <td class = "rowNumber">10</td>
      <td style = "text-align: right;">c201-25</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">386.6</td>
      <td style = "text-align: right;">c201-25-1</td>
    </tr>
    <tr>
      <td class = "rowNumber">11</td>
      <td style = "text-align: right;">c202-25</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">244.8</td>
      <td style = "text-align: right;">c202-25-10</td>
    </tr>
    <tr>
      <td class = "rowNumber">12</td>
      <td style = "text-align: right;">c203-25</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">247.1</td>
      <td style = "text-align: right;">c203-25-1</td>
    </tr>
    <tr>
      <td class = "rowNumber">13</td>
      <td style = "text-align: right;">c204-25</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">244.8</td>
      <td style = "text-align: right;">c204-25-2</td>
    </tr>
    <tr>
      <td class = "rowNumber">14</td>
      <td style = "text-align: right;">c205-25</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">267.0</td>
      <td style = "text-align: right;">c205-25-4</td>
    </tr>
    <tr>
      <td class = "rowNumber">15</td>
      <td style = "text-align: right;">c206-25</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">263.0</td>
      <td style = "text-align: right;">c206-25-2</td>
    </tr>
    <tr>
      <td class = "rowNumber">16</td>
      <td style = "text-align: right;">c207-25</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">261.2</td>
      <td style = "text-align: right;">c207-25-1</td>
    </tr>
    <tr>
      <td class = "rowNumber">17</td>
      <td style = "text-align: right;">c208-25</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">251.8</td>
      <td style = "text-align: right;">c208-25-1</td>
    </tr>
    <tr>
      <td class = "rowNumber">18</td>
      <td style = "text-align: right;">r101-25</td>
      <td style = "text-align: right;">9</td>
      <td style = "text-align: right;">643.7</td>
      <td style = "text-align: right;">r101-25-4</td>
    </tr>
    <tr>
      <td class = "rowNumber">19</td>
      <td style = "text-align: right;">r102-25</td>
      <td style = "text-align: right;">7</td>
      <td style = "text-align: right;">585.7</td>
      <td style = "text-align: right;">r102-25-5</td>
    </tr>
    <tr>
      <td class = "rowNumber">20</td>
      <td style = "text-align: right;">r103-25</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">474.0</td>
      <td style = "text-align: right;">r103-25-1</td>
    </tr>
    <tr>
      <td class = "rowNumber">21</td>
      <td style = "text-align: right;">r104-25</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">416.9</td>
      <td style = "text-align: right;">r104-25-9</td>
    </tr>
    <tr>
      <td class = "rowNumber">22</td>
      <td style = "text-align: right;">r105-25</td>
      <td style = "text-align: right;">6</td>
      <td style = "text-align: right;">582.2</td>
      <td style = "text-align: right;">r105-25-2</td>
    </tr>
    <tr>
      <td class = "rowNumber">23</td>
      <td style = "text-align: right;">r106-25</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">475.2</td>
      <td style = "text-align: right;">r106-25-5</td>
    </tr>
    <tr>
      <td class = "rowNumber">24</td>
      <td style = "text-align: right;">r107-25</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">440.3</td>
      <td style = "text-align: right;">r107-25-7</td>
    </tr>
    <tr>
      <td class = "rowNumber">25</td>
      <td style = "text-align: right;">r108-25</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">408.3</td>
      <td style = "text-align: right;">r108-25-3</td>
    </tr>
    <tr>
      <td class = "rowNumber">26</td>
      <td style = "text-align: right;">r109-25</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">481.0</td>
      <td style = "text-align: right;">r109-25-9</td>
    </tr>
    <tr>
      <td class = "rowNumber">27</td>
      <td style = "text-align: right;">r110-25</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">457.1</td>
      <td style = "text-align: right;">r110-25-1</td>
    </tr>
    <tr>
      <td class = "rowNumber">28</td>
      <td style = "text-align: right;">r111-25</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">477.1</td>
      <td style = "text-align: right;">r111-25-1</td>
    </tr>
    <tr>
      <td class = "rowNumber">29</td>
      <td style = "text-align: right;">r112-25</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">415.2</td>
      <td style = "text-align: right;">r112-25-8</td>
    </tr>
    <tr>
      <td class = "rowNumber">30</td>
      <td style = "text-align: right;">r201-25</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">503.9</td>
      <td style = "text-align: right;">r201-25-3</td>
    </tr>
    <tr>
      <td class = "rowNumber">31</td>
      <td style = "text-align: right;">r202-25</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">457.5</td>
      <td style = "text-align: right;">r202-25-7</td>
    </tr>
    <tr>
      <td class = "rowNumber">32</td>
      <td style = "text-align: right;">r203-25</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">444.5</td>
      <td style = "text-align: right;">r203-25-34</td>
    </tr>
    <tr>
      <td class = "rowNumber">33</td>
      <td style = "text-align: right;">r204-25</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">393.9</td>
      <td style = "text-align: right;">r204-25-10</td>
    </tr>
    <tr>
      <td class = "rowNumber">34</td>
      <td style = "text-align: right;">r205-25</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">418.8</td>
      <td style = "text-align: right;">r205-25-14</td>
    </tr>
    <tr>
      <td class = "rowNumber">35</td>
      <td style = "text-align: right;">r206-25</td>
      <td style = "text-align: right;">1</td>
      <td style = "text-align: right;">416.7</td>
      <td style = "text-align: right;">r206-25-36</td>
    </tr>
    <tr>
      <td class = "rowNumber">36</td>
      <td style = "text-align: right;">r207-25</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">402.0</td>
      <td style = "text-align: right;">r207-25-11</td>
    </tr>
    <tr>
      <td class = "rowNumber">37</td>
      <td style = "text-align: right;">r208-25</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">385.5</td>
      <td style = "text-align: right;">r208-25-6</td>
    </tr>
    <tr>
      <td class = "rowNumber">38</td>
      <td style = "text-align: right;">r209-25</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">409.8</td>
      <td style = "text-align: right;">r209-25-4</td>
    </tr>
    <tr>
      <td class = "rowNumber">39</td>
      <td style = "text-align: right;">r210-25</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">452.6</td>
      <td style = "text-align: right;">r210-25-7</td>
    </tr>
    <tr>
      <td class = "rowNumber">40</td>
      <td style = "text-align: right;">r211-25</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">407.7</td>
      <td style = "text-align: right;">r211-25-6</td>
    </tr>
    <tr>
      <td class = "rowNumber">41</td>
      <td style = "text-align: right;">rc101-25</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">488.2</td>
      <td style = "text-align: right;">rc101-25-18</td>
    </tr>
    <tr>
      <td class = "rowNumber">42</td>
      <td style = "text-align: right;">rc102-25</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">420.7</td>
      <td style = "text-align: right;">rc102-25-8</td>
    </tr>
    <tr>
      <td class = "rowNumber">43</td>
      <td style = "text-align: right;">rc103-25</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">386.4</td>
      <td style = "text-align: right;">rc103-25-7</td>
    </tr>
    <tr>
      <td class = "rowNumber">44</td>
      <td style = "text-align: right;">rc104-25</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">372.6</td>
      <td style = "text-align: right;">rc104-25-9</td>
    </tr>
    <tr>
      <td class = "rowNumber">45</td>
      <td style = "text-align: right;">rc105-25</td>
      <td style = "text-align: right;">5</td>
      <td style = "text-align: right;">481.4</td>
      <td style = "text-align: right;">rc105-25-3</td>
    </tr>
    <tr>
      <td class = "rowNumber">46</td>
      <td style = "text-align: right;">rc106-25</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">406.3</td>
      <td style = "text-align: right;">rc106-25-7</td>
    </tr>
    <tr>
      <td class = "rowNumber">47</td>
      <td style = "text-align: right;">rc107-25</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">368.3</td>
      <td style = "text-align: right;">rc107-25-2</td>
    </tr>
    <tr>
      <td class = "rowNumber">48</td>
      <td style = "text-align: right;">rc108-25</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">367.8</td>
      <td style = "text-align: right;">rc108-25-4</td>
    </tr>
    <tr>
      <td class = "rowNumber">49</td>
      <td style = "text-align: right;">rc201-25</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">574.5</td>
      <td style = "text-align: right;">rc201-25-23</td>
    </tr>
    <tr>
      <td class = "rowNumber">50</td>
      <td style = "text-align: right;">rc202-25</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">437.0</td>
      <td style = "text-align: right;">rc202-25-44</td>
    </tr>
    <tr>
      <td class = "rowNumber">51</td>
      <td style = "text-align: right;">rc203-25</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">362.9</td>
      <td style = "text-align: right;">rc203-25-7</td>
    </tr>
    <tr>
      <td class = "rowNumber">52</td>
      <td style = "text-align: right;">rc204-25</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">395.6</td>
      <td style = "text-align: right;">rc204-25-23</td>
    </tr>
    <tr>
      <td class = "rowNumber">53</td>
      <td style = "text-align: right;">rc205-25</td>
      <td style = "text-align: right;">3</td>
      <td style = "text-align: right;">547.8</td>
      <td style = "text-align: right;">rc205-25-23</td>
    </tr>
    <tr>
      <td class = "rowNumber">54</td>
      <td style = "text-align: right;">rc206-25</td>
      <td style = "text-align: right;">2</td>
      <td style = "text-align: right;">444.1</td>
      <td style = "text-align: right;">rc206-25-18</td>
    </tr>
    <tr>
      <td class = "rowNumber">55</td>
      <td style = "text-align: right;">rc207-25</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">748.2</td>
      <td style = "text-align: right;">rc207-25-100</td>
    </tr>
    <tr>
      <td class = "rowNumber">56</td>
      <td style = "text-align: right;">rc208-25</td>
      <td style = "text-align: right;">4</td>
      <td style = "text-align: right;">613.3</td>
      <td style = "text-align: right;">rc208-25-39</td>
    </tr>
  </tbody>
</table>
</body>
</html>

