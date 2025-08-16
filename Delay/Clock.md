# Clock

## One Sec

<img src="IMG/one_tick.png" width=600 height=250>

## Parellel Style (clock_arch1)

> **one_sec_tick**으로 freq를 조정하여 1초 Tick을 생성하고, 이를 sec_tick, min_tick, hour_tick에 병렬적으로 반영하는 방식으로, 구조가 간단하지만 조합논리 Depth가 깊어서 Fmax의 제약이 있음.

<img src="IMG/arch1.png" width=500 height=300>

## Cascade Style

> sec_tick을 min_module에, min_tick을 hour_module에 전이

<img src="IMG/arch2.png" width=500 height=300>

```verilog
always@(posedge clk or negedge rstn) begin
  if(~rstn) cnt <= 0;
  else if (i_tick) begin
    cnt <= 0;
    o_tick <= 1;
  end else begin
    cnt <= cnt + 1;
  end
end
```

### Cascade Delay

<table>
<tr>
<th>delay_propagate</th>
<td><img src="IMG/delay_propagate.png"></td>
</tr>
<tr>
<th>timing_arrange</th>
<td><img src="IMG/delay_arrange.png"></td>
</tr>
</table>

- **o_sec_tick**을 병렬적으로 인가했던 이전 아키텍처와 달리 i_tick를 읽은 다음 Cycle에 o_tick을 내놓는 Cascade 아키텍처 특성 상, **매 Cascade마다 1-cycle의 딜레이가 발생한다.**
- 타이밍 정렬을 위해
  - **sec 모듈**의 출력을 2-cycle 지연시킨다.
  - **min 모듈**의 출력을 1-cycle 지연시킨다.
  - **hour 모듈**의 출력을 0-cycle 지연시킨다.
